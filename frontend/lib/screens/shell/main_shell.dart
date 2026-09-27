import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_navigation.dart';
import 'package:machhunt/state/auth_state.dart';

class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/provider-dashboard') || location.startsWith('/seeker-dashboard')) {
      return 0;
    }
    if (location.startsWith('/add-machine') || location.startsWith('/create-requirement') || location.startsWith('/my-machines')) {
      return 1;
    }
    if (location.startsWith('/bookings')) {
      return 2;
    }
    if (location.startsWith('/admin')) {
      return 0;
    }
    if (location.startsWith('/notifications')) {
      return 3;
    }
    if (location.startsWith('/profile')) {
      return 4;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final isProvider = authState.isProvider;
    final isAdmin = authState.isAdmin;

    if (isAdmin) {
      switch (index) {
        case 0:
          context.go('/admin');
          break;
        case 1:
          context.go('/bookings');
          break;
        case 2:
          context.go('/notifications');
          break;
        case 3:
          context.go('/profile');
          break;
      }
      return;
    }

    switch (index) {
      case 0:
        if (isProvider) {
          context.go('/provider-dashboard');
        } else {
          context.go('/seeker-dashboard');
        }
        break;
      case 1:
        if (isProvider) {
          context.go('/my-machines');
        } else {
          context.go('/create-requirement');
        }
        break;
      case 2:
        context.go('/bookings');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  Future<void> _handleRoleSwitch(BuildContext context) async {
    final isCurrentlyProvider = authState.isProvider;
    final newRole = isCurrentlyProvider ? 'SEEKER' : 'PROVIDER';
    await authState.switchRole(newRole);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isCurrentlyProvider
                ? 'Switched to Capacity Seeker workspace.'
                : 'Switched to Capacity Provider workspace.',
          ),
          backgroundColor: AppColors.navyIndustrial,
          duration: const Duration(seconds: 2),
        ),
      );

      if (newRole == 'SEEKER') {
        context.go('/seeker-dashboard');
      } else {
        context.go('/provider-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final location = GoRouterState.of(context).uri.path;
    final selectedIndex = _calculateSelectedIndex(context);
    final isProvider = authState.isProvider;
    final isAdmin = authState.isAdmin;

    return ListenableBuilder(
      listenable: authState,
      builder: (context, _) {
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: AppColors.background,
          drawer: !isDesktop
              ? Drawer(
                  child: MachSidebar(
                    currentRoute: location,
                    isProvider: authState.isProvider,
                    isAdmin: authState.isAdmin,
                    onSwitchRole: () {
                      Navigator.of(context).pop();
                      _handleRoleSwitch(context);
                    },
                  ),
                )
              : null,
          appBar: !isDesktop
              ? MachTopBar(
                  title: 'MACH-HUNT',
                  onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.swap_horiz, color: AppColors.navyIndustrial),
                        tooltip: isProvider ? 'Switch to Seeker' : 'Switch to Provider',
                        onPressed: () => _handleRoleSwitch(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 20, color: AppColors.slate600),
                        tooltip: 'Sign Out',
                        onPressed: () async {
                          await authState.logout();
                          if (context.mounted) context.go('/login');
                        },
                      ),
                    ],
                  ),
                )
              : null,
          body: Row(
            children: [
              if (isDesktop)
                MachSidebar(
                  currentRoute: location,
                  isProvider: authState.isProvider,
                  isAdmin: authState.isAdmin,
                  onSwitchRole: () => _handleRoleSwitch(context),
                ),
              Expanded(
                child: Container(
                  color: AppColors.background,
                  child: widget.child,
                ),
              ),
            ],
          ),
          bottomNavigationBar: !isDesktop
              ? NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (idx) => _onItemTapped(idx, context),
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.steelBlue.withValues(alpha: 0.12),
                  elevation: 4,
                  destinations: isAdmin
                      ? const [
                          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Admin'),
                          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Bookings'),
                          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Alerts'),
                          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                        ]
                      : [
                          NavigationDestination(
                            icon: Icon(isProvider ? Icons.precision_manufacturing_outlined : Icons.explore_outlined),
                            selectedIcon: Icon(isProvider ? Icons.precision_manufacturing : Icons.explore),
                            label: isProvider ? 'Capacity' : 'Discovery',
                          ),
                          NavigationDestination(
                            icon: Icon(isProvider ? Icons.list_alt_outlined : Icons.post_add_outlined),
                            selectedIcon: Icon(isProvider ? Icons.list_alt : Icons.post_add),
                            label: isProvider ? 'Machines' : 'Post Need',
                          ),
                          const NavigationDestination(
                            icon: Icon(Icons.calendar_today_outlined),
                            selectedIcon: Icon(Icons.calendar_today),
                            label: 'Bookings',
                          ),
                          const NavigationDestination(
                            icon: Icon(Icons.notifications_outlined),
                            selectedIcon: Icon(Icons.notifications),
                            label: 'Alerts',
                          ),
                          const NavigationDestination(
                            icon: Icon(Icons.account_circle_outlined),
                            selectedIcon: Icon(Icons.account_circle),
                            label: 'Profile',
                          ),
                        ],
                )
              : null,
        );
      },
    );
  }
}
