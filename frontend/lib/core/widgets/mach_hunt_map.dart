import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_button.dart';

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
    this.originalData,
  });

  LatLng get position => LatLng(latitude, longitude);
}

/// Reusable Google Map Component for the Mach-Hunt Manufacturing Marketplace
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
    if (oldWidget.initialCenter != widget.initialCenter) {
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

  /// Programmatic camera movement to a coordinate
  Future<void> animateToLocation(LatLng target, {double? zoom}) async {
    if (_controller == null) return;
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
    animateToLocation(marker.position, zoom: 13.5);
    widget.onMarkerSelected?.call(marker);
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
          // 1. Google Map or Fallback
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
                        onPressed: () =>
                            _controller?.animateCamera(CameraUpdate.zoomIn()),
                      ),
                      const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        tooltip: 'Zoom Out',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () =>
                            _controller?.animateCamera(CameraUpdate.zoomOut()),
                      ),
                      const VerticalDivider(width: 1, indent: 4, endIndent: 4),
                      IconButton(
                        icon: const Icon(
                          Icons.my_location,
                          size: 16,
                          color: AppColors.machBlue,
                        ),
                        tooltip: 'Reset to City Center',
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                        onPressed: () => animateToLocation(
                          widget.initialCenter,
                          zoom: widget.initialZoom,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Loading Overlay
          if (widget.isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.machBlue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Loading capacity in ${widget.locationName}...',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 4. Empty State Badge (No capacity in location)
          if (!widget.isLoading && widget.markers.isEmpty && !_hasMapError)
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
                  color: Colors.white.withValues(alpha: 0.96),
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
                    const SizedBox(height: 2),
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
