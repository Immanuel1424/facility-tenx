import { TicketPriority } from '../enums/ticket-priority.enum';

export interface PriorityDetails {
  colorCode: string;
  iconName: string;
  defaultSlaHours: number;
}

export const PRIORITY_METADATA: Record<TicketPriority, PriorityDetails> = {
  [TicketPriority.LOW]: {
    colorCode: '#4CAF50', // Green
    iconName: 'arrow_downward',
    defaultSlaHours: 72,
  },
  [TicketPriority.MEDIUM]: {
    colorCode: '#2196F3', // Blue
    iconName: 'horizontal_rule',
    defaultSlaHours: 48,
  },
  [TicketPriority.HIGH]: {
    colorCode: '#FF9800', // Orange (matches requested example)
    iconName: 'arrow_upward',
    defaultSlaHours: 24,
  },
  [TicketPriority.URGENT]: {
    colorCode: '#F44336', // Red
    iconName: 'warning',
    defaultSlaHours: 4,
  },
};


