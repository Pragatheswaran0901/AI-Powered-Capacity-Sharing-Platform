import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';

class MachBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const MachBadge({
    super.key,
    required this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.slate100;
    final fg = textColor ?? AppColors.slate700;
    final border = borderColor ?? AppColors.slate200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}

class MachStatusBadge extends StatelessWidget {
  final String status;
  final bool showDot;

  const MachStatusBadge({super.key, required this.status, this.showDot = true});

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.slate100;
    Color fg = AppColors.slate700;
    String displayLabel = status.replaceAll('_', ' ').toUpperCase();

    final upper = status.toUpperCase();

    if (upper == 'AVAILABLE' ||
        upper == 'ACTIVE' ||
        upper == 'VERIFIED' ||
        upper == 'CONFIRMED' ||
        upper == 'COMPLETED') {
      bg = const Color(0xFFECFDF5);
      fg = const Color(0xFF059669);
      if (upper == 'AVAILABLE') displayLabel = 'AVAILABLE';
    } else if (upper == 'BUSY' ||
        upper == 'PENDING' ||
        upper == 'REQUESTED' ||
        upper == 'IN REVIEW') {
      bg = const Color(0xFFFFFBEB);
      fg = const Color(0xFFD97706);
    } else if (upper == 'IN_PROGRESS' ||
        upper == 'IN PRODUCTION' ||
        upper == 'MATCHES READY') {
      bg = const Color(0xFFEFF6FF);
      fg = const Color(0xFF2563EB);
      if (upper == 'IN_PROGRESS') displayLabel = 'IN PRODUCTION';
    } else if (upper == 'MAINTENANCE' || upper == 'OFFLINE') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    } else if (upper == 'REJECTED' ||
        upper == 'CANCELLED' ||
        upper == 'FAILED') {
      bg = const Color(0xFFFEF2F2);
      fg = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            displayLabel,
            style: GoogleFonts.inter(
              color: fg,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class MachVerifiedBadge extends StatelessWidget {
  final String label;
  final bool isCompact;

  const MachVerifiedBadge({
    super.key,
    this.label = 'Verified Business',
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 9,
        vertical: isCompact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 13,
            color: Color(0xFF059669),
          ),
          const SizedBox(width: 4.5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF047857),
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
