import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_badges.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/models/match_model.dart';

typedef MachineCard = MachMachineCard;

class MachMachineCard extends StatelessWidget {
  final String name;
  final String category;
  final String? manufacturer;
  final String? model;
  final int? year;
  final double hourlyPrice;
  final String? location;
  final String? dimensions;
  final String? tolerance;
  final String status;
  final bool isVerified;
  final double? rating;
  final int? utilizationPercentage;
  final List<MachineCapabilityModel> capabilities;
  final String? companyName;
  final String? industry;
  final String? googleMapsLink;
  final VoidCallback? onManageAvailability;
  final VoidCallback? onEdit;
  final VoidCallback? onViewDetails;

  const MachMachineCard({
    super.key,
    required this.name,
    required this.category,
    this.manufacturer,
    this.model,
    this.year,
    required this.hourlyPrice,
    this.location,
    this.dimensions,
    this.tolerance,
    this.status = 'AVAILABLE',
    this.isVerified = false,
    this.rating,
    this.utilizationPercentage,
    this.capabilities = const [],
    this.companyName,
    this.industry,
    this.googleMapsLink,
    this.onManageAvailability,
    this.onEdit,
    this.onViewDetails,
  });

  factory MachMachineCard.fromModel({
    Key? key,
    required MachineModel machine,
    VoidCallback? onEdit,
    VoidCallback? onManageAvailability,
    VoidCallback? onViewDetails,
  }) {
    return MachMachineCard(
      key: key,
      name: machine.name,
      category: machine.category,
      manufacturer: machine.manufacturer,
      model: machine.model,
      year: machine.year,
      hourlyPrice: machine.hourlyPrice,
      location: machine.locationAddress,
      dimensions: machine.dimensionsCapacity,
      tolerance: machine.precisionTolerance,
      status: machine.normalizedStatus,
      isVerified: machine.isVerified,
      rating: machine.averageRating,
      utilizationPercentage: machine.utilizationPercentage,
      capabilities: machine.capabilities,
      companyName: machine.companyName,
      industry: machine.industry,
      googleMapsLink: machine.googleMapsLink,
      onEdit: onEdit,
      onManageAvailability: onManageAvailability,
      onViewDetails: onViewDetails,
    );
  }

  String? _buildSubtitle() {
    final mfg = manufacturer?.trim() ?? '';
    final mdl = model?.trim() ?? '';
    final parts = <String>[];

    if (mfg.isNotEmpty && mdl.isNotEmpty) {
      if (mdl.toLowerCase().startsWith(mfg.toLowerCase())) {
        parts.add(mdl);
      } else {
        parts.add('$mfg $mdl');
      }
    } else if (mfg.isNotEmpty) {
      parts.add(mfg);
    } else if (mdl.isNotEmpty) {
      parts.add(mdl);
    }

    if (year != null && year! > 1900) {
      if (parts.isNotEmpty) {
        return '${parts.join(' ')} ($year)';
      }
      return '$year';
    }

    return parts.isEmpty ? null : parts.join(' ');
  }

  List<String> _buildCapabilityLabels() {
    final seen = <String>{};
    final labels = <String>[];

    for (final cap in capabilities) {
      final mat = cap.material.trim();
      final proc = cap.process.trim();
      String label = '';
      if (mat.isNotEmpty && proc.isNotEmpty) {
        label = '$mat • $proc';
      } else if (mat.isNotEmpty) {
        label = mat;
      } else if (proc.isNotEmpty) {
        label = proc;
      }
      if (label.isNotEmpty && seen.add(label.toLowerCase())) {
        labels.add(label);
      }
    }

    if (labels.isEmpty && category.trim().isNotEmpty) {
      labels.add(category.trim());
    }

    return labels;
  }

  String _formatRating(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  ({IconData icon, Color color, String label}) _resolveStatusVisuals() {
    final upper = status.toUpperCase();
    if (upper == 'AVAILABLE' || upper == 'ACTIVE') {
      return (
        icon: Icons.check_circle_rounded,
        color: AppColors.emerald,
        label: 'Available for Rent',
      );
    } else if (upper == 'BUSY') {
      return (
        icon: Icons.timelapse_rounded,
        color: AppColors.amberWarm,
        label: 'Busy',
      );
    } else if (upper == 'MAINTENANCE') {
      return (
        icon: Icons.build_circle_outlined,
        color: AppColors.slate600,
        label: 'Maintenance',
      );
    } else {
      return (
        icon: Icons.power_settings_new_rounded,
        color: AppColors.slate500,
        label: 'Offline',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();
    final capabilityLabels = _buildCapabilityLabels();
    final visibleChips = capabilityLabels.take(3).toList();
    final extraChipCount = capabilityLabels.length - visibleChips.length;
    final statusVisual = _resolveStatusVisuals();
    final hasLocation = location != null && location!.trim().isNotEmpty;
    final hasRating = rating != null && rating! > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Upper Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP ROW: Category Badge + Verified Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.slate100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.slate200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          category.trim().isNotEmpty
                              ? category.toUpperCase()
                              : 'MACHINE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: AppColors.emerald,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.emeraldDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // 2. MACHINE TITLE & SUBTITLE
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.28,
                    color: AppColors.navyIndustrial,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
                const SizedBox(height: 8),

                // 2.5 REAL-WORLD INDUSTRIAL FACILITY (DEMO CAPACITY)
                if (companyName != null && companyName!.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.business_rounded,
                        size: 14,
                        color: AppColors.machBlue,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '$companyName • ${industry ?? category}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],

                // 3. LOCATION + RATING ROW
                if (hasLocation || hasRating) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasLocation)
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: AppColors.slate500,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  location!.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.slate600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const Spacer(),
                      if (hasRating) ...[
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatRating(rating!),
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.navyIndustrial,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // 4. CAPABILITY CHIPS
                if (visibleChips.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final chipLabel in visibleChips)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.slate50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.slate200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            chipLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate700,
                            ),
                          ),
                        ),
                      if (extraChipCount > 0)
                        Tooltip(
                          message: capabilityLabels.skip(3).join(', '),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4.5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.slate100,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.slate200,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '+$extraChipCount more',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],

                // 5. AVAILABILITY + UTILIZATION ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusVisual.icon,
                            size: 15,
                            color: statusVisual.color,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              statusVisual.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: statusVisual.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (utilizationPercentage != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '$utilizationPercentage% Utilization',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // 6. BOTTOM SECTION: Visually Separated Footer
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Divider(height: 1, color: AppColors.slate200),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Left: SLOT RATE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'SLOT RATE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.slate400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.currency(hourlyPrice)}/hr',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                      ],
                    ),

                    // Right: Edit + Availability + Google Maps Action Buttons
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (googleMapsLink != null &&
                            googleMapsLink!.isNotEmpty) ...[
                          _CardActionIconButton(
                            tooltip: 'Open in Google Maps',
                            icon: Icons.map_outlined,
                            onPressed: () async {
                              final uri = Uri.parse(googleMapsLink!);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (onEdit != null)
                          _CardActionIconButton(
                            tooltip: 'Edit machine',
                            icon: Icons.edit_outlined,
                            onPressed: onEdit!,
                          ),
                        if (onEdit != null && onManageAvailability != null)
                          const SizedBox(width: 8),
                        if (onManageAvailability != null)
                          _CardActionIconButton(
                            tooltip: 'Manage availability',
                            icon: Icons.calendar_today_outlined,
                            onPressed: onManageAvailability!,
                          ),
                        if (onEdit == null && onViewDetails != null) ...[
                          const SizedBox(width: 8),
                          MachButton(
                            label: 'Details',
                            variant: MachButtonVariant.primary,
                            size: MachButtonSize.small,
                            onPressed: onViewDetails,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardActionIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  const _CardActionIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          hoverColor: AppColors.slate100,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.slate200, width: 1),
            ),
            child: Icon(icon, size: 17, color: AppColors.slate700),
          ),
        ),
      ),
    );
  }
}

typedef CapacityMatchCard = MachMatchCard;

class MachMatchCard extends StatefulWidget {
  final int matchPercentage;
  final String businessName;
  final String machineName;
  final String machineCategory;
  final String? manufacturer;
  final String? model;
  final int? year;
  final String locationAddress;
  final double hourlyPrice;
  final double capabilityScore;
  final double availabilityScore;
  final double distanceScore;
  final double costScore;
  final double reliabilityScore;
  final double distanceKm;
  final List<String> matchReasons;
  final List<MachineCapabilityModel> capabilities;
  final bool isVerified;
  final bool operatorAvailable;
  final String status;
  final double? rating;
  final int? completedJobs;
  final String? companyName;
  final String? industry;
  final String? googleMapsLink;
  final bool isSelectedForComparison;
  final ValueChanged<bool?>? onToggleComparison;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBook;

  const MachMatchCard({
    super.key,
    required this.matchPercentage,
    required this.businessName,
    required this.machineName,
    required this.machineCategory,
    this.manufacturer,
    this.model,
    this.year,
    required this.locationAddress,
    required this.hourlyPrice,
    required this.capabilityScore,
    required this.availabilityScore,
    required this.distanceScore,
    required this.costScore,
    required this.reliabilityScore,
    required this.distanceKm,
    required this.matchReasons,
    this.capabilities = const [],
    this.isVerified = false,
    this.operatorAvailable = false,
    this.status = 'ACTIVE',
    this.rating,
    this.completedJobs,
    this.companyName,
    this.industry,
    this.googleMapsLink,
    this.isSelectedForComparison = false,
    this.onToggleComparison,
    this.onViewDetails,
    this.onBook,
  });

  factory MachMatchCard.fromMatch({
    Key? key,
    required MatchResultModel match,
    bool isSelectedForComparison = false,
    ValueChanged<bool?>? onToggleComparison,
    VoidCallback? onViewDetails,
    VoidCallback? onBook,
  }) {
    return MachMatchCard(
      key: key,
      matchPercentage: match.matchPercentage,
      businessName: match.businessName,
      machineName: match.machineName,
      machineCategory: match.machineCategory,
      manufacturer: match.manufacturer,
      model: match.model,
      year: match.year,
      locationAddress: match.locationAddress,
      hourlyPrice: match.hourlyPrice,
      capabilityScore: match.scoreBreakdown.capabilityScore,
      availabilityScore: match.scoreBreakdown.availabilityScore,
      distanceScore: match.scoreBreakdown.distanceScore,
      costScore: match.scoreBreakdown.costScore,
      reliabilityScore: match.scoreBreakdown.reliabilityScore,
      distanceKm: match.scoreBreakdown.distanceKm,
      matchReasons: match.matchReasons,
      capabilities: match.capabilities,
      isVerified: match.isVerified,
      operatorAvailable: match.operatorAvailable,
      status: match.status,
      rating: match.averageRating,
      completedJobs: match.completedJobs,
      companyName: match.companyName,
      industry: match.industry,
      googleMapsLink: match.googleMapsLink,
      isSelectedForComparison: isSelectedForComparison,
      onToggleComparison: onToggleComparison,
      onViewDetails: onViewDetails,
      onBook: onBook,
    );
  }

  @override
  State<MachMatchCard> createState() => _MachMatchCardState();
}

class _MachMatchCardState extends State<MachMatchCard> {
  bool _showScoreBreakdown = false;

  String? _buildSubtitle() {
    final mfg = widget.manufacturer?.trim() ?? '';
    final mdl = widget.model?.trim() ?? '';
    final parts = <String>[];

    if (mfg.isNotEmpty && mdl.isNotEmpty) {
      if (mdl.toLowerCase().startsWith(mfg.toLowerCase())) {
        parts.add(mdl);
      } else {
        parts.add('$mfg $mdl');
      }
    } else if (mfg.isNotEmpty) {
      parts.add(mfg);
    } else if (mdl.isNotEmpty) {
      parts.add(mdl);
    }

    if (widget.year != null && widget.year! > 1900) {
      if (parts.isNotEmpty) {
        return '${parts.join(' ')} (${widget.year})';
      }
      return '${widget.year}';
    }

    return parts.isEmpty ? null : parts.join(' ');
  }

  List<String> _buildCapabilityLabels() {
    final seen = <String>{};
    final labels = <String>[];

    for (final cap in widget.capabilities) {
      final mat = cap.material.trim();
      final proc = cap.process.trim();
      String label = '';
      if (mat.isNotEmpty && proc.isNotEmpty) {
        label = '$mat • $proc';
      } else if (mat.isNotEmpty) {
        label = mat;
      } else if (proc.isNotEmpty) {
        label = proc;
      }
      if (label.isNotEmpty && seen.add(label.toLowerCase())) {
        labels.add(label);
      }
    }

    if (labels.isEmpty && widget.machineCategory.trim().isNotEmpty) {
      labels.add(widget.machineCategory.trim());
    }

    return labels;
  }

  String _formatRating(double val) {
    if (val == val.roundToDouble()) {
      return val.toInt().toString();
    }
    return val.toStringAsFixed(1);
  }

  ({IconData icon, Color color, String label}) _resolveStatusVisuals() {
    if (widget.operatorAvailable) {
      return (
        icon: Icons.verified_user_outlined,
        color: AppColors.successGreen,
        label: 'Certified Operator',
      );
    }
    final upper = widget.status.toUpperCase();
    if (upper == 'AVAILABLE' || upper == 'ACTIVE') {
      return (
        icon: Icons.check_circle_rounded,
        color: AppColors.successGreen,
        label: 'Available for Rent',
      );
    } else if (upper == 'BUSY') {
      return (
        icon: Icons.timelapse_rounded,
        color: AppColors.warmAmber,
        label: 'Busy',
      );
    } else {
      return (
        icon: Icons.check_circle_rounded,
        color: AppColors.successGreen,
        label: 'Available Capacity',
      );
    }
  }

  Widget _buildScoreRow(String label, int earned, int maxPoints) {
    final ratio = maxPoints > 0 ? (earned / maxPoints).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.secondarySlate,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 5,
                backgroundColor: AppColors.lightBorder,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ratio >= 0.85 ? AppColors.successGreen : AppColors.machBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '$earned/$maxPoints',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _buildSubtitle();
    final capabilityLabels = _buildCapabilityLabels();
    final visibleChips = capabilityLabels.take(3).toList();
    final extraChipCount = capabilityLabels.length - visibleChips.length;
    final statusVisual = _resolveStatusVisuals();
    final hasLocation = widget.locationAddress.trim().isNotEmpty;
    final hasRating = widget.rating != null && widget.rating! > 0;
    final hasJobs = widget.completedJobs != null && widget.completedJobs! > 0;
    final isTopMatch = widget.matchPercentage >= 85;

    final matchColor = isTopMatch
        ? AppColors.successGreen
        : (widget.matchPercentage >= 70
              ? AppColors.machBlue
              : AppColors.warmAmber);
    final matchBg = isTopMatch
        ? const Color(0xFFDCFCE7)
        : (widget.matchPercentage >= 70
              ? const Color(0xFFEFF6FF)
              : const Color(0xFFFEF3C7));

    final capPoints =
        (widget.capabilityScore <= 1.0
                ? widget.capabilityScore * 40
                : widget.capabilityScore)
            .round()
            .clamp(0, 40);
    final availPoints =
        (widget.availabilityScore <= 1.0
                ? widget.availabilityScore * 20
                : widget.availabilityScore)
            .round()
            .clamp(0, 20);
    final distPoints =
        (widget.distanceScore <= 1.0
                ? widget.distanceScore * 15
                : widget.distanceScore)
            .round()
            .clamp(0, 15);
    final costPoints =
        (widget.costScore <= 1.0 ? widget.costScore * 15 : widget.costScore)
            .round()
            .clamp(0, 15);
    final relPoints =
        (widget.reliabilityScore <= 1.0
                ? widget.reliabilityScore * 10
                : widget.reliabilityScore)
            .round()
            .clamp(0, 10);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isSelectedForComparison
              ? AppColors.machBlue
              : AppColors.lightBorder,
          width: widget.isSelectedForComparison ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Upper Card Content
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP ROW: Category Badge + Verified Unit Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.lightBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.machineCategory.trim().isNotEmpty
                              ? widget.machineCategory.toUpperCase()
                              : 'MACHINE',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.successGreen.withValues(
                              alpha: 0.3,
                            ),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_rounded,
                              size: 13,
                              color: AppColors.successGreen,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Verified Unit',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // 2. MACHINE NAME + SUBTITLE (LEFT) AND PROMINENT MATCH SCORE (RIGHT)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tooltip(
                            message: widget.machineName,
                            child: InkWell(
                              onTap: widget.onViewDetails,
                              borderRadius: BorderRadius.circular(4),
                              child: Text(
                                widget.machineName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  height: 1.25,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.secondarySlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Match Score Badge
                    Tooltip(
                      message:
                          'Match score calculated across Capability (40%), Availability (20%), Distance (15%), Cost (15%), and Reliability (10%). Click "Why this match?" for details.',
                      child: InkWell(
                        onTap: () => setState(
                          () => _showScoreBreakdown = !_showScoreBreakdown,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: matchBg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: matchColor.withValues(alpha: 0.35),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.matchPercentage}%',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.05,
                                  color: matchColor,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Match',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: matchColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. PROVIDER + LOCATION + DISTANCE
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softSurface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.lightBorder,
                      width: 0.8,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.companyName != null &&
                          widget.companyName!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.business_rounded,
                              size: 14,
                              color: AppColors.machBlue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '${widget.companyName!} (${widget.industry ?? "Industrial Facility"})',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Marketplace Provider: ${widget.businessName}',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.domain_rounded,
                              size: 14,
                              color: AppColors.machBlue,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.businessName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (hasLocation || widget.distanceKm > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (hasLocation)
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on_outlined,
                                      size: 13.5,
                                      color: AppColors.mutedSlate,
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        widget.locationAddress.trim(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.mutedSlate,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              const Spacer(),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.lightBorder,
                                ),
                              ),
                              child: Text(
                                Formatters.distance(widget.distanceKm),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondarySlate,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. CAPABILITY CHIPS
                if (visibleChips.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final chipLabel in visibleChips)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.5,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.softSurface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            chipLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondarySlate,
                            ),
                          ),
                        ),
                      if (extraChipCount > 0)
                        Tooltip(
                          message: capabilityLabels.skip(3).join(', '),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7.5,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softSurface,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.lightBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '+$extraChipCount more',
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.mutedSlate,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // 5. OPERATOR / AVAILABILITY + RATING ROW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusVisual.icon,
                            size: 14.5,
                            color: statusVisual.color,
                          ),
                          const SizedBox(width: 4.5),
                          Flexible(
                            child: Text(
                              statusVisual.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: statusVisual.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasRating) ...[
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 15,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 3),
                          Text(
                            _formatRating(widget.rating!),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                          if (hasJobs) ...[
                            const SizedBox(width: 3),
                            Text(
                              '(${widget.completedJobs} jobs)',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.mutedSlate,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),

                // 6. OPTIONAL EXPANDABLE "Why this match?" SECTION
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => setState(
                    () => _showScoreBreakdown = !_showScoreBreakdown,
                  ),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showScoreBreakdown
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.info_outline_rounded,
                          size: 13.5,
                          color: AppColors.machBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showScoreBreakdown
                              ? 'Hide match breakdown'
                              : 'Why this match?',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.machBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showScoreBreakdown) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.softSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScoreRow('Capability', capPoints, 40),
                        _buildScoreRow('Availability', availPoints, 20),
                        _buildScoreRow('Distance', distPoints, 15),
                        _buildScoreRow('Cost', costPoints, 15),
                        _buildScoreRow('Reliability', relPoints, 10),
                        if (widget.matchReasons.isNotEmpty) ...[
                          const Divider(
                            height: 12,
                            color: AppColors.lightBorder,
                          ),
                          for (final reason in widget.matchReasons.take(3))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 3),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_rounded,
                                    size: 12.5,
                                    color: AppColors.successGreen,
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.secondarySlate,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 7. FOOTER: SLOT RATE + COMPARE + BOOK CAPACITY
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Divider(height: 1, color: AppColors.lightBorder),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'SLOT RATE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.mutedSlate,
                          ),
                        ),
                        Text(
                          '${Formatters.currency(widget.hourlyPrice)}/hr',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    if (widget.onToggleComparison != null ||
                        widget.onBook != null) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (widget.googleMapsLink != null &&
                              widget.googleMapsLink!.isNotEmpty) ...[
                            Tooltip(
                              message: 'Open in Google Maps',
                              child: InkWell(
                                onTap: () async {
                                  final uri = Uri.parse(widget.googleMapsLink!);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.lightBorder,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.map_outlined,
                                    size: 16,
                                    color: AppColors.machBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          if (widget.onToggleComparison != null) ...[
                            Expanded(
                              flex: 4,
                              child: Tooltip(
                                message: widget.isSelectedForComparison
                                    ? 'Remove from comparison'
                                    : 'Add to comparison',
                                child: InkWell(
                                  onTap: () => widget.onToggleComparison!(
                                    !widget.isSelectedForComparison,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    height: 38,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.isSelectedForComparison
                                          ? AppColors.machBlue.withValues(
                                              alpha: 0.1,
                                            )
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: widget.isSelectedForComparison
                                            ? AppColors.machBlue
                                            : AppColors.lightBorder,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          widget.isSelectedForComparison
                                              ? Icons.check_box_rounded
                                              : Icons.compare_arrows_rounded,
                                          size: 14.5,
                                          color: widget.isSelectedForComparison
                                              ? AppColors.machBlue
                                              : AppColors.secondarySlate,
                                        ),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            'Compare',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  widget.isSelectedForComparison
                                                  ? AppColors.machBlue
                                                  : AppColors.primaryNavy,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (widget.onBook != null) const SizedBox(width: 8),
                          ],
                          if (widget.onBook != null)
                            Expanded(
                              flex: 6,
                              child: SizedBox(
                                height: 38,
                                child: ElevatedButton(
                                  onPressed: widget.onBook,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.machBlue,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Book Capacity',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MachBookingCard extends StatelessWidget {
  final String bookingId;
  final String requirementTitle;
  final String machineName;
  final String partnerName;
  final String status;
  final double totalAmount;
  final String startDate;
  final String endDate;
  final double totalHours;
  final String? escrowStatus;
  final bool isProvider;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onConfirmEscrow;
  final VoidCallback? onStartProduction;
  final VoidCallback? onComplete;
  final VoidCallback? onReview;

  const MachBookingCard({
    super.key,
    required this.bookingId,
    required this.requirementTitle,
    required this.machineName,
    required this.partnerName,
    required this.status,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.totalHours,
    this.escrowStatus,
    this.isProvider = false,
    this.onAccept,
    this.onReject,
    this.onConfirmEscrow,
    this.onStartProduction,
    this.onComplete,
    this.onReview,
  });

  int get _stepIndex {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'REQUESTED':
        return 0;
      case 'ACCEPTED':
        return 1;
      case 'CONFIRMED':
        return 2;
      case 'IN_PROGRESS':
        return 3;
      case 'COMPLETED':
        return 4;
      default:
        return 0;
    }
  }

  Widget _buildStep(String label, int stepIdx, int currentIdx) {
    final isDone = currentIdx > stepIdx;
    final isCurrent = currentIdx == stepIdx;

    Color nodeColor = AppColors.slate300;
    Color textColor = AppColors.slate400;

    if (isDone) {
      nodeColor = AppColors.emerald;
      textColor = AppColors.emerald;
    } else if (isCurrent) {
      nodeColor = AppColors.steelBlue;
      textColor = AppColors.navyIndustrial;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isDone || isCurrent ? nodeColor : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor, width: 2),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : (isCurrent
                      ? Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        )
                      : null),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _stepIndex;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'ORDER #${bookingId.substring(0, bookingId.length > 8 ? 8 : bookingId.length).toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    MachStatusBadge(status: status),
                  ],
                ),
                Text(
                  Formatters.currency(totalAmount),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navyIndustrial,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.slate200),

          // Booking Lifecycle Progress Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCTION LIFECYCLE',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStep('REQUESTED', 0, currentStep),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: currentStep > 0
                            ? AppColors.emerald
                            : AppColors.slate200,
                      ),
                    ),
                    _buildStep('ACCEPTED', 1, currentStep),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: currentStep > 1
                            ? AppColors.emerald
                            : AppColors.slate200,
                      ),
                    ),
                    _buildStep('CONFIRMED', 2, currentStep),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: currentStep > 2
                            ? AppColors.emerald
                            : AppColors.slate200,
                      ),
                    ),
                    _buildStep('IN PRODUCTION', 3, currentStep),
                    Expanded(
                      child: Container(
                        height: 2,
                        color: currentStep > 3
                            ? AppColors.emerald
                            : AppColors.slate200,
                      ),
                    ),
                    _buildStep('COMPLETED', 4, currentStep),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.slate200),

          // Details Grid
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        requirementTitle,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.navyIndustrial,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Machine: $machineName',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate600,
                        ),
                      ),
                      Text(
                        '${isProvider ? "Buyer" : "Provider"}: $partnerName',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalHours hours planned',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dates: $startDate to $endDate',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        color: AppColors.slate500,
                      ),
                    ),
                    if (escrowStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Escrow: $escrowStatus',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.emerald,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (onAccept != null ||
              onReject != null ||
              onConfirmEscrow != null ||
              onStartProduction != null ||
              onComplete != null ||
              onReview != null) ...[
            const Divider(height: 1, color: AppColors.slate200),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null) ...[
                    MachButton(
                      label: 'Decline',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: onReject,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (onAccept != null) ...[
                    MachButton(
                      label: 'Accept Order',
                      icon: Icons.check,
                      variant: MachButtonVariant.primary,
                      size: MachButtonSize.small,
                      onPressed: onAccept,
                    ),
                  ],
                  if (onConfirmEscrow != null) ...[
                    MachButton(
                      label: 'Fund Escrow & Confirm',
                      icon: Icons.lock_outline,
                      variant: MachButtonVariant.accent,
                      size: MachButtonSize.small,
                      onPressed: onConfirmEscrow,
                    ),
                  ],
                  if (onStartProduction != null) ...[
                    MachButton(
                      label: 'Start Production',
                      icon: Icons.play_arrow,
                      variant: MachButtonVariant.secondary,
                      size: MachButtonSize.small,
                      onPressed: onStartProduction,
                    ),
                  ],
                  if (onComplete != null) ...[
                    MachButton(
                      label: 'Mark Completed',
                      icon: Icons.check_circle_outline,
                      variant: MachButtonVariant.primary,
                      size: MachButtonSize.small,
                      onPressed: onComplete,
                    ),
                  ],
                  if (onReview != null) ...[
                    MachButton(
                      label: 'Rate & Review',
                      icon: Icons.star_outline,
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: onReview,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
