import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketSla } from '../src/modules/maintenance-ticket/entities/ticket-sla.entity';
import { SlaConfiguration } from '../src/modules/maintenance-ticket/entities/sla-configuration.entity';
import { TicketStatus } from '../src/modules/maintenance-ticket/enums/ticket-status.enum';
import { Company } from '../src/modules/tenant/entities/company.entity';
import { EscalationService } from '../src/modules/maintenance-ticket/services/escalation.service';

async function checkEscalationTickets() {
  console.log('🔍 Checking for tickets that need escalation...\n');

  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    const ticketRepo = app.get<Repository<MaintenanceTicket>>(
      getRepositoryToken(MaintenanceTicket),
    );
    const ticketSlaRepo = app.get<Repository<TicketSla>>(
      getRepositoryToken(TicketSla),
    );
    const companyRepo = app.get<Repository<Company>>(
      getRepositoryToken(Company),
    );
    const escalationService = app.get(EscalationService);

    // Get all companies
    const companies = await companyRepo.find();
    if (companies.length === 0) {
      console.log('❌ No companies found in database.\n');
      await app.close();
      process.exit(0);
    }

    console.log(`📋 Found ${companies.length} company(ies)\n`);

    let totalTicketsToEscalate = 0;
    let totalActiveTickets = 0;

    for (const company of companies) {
      console.log(`\n${'='.repeat(80)}`);
      console.log(`🏢 Company: ${company.name} (${company.id})`);
      console.log(`${'='.repeat(80)}\n`);

      // Find all active tickets with SLA
      const activeTicketsWithSla = await ticketSlaRepo
        .createQueryBuilder('sla')
        .leftJoinAndSelect('sla.ticket', 'ticket')
        .leftJoinAndSelect('sla.slaConfiguration', 'config')
        .where('sla.companyId = :companyId', { companyId: company.id })
        .andWhere('ticket.status NOT IN (:...resolvedStatuses)', {
          resolvedStatuses: [TicketStatus.COMPLETED, TicketStatus.CANCELLED],
        })
        .getMany();

      totalActiveTickets += activeTicketsWithSla.length;

      if (activeTicketsWithSla.length === 0) {
        console.log('  ℹ️  No active tickets with SLA found.\n');
        continue;
      }

      console.log(`  📊 Found ${activeTicketsWithSla.length} active ticket(s) with SLA\n`);

      const now = new Date();
      const ticketsNeedingEscalation: Array<{
        ticket: MaintenanceTicket;
        sla: TicketSla;
        reason: string;
        elapsedMinutes: number;
        thresholdMinutes?: number;
      }> = [];

      // Check each ticket
      for (const ticketSla of activeTicketsWithSla) {
        const ticket = ticketSla.ticket;
        const config = ticketSla.slaConfiguration;

        if (!config) {
          continue;
        }

        // Calculate elapsed time
        const baseTime = ticket.assignedAt || ticket.createdAt;
        const elapsedMinutes =
          (now.getTime() - baseTime.getTime()) / (1000 * 60) -
          (ticketSla.totalPausedMinutes || 0);

        const currentLevel = ticketSla.currentEscalationLevel || 0;

        // Check acknowledgment deadline
        const isAssigned = !!ticket.assignedTechnicianId || !!ticket.assignedSupervisorId;
        const isAcknowledged = !!(ticket.acknowledgedAt || ticketSla.acknowledgedAt);

        if (isAssigned && !isAcknowledged && config.acknowledgementTimeMinutes) {
          if (elapsedMinutes >= config.acknowledgementTimeMinutes) {
            ticketsNeedingEscalation.push({
              ticket,
              sla: ticketSla,
              reason: `Not acknowledged after ${Math.round(elapsedMinutes)} minutes (deadline: ${config.acknowledgementTimeMinutes} minutes)`,
              elapsedMinutes,
              thresholdMinutes: config.acknowledgementTimeMinutes,
            });
            continue;
          }
        }

        // Check escalation levels
        let needsEscalation = false;
        let reason = '';
        let thresholdMinutes: number | undefined;

        // Level 3: ADMIN
        if (
          config.escalationLevel3Minutes &&
          elapsedMinutes >= config.escalationLevel3Minutes &&
          currentLevel < 3
        ) {
          needsEscalation = true;
          reason = `Level 3 escalation (ADMIN) - ${Math.round(elapsedMinutes)} minutes elapsed`;
          thresholdMinutes = config.escalationLevel3Minutes;
        }
        // Level 2: SITE_COORDINATOR
        else if (
          config.escalationLevel2Minutes &&
          elapsedMinutes >= config.escalationLevel2Minutes &&
          currentLevel < 2
        ) {
          needsEscalation = true;
          reason = `Level 2 escalation (SITE_COORDINATOR) - ${Math.round(elapsedMinutes)} minutes elapsed`;
          thresholdMinutes = config.escalationLevel2Minutes;
        }
        // Level 1: SUPERVISOR
        else if (
          config.escalationLevel1Minutes &&
          elapsedMinutes >= config.escalationLevel1Minutes &&
          currentLevel < 1
        ) {
          needsEscalation = true;
          reason = `Level 1 escalation (SUPERVISOR) - ${Math.round(elapsedMinutes)} minutes elapsed`;
          thresholdMinutes = config.escalationLevel1Minutes;
        }

        if (needsEscalation) {
          ticketsNeedingEscalation.push({
            ticket,
            sla: ticketSla,
            reason,
            elapsedMinutes,
            thresholdMinutes,
          });
        }
      }

      if (ticketsNeedingEscalation.length === 0) {
        console.log('  ✅ No tickets need escalation at this time.\n');
      } else {
        totalTicketsToEscalate += ticketsNeedingEscalation.length;
        console.log(
          `  ⚠️  Found ${ticketsNeedingEscalation.length} ticket(s) that need escalation:\n`,
        );

        for (const item of ticketsNeedingEscalation) {
          const { ticket, sla, reason, elapsedMinutes, thresholdMinutes } = item;
          console.log(`  📌 Ticket: ${ticket.ticketNumber}`);
          console.log(`     Title: ${ticket.title}`);
          console.log(`     Priority: ${ticket.priority}`);
          console.log(`     Status: ${ticket.status}`);
          console.log(`     Current Escalation Level: ${sla.currentEscalationLevel || 0}`);
          console.log(`     Elapsed Time: ${Math.round(elapsedMinutes)} minutes`);
          if (thresholdMinutes) {
            console.log(`     Threshold: ${thresholdMinutes} minutes`);
            console.log(`     Overdue by: ${Math.round(elapsedMinutes - thresholdMinutes)} minutes`);
          }
          console.log(`     Reason: ${reason}`);
          if (ticket.assignedTechnicianId) {
            console.log(`     Assigned Technician: ${ticket.assignedTechnicianId}`);
          }
          if (ticket.assignedSupervisorId) {
            console.log(`     Assigned Supervisor: ${ticket.assignedSupervisorId}`);
          }
          console.log(`     Created: ${ticket.createdAt.toISOString()}`);
          if (ticket.assignedAt) {
            console.log(`     Assigned: ${ticket.assignedAt.toISOString()}`);
          }
          console.log('');
        }
      }
    }

    console.log(`\n${'='.repeat(80)}`);
    console.log('📊 SUMMARY');
    console.log(`${'='.repeat(80)}`);
    console.log(`Total Companies: ${companies.length}`);
    console.log(`Total Active Tickets: ${totalActiveTickets}`);
    console.log(`Tickets Needing Escalation: ${totalTicketsToEscalate}`);

    if (totalTicketsToEscalate > 0) {
      console.log(
        `\n💡 To trigger escalation, the escalation scheduler will automatically process these tickets.`,
      );
      console.log(
        `   Or you can manually trigger escalation by calling the escalation service.`,
      );
    }

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking escalation tickets:', error);
    if (error instanceof Error) {
      console.error('Stack:', error.stack);
    }
    process.exit(1);
  }
}

checkEscalationTickets();
