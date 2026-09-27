import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';

class MachPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? primaryAction;
  final List<Widget>? secondaryActions;
  final Widget? badge;
  final VoidCallback? onBack;

  const MachPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.primaryAction,
    this.secondaryActions,
    this.badge,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    Widget titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (onBack != null) ...[
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20, color: AppColors.slate700),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onBack,
              ),
              const SizedBox(width: 10),
            ],
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.navyIndustrial,
                ),
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 10),
              badge!,
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: AppColors.slate500,
            ),
          ),
        ],
      ],
    );

    Widget actionsBlock = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (secondaryActions != null) ...[
          for (var action in secondaryActions!) ...[
            action,
            const SizedBox(width: 8),
          ],
        ],
        ?primaryAction,
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          if (primaryAction != null || secondaryActions != null) ...[
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: actionsBlock,
            ),
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 16),
        actionsBlock,
      ],
    );
  }
}
