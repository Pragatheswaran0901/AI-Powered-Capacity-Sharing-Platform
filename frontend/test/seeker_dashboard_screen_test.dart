import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machhunt/models/user_model.dart';
import 'package:machhunt/screens/seeker/my_requirements_screen.dart';
import 'package:machhunt/screens/seeker/seeker_dashboard_screen.dart';
import 'package:machhunt/state/auth_state.dart';

void main() {
  group('Seeker Dashboard & My Requirements Screen Tests', () {
    setUp(() {
      authState.setCurrentUserForTesting(
        UserModel(
          id: 'user-seeker-1',
          email: 'seeker@machhunt.demo',
          fullName: 'Karthikeyan',
          phone: '+919876543210',
          role: 'SEEKER',
          isOnboarded: true,
        ),
      );
    });

    testWidgets(
      'SeekerDashboardScreen renders discovery workspace header, search panel, formula, and metrics',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SeekerDashboardScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Header greeting with dynamic user name
        expect(find.textContaining('Karthikeyan'), findsOneWidget);
        expect(
          find.text('Find manufacturing capacity for your next production requirement.'),
          findsOneWidget,
        );

        // Summary metric pills
        expect(find.text('Active Requirements'), findsOneWidget);
        expect(find.text('Active Bookings'), findsOneWidget);
        expect(find.text('Available Matches'), findsOneWidget);

        // Search panel title
        expect(find.text('What do you need to manufacture?'), findsOneWidget);
        expect(find.text('✨ Parse with AI'), findsOneWidget);

        // 6 fields labels
        expect(find.text('Requirement'), findsOneWidget);
        expect(find.text('Process'), findsOneWidget);
        expect(find.text('Material'), findsOneWidget);
        expect(find.text('Quantity'), findsOneWidget);
        expect(find.text('Budget (₹)'), findsOneWidget);
        expect(find.text('Location'), findsOneWidget);

        // Primary Find Matching Machines button
        expect(find.textContaining('Matching'), findsWidgets);

        // Recommended Capacity header & ranking formula
        expect(find.text('Recommended Manufacturing Capacity'), findsOneWidget);
        expect(
          find.textContaining('Capability (40%) + Availability (20%) + Distance (15%) + Cost (15%) + Reliability (10%)'),
          findsOneWidget,
        );

        // Lower dashboard active bookings
        expect(
          find.text('Active Bookings & Production Activity'),
          findsOneWidget,
        );

        // Top Location Selector & Showing capacity in badge
        expect(find.text('Coimbatore'), findsWidgets);
        expect(find.text('Showing capacity in: '), findsOneWidget);
        expect(find.text('📍 Coimbatore'), findsOneWidget);
      },
    );

    testWidgets(
      'SeekerDashboardScreen location selector can switch to Tiruppur',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SeekerDashboardScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Find the top location selector dropdown and tap it
        final locationDropdowns = find.byType(DropdownButton<String>);
        expect(locationDropdowns, findsWidgets);

        // Tap the first dropdown (top location selector)
        await tester.tap(locationDropdowns.first);
        await tester.pump(const Duration(milliseconds: 200));

        // Check that Tiruppur option appears
        expect(find.text('Tiruppur'), findsWidgets);

        // Select Tiruppur
        await tester.tap(find.text('Tiruppur').last);
        await tester.pump(const Duration(milliseconds: 200));

        // Location badge or text should reflect Tiruppur
        expect(find.text('Tiruppur'), findsWidgets);
      },
    );

    testWidgets(
      'MyRequirementsScreen renders requirement management workspace with filter tabs and search',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: MyRequirementsScreen(),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Management header
        expect(find.text('My Requirements'), findsOneWidget);
        expect(
          find.text('Manage production RFQs, track matching machines, and view booking statuses.'),
          findsOneWidget,
        );
        expect(find.text('+ New Requirement'), findsOneWidget);

        // Filter tabs
        expect(find.text('All'), findsOneWidget);
        expect(find.text('Active'), findsOneWidget);
        expect(find.text('Matched'), findsOneWidget);
        expect(find.text('Booked'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
        expect(find.text('Cancelled'), findsOneWidget);

        // Search bar
        expect(
          find.text('Search requirements by title, process, material, or location...'),
          findsOneWidget,
        );
      },
    );
  });
}

