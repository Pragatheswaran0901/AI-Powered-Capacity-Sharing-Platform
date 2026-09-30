import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:url_launcher/url_launcher.dart';

/// Normalized data representation for pins placed on the Mach-Hunt map
class MachMapMarker {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double hourlyPrice;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final int? matchPercentage;
  final bool isAvailable;
  final String? mapsUrl;
  final String? companyName;
  final String? industry;
  final String? city;
  final dynamic originalData; // MachineModel or MatchResultModel

  const MachMapMarker({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.hourlyPrice,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.matchPercentage,
    this.isAvailable = true,
    this.mapsUrl,
    this.companyName,
    this.industry,
    this.city,
    this.originalData,
  });

  LatLng get position => LatLng(latitude, longitude);

  /// Standard cross-platform Google Maps URL
  String get googleMapsUrl {
    if (mapsUrl != null && mapsUrl!.isNotEmpty) {
      return mapsUrl!;
    }
    return 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  }
}

/// Returns true if GoogleMap is supported on this platform.
/// On Web (kIsWeb), Android, and iOS: returns true.
/// On native Windows Desktop (TargetPlatform.windows), macOS, and Linux: strictly returns false.
bool get isSupportedMapPlatform {
  if (kIsWeb) return true;
  if (defaultTargetPlatform == TargetPlatform.windows) return false;
  return defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
}

bool get isGoogleMapsSupported => isSupportedMapPlatform;

/// Platform-Aware Google Map Component for the Mach-Hunt Manufacturing Marketplace.
///
/// On Web, Android, and iOS: Renders interactive GoogleMap with live capacity pins.
/// On Windows desktop: Renders an industrial Mach-Hunt capacity map fallback with
/// browser deep-linking, preserving 100% of marketplace capacity data and booking actions.
class MachHuntMap extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<MachMapMarker> markers;
  final String? selectedMarkerId;
  final ValueChanged<MachMapMarker>? onMarkerSelected;
  final ValueChanged<MachMapMarker>? onBookCapacity;
  final ValueChanged<MachMapMarker>? onCompareCapacity;
  final double? height;
  final bool isLoading;
  final String locationName;

  const MachHuntMap({
    super.key,
    required this.initialCenter,
    this.initialZoom = 12.0,
    required this.markers,
    this.selectedMarkerId,
    this.onMarkerSelected,
    this.onBookCapacity,
    this.onCompareCapacity,
    this.height,
    this.isLoading = false,
    this.locationName = 'Coimbatore',
  });

  @override
  State<MachHuntMap> createState() => MachHuntMapState();
}

class MachHuntMapState extends State<MachHuntMap> {
  GoogleMapController? _controller;
  MachMapMarker? _activeMarker;
  bool _hasMapError = false;

  void reportMapError() {
    if (mounted) {
      setState(() => _hasMapError = true);
    }
  }

  @override
  void initState() {
    super.initState();
    _syncActiveMarker();
  }

  @override
  void didUpdateWidget(covariant MachHuntMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMarkerId != widget.selectedMarkerId ||
        oldWidget.markers != widget.markers) {
      _syncActiveMarker();
    }
    if (isGoogleMapsSupported && oldWidget.initialCenter != widget.initialCenter) {
      animateToLocation(widget.initialCenter, zoom: widget.initialZoom);
    }
  }

  void _syncActiveMarker() {
    if (widget.selectedMarkerId != null) {
      try {
        _activeMarker = widget.markers.firstWhere(
          (m) => m.id == widget.selectedMarkerId,
        );
      } catch (_) {
        _activeMarker = null;
      }
    } else if (_activeMarker != null &&
        !widget.markers.any((m) => m.id == _activeMarker!.id)) {
      _activeMarker = null;
    }
  }

  /// Programmatic camera movement to a coordinate (only on supported platforms)
  Future<void> animateToLocation(LatLng target, {double? zoom}) async {
    if (!isGoogleMapsSupported || _controller == null) return;
    try {
      await _controller!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: zoom ?? widget.initialZoom),
        ),
      );
    } catch (e) {
      debugPrint('[MachHuntMap] Camera animation error: $e');
    }
  }

  /// Focus and select a specific marker
  void selectMarker(MachMapMarker marker) {
    setState(() => _activeMarker = marker);
    if (isGoogleMapsSupported) {
      animateToLocation(marker.position, zoom: 13.5);
    }
    widget.onMarkerSelected?.call(marker);
  }

  /// Launch Google Maps in user's browser
  Future<void> _openGoogleMaps({MachMapMarker? marker}) async {
    final String url;
    if (marker != null) {
      url = marker.googleMapsUrl;
    } else if (_activeMarker != null) {
      url = _activeMarker!.googleMapsUrl;
    } else if (widget.markers.isNotEmpty) {
      url = widget.markers.first.googleMapsUrl;
    } else {
      url =
          'https://www.google.com/maps/search/?api=1&query=${widget.initialCenter.latitude},${widget.initialCenter.longitude}';
    }

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('[MachHuntMap] Could not open maps URL ($url): $e');
    }
  }

  Set<Marker> _buildMarkers() {
    final Set<Marker> set = {};

    for (final m in widget.markers) {
      final isSelected = m.id == _activeMarker?.id;

      // Color coding per Mach-Hunt Design Guidelines:
      // Selected -> Azure/Blue, Available -> Green, Provider highlight -> Orange
      final double hue = isSelected
          ? BitmapDescriptor.hueAzure
          : (m.matchPercentage != null && m.matchPercentage! >= 85)
              ? BitmapDescriptor.hueGreen
              : BitmapDescriptor.hueOrange;

      set.add(
        Marker(
          markerId: MarkerId(m.id),
          position: m.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: m.title,
            snippet: '₹${m.hourlyPrice.toInt()}/hr • ${m.category}',
            onTap: () => selectMarker(m),
          ),
          onTap: () => selectMarker(m),
        ),
      );
    }

    return set;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final mapHeight = widget.height ?? (isDesktop ? 440.0 : 320.0);

    // CRITICAL: On Windows Desktop, GoogleMap MUST NEVER be instantiated!
    if (!isSupportedMapPlatform) {
      return WindowsMapFallback(
        height: mapHeight,
        locationName: widget.locationName,
        markers: widget.markers,
        selectedMarkerId: widget.selectedMarkerId,
        onMarkerSelected: widget.onMarkerSelected,
        onBookCapacity: widget.onBookCapacity,
        onCompareCapacity: widget.onCompareCapacity,
        isLoading: widget.isLoading,
        onOpenGoogleMaps: (m) => _openGoogleMaps(marker: m),
      );
    }

    return _buildInteractiveGoogleMap(mapHeight);
  }

  Widget _buildInteractiveGoogleMap(double mapHeight) {
    return Container(
      height: mapHeight,
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
      child: Stack(
        children: [
          // 1. Interactive Google Map or Error Fallback
          if (_hasMapError)
            _buildUnavailableState()
          else
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialCenter,
                zoom: widget.initialZoom,
              ),
              markers: _buildMarkers(),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: true,
              onMapCreated: (ctrl) {
                _controller = ctrl;
                if (mounted) setState(() {});
              },
              onTap: (_) {
                if (_activeMarker != null) {
                  setState(() => _activeMarker = null);
                }
              },
            ),

          // 2. Map Header Bar
          Positioned(
            top: 12,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.precision_manufacturing_rounded,
                        size: 16,
                        color: AppColors.machOrange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Capacity in ${widget.locationName}',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightSurface,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.lightBorder),
                        ),
                        child: Text(
                          '${widget.markers.length} Units',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.machBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Controls: Zoom In, Zoom Out, Reset Center
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        tooltip: 'Zoom In',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (_controller != null) {
                            _controller!.animateCamera(CameraUpdate.zoomIn());
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                        child: VerticalDivider(
                          width: 1,
                          color: AppColors.lightBorder,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        tooltip: 'Zoom Out',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          if (_controller != null) {
                            _controller!.animateCamera(CameraUpdate.zoomOut());
                          }
                        },
                      ),
                      const SizedBox(
                        height: 16,
                        child: VerticalDivider(
                          width: 1,
                          color: AppColors.lightBorder,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location, size: 16),
                        tooltip: 'Reset to Cluster Center',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          animateToLocation(
                            widget.initialCenter,
                            zoom: widget.initialZoom,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Cluster Legend Pill
          Positioned(
            top: 56,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem(AppColors.successGreen, 'High Match (≥85%)'),
                  const SizedBox(width: 10),
                  _buildLegendItem(AppColors.machOrange, 'Verified Partner'),
                  const SizedBox(width: 10),
                  _buildLegendItem(AppColors.machBlue, 'Selected Unit'),
                ],
              ),
            ),
          ),

          // 4. Loading Overlay or Empty Cluster Info
          if (widget.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.machOrange),
                      SizedBox(height: 12),
                      Text(
                        'Updating Geospatial Capacity...',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (widget.markers.isEmpty)
            Positioned(
              bottom: 14,
              left: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppColors.machOrange,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No available manufacturing units registered yet in ${widget.locationName}. Switch location to Coimbatore or Tiruppur to view active capacity.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Active Marker Detail Card Popup
          if (_activeMarker != null)
            Positioned(
              left: 14,
              right: 14,
              bottom: 14,
              child: _buildMarkerDetailCard(_activeMarker!),
            ),
        ],
      ),
    );
  }

  // Note: On Windows Desktop, rendering is delegated to the standalone
  // WindowsMapFallback widget below to ensure GoogleMap is never instantiated.

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.secondarySlate,
          ),
        ),
      ],
    );
  }

  Widget _buildMarkerDetailCard(MachMapMarker marker) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.machBlue.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            marker.title,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (marker.matchPercentage != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: AppColors.successGreen.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              '${marker.matchPercentage}% Match',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (marker.companyName != null &&
                        marker.companyName!.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.business_rounded,
                            size: 13,
                            color: AppColors.machBlue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${marker.companyName} (${marker.city ?? widget.locationName})',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${marker.industry ?? marker.category} • Provider: ${marker.subtitle}',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondarySlate,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        '${marker.subtitle} • ${marker.category}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondarySlate,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.mutedSlate,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => setState(() => _activeMarker = null),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '₹${marker.hourlyPrice.toInt()}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  Text(
                    ' / hr',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                  if (marker.distanceKm != null) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.near_me_outlined,
                            size: 11,
                            color: AppColors.machBlue,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${marker.distanceKm!.toStringAsFixed(1)} km',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    tooltip: 'Open in Google Maps',
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    constraints: const BoxConstraints(),
                    color: AppColors.machBlue,
                    onPressed: () => _openGoogleMaps(marker: marker),
                  ),
                  const SizedBox(width: 6),
                  if (widget.onCompareCapacity != null)
                    MachButton(
                      label: 'Compare',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: () => widget.onCompareCapacity?.call(marker),
                    ),
                  if (widget.onBookCapacity != null) ...[
                    const SizedBox(width: 8),
                    MachButton(
                      label: 'Book Capacity',
                      variant: MachButtonVariant.accent,
                      size: MachButtonSize.small,
                      onPressed: () => widget.onBookCapacity?.call(marker),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState() {
    return Container(
      color: AppColors.lightSurface,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.map_outlined,
              size: 40,
              color: AppColors.mutedSlate,
            ),
            const SizedBox(height: 12),
            Text(
              'Map Unavailable',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Interactive map could not load. Manufacturing capacity cards remain fully available below.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dedicated, platform-safe Windows fallback for Mach-Hunt Manufacturing Marketplace.
///
/// CRITICAL ARCHITECTURAL GUARANTEE:
/// On Windows desktop, GoogleMap widget is NEVER instantiated.
/// This widget provides the full capacity count, real-time industrial cluster data,
/// direct browser links to actual Google Maps coordinates, and interactive capacity booking.
class WindowsMapFallback extends StatefulWidget {
  final double height;
  final String locationName;
  final List<MachMapMarker> markers;
  final String? selectedMarkerId;
  final ValueChanged<MachMapMarker>? onMarkerSelected;
  final ValueChanged<MachMapMarker>? onBookCapacity;
  final ValueChanged<MachMapMarker>? onCompareCapacity;
  final bool isLoading;
  final void Function(MachMapMarker?) onOpenGoogleMaps;

  const WindowsMapFallback({
    super.key,
    required this.height,
    required this.locationName,
    required this.markers,
    this.selectedMarkerId,
    this.onMarkerSelected,
    this.onBookCapacity,
    this.onCompareCapacity,
    this.isLoading = false,
    required this.onOpenGoogleMaps,
  });

  @override
  State<WindowsMapFallback> createState() => _WindowsMapFallbackState();
}

class _WindowsMapFallbackState extends State<WindowsMapFallback> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _listSectionKey = GlobalKey();
  MachMapMarker? _selectedMarker;

  @override
  void initState() {
    super.initState();
    _syncSelectedMarker();
  }

  @override
  void didUpdateWidget(covariant WindowsMapFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMarkerId != widget.selectedMarkerId ||
        oldWidget.markers != widget.markers) {
      _syncSelectedMarker();
    }
  }

  void _syncSelectedMarker() {
    if (widget.selectedMarkerId != null) {
      try {
        _selectedMarker = widget.markers.firstWhere(
          (m) => m.id == widget.selectedMarkerId,
        );
      } catch (_) {
        _selectedMarker = null;
      }
    } else if (_selectedMarker != null &&
        !widget.markers.any((m) => m.id == _selectedMarker!.id)) {
      _selectedMarker = null;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCapacityList() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        220.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.markers.length;

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
      child: widget.isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.machOrange),
                  SizedBox(height: 12),
                  Text(
                    'Loading Manufacturing Capacity...',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            )
          : Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Header Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                      decoration: const BoxDecoration(
                        color: AppColors.softSurface,
                        border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
                      ),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.precision_manufacturing_rounded,
                                size: 18,
                                color: AppColors.machOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Capacity in ${widget.locationName}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.machBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: AppColors.machBlue.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  '$count Units',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.machBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            onPressed: () => widget.onOpenGoogleMaps(null),
                            icon: const Icon(Icons.open_in_new_rounded, size: 14),
                            label: const Text('Open in Google Maps'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.machBlue,
                              side: const BorderSide(color: AppColors.lightBorder),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              textStyle: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Exact User Specified Hero Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
                      decoration: const BoxDecoration(
                        color: AppColors.lightSurface,
                        border: Border(bottom: BorderSide(color: AppColors.lightBorder)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Manufacturing Capacity',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Interactive map is available in\nChrome, Android and iOS.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.secondarySlate,
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.machOrange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.machOrange.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                '$count Capacity Units',
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.machOrange,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _scrollToCapacityList,
                                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                                  label: const Text('View Capacity List'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryNavy,
                                    side: const BorderSide(color: AppColors.primaryNavy, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => widget.onOpenGoogleMaps(null),
                                  icon: const Icon(Icons.location_on_rounded, size: 16),
                                  label: const Text('Open in Google Maps'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.machBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    textStyle: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Real Capacity Records List
                    Container(
                      key: _listSectionKey,
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Available Capacity in ${widget.locationName}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                              Text(
                                'Capacity in ${widget.locationName} — $count Units',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (widget.markers.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No capacity registered in ${widget.locationName} yet. Select Coimbatore or Tiruppur.',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.secondarySlate,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.markers.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final m = widget.markers[index];
                                final isSelected = _selectedMarker?.id == m.id;
                                return _buildRecordCard(m, isSelected);
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildRecordCard(MachMapMarker m, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() => _selectedMarker = m);
        widget.onMarkerSelected?.call(m);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.softSurface : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.machBlue : AppColors.lightBorder,
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.06 : 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Company Name + Match badge / Availability badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.companyName ?? m.subtitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capacity/Process: ${m.title} (${m.category})',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.machBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (m.matchPercentage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${m.matchPercentage}% Match',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: (m.isAvailable ? AppColors.successGreen : AppColors.mutedSlate)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        m.isAvailable ? 'Available' : 'Booked',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: m.isAvailable ? AppColors.successGreen : AppColors.mutedSlate,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Metadata Row: Industry, Provider, Address, Coordinates
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                if (m.industry != null && m.industry!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category_outlined, size: 13, color: AppColors.secondarySlate),
                      const SizedBox(width: 4),
                      Text(
                        m.industry!,
                        style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.secondarySlate),
                      ),
                    ],
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.business_outlined, size: 13, color: AppColors.secondarySlate),
                    const SizedBox(width: 4),
                    Text(
                      'Provider: ${m.subtitle}',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.secondarySlate),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_city_outlined, size: 13, color: AppColors.secondarySlate),
                    const SizedBox(width: 4),
                    Text(
                      m.city ?? widget.locationName,
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.secondarySlate),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pin_drop_outlined, size: 13, color: AppColors.secondarySlate),
                    const SizedBox(width: 4),
                    Text(
                      '${m.latitude.toStringAsFixed(4)}, ${m.longitude.toStringAsFixed(4)}',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.secondarySlate),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Bottom Row: Rate + Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '₹${m.hourlyPrice.toInt()}/hr',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryNavy,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Open in Google Maps using real company link
                    OutlinedButton.icon(
                      onPressed: () => widget.onOpenGoogleMaps(m),
                      icon: const Icon(Icons.open_in_new_rounded, size: 13),
                      label: const Text('Open in Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.machBlue,
                        side: const BorderSide(color: AppColors.lightBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        textStyle: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (widget.onCompareCapacity != null) ...[
                      OutlinedButton(
                        onPressed: () => widget.onCompareCapacity?.call(m),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.secondarySlate,
                          side: const BorderSide(color: AppColors.lightBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          textStyle: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Compare'),
                      ),
                    ],
                    if (widget.onBookCapacity != null) ...[
                      MachButton(
                        label: 'Book Capacity',
                        variant: MachButtonVariant.accent,
                        size: MachButtonSize.small,
                        onPressed: () => widget.onBookCapacity?.call(m),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

