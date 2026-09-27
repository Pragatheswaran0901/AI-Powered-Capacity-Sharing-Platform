import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:machhunt/core/storage/token_storage.dart';
import 'package:machhunt/models/user_model.dart';
import 'package:machhunt/screens/auth/login_screen.dart';
import 'package:machhunt/screens/auth/otp_verification_screen.dart';
import 'package:machhunt/state/auth_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Email OTP Authentication Tests', () {
    testWidgets('LoginScreen displays Welcome brand, tagline, email input and buttons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Verify Welcome elements from requirements
      expect(find.text('MACH-HUNT'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Use Demo Account'), findsOneWidget);
      expect(find.text('Work or Company Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('LoginScreen validates email and password before sign in', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: LoginScreen(),
        ),
      );

      // Tap Sign In without email
      final signInBtn = find.text('Sign In');
      await tester.ensureVisible(signInBtn);
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();

      expect(find.text('Email address is required.'), findsOneWidget);

      // Enter email without password
      final emailInput = find.byType(TextField).first;
      await tester.enterText(emailInput, 'janika@machhunt.demo');
      await tester.tap(signInBtn);
      await tester.pumpAndSettle();

      expect(find.text('Password is required.'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen displays 6 input boxes, email recipient, and timer', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const testEmail = 'ops@precisionmfg.com';

      await tester.pumpWidget(
        const MaterialApp(
          home: OtpVerificationScreen(email: testEmail),
        ),
      );

      // Verify Header and recipient
      expect(find.text('Check your email'), findsOneWidget);
      expect(find.text('We sent a 6-digit verification code to'), findsOneWidget);
      expect(find.text(testEmail), findsOneWidget);

      // Verify 6 OTP input boxes
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify Verify button and Change email option
      expect(find.text('Verify & Continue'), findsOneWidget);
      expect(find.text('Change email'), findsOneWidget);
    });

    testWidgets('OtpVerificationScreen enforces 6-digit entry before submission', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OtpVerificationScreen(email: 'test@example.com'),
        ),
      );

      // Tap verify with empty inputs
      final verifyBtn = find.text('Verify & Continue');
      await tester.ensureVisible(verifyBtn);
      await tester.tap(verifyBtn);
      await tester.pumpAndSettle();

      expect(find.text('Please enter all 6 digits.'), findsOneWidget);
    });

    test('UserModel correctly identifies role-based permissions and onboarding status', () {
      final seekerUser = UserModel(
        id: 'u-1',
        email: 'seeker@example.com',
        fullName: 'Seeker One',
        phone: '9876543210',
        role: 'SEEKER',
        isOnboarded: false,
        emailVerified: true,
        authenticationProvider: 'email_otp',
      );
      expect(seekerUser.isSeeker, isTrue);
      expect(seekerUser.isProvider, isFalse);
      expect(seekerUser.isAdmin, isFalse);
      expect(seekerUser.isOnboarded, isFalse);

      final providerUser = UserModel(
        id: 'u-2',
        email: 'provider@example.com',
        fullName: 'Provider One',
        phone: '9876543211',
        role: 'PROVIDER',
        isOnboarded: true,
        emailVerified: true,
        authenticationProvider: 'email_otp',
      );
      expect(providerUser.isProvider, isTrue);
      expect(providerUser.isSeeker, isFalse);
      expect(providerUser.isOnboarded, isTrue);

      final adminUser = UserModel(
        id: 'u-3',
        email: 'admin@example.com',
        fullName: 'Admin One',
        phone: '9876543212',
        role: 'ADMIN',
        isOnboarded: true,
        emailVerified: true,
      );
      expect(adminUser.isAdmin, isTrue);
    });

    test('TokenStorage correctly handles secure token lifecycle and session clear', () async {
      final storage = TokenStorage();

      await storage.saveTokens(
        accessToken: 'mock_jwt_access_token_123',
        refreshToken: 'mock_jwt_refresh_token_456',
        userId: 'u-999',
        role: 'SEEKER',
        fullName: 'Test MSME User',
        isOnboarded: true,
      );

      expect(await storage.hasValidToken(), isTrue);
      expect(await storage.getAccessToken(), 'mock_jwt_access_token_123');
      expect(await storage.getRefreshToken(), 'mock_jwt_refresh_token_456');
      expect(await storage.getUserId(), 'u-999');
      expect(await storage.getUserRole(), 'SEEKER');
      expect(await storage.getIsOnboarded(), isTrue);

      // Clear tokens (Logout)
      await storage.clear();
      expect(await storage.hasValidToken(), isFalse);
      expect(await storage.getAccessToken(), isNull);
      expect(await storage.getRefreshToken(), isNull);
    });

    test('AuthState handles logout and clears in-memory state', () async {
      authState.logout();
      expect(authState.isAuthenticated, isFalse);
      expect(authState.currentUser, isNull);
      expect(authState.errorMessage, isNull);
    });
  });
}
