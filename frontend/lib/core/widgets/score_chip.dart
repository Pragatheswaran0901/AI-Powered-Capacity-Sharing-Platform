import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/app_colors.dart';

class ScoreChip extends StatelessWidget {
  final int percentage;
  final VoidCallback? onTap;

  const ScoreChip({
    super.key,
    required this.percentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.matchHigh;
    Color bg = AppColors.successBg;

    if (percentage < 65) {
      color = AppColors.matchLow;
      bg = const Color(0xFFF1F5F9);
    } else if (percentage < 85) {
      color = AppColors.matchMedium;
      bg = AppColors.warningBg;
    }

    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$percentage% Match',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: chip,
      );
    }
    return chip;
  }
}
