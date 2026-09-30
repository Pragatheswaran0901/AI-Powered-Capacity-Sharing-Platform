import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';

enum MachButtonVariant {
  primary, // Deep Industrial Navy
  secondary, // Cobalt Blue
  accent, // Manufacturing Orange
  dark, // Dark Slate / Navy
  outline, // Bordered Subtle
  danger, // Red
  ghost, // Subtle text
}

enum MachButtonSize { small, medium, large }

class MachButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MachButtonVariant variant;
  final MachButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;

  const MachButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = MachButtonVariant.primary,
    this.size = MachButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case MachButtonVariant.primary:
        bg = AppColors.primary;
        fg = Colors.white;
        break;
      case MachButtonVariant.secondary:
        bg = AppColors.steelBlue;
        fg = Colors.white;
        break;
      case MachButtonVariant.accent:
        bg = AppColors.machOrange;
        fg = Colors.white;
        break;
      case MachButtonVariant.dark:
        bg = AppColors.darkNavy;
        fg = Colors.white;
        break;
      case MachButtonVariant.outline:
        bg = Colors.white;
        fg = AppColors.primaryNavy;
        borderSide = const BorderSide(color: AppColors.lightBorder, width: 1.2);
        break;
      case MachButtonVariant.danger:
        bg = AppColors.errorRed;
        fg = Colors.white;
        break;
      case MachButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.steelBlue;
        break;
    }

    double height;
    double fontSize;
    EdgeInsets padding;
    double iconSize;

    switch (size) {
      case MachButtonSize.small:
        height = 36;
        fontSize = 12;
        iconSize = 15;
        padding = const EdgeInsets.symmetric(horizontal: 12);
        break;
      case MachButtonSize.medium:
        height = 44;
        fontSize = 13.5;
        iconSize = 17;
        padding = const EdgeInsets.symmetric(horizontal: 18);
        break;
      case MachButtonSize.large:
        height = 50;
        fontSize = 15;
        iconSize = 19;
        padding = const EdgeInsets.symmetric(horizontal: 24);
        break;
    }

    Widget content = isLoading
        ? SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: fg),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                  color: fg,
                ),
              ),
            ],
          );

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: variant == MachButtonVariant.primary ? 0.5 : 0,
          shadowColor: AppColors.navyDark.withValues(alpha: 0.2),
          side: borderSide,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: padding,
        ),
        child: content,
      ),
    );
  }
}

class MachOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final MachButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final Color? color;

  const MachOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.size = MachButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return MachButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      variant: MachButtonVariant.outline,
      size: size,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }
}
