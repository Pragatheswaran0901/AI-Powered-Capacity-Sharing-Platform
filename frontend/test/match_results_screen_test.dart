import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machhunt/core/design_system/mach_domain_cards.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/models/match_model.dart';

void main() {
  group('CapacityMatchCard (MachMatchCard) Widget Tests', () {
    testWidgets(
      'Renders real match data accurately including score, provider, distance, capabilities, rating, slot rate, and actions',
      (WidgetTester tester) async {
        final match = MatchResultModel(
          machineId: 'mach-201',
          businessId: 'biz-201',
          businessName: 'Kovai Precision Works',
          machineName: 'Haas VMC CNC Milling Machine',
          machineCategory: 'VMC',
          manufacturer: 'Haas',
          model: 'VF-2SS',
          year: 2022,
          locationAddress: 'Ganapathy, Coimbatore',
          hourlyPrice: 750.0,
          overallScore: 0.99,
          matchPercentage: 99,
          scoreBreakdown: MatchScoreBreakdownModel(
            capabilityScore: 1.0,
            availabilityScore: 0.95,
            distanceScore: 1.0,
            costScore: 1.0,
            reliabilityScore: 1.0,
            distanceKm: 4.2,
            estimatedCost: 15000.0,
          ),
          matchReasons: [
            'Exact CNC Milling & Aluminium capability match',
            'Within 5 km of Coimbatore',
          ],
          capabilities: [
            MachineCapabilityModel(
              id: 'cap-1',
              process: 'VMC',
              material: 'Aluminium',
            ),
            MachineCapabilityModel(
              id: 'cap-2',
              process: 'CNC Milling',
              material: 'Stainless Steel',
            ),
            MachineCapabilityModel(
              id: 'cap-3',
              process: 'CNC Milling',
              material: 'Mild Steel',
            ),
            MachineCapabilityModel(
              id: 'cap-4',
              process: 'CNC Milling',
              material: 'Brass',
            ),
          ],
          operatorAvailable: true,
          status: 'ACTIVE',
          averageRating: 4.9,
          completedJobs: 15,
          verificationStatus: 'VERIFIED',
        );

        bool compareTapped = false;
        bool bookTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  child: CapacityMatchCard.fromMatch(
                    match: match,
                    isSelectedForComparison: false,
                    onToggleComparison: (_) => compareTapped = true,
                    onBook: () => bookTapped = true,
                  ),
                ),
              ),
            ),
          ),
        );

        // Category & Verified Unit badge
        expect(find.text('VMC'), findsOneWidget);
        expect(find.text('Verified Unit'), findsOneWidget);

        // Machine Name & Model/Year
        expect(find.text('Haas VMC CNC Milling Machine'), findsOneWidget);
        expect(find.text('Haas VF-2SS (2022)'), findsOneWidget);

        // Match score badge
        expect(find.text('99%'), findsOneWidget);
        expect(find.text('Match'), findsOneWidget);

        // Provider, Location, Distance
        expect(find.text('Kovai Precision Works'), findsOneWidget);
        expect(find.text('Ganapathy, Coimbatore'), findsOneWidget);
        expect(find.text('4.2 km'), findsOneWidget);

        // Capability chips (top 3 + "+1 more")
        expect(find.text('Aluminium • VMC'), findsOneWidget);
        expect(find.text('Stainless Steel • CNC Milling'), findsOneWidget);
        expect(find.text('Mild Steel • CNC Milling'), findsOneWidget);
        expect(find.text('+1 more'), findsOneWidget);

        // Operator / Availability & Rating
        expect(find.text('Certified Operator'), findsOneWidget);
        expect(find.text('4.9'), findsOneWidget);
        expect(find.text('(15 jobs)'), findsOneWidget);

        // Slot rate
        expect(find.text('SLOT RATE'), findsOneWidget);
        expect(find.text('₹750/hr'), findsOneWidget);

        // Expandable "Why this match?" breakdown
        expect(find.text('Why this match?'), findsOneWidget);
        await tester.tap(find.text('Why this match?'));
        await tester.pumpAndSettle();

        expect(find.text('40/40'), findsOneWidget);
        expect(find.text('19/20'), findsOneWidget);
        expect(find.text('15/15'), findsNWidgets(2));
        expect(find.text('10/10'), findsOneWidget);

        // Compare & Book Capacity buttons
        final compareBtn = find.text('Compare');
        final bookBtn = find.text('Book Capacity');
        expect(compareBtn, findsOneWidget);
        expect(bookBtn, findsOneWidget);

        await tester.ensureVisible(compareBtn);
        await tester.pumpAndSettle();
        await tester.tap(compareBtn);
        expect(compareTapped, isTrue);

        await tester.ensureVisible(bookBtn);
        await tester.pumpAndSettle();
        await tester.tap(bookBtn);
        expect(bookTapped, isTrue);
      },
    );

    testWidgets(
      'Does not fake Verified Unit or Rating when absent and shows Available for Rent when operatorAvailable is false',
      (WidgetTester tester) async {
        final match = MatchResultModel(
          machineId: 'mach-202',
          businessId: 'biz-202',
          businessName: 'Hosur TurnTech',
          machineName: 'Standard CNC Turning Center',
          machineCategory: 'CNC Turning',
          locationAddress: 'Hosur',
          hourlyPrice: 680.0,
          overallScore: 0.78,
          matchPercentage: 78,
          scoreBreakdown: MatchScoreBreakdownModel(
            capabilityScore: 0.8,
            availabilityScore: 0.8,
            distanceScore: 0.67,
            costScore: 0.8,
            reliabilityScore: 0.8,
            distanceKm: 65.0,
            estimatedCost: 12000.0,
          ),
          matchReasons: [],
          capabilities: [],
          operatorAvailable: false,
          status: 'ACTIVE',
          averageRating: 0.0,
          completedJobs: 0,
          verificationStatus: 'PENDING',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: SizedBox(
                  width: 380,
                  child: CapacityMatchCard.fromMatch(
                    match: match,
                    isSelectedForComparison: true,
                    onToggleComparison: (_) {},
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('CNC TURNING'), findsOneWidget);
        expect(find.text('Verified Unit'), findsNothing);
        expect(find.text('78%'), findsOneWidget);
        expect(find.text('Available for Rent'), findsOneWidget);
        expect(find.text('Certified Operator'), findsNothing);
        expect(find.text('₹680/hr'), findsOneWidget);
        expect(find.byTooltip('Remove from comparison'), findsOneWidget);
      },
    );
  });
}
