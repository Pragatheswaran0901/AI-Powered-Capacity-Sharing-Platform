import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_badges.dart';

class MachMachineCard extends StatelessWidget {
  final String name;
  final String category;
  final String? manufacturer;
  final String? model;
  final double hourlyPrice;
  final String? location;
  final String? dimensions;
  final String? tolerance;
  final String status;
  final bool isVerified;
  final VoidCallback? onManageAvailability;
  final VoidCallback? onEdit;
  final VoidCallback? onViewDetails;

  const MachMachineCard({
    super.key,
    required this.name,
    required this.category,
    this.manufacturer,
    this.model,
    required this.hourlyPrice,
    this.location,
    this.dimensions,
    this.tolerance,
    this.status = 'AVAILABLE',
    this.isVerified = true,
    this.onManageAvailability,
    this.onEdit,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200, width: 1),
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
        children: [
          // Top bar with category and status
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MachBadge(
                      label: category,
                      icon: Icons.precision_manufacturing_outlined,
                      backgroundColor: AppColors.slate100,
                      textColor: AppColors.navyIndustrial,
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 8),
                      const MachVerifiedBadge(label: 'Verified Machine', isCompact: true),
                    ],
                  ],
                ),
                MachStatusBadge(status: status),
              ],
            ),
          ),

          // Main Machine Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyIndustrial,
                  ),
                ),
                if (manufacturer != null || model != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${manufacturer ?? ""} ${model ?? ""}'.trim(),
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Specs Grid
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate200.withValues(alpha: 0.7), width: 1),
                  ),
                  child: Row(
                    children: [
                      if (tolerance != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('TOLERANCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400)),
                              const SizedBox(height: 2),
                              Text(tolerance!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial)),
                            ],
                          ),
                        ),
                      ],
                      if (dimensions != null) ...[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ENVELOPE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400)),
                              const SizedBox(height: 2),
                              Text(dimensions!, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial)),
                            ],
                          ),
                        ),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HOURLY RATE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400)),
                            const SizedBox(height: 2),
                            Text('${Formatters.currency(hourlyPrice)}/hr', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.steelBlue)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.slate200),

          // Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (location != null)
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.slate400),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.slate500),
                          ),
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onManageAvailability != null)
                      MachButton(
                        label: 'Availability',
                        icon: Icons.calendar_month_outlined,
                        variant: MachButtonVariant.outline,
                        size: MachButtonSize.small,
                        onPressed: onManageAvailability,
                      ),
                    if (onViewDetails != null) ...[
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
    );
  }
}

class MachMatchCard extends StatelessWidget {
  final int matchPercentage;
  final String businessName;
  final String machineName;
  final String machineCategory;
  final String locationAddress;
  final double hourlyPrice;
  final double capabilityScore;
  final double availabilityScore;
  final double distanceScore;
  final double costScore;
  final double reliabilityScore;
  final double distanceKm;
  final List<String> matchReasons;
  final double rating;
  final int completedJobs;
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
    required this.locationAddress,
    required this.hourlyPrice,
    required this.capabilityScore,
    required this.availabilityScore,
    required this.distanceScore,
    required this.costScore,
    required this.reliabilityScore,
    required this.distanceKm,
    required this.matchReasons,
    this.rating = 4.8,
    this.completedJobs = 14,
    this.isSelectedForComparison = false,
    this.onToggleComparison,
    this.onViewDetails,
    this.onBook,
  });

  Widget _buildDimensionBar(String label, double score, String displayValue) {
    final pct = (score * 100).clamp(0, 100).toInt();
    Color barColor = AppColors.steelBlue;
    if (pct >= 90) {
      barColor = AppColors.emerald;
    } else if (pct < 70) {
      barColor = AppColors.amberWarm;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: score.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: AppColors.slate200,
                valueColor: AlwaysStoppedAnimation<Color>(barColor),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 38,
            child: Text(
              displayValue,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyIndustrial,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTopMatch = matchPercentage >= 90;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelectedForComparison
              ? AppColors.steelBlue
              : (isTopMatch ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.slate200),
          width: isSelectedForComparison ? 2 : (isTopMatch ? 1.5 : 1),
        ),
        boxShadow: [
          BoxShadow(
            color: isTopMatch
                ? AppColors.emerald.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Match Score & Business Name
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
            decoration: BoxDecoration(
              color: isTopMatch ? const Color(0xFFF0FDF4) : AppColors.slate50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isTopMatch ? AppColors.emerald : AppColors.steelBlue,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt, color: Colors.white, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$matchPercentage% MATCH',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          const MachVerifiedBadge(label: 'Verified Business', isCompact: true),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        businessName,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyIndustrial,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            machineName,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate600,
                            ),
                          ),
                          const Text(' · ', style: TextStyle(color: AppColors.slate400)),
                          Text(
                            locationAddress,
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Price Tag
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Formatters.currency(hourlyPrice),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.steelBlue,
                      ),
                    ),
                    Text(
                      'per hour',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.slate400),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 3),
                        Text(
                          '$rating ($completedJobs jobs)',
                          style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.slate600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.slate200),

          // Body: 5-Dimension Score Bars + Why This Matches
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: 5 Deterministic Score Dimensions
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MATCH DIMENSIONS',
                            style: GoogleFonts.inter(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: AppColors.slate400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDimensionBar('Capability', capabilityScore, '${(capabilityScore * 100).toInt()}%'),
                          _buildDimensionBar('Availability', availabilityScore, '${(availabilityScore * 100).toInt()}%'),
                          _buildDimensionBar('Distance', distanceScore, '${distanceKm.toStringAsFixed(1)} km'),
                          _buildDimensionBar('Cost', costScore, '${(costScore * 100).toInt()}%'),
                          _buildDimensionBar('Reliability', reliabilityScore, '${(reliabilityScore * 100).toInt()}%'),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column: Explainable AI "Why This Matches"
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate200, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology, size: 16, color: AppColors.steelBlue),
                                const SizedBox(width: 6),
                                Text(
                                  'WHY THIS MATCHES',
                                  style: GoogleFonts.inter(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.6,
                                    color: AppColors.steelBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (matchReasons.isEmpty) ...[
                              Text('• Matches required tooling and material', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate600)),
                              Text('• Verified manufacturing capability', style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate600)),
                            ] else
                              for (var reason in matchReasons.take(4)) ...[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 14, color: AppColors.emerald),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          reason,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            height: 1.35,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.slate700,
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
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                const Divider(height: 1, color: AppColors.slate200),
                const SizedBox(height: 14),

                // Bottom Actions: Compare Checkbox + Details + Book
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onToggleComparison != null)
                      InkWell(
                        onTap: () => onToggleComparison!(!isSelectedForComparison),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: isSelectedForComparison,
                                onChanged: onToggleComparison,
                                activeColor: AppColors.steelBlue,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Compare Machine',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.navyIndustrial,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onViewDetails != null)
                          MachButton(
                            label: 'View Details',
                            variant: MachButtonVariant.outline,
                            size: MachButtonSize.medium,
                            onPressed: onViewDetails,
                          ),
                        if (onBook != null) ...[
                          const SizedBox(width: 10),
                          MachButton(
                            label: 'Book Capacity',
                            icon: Icons.flash_on_rounded,
                            variant: MachButtonVariant.accent,
                            size: MachButtonSize.medium,
                            onPressed: onBook,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
                    ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))
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
                    Expanded(child: Container(height: 2, color: currentStep > 0 ? AppColors.emerald : AppColors.slate200)),
                    _buildStep('ACCEPTED', 1, currentStep),
                    Expanded(child: Container(height: 2, color: currentStep > 1 ? AppColors.emerald : AppColors.slate200)),
                    _buildStep('CONFIRMED', 2, currentStep),
                    Expanded(child: Container(height: 2, color: currentStep > 2 ? AppColors.emerald : AppColors.slate200)),
                    _buildStep('IN PRODUCTION', 3, currentStep),
                    Expanded(child: Container(height: 2, color: currentStep > 3 ? AppColors.emerald : AppColors.slate200)),
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
                        style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Machine: $machineName',
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.slate600),
                      ),
                      Text(
                        '${isProvider ? "Buyer" : "Provider"}: $partnerName',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalHours hours planned',
                      style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dates: $startDate to $endDate',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.slate500),
                    ),
                    if (escrowStatus != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Escrow: $escrowStatus',
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.emerald),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (onAccept != null || onReject != null || onConfirmEscrow != null || onStartProduction != null || onComplete != null || onReview != null) ...[
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
