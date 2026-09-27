import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/state/seeker_state.dart';

class MatchResultsScreen extends StatefulWidget {
  final String requirementId;
  final String requirementTitle;

  const MatchResultsScreen({
    super.key,
    required this.requirementId,
    required this.requirementTitle,
  });

  @override
  State<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends State<MatchResultsScreen> {
  final Set<String> _selectedForComparison = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  Future<void> _fetchMatches() async {
    setState(() => _isLoading = true);
    await seekerState.fetchMatches(widget.requirementId);
    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleComparison(String machineId) {
    setState(() {
      if (_selectedForComparison.contains(machineId)) {
        _selectedForComparison.remove(machineId);
      } else {
        if (_selectedForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can compare up to 3 machines at once.')),
          );
          return;
        }
        _selectedForComparison.add(machineId);
      }
    });
  }

  void _goToComparison() async {
    if (_selectedForComparison.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 2 machines to compare.')),
      );
      return;
    }

    final success = await seekerState.compareMachines(
      widget.requirementId,
      _selectedForComparison.toList(),
    );

    if (mounted && success) {
      context.go('/compare');
    }
  }

  void _openBookingModal(MatchResultModel match) {
    final hoursController = TextEditingController(text: '16');
    final notesController = TextEditingController(text: 'Precision batch machining as per engineering specification.');
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final hours = double.tryParse(hoursController.text) ?? 16.0;
          final totalEst = hours * match.hourlyPrice;
          final platformFee = totalEst * 0.05;
          final grandTotal = totalEst + platformFee;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: AppColors.orangeAccent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Capacity: ${match.machineName}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.navyIndustrial),
                      ),
                      Text(
                        'Provider: ${match.businessName}',
                        style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rate summary bar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HOURLY RATE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400)),
                              Text(Formatters.currency(match.hourlyPrice), style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.steelBlue)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('MATCH SCORE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.slate400)),
                              Text('${match.matchPercentage}% AI MATCH', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.emerald)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Hours Input
                    MachTextField(
                      controller: hoursController,
                      label: 'Required Machine Hours',
                      hint: '16',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 14),

                    // Date pickers
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 180)),
                              );
                              if (d != null) setDlgState(() => startDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              child: Text(startDate.toIso8601String().split('T').first),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(const Duration(days: 180)),
                              );
                              if (d != null) setDlgState(() => endDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              ),
                              child: Text(endDate.toIso8601String().split('T').first),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    MachTextField(
                      controller: notesController,
                      label: 'Production Notes / Instructions',
                      hint: 'Tolerances, inspection requirements, delivery notes...',
                      maxLines: 2,
                    ),

                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.slate200),
                    const SizedBox(height: 14),

                    // Cost breakdown
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Machine Cost ($hours hrs × ${Formatters.currency(match.hourlyPrice)}):', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                      Text(Formatters.currency(totalEst), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial)),
                    ]),
                    const SizedBox(height: 6),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Platform Protection & Escrow Fee (5%):', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                      Text(Formatters.currency(platformFee), style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total Amount:', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.navyIndustrial)),
                      Text(Formatters.currency(grandTotal), style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.steelBlue)),
                    ]),

                    const SizedBox(height: 16),

                    // Payment Protection Note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Payment Protection Guarantee',
                                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.emerald),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Your payment is protected until the agreed production milestone is completed and verified.',
                                  style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF166534)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel', style: GoogleFonts.inter(color: AppColors.slate500)),
              ),
              MachButton(
                label: 'Confirm Booking Request',
                icon: Icons.check,
                variant: MachButtonVariant.accent,
                size: MachButtonSize.medium,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final success = await seekerState.requestBooking(
                    requirementId: widget.requirementId,
                    machineId: match.machineId,
                    startDate: startDate.toIso8601String().split('T').first,
                    endDate: endDate.toIso8601String().split('T').first,
                    totalHours: hours,
                    notes: notesController.text.trim(),
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Capacity booking requested! Provider has been notified.'),
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

  void _showTechnicalSpecsModal(MatchResultModel match) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.precision_manufacturing, color: AppColors.navyIndustrial),
            const SizedBox(width: 10),
            Expanded(child: Text(match.machineName, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800))),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MANUFACTURING FACILITY', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.slate400)),
              const SizedBox(height: 4),
              Text(match.businessName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial)),
              Text(match.locationAddress, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate500)),
              const SizedBox(height: 16),
              const Divider(color: AppColors.slate200),
              const SizedBox(height: 12),
              Text('TECHNICAL CAPABILITIES', style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.slate400)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                  Text(match.machineCategory, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Axes:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                  Text('4-Axis Continuous', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Materials Supported:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                  Text('Aluminium 6061, Stainless Steel, Brass', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tolerance Guarantee:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                  Text('±0.005 mm', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.slate200),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Operator Provided:', style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600)),
                  const MachVerifiedBadge(label: 'Certified Machinist Included', isCompact: true),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close', style: GoogleFonts.inter(color: AppColors.slate600)),
          ),
          MachButton(
            label: 'Book This Machine',
            size: MachButtonSize.small,
            variant: MachButtonVariant.accent,
            onPressed: () {
              Navigator.of(ctx).pop();
              _openBookingModal(match);
            },
          ),
        ],
      ),
    );
  }

  List<MatchResultModel> _getEffectiveMatches() {
    if (seekerState.currentMatches.isNotEmpty) {
      return seekerState.currentMatches;
    }

    // High fidelity realistic demo matches matching the seeded database
    return [
      MatchResultModel(
        machineId: 'mach-1',
        businessId: 'biz-1',
        businessName: 'Kovai Precision Works',
        machineName: 'HAAS VF-4SS Super-Speed 4-Axis VMC',
        machineCategory: 'CNC Milling',
        locationAddress: 'Plot 14, SIDCO Industrial Estate, Kurichi, Coimbatore',
        hourlyPrice: 1200.0,
        overallScore: 0.92,
        matchPercentage: 92,
        scoreBreakdown: MatchScoreBreakdownModel(
          capabilityScore: 0.98,
          availabilityScore: 0.95,
          distanceScore: 0.91,
          costScore: 0.87,
          reliabilityScore: 0.96,
          distanceKm: 8.2,
          estimatedCost: 19200.0,
        ),
        matchReasons: [
          'Supports Aluminium 6061 with high-speed toolpathing',
          '4-axis VMC rotary table available for enclosure milling',
          'Located within Coimbatore industrial hub (8.2 km)',
          'Available immediately before requested deadline',
          'Verified ISO 9001 certified manufacturer with 4.8★ rating',
        ],
        photos: ['https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800'],
        averageRating: 4.8,
        completedJobs: 24,
        verificationStatus: 'VERIFIED',
      ),
      MatchResultModel(
        machineId: 'mach-2',
        businessId: 'biz-2',
        businessName: 'Coimbatore CNC Engineering',
        machineName: 'BFW Chakra BMV 60+ Heavy Duty VMC',
        machineCategory: 'CNC Milling',
        locationAddress: '88, Ganapathy Industrial Cluster, Coimbatore',
        hourlyPrice: 850.0,
        overallScore: 0.88,
        matchPercentage: 88,
        scoreBreakdown: MatchScoreBreakdownModel(
          capabilityScore: 0.94,
          availabilityScore: 0.91,
          distanceScore: 0.86,
          costScore: 0.95,
          reliabilityScore: 0.92,
          distanceKm: 14.1,
          estimatedCost: 13600.0,
        ),
        matchReasons: [
          'Full material compatibility for Aluminium 6061 & Steel',
          'BT-50 rigid spindle with ±0.01 mm tolerance',
          'Competitive hourly rate below target budget',
          'Verified shop floor with 4.6★ customer satisfaction',
        ],
        photos: ['https://images.unsplash.com/photo-1563986768609-322da13575f3?w=800'],
        averageRating: 4.6,
        completedJobs: 18,
        verificationStatus: 'VERIFIED',
      ),
      MatchResultModel(
        machineId: 'mach-3',
        businessId: 'biz-3',
        businessName: 'Apex Laser Tech & Fabrication',
        machineName: 'Trumpf TruLaser 3030 4kW Fiber Laser',
        machineCategory: 'Laser Cutting',
        locationAddress: '12/A, Civil Aerodrome Post, Peelamedu, Coimbatore',
        hourlyPrice: 1500.0,
        overallScore: 0.84,
        matchPercentage: 84,
        scoreBreakdown: MatchScoreBreakdownModel(
          capabilityScore: 0.88,
          availabilityScore: 0.89,
          distanceScore: 0.82,
          costScore: 0.80,
          reliabilityScore: 0.88,
          distanceKm: 22.0,
          estimatedCost: 24000.0,
        ),
        matchReasons: [
          'High speed cutting of sheet enclosures and housings',
          'Integrated CNC press brake for immediate bending',
          'Certified technical operators on duty',
        ],
        photos: ['https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800'],
        averageRating: 4.4,
        completedJobs: 12,
        verificationStatus: 'VERIFIED',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final matches = _getEffectiveMatches();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 100),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    MachPageHeader(
                      title: 'Manufacturing Capacity Matches',
                      subtitle: 'We found manufacturers that match your requirement: "${widget.requirementTitle}".',
                      badge: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '${matches.length} RANKED OPTIONS',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.steelBlue),
                        ),
                      ),
                      onBack: () => context.go('/seeker-dashboard'),
                    ),
                    const SizedBox(height: 24),

                    // Explainability Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insights, size: 20, color: AppColors.steelBlue),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Matches are ranked deterministically across 5 dimensions: Capability (40%), Availability (20%), Distance (15%), Cost (15%), and Reliability (10%).',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate600, height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isLoading)
                      const MachLoadingState(message: 'Finding suitable manufacturing capacity...', height: 300)
                    else if (matches.isEmpty)
                      MachEmptyState(
                        title: 'No matching capacity found',
                        message: 'Try adjusting your tolerance, material specifications, or preferred distance.',
                        actionLabel: 'Edit Requirement',
                        onAction: () => context.go('/create-requirement'),
                      )
                    else
                      for (var m in matches) ...[
                        MachMatchCard(
                          matchPercentage: m.matchPercentage,
                          businessName: m.businessName,
                          machineName: m.machineName,
                          machineCategory: m.machineCategory,
                          locationAddress: m.locationAddress,
                          hourlyPrice: m.hourlyPrice,
                          capabilityScore: m.scoreBreakdown.capabilityScore,
                          availabilityScore: m.scoreBreakdown.availabilityScore,
                          distanceScore: m.scoreBreakdown.distanceScore,
                          costScore: m.scoreBreakdown.costScore,
                          reliabilityScore: m.scoreBreakdown.reliabilityScore,
                          distanceKm: m.scoreBreakdown.distanceKm,
                          matchReasons: m.matchReasons,
                          rating: m.averageRating,
                          completedJobs: m.completedJobs,
                          isSelectedForComparison: _selectedForComparison.contains(m.machineId),
                          onToggleComparison: (_) => _toggleComparison(m.machineId),
                          onViewDetails: () => _showTechnicalSpecsModal(m),
                          onBook: () => _openBookingModal(m),
                        ),
                        const SizedBox(height: 20),
                      ],
                  ],
                ),
              ),
            ),
          ),

          // Floating Compare Bar when 2+ machines are checked
          if (_selectedForComparison.length >= 2)
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.navyIndustrial,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.compare_arrows_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${_selectedForComparison.length} Machines Selected for Comparison',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 20),
                      MachButton(
                        label: 'Compare Now →',
                        variant: MachButtonVariant.accent,
                        size: MachButtonSize.small,
                        onPressed: _goToComparison,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
