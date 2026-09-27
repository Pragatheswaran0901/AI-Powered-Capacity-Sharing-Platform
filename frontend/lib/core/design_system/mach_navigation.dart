import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_badges.dart';
import 'package:machhunt/state/auth_state.dart';

class MachSidebar extends StatelessWidget {
  final String currentRoute;
  final bool isProvider;
  final bool isAdmin;
  final VoidCallback? onSwitchRole;

  const MachSidebar({
    super.key,
    required this.currentRoute,
    required this.isProvider,
    this.isAdmin = false,
    this.onSwitchRole,
  });

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
    String? badgeText,
  }) {
    final isSelected = currentRoute.startsWith(route) || (route == '/provider-dashboard' && currentRoute == '/my-machines');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (currentRoute != route) {
              context.go(route);
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.steelBlue.withValues(alpha: 0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(color: AppColors.steelBlue.withValues(alpha: 0.25), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 19,
                  color: isSelected ? AppColors.steelBlue : AppColors.slate400,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.slate300,
                    ),
                  ),
                ),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.steelBlue : AppColors.slate800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeText,
                      style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final biz = authState.currentBusiness;

    return Container(
      width: 250,
      color: AppColors.navyIndustrial,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Platform Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.steelBlue,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.steelBlue.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MACH-HUNT',
                      style: GoogleFonts.inter(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Capacity Platform',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.slate800),
          const SizedBox(height: 12),

          // User Context Pill
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.navySurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate700.withValues(alpha: 0.5), width: 1),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isProvider ? AppColors.orangeAccent : AppColors.steelBlue,
                    child: Text(
                      (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : 'M',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          biz?.name ?? user?.fullName ?? "MSME Account",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isProvider ? 'Capacity Provider' : 'Capacity Seeker',
                          style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w500, color: AppColors.slate400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isAdmin) ...[
                    _buildNavItem(context: context, icon: Icons.admin_panel_settings_outlined, label: 'Admin Oversight', route: '/admin'),
                    _buildNavItem(context: context, icon: Icons.receipt_long_outlined, label: 'All Bookings', route: '/bookings'),
                    _buildNavItem(context: context, icon: Icons.notifications_outlined, label: 'Notifications', route: '/notifications'),
                    _buildNavItem(context: context, icon: Icons.person_outline, label: 'Profile', route: '/profile'),
                  ] else if (isProvider) ...[
                    _buildNavItem(context: context, icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/provider-dashboard'),
                    _buildNavItem(context: context, icon: Icons.precision_manufacturing_outlined, label: 'My Machines', route: '/my-machines'),
                    _buildNavItem(context: context, icon: Icons.calendar_month_outlined, label: 'Availability', route: '/availability'),
                    _buildNavItem(context: context, icon: Icons.inbox_outlined, label: 'Incoming Requests', route: '/incoming-requests'),
                    _buildNavItem(context: context, icon: Icons.receipt_long_outlined, label: 'Bookings', route: '/bookings'),
                    _buildNavItem(context: context, icon: Icons.verified_user_outlined, label: 'Verification', route: '/profile'),
                    _buildNavItem(context: context, icon: Icons.settings_outlined, label: 'Settings', route: '/profile'),
                  ] else ...[
                    _buildNavItem(context: context, icon: Icons.dashboard_outlined, label: 'Dashboard', route: '/seeker-dashboard'),
                    _buildNavItem(context: context, icon: Icons.add_circle_outline, label: 'Create Requirement', route: '/create-requirement'),
                    _buildNavItem(context: context, icon: Icons.assignment_outlined, label: 'My Requirements', route: '/my-requirements'),
                    _buildNavItem(context: context, icon: Icons.compare_arrows_outlined, label: 'Compare Options', route: '/compare'),
                    _buildNavItem(context: context, icon: Icons.receipt_long_outlined, label: 'Bookings', route: '/bookings'),
                    _buildNavItem(context: context, icon: Icons.verified_user_outlined, label: 'Verification', route: '/profile'),
                    _buildNavItem(context: context, icon: Icons.settings_outlined, label: 'Settings', route: '/profile'),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Action: Role Switcher
          const Divider(height: 1, color: AppColors.slate800),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onSwitchRole ?? () {
                  if (isProvider) {
                    context.go('/seeker-dashboard');
                  } else {
                    context.go('/provider-dashboard');
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: AppColors.navySurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate700, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.swap_horiz_rounded,
                        size: 18,
                        color: isProvider ? AppColors.steelBlue : AppColors.orangeAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isProvider ? 'Switch to Seeker' : 'Switch to Provider',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sign Out Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mach-Hunt v2.0',
                  style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate500),
                ),
                InkWell(
                  onTap: () async {
                    await authState.logout();
                    if (context.mounted) context.go('/login');
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        const Icon(Icons.logout, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 4),
                        Text(
                          'Sign Out',
                          style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MachTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onMenuPressed;

  const MachTopBar({
    super.key,
    required this.title,
    this.trailing,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1)),
      ),
      child: Row(
        children: [
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.navyIndustrial),
              onPressed: onMenuPressed,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: AppColors.navyIndustrial,
            ),
          ),
          const Spacer(),
          ?trailing,
          if (user != null) ...[
            const SizedBox(width: 14),
            Row(
              children: [
                MachStatusBadge(status: user.role, showDot: false),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.steelBlue,
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                    style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
