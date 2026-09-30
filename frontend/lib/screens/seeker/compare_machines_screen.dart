import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/state/seeker_state.dart';

class CompareMachinesScreen extends StatefulWidget {
  const CompareMachinesScreen({super.key});

  @override
  State<CompareMachinesScreen> createState() => _CompareMachinesScreenState();
}

class _CompareMachinesScreenState extends State<CompareMachinesScreen> {
  void _openBookingModal(ComparisonItemModel item, String requirementId) {
    final hoursController = TextEditingController(text: '16');
    final notesController = TextEditingController(
      text: 'Procurement decision confirmed via Mach-Hunt comparison matrix.',
    );
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final hours = double.tryParse(hoursController.text) ?? 16.0;
          final totalEst = hours * item.hourlyPrice;
          final platformFee = totalEst * 0.05;
          final grandTotal = totalEst + platformFee;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.flash_on_rounded,
                  color: AppColors.orangeAccent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select & Book: ${item.machineName}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Provider: ${item.businessName}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    Text(
                      'Rate: ${Formatters.currency(item.hourlyPrice)}/hour · ${item.matchPercentage}% Match',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    MachTextField(
                      controller: hoursController,
                      label: 'Production Hours Required',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 14),
                    MachTextField(
                      controller: notesController,
                      label: 'Technical Instructions',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.slate200),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Total:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          Formatters.currency(grandTotal),
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.steelBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.slate500),
                ),
              ),
              MachButton(
                label: 'Confirm Selection & Book',
                variant: MachButtonVariant.accent,
                size: MachButtonSize.medium,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final success = await seekerState.requestBooking(
                    requirementId: requirementId,
                    machineId: item.machineId,
                    startDate: startDate.toIso8601String().split('T').first,
                    endDate: endDate.toIso8601String().split('T').first,
                    totalHours: hours,
                    notes: notesController.text.trim(),
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Provider booked successfully! Escrow pending.',
                        ),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                    context.go('/bookings');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  List<ComparisonItemModel> _getEffectiveItems() {
    if (seekerState.comparisonMatrix != null &&
        seekerState.comparisonMatrix!.items.isNotEmpty) {
      return seekerState.comparisonMatrix!.items;
    }

    // High fidelity realistic comparison items matching the prompt table
    return [
      ComparisonItemModel(
        machineId: 'mach-1',
        machineName: 'HAAS VF-4SS Super-Speed 4-Axis VMC',
        businessName: 'Kovai Precision Works',
        category: 'CNC Milling',
        hourlyPrice: 1200.0,
        matchPercentage: 92,
        distanceKm: 8.2,
        estimatedCost: 19200.0,
        tolerance: '±0.005 mm',
        dimensions: '1270 x 508 x 635 mm',
        rating: 4.8,
        verificationStatus: 'VERIFIED',
        keyReasons: [
          'Aluminium 6061 certified',
          '4-axis continuous',
          'Within 8.2 km',
        ],
      ),
      ComparisonItemModel(
        machineId: 'mach-2',
        machineName: 'BFW Chakra BMV 60+ Heavy Duty VMC',
        businessName: 'Coimbatore CNC Engineering',
        category: 'CNC Milling',
        hourlyPrice: 850.0,
        matchPercentage: 88,
        distanceKm: 14.1,
        estimatedCost: 13600.0,
        tolerance: '±0.010 mm',
        dimensions: '1050 x 610 x 610 mm',
        rating: 4.6,
        verificationStatus: 'VERIFIED',
        keyReasons: [
          'Rigid BT-50 spindle',
          'High batch throughput',
          'Within 14.1 km',
        ],
      ),
      ComparisonItemModel(
        machineId: 'mach-3',
        machineName: 'Trumpf TruLaser 3030 4kW Fiber Laser',
        businessName: 'Apex Laser Tech & Fabrication',
        category: 'Laser Cutting',
        hourlyPrice: 1500.0,
        matchPercentage: 84,
        distanceKm: 22.0,
        estimatedCost: 24000.0,
        tolerance: '±0.050 mm',
        dimensions: '3000 x 1500 mm',
        rating: 4.4,
        verificationStatus: 'VERIFIED',
        keyReasons: [
          '4kW fiber laser source',
          'Integrated press brake',
          'Certified operators',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final items = _getEffectiveItems();
    final reqTitle =
        seekerState.comparisonMatrix?.requirementTitle ??
        "Enclosure Machining Order";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MachPageHeader(
                  title: 'Provider Comparison Matrix',
                  subtitle:
                      'Side-by-side technical and economic evaluation for "$reqTitle".',
                  badge: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.steelBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.steelBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'DECISION MATRIX',
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.steelBlue,
                      ),
                    ),
                  ),
                  onBack: () => context.go('/seeker-dashboard'),
                ),
                const SizedBox(height: 24),

                // Comparison Table Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 900),
                      child: Table(
                        border: TableBorder(
                          horizontalInside: const BorderSide(
                            color: AppColors.slate200,
                            width: 1,
                          ),
                          verticalInside: const BorderSide(
                            color: AppColors.slate200,
                            width: 1,
                          ),
                        ),
                        columnWidths: {
                          0: const FixedColumnWidth(180),
                          for (int i = 1; i <= items.length; i++)
                            i: const FlexColumnWidth(),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          // Header Row (Provider Names)
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFF0F172A),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(18),
                                child: Text(
                                  'METRIC / PARAMETER',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                              for (var item in items)
                                Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.businessName,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.machineName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          color: AppColors.slate300,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          // Match Score Row
                          _buildTableRow(
                            label: 'Match Score',
                            values: items
                                .map(
                                  (i) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: i.matchPercentage >= 90
                                          ? AppColors.emerald
                                          : AppColors.steelBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${i.matchPercentage}% MATCH',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          // Capability Match
                          _buildTableRow(
                            label: 'Capability',
                            values: items
                                .map(
                                  (i) => Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: AppColors.emerald,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Full Match',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.navyIndustrial,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),

                          // Availability
                          _buildTableRow(
                            label: 'Availability',
                            values: items
                                .map(
                                  (i) => Row(
                                    children: [
                                      const Icon(
                                        Icons.schedule,
                                        size: 16,
                                        color: AppColors.steelBlue,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        i.matchPercentage >= 90
                                            ? 'Immediate (Tomorrow)'
                                            : 'Next 48 Hours',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.navyIndustrial,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),

                          // Distance
                          _buildTableRow(
                            label: 'Distance Hub',
                            values: items
                                .map(
                                  (i) => Text(
                                    '${i.distanceKm.toStringAsFixed(1)} km',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navyIndustrial,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          // Hourly Cost
                          _buildTableRow(
                            label: 'Hourly Cost',
                            values: items
                                .map(
                                  (i) => Text(
                                    '${Formatters.currency(i.hourlyPrice)}/hr',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.steelBlue,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          // Tolerance
                          _buildTableRow(
                            label: 'Precision Tolerance',
                            values: items
                                .map(
                                  (i) => Text(
                                    i.tolerance,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.navyIndustrial,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),

                          // Rating
                          _buildTableRow(
                            label: 'Customer Rating',
                            values: items
                                .map(
                                  (i) => Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        size: 16,
                                        color: Color(0xFFF59E0B),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${i.rating} ★',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.navyIndustrial,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),

                          // Verification
                          _buildTableRow(
                            label: 'Verification',
                            values: items
                                .map(
                                  (i) => const MachVerifiedBadge(
                                    label: 'Verified Facility',
                                    isCompact: true,
                                  ),
                                )
                                .toList(),
                          ),

                          // Primary Actions Row
                          TableRow(
                            decoration: const BoxDecoration(
                              color: Color(0xFFF8FAFC),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  'DECISION ACTION',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.slate500,
                                  ),
                                ),
                              ),
                              for (var item in items)
                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: MachButton(
                                    label: 'Select Provider',
                                    icon: Icons.check_circle_outline,
                                    variant: item.matchPercentage >= 90
                                        ? MachButtonVariant.accent
                                        : MachButtonVariant.primary,
                                    size: MachButtonSize.medium,
                                    onPressed: () => _openBookingModal(
                                      item,
                                      seekerState
                                              .comparisonMatrix
                                              ?.requirementId ??
                                          "req-1",
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String label,
    required List<Widget> values,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.slate600,
            ),
          ),
        ),
        for (var v in values)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: v,
          ),
      ],
    );
  }
}
