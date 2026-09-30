import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/widgets/app_card.dart';
import 'package:machhunt/core/widgets/app_text_field.dart';
import 'package:machhunt/core/widgets/score_chip.dart';
import 'package:machhunt/core/widgets/status_badge.dart';
import 'package:machhunt/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders sign in fields and button', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('MACH-HUNT'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Use Demo Account'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('ScoreChip renders match percentage correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ScoreChip(percentage: 94))),
    );

    expect(find.text('94% Match'), findsOneWidget);
    expect(find.byIcon(Icons.bolt), findsOneWidget);
  });

  testWidgets('StatusBadge renders status correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: StatusBadge(status: 'VERIFIED')),
      ),
    );

    expect(find.text('VERIFIED'), findsOneWidget);
  });

  testWidgets('AppCard renders child with appropriate padding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppCard(child: Text('Machining Capacity'))),
      ),
    );

    expect(find.text('Machining Capacity'), findsOneWidget);
  });

  testWidgets('AppTextField accepts text input', (WidgetTester tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppTextField(label: 'Machine Name', controller: controller),
        ),
      ),
    );

    expect(find.text('Machine Name'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Haas VF-2');
    expect(controller.text, 'Haas VF-2');
  });

  test('Formatters format currency correctly for INR', () {
    expect(Formatters.currency(25000), '₹25,000');
    expect(Formatters.currency(1500), '₹1,500');
    expect(Formatters.currency(0), '₹0');
  });

  test('Formatters format distance correctly', () {
    expect(Formatters.distance(4.2), '4.2 km');
    expect(Formatters.distance(0.8), '800 m');
  });
}
