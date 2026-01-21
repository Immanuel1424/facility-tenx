import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MaintenanceTicket } from '../src/modules/maintenance-ticket/entities/maintenance-ticket.entity';
import { TicketSla } from '../src/modules/maintenance-ticket/entities/ticket-sla.entity';
import { SlaConfiguration } from '../src/modules/maintenance-ticket/entities/sla-configuration.entity';
import { EscalationHistory } from '../src/modules/maintenance-ticket/entities/escalation-history.entity';
import { User } from '../src/modules/iam/entities/user.entity';
import { EscalationService } from '../src/modules/maintenance-ticket/services/escalation.service';

async function checkTicketEscalation() {
  const ticketNumber = process.argv[2] || 'TKT-2026-0026';
  console.log(`🔍 Checking escalation status for ticket: ${ticketNumber}\n`);

  try {
    const app = await NestFactory.createApplicationContext(AppModule);
    const ticketRepo = app.get<Repository<MaintenanceTicket>>(
      getRepositoryToken(MaintenanceTicket),
    );
    const ticketSlaRepo = app.get<Repository<TicketSla>>(
      getRepositoryToken(TicketSla),
    );
    const escalationHistoryRepo = app.get<Repository<EscalationHistory>>(
      getRepositoryToken(EscalationHistory),
    );
    const userRepo = app.get<Repository<User>>(getRepositoryToken(User));
    const escalationService = app.get(EscalationService);

    // Find the ticket
    const ticket = await ticketRepo.findOne({
      where: { ticketNumber },
      relations: ['assignedTechnician', 'assignedSupervisor', 'creator', 'category'],
    });

    if (!ticket) {
      console.error(`❌ Ticket ${ticketNumber} not found.\n`);
      await app.close();
      process.exit(1);
    }

    console.log(`${'='.repeat(80)}`);
    console.log(`📋 TICKET DETAILS`);
    console.log(`${'='.repeat(80)}\n`);
    console.log(`Ticket Number: ${ticket.ticketNumber}`);
    console.log(`Title: ${ticket.title}`);
    console.log(`Status: ${ticket.status}`);
    console.log(`Priority: ${ticket.priority}`);
    console.log(`Company ID: ${ticket.companyId}`);
    console.log(`Created At: ${ticket.createdAt.toISOString()}`);
    console.log(`Created By: ${ticket.creator?.email || ticket.createdBy}`);
    console.log(`Assigned At: ${ticket.assignedAt ? ticket.assignedAt.toISOString() : 'Not assigned'}`);
    console.log(`Acknowledged At: ${ticket.acknowledgedAt ? ticket.acknowledgedAt.toISOString() : 'Not acknowledged'}`);
    console.log(`Is Escalated: ${ticket.isEscalated}`);
    console.log(`Escalation Level: ${ticket.escalationLevel || 0}`);
    console.log(`Escalated At: ${ticket.escalatedAt ? ticket.escalatedAt.toISOString() : 'Not escalated'}`);

    if (ticket.assignedTechnicianId) {
      const technician = await userRepo.findOne({
        where: { id: ticket.assignedTechnicianId },
        select: ['email', 'firstName', 'lastName'],
      });
      console.log(`Assigned Technician: ${technician?.email || ticket.assignedTechnicianId} (${technician?.firstName || ''} ${technician?.lastName || ''})`);
    } else {
      console.log(`Assigned Technician: Not assigned`);
    }

    if (ticket.assignedSupervisorId) {
      const supervisor = await userRepo.findOne({
        where: { id: ticket.assignedSupervisorId },
        select: ['email', 'firstName', 'lastName'],
      });
      console.log(`Assigned Supervisor: ${supervisor?.email || ticket.assignedSupervisorId} (${supervisor?.firstName || ''} ${supervisor?.lastName || ''})`);
    } else {
      console.log(`Assigned Supervisor: Not assigned`);
    }

    // Get SLA information
    const ticketSla = await ticketSlaRepo.findOne({
      where: { ticketId: ticket.id, companyId: ticket.companyId },
      relations: ['slaConfiguration'],
    });

    console.log(`\n${'='.repeat(80)}`);
    console.log(`⏱️  SLA & ESCALATION CONFIGURATION`);
    console.log(`${'='.repeat(80)}\n`);

    if (!ticketSla) {
      console.log('❌ No SLA configuration found for this ticket.');
      console.log('   Escalation will not work without SLA configuration.\n');
    } else {
      const config = ticketSla.slaConfiguration;
      console.log(`SLA Status: ${ticketSla.slaStatus}`);
      console.log(`Current Escalation Level: ${ticketSla.currentEscalationLevel || 0}`);
      console.log(`Last Escalation At: ${ticketSla.lastEscalationAt ? ticketSla.lastEscalationAt.toISOString() : 'Never'}`);
      console.log(`Total Paused Minutes: ${ticketSla.totalPausedMinutes || 0}`);
      console.log(`Acknowledged At: ${ticketSla.acknowledgedAt ? ticketSla.acknowledgedAt.toISOString() : 'Not acknowledged'}`);

      if (config) {
        console.log(`\n📊 Escalation Configuration:`);
        console.log(`   Priority: ${config.priority}`);
        console.log(`   Is Active: ${config.isActive}`);
        if (config.acknowledgementTimeMinutes) {
          console.log(`   ⚠️  Acknowledgement Deadline: ${config.acknowledgementTimeMinutes} minutes`);
        } else {
          console.log(`   ⚠️  Acknowledgement Deadline: NOT CONFIGURED`);
        }
        if (config.escalationLevel1Minutes) {
          console.log(`   Level 1 (SUPERVISOR): ${config.escalationLevel1Minutes} minutes`);
        } else {
          console.log(`   Level 1 (SUPERVISOR): NOT CONFIGURED`);
        }
        if (config.escalationLevel2Minutes) {
          console.log(`   Level 2 (SITE_COORDINATOR): ${config.escalationLevel2Minutes} minutes`);
        } else {
          console.log(`   Level 2 (SITE_COORDINATOR): NOT CONFIGURED`);
        }
        if (config.escalationLevel3Minutes) {
          console.log(`   Level 3 (ADMIN): ${config.escalationLevel3Minutes} minutes`);
        } else {
          console.log(`   Level 3 (ADMIN): NOT CONFIGURED`);
        }
      } else {
        console.log('❌ SLA Configuration not found.');
      }

      // Calculate elapsed time
      const now = new Date();
      const baseTime = ticket.assignedAt || ticket.createdAt;
      const elapsedMinutes =
        (now.getTime() - baseTime.getTime()) / (1000 * 60) -
        (ticketSla.totalPausedMinutes || 0);

      console.log(`\n⏰ Time Calculations:`);
      console.log(`   Base Time: ${baseTime.toISOString()}`);
      console.log(`   Current Time: ${now.toISOString()}`);
      console.log(`   Elapsed Minutes: ${Math.round(elapsedMinutes)} minutes (${Math.round(elapsedMinutes / 60)} hours)`);

      // Check acknowledgment
      const isAssigned = !!ticket.assignedTechnicianId || !!ticket.assignedSupervisorId;
      const isAcknowledged = !!(ticket.acknowledgedAt || ticketSla.acknowledgedAt);

      console.log(`\n✅ Assignment & Acknowledgment Status:`);
      console.log(`   Is Assigned: ${isAssigned}`);
      console.log(`   Is Acknowledged: ${isAcknowledged}`);

      if (isAssigned && !isAcknowledged && config?.acknowledgementTimeMinutes) {
        const acknowledgmentElapsed = elapsedMinutes;
        const overdue = acknowledgmentElapsed - config.acknowledgementTimeMinutes;
        console.log(`\n⚠️  ACKNOWLEDGMENT CHECK:`);
        console.log(`   Elapsed: ${Math.round(acknowledgmentElapsed)} minutes`);
        console.log(`   Deadline: ${config.acknowledgementTimeMinutes} minutes`);
        if (overdue > 0) {
          console.log(`   ❌ OVERDUE by ${Math.round(overdue)} minutes`);
          console.log(`   🚨 SHOULD BE ESCALATED TO LEVEL 1 (SUPERVISOR)`);
        } else {
          console.log(`   ⏳ Time remaining: ${Math.round(-overdue)} minutes`);
        }
      }

      // Check escalation levels
      const currentLevel = ticketSla.currentEscalationLevel || 0;
      console.log(`\n📈 Escalation Level Check:`);
      console.log(`   Current Level: ${currentLevel}`);

      if (config) {
        // Level 3
        if (config.escalationLevel3Minutes && elapsedMinutes >= config.escalationLevel3Minutes && currentLevel < 3) {
          const overdue = elapsedMinutes - config.escalationLevel3Minutes;
          console.log(`   ❌ Level 3 (ADMIN) threshold exceeded by ${Math.round(overdue)} minutes`);
          console.log(`   🚨 SHOULD BE ESCALATED TO LEVEL 3`);
        }
        // Level 2
        else if (config.escalationLevel2Minutes && elapsedMinutes >= config.escalationLevel2Minutes && currentLevel < 2) {
          const overdue = elapsedMinutes - config.escalationLevel2Minutes;
          console.log(`   ❌ Level 2 (SITE_COORDINATOR) threshold exceeded by ${Math.round(overdue)} minutes`);
          console.log(`   🚨 SHOULD BE ESCALATED TO LEVEL 2`);
        }
        // Level 1
        else if (config.escalationLevel1Minutes && elapsedMinutes >= config.escalationLevel1Minutes && currentLevel < 1) {
          const overdue = elapsedMinutes - config.escalationLevel1Minutes;
          console.log(`   ❌ Level 1 (SUPERVISOR) threshold exceeded by ${Math.round(overdue)} minutes`);
          console.log(`   🚨 SHOULD BE ESCALATED TO LEVEL 1`);
        } else {
          console.log(`   ✅ No escalation needed at this time`);
        }
      }
    }

    // Get escalation history
    const escalationHistory = await escalationHistoryRepo.find({
      where: { ticketId: ticket.id, companyId: ticket.companyId },
      order: { escalatedAt: 'DESC' },
      relations: ['escalator'],
    });

    console.log(`\n${'='.repeat(80)}`);
    console.log(`📜 ESCALATION HISTORY`);
    console.log(`${'='.repeat(80)}\n`);

    if (escalationHistory.length === 0) {
      console.log('   No escalation history found.');
    } else {
      for (const history of escalationHistory) {
        console.log(`   Level ${history.escalationLevel}: ${history.escalatedToRole}`);
        console.log(`   From: ${history.escalatedFromRole || 'Initial'}`);
        console.log(`   At: ${history.escalatedAt.toISOString()}`);
        console.log(`   By: ${history.escalatedBy ? history.escalator?.email || history.escalatedBy : 'Automatic'}`);
        console.log(`   Reason: ${history.reason}`);
        console.log(`   Is Automatic: ${history.isAutomatic}`);
        console.log('');
      }
    }

    // Test escalation check
    console.log(`\n${'='.repeat(80)}`);
    console.log(`🧪 TESTING ESCALATION LOGIC`);
    console.log(`${'='.repeat(80)}\n`);

    if (ticketSla && ticketSla.slaConfiguration) {
      console.log('Running escalation check...');
      try {
        await escalationService.checkAndEscalateTickets(ticket.companyId);
        console.log('✅ Escalation check completed. Check escalation history above for any changes.\n');
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : String(error);
        console.error(`❌ Error during escalation check: ${errorMessage}\n`);
      }
    } else {
      console.log('⚠️  Cannot test escalation - ticket has no SLA configuration.\n');
    }

    await app.close();
    process.exit(0);
  } catch (error) {
    console.error('❌ Error checking ticket escalation:', error);
    if (error instanceof Error) {
      console.error('Stack:', error.stack);
    }
    process.exit(1);
  }
}

checkTicketEscalation();
