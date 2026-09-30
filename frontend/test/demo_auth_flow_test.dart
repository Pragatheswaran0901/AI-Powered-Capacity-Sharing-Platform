import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/screens/auth/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Demo Authentication Flow Tests (AUTH_MODE=demo)', () {
    testWidgets(
      'LoginScreen contains only password-auth elements and zero OTP elements',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

        // Verify exact header and title elements
        expect(find.text('MACH-HUNT'), findsOneWidget);
        expect(find.text('Welcome to Mach-Hunt'), findsOneWidget);
        expect(find.text('Sign in to continue'), findsOneWidget);

        // Verify input labels
        expect(find.text('Work or Company Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);

        // Verify buttons
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Use Demo Account'), findsOneWidget);

        // Verify ZERO active OTP UI elements
        expect(find.text('OTP'), findsNothing);
        expect(find.text('Continue with OTP →'), findsNothing);
        expect(find.text('Verify OTP'), findsNothing);
        expect(find.text('Send OTP'), findsNothing);
        expect(find.text('Resend OTP'), findsNothing);
        expect(find.text('Verify Code'), findsNothing);
        expect(find.text('Verification Code'), findsNothing);
        expect(find.text('Switch to OTP'), findsNothing);
        expect(find.text('Email Verification'), findsNothing);
      },
    );

    testWidgets(
      'Demo account picker shows ONLY Janika, Pragatheswaran, Jayanth, Reethika',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

        // Tap Use Demo Account
        final demoBtn = find.text('Use Demo Account');
        await tester.ensureVisible(demoBtn);
        await tester.tap(demoBtn);
        await tester.pumpAndSettle();

        // Verify title
        expect(find.text('Select Demo Account'), findsOneWidget);

        // Verify the ONLY 4 allowed demo accounts
        expect(find.text('Janika'), findsOneWidget);
        expect(find.text('janika@machhunt.demo'), findsOneWidget);

        expect(find.text('Pragatheswaran'), findsOneWidget);
        expect(find.text('pragatheswaran@machhunt.demo'), findsOneWidget);

        expect(find.text('Jayanth'), findsOneWidget);
        expect(find.text('jayanth@machhunt.demo'), findsOneWidget);

        expect(find.text('Reethika'), findsOneWidget);
        expect(find.text('reethika@machhunt.demo'), findsOneWidget);

        // Verify disallowed demo accounts are NOT present
        expect(find.text('Admin'), findsNothing);
        expect(find.text('Senthil'), findsNothing);
        expect(find.text('Murugan'), findsNothing);
        expect(find.text('Karthikeyan'), findsNothing);
      },
    );

    testWidgets(
      'Selecting a demo account populates credentials without auto-submitting',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

        // Open demo account modal
        final demoBtn = find.text('Use Demo Account');
        await tester.ensureVisible(demoBtn);
        await tester.tap(demoBtn);
        await tester.pumpAndSettle();

        // Tap Janika
        final janikaTile = find.text('Janika');
        await tester.tap(janikaTile);
        await tester.pumpAndSettle();

        // Modal closed, fields populated
        expect(find.text('janika@machhunt.demo'), findsOneWidget);
        expect(find.text('password123'), findsOneWidget);

        // Screen is still on LoginScreen (did not navigate away or open OTP)
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Enter OTP'), findsNothing);
        expect(find.text('Verify OTP'), findsNothing);
      },
    );

    testWidgets(
      'Email validator rejects obviously malformed emails and accepts demo emails',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

        final signInBtn = find.text('Sign In');
        final emailInput = find.byType(TextField).first;

        // 1. Empty email
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        expect(find.text('Email address is required.'), findsOneWidget);

        // 2. Malformed email 'abc'
        await tester.enterText(emailInput, 'abc');
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );

        // 3. Malformed email 'abc@'
        await tester.enterText(emailInput, 'abc@');
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );

        // 4. Malformed email '@example.com'
        await tester.enterText(emailInput, '@example.com');
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        expect(
          find.text('Please enter a valid email address.'),
          findsOneWidget,
        );

        // 5. Valid demo email 'janika@machunt.demo' (from screenshot)
        await tester.enterText(emailInput, 'janika@machunt.demo');
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        // Should NOT reject email as malformed, should ask for password
        expect(find.text('Please enter a valid email address.'), findsNothing);
        expect(find.text('Password is required.'), findsOneWidget);

        // 6. Valid seeded email 'janika@machhunt.demo'
        await tester.enterText(emailInput, 'janika@machhunt.demo');
        await tester.tap(signInBtn);
        await tester.pumpAndSettle();
        expect(find.text('Please enter a valid email address.'), findsNothing);
        expect(find.text('Password is required.'), findsOneWidget);
      },
    );

    test('ApiEndpoints defaults to AUTH_MODE=demo with isDemoMode=true', () {
      expect(ApiEndpoints.authMode, 'demo');
      expect(ApiEndpoints.isDemoMode, isTrue);
      expect(ApiEndpoints.isOtpMode, isFalse);
    });
  });
}
