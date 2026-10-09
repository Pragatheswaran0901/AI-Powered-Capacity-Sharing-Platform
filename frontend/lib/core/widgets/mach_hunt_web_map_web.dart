import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'mach_hunt_map.dart';

@JS('machHuntCreateMapContainer')
external JSObject _createMapContainer(JSNumber viewId);

@JS('MachHuntWebMap.initMap')
external void _jsInitMap(JSString containerId, JSNumber lat, JSNumber lng, JSNumber zoom);

@JS('MachHuntWebMap.updateMarkers')
external void _jsUpdateMarkers(JSString markersJson);

@JS('MachHuntWebMap.selectMarker')
external void _jsSelectMarker(JSString markerId);

@JS('MachHuntWebMap.panTo')
external void _jsPanTo(JSNumber lat, JSNumber lng, JSNumber? zoom);

@JS('machHuntOnMarkerSelected')
external set _jsOnMarkerSelected(JSFunction? callback);

@JS('machHuntOnBookCapacity')
external set _jsOnBookCapacity(JSFunction? callback);

@JS('machHuntOnCompareCapacity')
external set _jsOnCompareCapacity(JSFunction? callback);

const String _kViewType = 'mach-hunt-web-map-view';
bool _isViewFactoryRegistered = false;

class MachHuntWebMap extends StatefulWidget {
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

  static void selectMarker(String markerId) {
    try {
      _jsSelectMarker(markerId.toJS);
    } catch (e) {
      debugPrint('[MachHuntWebMap] selectMarker error: $e');
    }
  }

  static void panTo(double lat, double lng, {double? zoom}) {
    try {
      _jsPanTo(lat.toJS, lng.toJS, zoom?.toJS);
    } catch (e) {
      debugPrint('[MachHuntWebMap] panTo error: $e');
    }
  }

  @override
  State<MachHuntWebMap> createState() => _MachHuntWebMapState();
}

class _MachHuntWebMapState extends State<MachHuntWebMap> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    if (!_isViewFactoryRegistered) {
      ui_web.platformViewRegistry.registerViewFactory(
        _kViewType,
        (int viewId) => _createMapContainer(viewId.toJS),
      );
      _isViewFactoryRegistered = true;
    }

    _setupCallbacks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  void _setupCallbacks() {
    _jsOnMarkerSelected = ((JSString id) {
      final markerId = id.toDart;
      final m = _findMarkerById(markerId);
      if (m != null) {
        widget.onMarkerSelected?.call(m);
      }
    }).toJS;

    _jsOnBookCapacity = ((JSString id) {
      final markerId = id.toDart;
      final m = _findMarkerById(markerId);
      if (m != null) {
        widget.onBookCapacity?.call(m);
      }
    }).toJS;

    _jsOnCompareCapacity = ((JSString id) {
      final markerId = id.toDart;
      final m = _findMarkerById(markerId);
      if (m != null) {
        widget.onCompareCapacity?.call(m);
      }
    }).toJS;
  }

  MachMapMarker? _findMarkerById(String id) {
    for (final m in widget.markers) {
      if (m.id == id) return m;
    }
    return null;
  }

  void _initializeMap() {
    if (!mounted) return;
    try {
      _jsInitMap(
        'mach-hunt-web-map-container'.toJS,
        widget.initialCenter.latitude.toJS,
        widget.initialCenter.longitude.toJS,
        widget.initialZoom.toJS,
      );
      _syncMarkers();
      _isInitialized = true;
    } catch (e) {
      debugPrint('[MachHuntWebMap] Init map JS error: $e');
    }
  }

  void _syncMarkers() {
    try {
      final validMarkers = widget.markers
          .where((m) => m.latitude != 0.0 && m.longitude != 0.0)
          .map((m) => m.toJson())
          .toList();
      final jsonStr = jsonEncode(validMarkers);
      _jsUpdateMarkers(jsonStr.toJS);

      if (widget.selectedMarkerId != null) {
        _jsSelectMarker(widget.selectedMarkerId!.toJS);
      }
    } catch (e) {
      debugPrint('[MachHuntWebMap] Sync markers JS error: $e');
    }
  }

  @override
  void didUpdateWidget(covariant MachHuntWebMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _setupCallbacks();

    if (!_isInitialized) {
      _initializeMap();
      return;
    }

    if (widget.markers != oldWidget.markers) {
      _syncMarkers();
    } else if (widget.selectedMarkerId != oldWidget.selectedMarkerId) {
      if (widget.selectedMarkerId != null) {
        MachHuntWebMap.selectMarker(widget.selectedMarkerId!);
      }
    }

    if (widget.initialCenter != oldWidget.initialCenter) {
      MachHuntWebMap.panTo(
        widget.initialCenter.latitude,
        widget.initialCenter.longitude,
        zoom: widget.initialZoom,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: const HtmlElementView(
        viewType: _kViewType,
      ),
    );
  }
}
