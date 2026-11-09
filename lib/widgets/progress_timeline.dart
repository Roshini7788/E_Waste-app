import 'package:flutter/material.dart';
import '../models/waste_request.dart';
import '../theme/app_theme.dart';

class ProgressTimeline extends StatelessWidget {
  final RequestStatus currentStatus;

  const ProgressTimeline({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    const statuses = [
      RequestStatus.pending,
      RequestStatus.scheduled,
      RequestStatus.collected,
      RequestStatus.recycled,
    ];

    final currentIndex = currentStatus.stepIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;

        if (isNarrow) {
          // Vertical layout for small screens
          return Column(
            children: List.generate(statuses.length, (index) {
              final status = statuses[index];
              final isPassed = index < currentIndex;
              final isCurrent = index == currentIndex;
              final isLast = index == statuses.length - 1;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      _buildStepCircle(status, isPassed, isCurrent),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 36,
                          color: isPassed ? AppTheme.accentGreen : Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.label,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                              color: isCurrent
                                  ? status.color
                                  : (isPassed ? Colors.black87 : Colors.grey.shade500),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getStepDescription(status),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        }

        // Horizontal layout for wider views
        return Column(
          children: [
            Row(
              children: List.generate(statuses.length * 2 - 1, (i) {
                if (i.isEven) {
                  final index = i ~/ 2;
                  final status = statuses[index];
                  final isPassed = index < currentIndex;
                  final isCurrent = index == currentIndex;
                  return _buildStepCircle(status, isPassed, isCurrent);
                } else {
                  final prevIndex = i ~/ 2;
                  final isLineActive = prevIndex < currentIndex;
                  return Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isLineActive ? AppTheme.accentGreen : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }
              }),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(statuses.length, (index) {
                final status = statuses[index];
                final isCurrent = index == currentIndex;
                final isPassed = index < currentIndex;

                return Expanded(
                  child: Text(
                    status.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                      color: isCurrent
                          ? status.color
                          : (isPassed ? AppTheme.primaryGreen : Colors.grey.shade500),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepCircle(RequestStatus status, bool isPassed, bool isCurrent) {
    if (isPassed) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppTheme.accentGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (isCurrent) {
      return Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: status.color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: status.color.withValues(alpha: 0.35),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          status.icon,
          color: Colors.white,
          size: 18,
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Icon(
          status.icon,
          color: Colors.grey.shade500,
          size: 16,
        ),
      );
    }
  }

  String _getStepDescription(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return 'Request submitted and awaiting facility assignment';
      case RequestStatus.scheduled:
        return 'Collector assigned & route confirmed for pickup';
      case RequestStatus.collected:
        return 'Device picked up and transported to recycling hub';
      case RequestStatus.recycled:
        return 'Safely disassembled, hazardous parts contained & materials reclaimed';
    }
  }
}
