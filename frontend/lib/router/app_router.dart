import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/screens/splash_screen.dart';
import 'package:machhunt/screens/landing/landing_screen.dart';
import 'package:machhunt/screens/auth/login_screen.dart';
import 'package:machhunt/screens/auth/otp_verification_screen.dart';
import 'package:machhunt/screens/auth/role_selection_screen.dart';
import 'package:machhunt/screens/auth/register_screen.dart';
import 'package:machhunt/screens/onboarding/business_onboarding_screen.dart';
import 'package:machhunt/screens/shell/main_shell.dart';
import 'package:machhunt/screens/provider/provider_dashboard_screen.dart';
import 'package:machhunt/screens/provider/my_machines_screen.dart';
import 'package:machhunt/screens/provider/add_machine_screen.dart';
import 'package:machhunt/screens/provider/availability_calendar_screen.dart';
import 'package:machhunt/screens/seeker/seeker_dashboard_screen.dart';
import 'package:machhunt/screens/seeker/create_requirement_screen.dart';
import 'package:machhunt/screens/seeker/match_results_screen.dart';
import 'package:machhunt/screens/seeker/compare_machines_screen.dart';
import 'package:machhunt/screens/bookings/bookings_list_screen.dart';
import 'package:machhunt/screens/admin/admin_dashboard_screen.dart';
import 'package:machhunt/screens/notifications/notifications_screen.dart';
import 'package:machhunt/screens/profile/profile_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/otp-verify',
      redirect: (context, state) {
        if (ApiEndpoints.isDemoMode) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? (state.extra as String? ?? '');
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/otp',
      redirect: (context, state) {
        if (ApiEndpoints.isDemoMode) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? (state.extra as String? ?? '');
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/verify-otp',
      redirect: (context, state) {
        if (ApiEndpoints.isDemoMode) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? (state.extra as String? ?? '');
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/email-verification',
      redirect: (context, state) {
        if (ApiEndpoints.isDemoMode) {
          return '/login';
        }
        return null;
      },
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? (state.extra as String? ?? '');
        return OtpVerificationScreen(email: email);
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const BusinessOnboardingScreen(),
    ),
    GoRoute(
      path: '/onboarding-business',
      builder: (context, state) => const BusinessOnboardingScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/provider-dashboard',
          builder: (context, state) => const ProviderDashboardScreen(),
        ),
        GoRoute(
          path: '/my-machines',
          builder: (context, state) => const MyMachinesScreen(),
        ),
        GoRoute(
          path: '/add-machine',
          builder: (context, state) => const AddMachineScreen(),
        ),
        GoRoute(
          path: '/availability',
          builder: (context, state) => const AvailabilityCalendarScreen(
            machineId: 'm-default',
            machineName: 'HAAS VF-2SS Super-Speed 4-Axis VMC',
          ),
        ),
        GoRoute(
          path: '/machine-availability/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final name = state.uri.queryParameters['name'] ?? 'Machine';
            return AvailabilityCalendarScreen(machineId: id, machineName: name);
          },
        ),
        GoRoute(
          path: '/incoming-requests',
          builder: (context, state) => const BookingsListScreen(),
        ),
        GoRoute(
          path: '/seeker-dashboard',
          builder: (context, state) => const SeekerDashboardScreen(),
        ),
        GoRoute(
          path: '/create-requirement',
          builder: (context, state) => const CreateRequirementScreen(),
        ),
        GoRoute(
          path: '/my-requirements',
          builder: (context, state) => const SeekerDashboardScreen(),
        ),
        GoRoute(
          path: '/matches/:reqId',
          builder: (context, state) {
            final reqId = state.pathParameters['reqId'] ?? '';
            final title = state.uri.queryParameters['title'] ?? 'Capacity Matches';
            return MatchResultsScreen(requirementId: reqId, requirementTitle: title);
          },
        ),
        GoRoute(
          path: '/compare',
          builder: (context, state) => const CompareMachinesScreen(),
        ),
        GoRoute(
          path: '/bookings',
          builder: (context, state) => const BookingsListScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
