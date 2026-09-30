import 'package:google_maps_flutter/google_maps_flutter.dart';

class ManufacturingLocation {
  final String id;
  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final String state;

  const ManufacturingLocation({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    this.state = 'Tamil Nadu',
  });

  LatLng get latLng => LatLng(latitude, longitude);
}

class MapsConfig {
  /// Maps API key passed via compile-time environment variable, or fallback placeholder.
  /// Never hardcode live production secrets here.
  static const String apiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyDGAgFJPu2uAoNa6RSQ5VbWhseZyppxfYw',
  );

  /// Default center if location is unknown (Coimbatore industrial hub)
  static const LatLng defaultCenter = LatLng(11.0168, 76.9558);
  static const double defaultZoom = 12.0;

  /// Tamil Nadu Industrial Clusters for the Mach-Hunt marketplace
  static const List<ManufacturingLocation> supportedLocations = [
    ManufacturingLocation(
      id: 'cbe',
      name: 'Coimbatore',
      district: 'Coimbatore',
      latitude: 11.0168,
      longitude: 76.9558,
    ),
    ManufacturingLocation(
      id: 'tpr',
      name: 'Tiruppur',
      district: 'Tiruppur',
      latitude: 11.1085,
      longitude: 77.3411,
    ),
    ManufacturingLocation(
      id: 'erd',
      name: 'Erode',
      district: 'Erode',
      latitude: 11.3410,
      longitude: 77.7172,
    ),
    ManufacturingLocation(
      id: 'krr',
      name: 'Karur',
      district: 'Karur',
      latitude: 10.9601,
      longitude: 78.0766,
    ),
    ManufacturingLocation(
      id: 'slm',
      name: 'Salem',
      district: 'Salem',
      latitude: 11.6643,
      longitude: 78.1460,
    ),
    ManufacturingLocation(
      id: 'hsr',
      name: 'Hosur',
      district: 'Krishnagiri',
      latitude: 12.7409,
      longitude: 77.8253,
    ),
    ManufacturingLocation(
      id: 'chn',
      name: 'Chennai',
      district: 'Chennai',
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    ManufacturingLocation(
      id: 'spb',
      name: 'Sriperumbudur',
      district: 'Kanchipuram',
      latitude: 12.9691,
      longitude: 79.9472,
    ),
    ManufacturingLocation(
      id: 'ogd',
      name: 'Oragadam',
      district: 'Kanchipuram',
      latitude: 12.8362,
      longitude: 79.9460,
    ),
    ManufacturingLocation(
      id: 'rnp',
      name: 'Ranipet',
      district: 'Ranipet',
      latitude: 12.9272,
      longitude: 79.3333,
    ),
    ManufacturingLocation(
      id: 'vlr',
      name: 'Vellore',
      district: 'Vellore',
      latitude: 12.9165,
      longitude: 79.1325,
    ),
    ManufacturingLocation(
      id: 'svk',
      name: 'Sivakasi',
      district: 'Virudhunagar',
      latitude: 9.4533,
      longitude: 77.7983,
    ),
    ManufacturingLocation(
      id: 'dgl',
      name: 'Dindigul',
      district: 'Dindigul',
      latitude: 10.3673,
      longitude: 77.9803,
    ),
    ManufacturingLocation(
      id: 'tht',
      name: 'Thoothukudi',
      district: 'Thoothukudi',
      latitude: 8.7642,
      longitude: 78.1348,
    ),
    ManufacturingLocation(
      id: 'tnv',
      name: 'Tirunelveli',
      district: 'Tirunelveli',
      latitude: 8.7139,
      longitude: 77.7567,
    ),
  ];

  /// Lookup city center coordinates by name
  static LatLng getCoordinatesForLocation(String locationName) {
    final query = locationName.trim().toLowerCase();
    for (final loc in supportedLocations) {
      if (loc.name.toLowerCase() == query ||
          loc.district.toLowerCase() == query ||
          query.contains(loc.name.toLowerCase())) {
        return loc.latLng;
      }
    }
    return defaultCenter;
  }
}
