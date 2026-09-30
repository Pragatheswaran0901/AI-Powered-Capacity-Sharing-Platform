import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/app_colors.dart';

/// Reusable application-wide background component for authenticated screens and dashboards.
///
/// Displays the sharp, unblurred industrial manufacturing background image
/// (`assets/images/machhunt_bg_all_pages.png`) visible around the perimeter of the
/// viewport, while housing the dashboard content inside a calm, content-safe surface
/// (`#F8FAFC` at ~92% opacity) to eliminate visual noise and clashing lines behind text.
class AppBackground extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  final double overlayOpacity;
  final Color overlayColor;
  final bool enableSafeContentSurface;

  const AppBackground({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
    this.overlayOpacity = 0.0,
    this.overlayColor = Colors.white,
    this.enableSafeContentSurface = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Sharp full-viewport manufacturing application background image (never blurred or darkened)
        Positioned.fill(
          child: Image.asset(
            'assets/images/machhunt_bg_all_pages.png',
            fit: BoxFit.cover,
            alignment: alignment,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFFF1F5F9), // Fallback slate surface
            ),
          ),
        ),

        // 2. Subtle edge fade: background is clearly recognizable around edges
        // and smoothly quiets down towards the content workspace
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.08, 0.92, 1.0],
                colors: [
                  const Color(0xFFF8FAFC).withValues(alpha: 0.20),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.88),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.90),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                stops: const [0.0, 0.05, 0.95, 1.0],
                colors: [
                  const Color(0xFFF8FAFC).withValues(alpha: 0.15),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.85),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.85),
                  const Color(0xFFF8FAFC).withValues(alpha: 0.15),
                ],
              ),
            ),
          ),
        ),

        // Optional custom overlay if explicitly provided
        if (overlayOpacity > 0)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: overlayColor.withValues(alpha: overlayOpacity),
              ),
            ),
          ),

        // 3. Main Application Content Container (Safe Content Surface)
        Positioned.fill(
          child: enableSafeContentSurface
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 768;
                    final horizontalMargin = isMobile ? 8.0 : 16.0;
                    final verticalMargin = isMobile ? 6.0 : 12.0;

                    return Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: horizontalMargin,
                            vertical: verticalMargin,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF8FAFC,
                            ).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.lightBorder.withValues(
                                alpha: 0.85,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: child,
                        ),
                      ),
                    );
                  },
                )
              : child,
        ),
      ],
    );
  }
}
