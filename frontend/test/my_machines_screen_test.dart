import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:machhunt/core/design_system/mach_domain_cards.dart';
import 'package:machhunt/models/machine_model.dart';

void main() {
  group('MachineCard Marketplace Widget Tests', () {
    testWidgets('Renders all real machine data fields accurately', (
      WidgetTester tester,
    ) async {
      final machine = MachineModel(
        id: 'mach-101',
        businessId: 'biz-101',
        name: 'HAAS VF-4SS Super-Speed 4-Axis VMC',
        category: 'CNC Milling',
        manufacturer: 'HAAS Automation',
        model: 'VF-4SS',
        year: 2023,
        hourlyPrice: 1200.0,
        locationAddress: 'Plot 14, SIDCO Kurichi, Coimbatore',
        latitude: 10.9412,
        longitude: 76.9723,
        status: 'ACTIVE',
        verificationStatus: 'VERIFIED',
        averageRating: 5.0,
        capabilities: [
          MachineCapabilityModel(
            id: 'c1',
            process: 'CNC Milling',
            material: 'Aluminium 6061',
          ),
          MachineCapabilityModel(
            id: 'c2',
            process: 'CNC Milling',
            material: 'Stainless Steel 304',
          ),
          MachineCapabilityModel(
            id: 'c3',
            process: 'CNC Machining',
            material: 'Brass',
          ),
          MachineCapabilityModel(
            id: 'c4',
            process: 'CNC Milling',
            material: 'Mild Steel',
          ),
        ],
        availabilities: [
          MachineAvailabilityModel(
            id: 'a1',
            date: '2026-09-30',
            startTime: '08:00:00',
            endTime: '20:00:00',
            isAvailable: true,
          ),
        ],
      );

      bool editTapped = false;
      bool availTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 380,
              child: MachineCard.fromModel(
                machine: machine,
                onEdit: () => editTapped = true,
                onManageAvailability: () => availTapped = true,
              ),
            ),
          ),
        ),
      );

      // Category badge & Verified badge
      expect(find.text('CNC MILLING'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);

      // Title & Manufacturer/Model/Year subtitle
      expect(find.text('HAAS VF-4SS Super-Speed 4-Axis VMC'), findsOneWidget);
      expect(find.text('HAAS Automation VF-4SS (2023)'), findsOneWidget);

      // Location & Rating
      expect(find.text('Plot 14, SIDCO Kurichi, Coimbatore'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Capability chips (top 3 + "+1 more")
      expect(find.text('Aluminium 6061 • CNC Milling'), findsOneWidget);
      expect(find.text('Stainless Steel 304 • CNC Milling'), findsOneWidget);
      expect(find.text('Brass • CNC Machining'), findsOneWidget);
      expect(find.text('+1 more'), findsOneWidget);

      // Availability & Utilization
      expect(find.text('Available for Rent'), findsOneWidget);
      expect(find.text('67% Utilization'), findsOneWidget);

      // Slot rate in INR
      expect(find.text('SLOT RATE'), findsOneWidget);
      expect(find.text('₹1,200/hr'), findsOneWidget);

      // Actions with tooltips
      final editBtn = find.byTooltip('Edit machine');
      final availBtn = find.byTooltip('Manage availability');
      expect(editBtn, findsOneWidget);
      expect(availBtn, findsOneWidget);

      await tester.tap(editBtn);
      expect(editTapped, isTrue);

      await tester.tap(availBtn);
      expect(availTapped, isTrue);
    });

    testWidgets(
      'Does not fake Verified badge or Utilization when not present',
      (WidgetTester tester) async {
        final unverifiedMachine = MachineModel(
          id: 'mach-102',
          businessId: 'biz-101',
          name: 'Custom Shop Lathe',
          category: 'Lathe',
          hourlyPrice: 650.0,
          locationAddress: 'Peelamedu, Coimbatore',
          latitude: 11.0,
          longitude: 77.0,
          status: 'MAINTENANCE',
          verificationStatus: 'PENDING',
          capabilities: [],
          availabilities: [],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 380,
                child: MachineCard.fromModel(machine: unverifiedMachine),
              ),
            ),
          ),
        );

        expect(find.text('LATHE'), findsOneWidget);
        expect(find.text('Verified'), findsNothing);
        expect(find.text('Maintenance'), findsOneWidget);
        expect(find.textContaining('Utilization'), findsNothing);
        expect(find.text('₹650/hr'), findsOneWidget);
      },
    );
  });
}
