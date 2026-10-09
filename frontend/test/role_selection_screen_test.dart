import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machhunt/models/user_model.dart';
import 'package:machhunt/screens/auth/role_selection_screen.dart';
import 'package:machhunt/state/auth_state.dart';

void main() {
  group('RoleSelectionScreen Tests', () {
    setUp(() {
      authState.setCurrentUserForTesting(
        UserModel(
          id: 'user-onboarding-test',
          email: 'newuser@machhunt.demo',
          fullName: 'Arun Kumar',
          phone: '+919876543210',
          role: 'SEEKER',
          isOnboarded: false,
        ),
      );
    });

    testWidgets(
      'Renders premium header, progress indicator, headline, and both role cards',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: RoleSelectionScreen()));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 700));

        // Brand header & progress indicator
        expect(find.text('MACH-HUNT'), findsOneWidget);
        expect(find.text('ENTERPRISE'), findsOneWidget);
        expect(find.text('STEP 1 OF 2'), findsOneWidget);
        expect(find.text('INTENT & ROLE SELECTION'), findsOneWidget);
        expect(find.text('Sign Out'), findsOneWidget);

        // Headline & supporting text
        expect(find.text('Power Your Next Manufacturing Move'), findsOneWidget);
        expect(
          find.text(
            'Select how your business will operate on the Mach-Hunt shared capacity network. You can seamlessly switch modes anytime from your dashboard.',
          ),
          findsOneWidget,
        );

        // Capacity Provider card
        expect(find.text('Capacity Provider'), findsOneWidget);
        expect(
          find.text('Turn Idle Capacity Into Opportunity'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Connect with MSMEs seeking your manufacturing capabilities and monetize available machine time.',
          ),
          findsOneWidget,
        );
        expect(find.text('MONETIZE CAPACITY'), findsOneWidget);
        expect(find.text('List Your Capacity'), findsOneWidget);
        expect(
          find.text('List CNC, VMC, turning, and laser equipment'),
          findsOneWidget,
        );
        expect(
          find.text('Publish machine availability and shift calendars'),
          findsOneWidget,
        );
        expect(find.text('Receive procurement requests'), findsOneWidget);
        expect(find.text('Manage orders and milestones'), findsOneWidget);

        // Capacity Seeker card
        expect(find.text('Capacity Seeker'), findsOneWidget);
        expect(
          find.text('Find the Right Manufacturing Partner'),
          findsOneWidget,
        );
        expect(
          find.text(
            'Discover suitable manufacturers based on your production requirements, capabilities, and location.',
          ),
          findsOneWidget,
        );
        expect(find.text('AI-POWERED SOURCING'), findsOneWidget);
        expect(find.text('Find Manufacturing Partners'), findsOneWidget);
        expect(
          find.text('Describe requirements in plain English'),
          findsOneWidget,
        );
        expect(
          find.text('Extract manufacturing requirements using AI'),
          findsOneWidget,
        );
        expect(find.text('Compare matching manufacturers'), findsOneWidget);
        expect(
          find.text('Track procurement requests and milestones'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'Renders responsive mobile layout without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: RoleSelectionScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('Power Your Next Manufacturing Move'), findsOneWidget);
        expect(find.text('Capacity Provider'), findsOneWidget);
        expect(find.text('Capacity Seeker'), findsOneWidget);
        expect(find.text('List Your Capacity'), findsOneWidget);
        expect(find.text('Find Manufacturing Partners'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders responsive tablet layout without overflow',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(768, 1024);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: RoleSelectionScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 700));

        expect(find.text('Power Your Next Manufacturing Move'), findsOneWidget);
        expect(find.text('Capacity Provider'), findsOneWidget);
        expect(find.text('Capacity Seeker'), findsOneWidget);
      },
    );

    testWidgets(
      'Hover interaction on cards updates cleanly without assertion errors',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const MaterialApp(
            home: RoleSelectionScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 800));

        final providerTitle = find.text('Capacity Provider');
        expect(providerTitle, findsOneWidget);

        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(providerTitle));
        await tester.pump(const Duration(milliseconds: 250));

        expect(providerTitle, findsOneWidget);
      },
    );
  });
}
