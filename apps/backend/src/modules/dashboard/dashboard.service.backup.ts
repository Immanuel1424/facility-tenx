import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { User, UserStatus } from '../iam/entities/user.entity';
import { DashboardStatsDto } from './dto/dashboard-stats.dto';
import {
  DashboardAnalyticsDto,
  StatusDistributionDto,
  PriorityDistributionDto,
  DepartmentDistributionDto,
  VillaDistributionDto,
  TechnicianPerformanceDto,
  TrendDataPointDto,
  PerformanceMetricsDto,
  PredictionDto,
} from './dto/dashboard-analytics.dto';
import { MaintenanceTicket } from '../maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketStatus } from '../maintenance-ticket/enums/ticket-status.enum';
import { TicketPriority } from '../maintenance-ticket/enums/ticket-priority.enum';
import { Department } from '../maintenance-ticket/entities/department.entity';

@Injectable()
export class DashboardService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(MaintenanceTicket)
    private readonly ticketRepo: Repository<MaintenanceTicket>,
    @InjectRepository(Department)
    private readonly departmentRepo: Repository<Department>,
  ) {}

  async getStats(companyId: string, role?: string, userId?: string): Promise<DashboardStatsDto> {
    if (!companyId) {
      throw new Error('Company ID is required');
    }

    try {
      // Get all tickets for the company
      // For TENANT role, scope by villa_number (through the user's villaNumber)
      // For TECHNICIAN roles, scope by assignedTechnicianId
      const whereClause: {
        companyId: string;
        createdBy?: string;
        villaNumber?: string;
        assignedTechnicianId?: string;
      } = { companyId };

      if (role === 'TENANT' && userId) {
        const user = await this.userRepo.findOne({
          where: { companyId, id: userId },
        });

        if (user?.villaNumber != null) {
          // Scope tenant stats to their villa_number
          whereClause.villaNumber = user.villaNumber;
        } else {
          // Fallback: scope by createdBy if villaNumber is not set
          whereClause.createdBy = userId;
        }
      } else if (
        role === 'TECHNICIAN' &&
        userId
      ) {
        // For technicians, scope stats to tickets assigned to them
        whereClause.assignedTechnicianId = userId;
      }

      const allTickets = await this.ticketRepo.find({
        where: whereClause,
        select: [
          'id',
          'status',
          'assignedTechnicianId',
          'isEscalated',
          'autoCloseAt',
          'updatedAt',
          'createdAt',
        ],
      });

      // Calculate ticket statistics based on status
      // For both admin and tenant dashboards, "Open Requests" should match the
      // "NEW" status filter used by the frontend when navigating from the card.
      const openRequests = allTickets.filter(
        (t) => t.status === TicketStatus.NEW,
      ).length;

      const inProgress = allTickets.filter((t) => t.status === TicketStatus.IN_PROGRESS).length;

      const acknowledged = allTickets.filter((t) => t.status === TicketStatus.ACKNOWLEDGED).length;

      const resolved = allTickets.filter((t) =>
        TicketStatus.COMPLETED === t.status,
      ).length;

      const totalRequests = allTickets.length;

      // Count tickets completed today
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      const completedToday = allTickets.filter((t) => {
        if (t.status !== TicketStatus.COMPLETED) {
          return false;
        }
        if (!t.updatedAt) {
          return false;
        }
        const updatedDate = t.updatedAt instanceof Date ? t.updatedAt : new Date(t.updatedAt);
        return updatedDate >= today;
      }).length;

      // Count assigned tickets
      // For technicians: count tickets assigned to them (regardless of status)
      // For other roles: count tickets with status ASSIGNED
      const assigned =
        role === 'TECHNICIAN'
          ? allTickets.filter((t) => t.assignedTechnicianId === userId).length
          : allTickets.filter((t) => t.status === TicketStatus.ASSIGNED).length;

      // Count completed tickets (same as resolved)
      const completed = resolved;

      // Count pending tickets (NEW + ON_HOLD status)
      // Pending represents tickets awaiting action (new tickets or tickets on hold)
      const pending = allTickets.filter((t) =>
        [TicketStatus.NEW, TicketStatus.ON_HOLD].includes(t.status),
      ).length;

      // Count escalated tickets
      const escalated = allTickets.filter((t) => t.isEscalated === true).length;

      // Count overdue tickets (auto_close_at in past and not closed)
      const now = new Date();
      const overdue = allTickets.filter((t) => {
        if (!t.autoCloseAt) {
          return false;
        }
        if ([TicketStatus.COMPLETED, TicketStatus.CANCELLED].includes(t.status)) {
          return false;
        }
        const autoCloseDate = t.autoCloseAt instanceof Date ? t.autoCloseAt : new Date(t.autoCloseAt);
        return autoCloseDate < now;
      }).length;

      // For non-tenant users, get additional stats
      let activeUsers = 0;
      if (role !== 'TENANT') {
        activeUsers = await this.userRepo.count({
          where: {
            companyId,
            status: UserStatus.ACTIVE,
          },
        });
      }

      // For now, pendingApproval is set to 0 as there's no approval workflow yet
      const pendingApproval = 0;

      return {
        openRequests,
        inProgress,
        resolved,
        totalRequests,
        activeUsers,
        pendingApproval,
        completedToday,
        assigned,
        completed,
        pending,
        acknowledged,
        onHold: 0,
        escalated,
        overdue,
      };
    } catch (error) {
      throw new Error(`Failed to get dashboard stats: ${error instanceof Error ? error.message : String(error)}`);
    }
  }

  async getAnalytics(
    companyId: string,
    role?: string,
    userId?: string,
    period: 'daily' | 'weekly' | 'monthly' = 'weekly',
  ): Promise<DashboardAnalyticsDto> {
    if (!companyId) {
      throw new Error('Company ID is required');
    }

    try {
      // Build where clause similar to getStats
      const whereClause: {
        companyId: string;
        createdBy?: string;
        villaNumber?: string;
        assignedTechnicianId?: string;
      } = { companyId };

      if (role === 'TENANT' && userId) {
        const user = await this.userRepo.findOne({
          where: { companyId, id: userId },
        });

        if (user?.villaNumber != null) {
          whereClause.villaNumber = user.villaNumber;
        } else {
          whereClause.createdBy = userId;
        }
      } else if (
        role === 'TECHNICIAN' &&
        userId
      ) {
        whereClause.assignedTechnicianId = userId;
      }

      // Get all tickets with necessary fields
      const allTickets = await this.ticketRepo.find({
        where: whereClause,
        relations: ['department', 'villa'],
        select: [
          'id',
          'status',
          'priority',
          'departmentId',
          'villaNumber',
          'villaId',
          'assignedTechnicianId',
          'createdAt',
          'acknowledgedAt',
          'completedAt',
          'closedAt',
          'updatedAt',
        ],
      });

      const totalTickets = allTickets.length;

      // Status Distribution
      const statusDistribution: StatusDistributionDto[] = Object.values(
        TicketStatus,
      ).map((status) => {
        const count = allTickets.filter((t) => t.status === status).length;
        return {
          status,
          count,
          percentage: totalTickets > 0 ? (count / totalTickets) * 100 : 0,
        };
      });

      // Priority Distribution
      const priorityDistribution: PriorityDistributionDto[] = Object.values(
        TicketPriority,
      ).map((priority) => {
        const count = allTickets.filter((t) => t.priority === priority).length;
        return {
          priority,
          count,
          percentage: totalTickets > 0 ? (count / totalTickets) * 100 : 0,
        };
      });

      // Department Distribution
      const departmentMap = new Map<string, number>();
      allTickets.forEach((ticket) => {
        const deptName = ticket.department?.name || 'Unassigned';
        departmentMap.set(deptName, (departmentMap.get(deptName) || 0) + 1);
      });

      const departmentDistribution: DepartmentDistributionDto[] = Array.from(
        departmentMap.entries(),
      ).map(([departmentName, count]) => ({
        departmentName,
        count,
        percentage: totalTickets > 0 ? (count / totalTickets) * 100 : 0,
      }));

      // Villa Distribution
      const villaDistribution = this.calculateVillaDistribution(allTickets, totalTickets);

      // Technician Performance
      const technicianPerformance = await this.calculateTechnicianPerformance(
        allTickets,
        companyId,
      );

      // Trend Data
      const trends = this.calculateTrends(allTickets, period);

      // Performance Metrics
      const performance = this.calculatePerformanceMetrics(allTickets);

      // Predictions
      const predictions = this.calculatePredictions(allTickets, trends);

      return {
        statusDistribution,
        priorityDistribution,
        departmentDistribution,
        villaDistribution,
        technicianPerformance,
        trends,
        performance,
        predictions,
      };
    } catch (error) {
      throw new Error(
        `Failed to get dashboard analytics: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  private calculateTrends(
    tickets: MaintenanceTicket[],
    period: 'daily' | 'weekly' | 'monthly',
  ): TrendDataPointDto[] {
    const now = new Date();
    const daysBack = period === 'daily' ? 7 : period === 'weekly' ? 30 : 90;
    const startDate = new Date(now);
    startDate.setDate(startDate.getDate() - daysBack);

    const trends: TrendDataPointDto[] = [];
    const dateMap = new Map<string, { created: number; resolved: number; inProgress: number }>();

    // Initialize date map
    for (let i = 0; i < daysBack; i++) {
      const date = new Date(startDate);
      date.setDate(date.getDate() + i);
      const dateKey = date.toISOString().split('T')[0];
      dateMap.set(dateKey, { created: 0, resolved: 0, inProgress: 0 });
    }

    // Process tickets
    tickets.forEach((ticket) => {
      // Handle created date
      if (ticket.createdAt) {
        try {
          const createdDate = ticket.createdAt instanceof Date
            ? ticket.createdAt
            : new Date(ticket.createdAt);
          
          if (!isNaN(createdDate.getTime())) {
            const createdKey = createdDate.toISOString().split('T')[0];
            if (dateMap.has(createdKey)) {
              const data = dateMap.get(createdKey)!;
              data.created++;
            }
          }
        } catch (error) {
          // Skip invalid dates
        }
      }

      // Check resolved date
      const resolvedDate = ticket.completedAt || ticket.closedAt;
      if (resolvedDate) {
        try {
          const resolved = resolvedDate instanceof Date
            ? resolvedDate
            : new Date(resolvedDate);
          
          if (!isNaN(resolved.getTime())) {
            const resolvedKey = resolved.toISOString().split('T')[0];
            if (dateMap.has(resolvedKey)) {
              const data = dateMap.get(resolvedKey)!;
              data.resolved++;
            }
          }
        } catch (error) {
          // Skip invalid dates
        }
      }

      // Check in progress
      if (ticket.status === TicketStatus.IN_PROGRESS && ticket.updatedAt) {
        try {
          const updatedDate = ticket.updatedAt instanceof Date
            ? ticket.updatedAt
            : new Date(ticket.updatedAt);
          
          if (!isNaN(updatedDate.getTime())) {
            const updatedKey = updatedDate.toISOString().split('T')[0];
            if (dateMap.has(updatedKey)) {
              const data = dateMap.get(updatedKey)!;
              data.inProgress++;
            }
          }
        } catch (error) {
          // Skip invalid dates
        }
      }
    });

    // Convert to array
    Array.from(dateMap.entries())
      .sort(([a], [b]) => a.localeCompare(b))
      .forEach(([date, data]) => {
        trends.push({
          date,
          created: data.created,
          resolved: data.resolved,
          inProgress: data.inProgress,
        });
      });

    return trends;
  }

  private calculatePerformanceMetrics(
    tickets: MaintenanceTicket[],
  ): PerformanceMetricsDto {
    const resolvedTickets = tickets.filter((t) =>
      t.status === TicketStatus.COMPLETED,
    );

    let totalResolutionTime = 0;
    let totalFirstResponseTime = 0;
    let resolvedCount = 0;
    let respondedCount = 0;

    resolvedTickets.forEach((ticket) => {
      if (!ticket.createdAt) {
        return;
      }

      try {
        const created = ticket.createdAt instanceof Date
          ? ticket.createdAt
          : new Date(ticket.createdAt);
        
        if (isNaN(created.getTime())) {
          return;
        }

        const resolved = ticket.completedAt || ticket.closedAt;

        if (resolved) {
          try {
            const resolvedDate = resolved instanceof Date ? resolved : new Date(resolved);
            if (!isNaN(resolvedDate.getTime())) {
              const hours = (resolvedDate.getTime() - created.getTime()) / (1000 * 60 * 60);
              if (hours >= 0) {
                totalResolutionTime += hours;
                resolvedCount++;
              }
            }
          } catch (error) {
            // Skip invalid resolved date
          }
        }

        if (ticket.acknowledgedAt) {
          try {
            const acknowledged = ticket.acknowledgedAt instanceof Date
              ? ticket.acknowledgedAt
              : new Date(ticket.acknowledgedAt);
            
            if (!isNaN(acknowledged.getTime())) {
              const hours = (acknowledged.getTime() - created.getTime()) / (1000 * 60 * 60);
              if (hours >= 0) {
                totalFirstResponseTime += hours;
                respondedCount++;
              }
            }
          } catch (error) {
            // Skip invalid acknowledged date
          }
        }
      } catch (error) {
        // Skip tickets with invalid dates
      }
    });

    // Calculate SLA compliance (tickets resolved within 48 hours)
    const slaThreshold = 48; // hours
    const slaCompliant = resolvedTickets.filter((ticket) => {
      if (!ticket.createdAt) return false;
      
      try {
        const created = ticket.createdAt instanceof Date
          ? ticket.createdAt
          : new Date(ticket.createdAt);
        
        if (isNaN(created.getTime())) return false;

        const resolved = ticket.completedAt || ticket.closedAt;
        if (!resolved) return false;
        
        const resolvedDate = resolved instanceof Date ? resolved : new Date(resolved);
        if (isNaN(resolvedDate.getTime())) return false;
        
        const hours = (resolvedDate.getTime() - created.getTime()) / (1000 * 60 * 60);
        return hours >= 0 && hours <= slaThreshold;
      } catch (error) {
        return false;
      }
    }).length;

    return {
      averageResolutionTime:
        resolvedCount > 0 ? totalResolutionTime / resolvedCount : 0,
      averageFirstResponseTime:
        respondedCount > 0 ? totalFirstResponseTime / respondedCount : 0,
      slaCompliance:
        resolvedTickets.length > 0
          ? (slaCompliant / resolvedTickets.length) * 100
          : 0,
      ticketsResolved: resolvedTickets.length,
    };
  }

  private calculatePredictions(
    tickets: MaintenanceTicket[],
    trends: TrendDataPointDto[],
  ): PredictionDto {
    if (trends.length < 2) {
      return {
        predictedVolume: 0,
        confidence: 0,
        trend: 'stable',
        expectedResolutionTime: 0,
      };
    }

    // Simple linear regression for volume prediction
    const recentTrends = trends.slice(-7); // Last 7 days
    const avgCreated = recentTrends.reduce((sum, t) => sum + t.created, 0) / recentTrends.length;
    const avgResolved = recentTrends.reduce((sum, t) => sum + t.resolved, 0) / recentTrends.length;

    // Calculate trend direction
    const firstHalf = recentTrends.slice(0, Math.floor(recentTrends.length / 2));
    const secondHalf = recentTrends.slice(Math.floor(recentTrends.length / 2));
    const firstAvg = firstHalf.reduce((sum, t) => sum + t.created, 0) / firstHalf.length;
    const secondAvg = secondHalf.reduce((sum, t) => sum + t.created, 0) / secondHalf.length;

    let trend: 'increasing' | 'decreasing' | 'stable' = 'stable';
    if (secondAvg > firstAvg * 1.1) {
      trend = 'increasing';
    } else if (secondAvg < firstAvg * 0.9) {
      trend = 'decreasing';
    }

    // Predict next period volume (simple average with trend adjustment)
    const trendFactor = trend === 'increasing' ? 1.1 : trend === 'decreasing' ? 0.9 : 1.0;
    const predictedVolume = Math.round(avgCreated * trendFactor * 7); // 7 days ahead

    // Calculate expected resolution time from historical data
    const resolvedTickets = tickets.filter((t) =>
      t.status === TicketStatus.COMPLETED,
    );
    let totalTime = 0;
    let count = 0;
    resolvedTickets.forEach((ticket) => {
      if (!ticket.createdAt) return;
      
      try {
        const created = ticket.createdAt instanceof Date
          ? ticket.createdAt
          : new Date(ticket.createdAt);
        
        if (isNaN(created.getTime())) return;

        const resolved = ticket.completedAt || ticket.closedAt;
        if (resolved) {
          try {
            const resolvedDate = resolved instanceof Date ? resolved : new Date(resolved);
            if (!isNaN(resolvedDate.getTime())) {
              const hours = (resolvedDate.getTime() - created.getTime()) / (1000 * 60 * 60);
              if (hours >= 0) {
                totalTime += hours;
                count++;
              }
            }
          } catch (error) {
            // Skip invalid resolved date
          }
        }
      } catch (error) {
        // Skip tickets with invalid dates
      }
    });

    return {
      predictedVolume,
      confidence: recentTrends.length >= 7 ? 75 : recentTrends.length >= 3 ? 50 : 25,
      trend,
      expectedResolutionTime: count > 0 ? totalTime / count : 0,
    };
  }

  private calculateVillaDistribution(
    tickets: MaintenanceTicket[],
    totalTickets: number,
  ): VillaDistributionDto[] {
    const villaMap = new Map<string, number>();
    
    tickets.forEach((ticket) => {
      // Use villa relationship if available, otherwise fallback to deprecated villaNumber
      const villaNumber = ticket.villa?.villaNumber ?? 
        (ticket.villaNumber != null ? String(ticket.villaNumber) : null);
      
      if (villaNumber != null) {
        villaMap.set(
          villaNumber,
          (villaMap.get(villaNumber) || 0) + 1,
        );
      }
    });

    return Array.from(villaMap.entries())
      .map(([villaNumber, count]) => ({
        villaNumber,
        count,
        percentage: totalTickets > 0 ? (count / totalTickets) * 100 : 0,
      }))
      .sort((a, b) => b.count - a.count) // Sort by count descending
      .slice(0, 20); // Top 20 villas
  }

  private async calculateTechnicianPerformance(
    tickets: MaintenanceTicket[],
    companyId: string,
  ): Promise<TechnicianPerformanceDto[]> {
    const technicianMap = new Map<
      string,
      {
        tickets: MaintenanceTicket[];
        completed: MaintenanceTicket[];
      }
    >();

    // Group tickets by technician
    tickets.forEach((ticket) => {
      if (ticket.assignedTechnicianId) {
        if (!technicianMap.has(ticket.assignedTechnicianId)) {
          technicianMap.set(ticket.assignedTechnicianId, {
            tickets: [],
            completed: [],
          });
        }
        const techData = technicianMap.get(ticket.assignedTechnicianId)!;
        techData.tickets.push(ticket);
        if (ticket.status === TicketStatus.COMPLETED) {
          techData.completed.push(ticket);
        }
      }
    });

    // Get technician names
    const technicianIds = Array.from(technicianMap.keys());
    if (technicianIds.length === 0) {
      return [];
    }

    const technicians = await this.userRepo.find({
      where: {
        companyId,
        id: In(technicianIds),
      },
      select: ['id', 'firstName', 'lastName'],
    });

    const technicianNameMap = new Map<string, string>();
    technicians.forEach((tech) => {
      technicianNameMap.set(
        tech.id,
        `${tech.firstName || ''} ${tech.lastName || ''}`.trim() || 'Unknown',
      );
    });

    // Calculate performance metrics
    return Array.from(technicianMap.entries())
      .map(([technicianId, data]) => {
        let totalResolutionTime = 0;
        let resolvedCount = 0;

        data.completed.forEach((ticket) => {
          if (ticket.createdAt && (ticket.completedAt || ticket.closedAt)) {
            try {
              const created =
                ticket.createdAt instanceof Date
                  ? ticket.createdAt
                  : new Date(ticket.createdAt);
              const resolved = ticket.completedAt || ticket.closedAt;
              if (resolved) {
                const resolvedDate =
                  resolved instanceof Date ? resolved : new Date(resolved);
                if (
                  !isNaN(created.getTime()) &&
                  !isNaN(resolvedDate.getTime())
                ) {
                  const hours =
                    (resolvedDate.getTime() - created.getTime()) /
                    (1000 * 60 * 60);
                  if (hours >= 0) {
                    totalResolutionTime += hours;
                    resolvedCount++;
                  }
                }
              }
            } catch (error) {
              // Skip invalid dates
            }
          }
        });

        return {
          technicianId,
          technicianName:
            technicianNameMap.get(technicianId) || 'Unknown Technician',
          totalTickets: data.tickets.length,
          completedTickets: data.completed.length,
          averageResolutionTime:
            resolvedCount > 0 ? totalResolutionTime / resolvedCount : 0,
          completionRate:
            data.tickets.length > 0
              ? (data.completed.length / data.tickets.length) * 100
              : 0,
        };
      })
      .sort((a, b) => b.totalTickets - a.totalTickets)
      .slice(0, 10); // Top 10 technicians
  }
}
