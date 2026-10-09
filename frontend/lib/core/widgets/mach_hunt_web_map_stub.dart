import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'mach_hunt_map.dart';

class MachHuntWebMap extends StatelessWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<MachMapMarker> markers;
  final String? selectedMarkerId;
  final ValueChanged<MachMapMarker>? onMarkerSelected;
  final ValueChanged<MachMapMarker>? onBookCapacity;
  final ValueChanged<MachMapMarker>? onCompareCapacity;
  final double height;
  final bool isLoading;
  final String locationName;

  const MachHuntWebMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = 12.0,
    required this.markers,
    this.selectedMarkerId,
    this.onMarkerSelected,
    this.onBookCapacity,
    this.onCompareCapacity,
    required this.height,
    this.isLoading = false,
    required this.locationName,
  });

  static void selectMarker(String markerId) {}

  static void panTo(double lat, double lng, {double? zoom}) {}

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
