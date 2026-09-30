import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:machhunt/core/config/maps_config.dart';
import 'package:machhunt/core/widgets/mach_hunt_map.dart';
import 'package:machhunt/models/match_model.dart';

void main() {
  group('Google Maps Platform Integration Tests', () {
    test('MapsConfig returns correct coordinates for Tamil Nadu industrial hubs', () {
      final coimbatore = MapsConfig.getCoordinatesForLocation('Coimbatore');
      expect(coimbatore.latitude, closeTo(11.0168, 0.001));
      expect(coimbatore.longitude, closeTo(76.9558, 0.001));

      final tiruppur = MapsConfig.getCoordinatesForLocation('Tiruppur');
      expect(tiruppur.latitude, closeTo(11.1085, 0.001));
      expect(tiruppur.longitude, closeTo(77.3411, 0.001));

      final chennai = MapsConfig.getCoordinatesForLocation('Chennai');
      expect(chennai.latitude, closeTo(13.0827, 0.001));
      expect(chennai.longitude, closeTo(80.2707, 0.001));

      final hosur = MapsConfig.getCoordinatesForLocation('Hosur');
      expect(hosur.latitude, closeTo(12.7409, 0.001));
      expect(hosur.longitude, closeTo(77.8253, 0.001));
    });

    test('MapsConfig falls back to Coimbatore for unknown locations', () {
      final fallback = MapsConfig.getCoordinatesForLocation('Unknown Hub');
      expect(fallback.latitude, closeTo(11.0168, 0.001));
      expect(fallback.longitude, closeTo(76.9558, 0.001));
    });

    test('MachMapMarker preserves canonical capacity fields', () {
      const marker = MachMapMarker(
        id: 'mach-101',
        title: 'Haas VF-4SS VMC',
        subtitle: 'Kovai Precision Works',
        category: 'CNC Milling',
        hourlyPrice: 1200.0,
        latitude: 11.0168,
        longitude: 76.9558,
        distanceKm: 4.2,
        matchPercentage: 94,
        isAvailable: true,
      );

      expect(marker.id, 'mach-101');
      expect(marker.position.latitude, 11.0168);
      expect(marker.position.longitude, 76.9558);
      expect(marker.distanceKm, 4.2);
      expect(marker.matchPercentage, 94);
      expect(marker.isAvailable, isTrue);
    });

    test('MatchResultModel correctly parses latitude and longitude from JSON', () {
      final json = {
        'machine_id': 'mach-1',
        'business_id': 'biz-1',
        'machine_name': 'Haas VF-4SS VMC',
        'business_name': 'Kovai Precision Works',
        'machine_category': 'CNC Milling',
        'hourly_price': 1200.0,
        'location_address': 'Peelamedu, Coimbatore',
        'latitude': 11.0168,
        'longitude': 76.9558,
        'match_percentage': 92,
        'score_breakdown': {
          'capability_score': 0.95,
          'availability_score': 0.90,
          'distance_score': 0.85,
          'cost_score': 0.90,
          'reliability_score': 0.95,
          'distance_km': 4.2,
        },
        'match_reasons': ['Capability match', 'Available slot'],
        'capabilities': [],
      };

      final model = MatchResultModel.fromJson(json);
      expect(model.latitude, 11.0168);
      expect(model.longitude, 76.9558);
      expect(model.scoreBreakdown.distanceKm, 4.2);
    });

    testWidgets('MachHuntMap widget renders with bounded height and handles loading state',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 380,
              child: MachHuntMap(
                initialCenter: LatLng(11.0168, 76.9558),
                markers: [],
                isLoading: true,
                locationName: 'Coimbatore',
              ),
            ),
          ),
        ),
      );

      // Verify bounded rendering and loading indicator/text
      expect(find.text('Updating Geospatial Capacity...'), findsOneWidget);
      expect(find.text('Capacity in Coimbatore'), findsOneWidget);
    });

    testWidgets('MachHuntMap renders graceful Windows desktop fallback without crashing and never instantiates GoogleMap', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        const marker = MachMapMarker(
          id: 'mach-1',
          title: 'CNC Vertical Machining Center',
          subtitle: 'Kovai Precision Works',
          category: 'CNC Milling',
          hourlyPrice: 1500.0,
          latitude: 11.0168,
          longitude: 76.9558,
          matchPercentage: 92,
        );

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 500,
                child: MachHuntMap(
                  initialCenter: LatLng(11.0168, 76.9558),
                  markers: [marker],
                  locationName: 'Coimbatore',
                ),
              ),
            ),
          ),
        );

        // 1. Verify GoogleMap is NEVER instantiated on Windows
        expect(find.byType(GoogleMap), findsNothing);

        // 2. Verify WindowsMapFallback is instantiated instead
        expect(find.byType(WindowsMapFallback), findsOneWidget);

        // 3. Verify user requested texts on Windows fallback
        expect(find.text('Manufacturing Capacity'), findsOneWidget);
        expect(
          find.text('Interactive map is available in\nChrome, Android and iOS.'),
          findsOneWidget,
        );
        expect(find.text('1 Capacity Units'), findsOneWidget);
        expect(find.text('View Capacity List'), findsOneWidget);
        expect(find.text('Open in Google Maps'), findsWidgets);
        expect(find.text('Available Capacity in Coimbatore'), findsOneWidget);
        expect(find.textContaining('Capacity/Process: CNC Vertical Machining Center'), findsOneWidget);
        expect(find.text('₹1500/hr'), findsOneWidget);

        // 4. Verify technical error is NOT displayed to the user
        expect(find.textContaining('TargetPlatform windows is not yet supported'), findsNothing);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
