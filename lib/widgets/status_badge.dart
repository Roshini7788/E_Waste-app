import 'package:flutter/material.dart';
import '../models/waste_request.dart';

class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final bool isSimulated;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSimulated = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 3 : 5,
          ),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: status.color.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                status.icon,
                size: compact ? 12 : 14,
                color: status.color,
              ),
              const SizedBox(width: 5),
              Text(
                status.label,
                style: TextStyle(
                  color: status.color,
                  fontSize: compact ? 11 : 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        if (isSimulated)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 6 : 8,
              vertical: compact ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.blueGrey.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Text(
              'Demo Data',
              style: TextStyle(
                color: Colors.blueGrey.shade700,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
