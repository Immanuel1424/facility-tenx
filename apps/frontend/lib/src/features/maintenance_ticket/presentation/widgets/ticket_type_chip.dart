import 'package:flutter/material.dart';

import '../../domain/entities/ticket_type_entity.dart';

class TicketTypeChip extends StatelessWidget {
  const TicketTypeChip({
    super.key,
    required this.ticketType,
    this.size = ChipSize.medium,
  });

  final TicketType ticketType;
  final ChipSize size;

  @override
  Widget build(BuildContext context) {
    final color = Color(ticketType.colorValue);
    final textStyle = size == ChipSize.small
        ? Theme.of(context).textTheme.labelSmall
        : Theme.of(context).textTheme.labelMedium;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size == ChipSize.small ? 6 : 8,
        vertical: size == ChipSize.small ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size == ChipSize.small ? 6 : 8,
            height: size == ChipSize.small ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            ticketType.displayName,
            style: textStyle?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

enum ChipSize { small, medium, large }

