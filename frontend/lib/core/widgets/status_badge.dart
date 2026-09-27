import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = const Color(0xFFF1F5F9);
    Color fg = const Color(0xFF475569);
    String label = status;

    final upper = status.toUpperCase();

    if (upper == 'VERIFIED' || upper == 'CONFIRMED' || upper == 'COMPLETED' || upper == 'ACTIVE') {
      bg = AppColors.successBg;
      fg = AppColors.success;
    } else if (upper == 'PENDING' || upper == 'ACCEPTED') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
    } else if (upper == 'IN_PROGRESS' || upper == 'MATCHED') {
      bg = AppColors.infoBg;
      fg = AppColors.info;
      label = upper == 'IN_PROGRESS' ? 'IN PRODUCTION' : label;
    } else if (upper == 'REJECTED' || upper == 'CANCELLED' || upper == 'DISPUTED') {
      bg = AppColors.errorBg;
      fg = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
