import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/app_colors.dart';

class MachCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final BorderSide? borderSide;
  final double borderRadius;
  final double elevation;
  final bool hasHoverEffect;
  final Widget? header;
  final Widget? footer;

  const MachCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.backgroundColor,
    this.borderSide,
    this.borderRadius = 10,
    this.elevation = 0,
    this.hasHoverEffect = true,
    this.header,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) ...[
          header!,
          const Divider(height: 1, color: AppColors.slate200),
        ],
        Padding(
          padding: padding,
          child: child,
        ),
        if (footer != null) ...[
          const Divider(height: 1, color: AppColors.slate200),
          footer!,
        ],
      ],
    );

    final boxDecoration = BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.fromBorderSide(
        borderSide ?? const BorderSide(color: AppColors.slate200, width: 1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    if (onTap != null) {
      return Container(
        decoration: boxDecoration,
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            hoverColor: AppColors.slate100.withValues(alpha: 0.6),
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      decoration: boxDecoration,
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );
  }
}
