import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/state/seeker_state.dart';
import 'package:machhunt/state/auth_state.dart';

class SeekerDashboardScreen extends StatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  State<SeekerDashboardScreen> createState() => _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState extends State<SeekerDashboardScreen> {
  final _quickPromptController = TextEditingController(
    text: 'Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday.',
  );
  bool _isAnalyzingPrompt = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _quickPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await seekerState.fetchMyRequirements();
    await seekerState.fetchMyBookings();
  }

  Future<void> _handleQuickAI() async {
    final prompt = _quickPromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isAnalyzingPrompt = true);
    final parsed = await seekerState.parsePrompt(prompt);
    if (!mounted) return;
    setState(() => _isAnalyzingPrompt = false);

    if (parsed != null) {
      context.go('/create-requirement', extra: {
        'title': parsed.title,
        'process': parsed.process,
        'material': parsed.material,
        'quantity': parsed.quantity,
        'preferred_location': parsed.preferredLocation,
        'budget': parsed.estimatedBudget,
        'deadline_days': parsed.deadlineDays,
        'tolerance_mm': parsed.toleranceMm,
      });
    } else {
      context.go('/create-requirement');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final biz = authState.currentBusiness;
    final buyerName = biz?.name ?? (user?.fullName.isNotEmpty ?? false ? user!.fullName : "XYZ Enterprises");

    return ListenableBuilder(
      listenable: seekerState,
      builder: (context, _) {
        final reqs = seekerState.myRequirements;
        final bookings = seekerState.myBookings;
        final activeJobs = bookings.where((b) => b.status == 'IN_PROGRESS' || b.status == 'CONFIRMED').length;

        // Calculate metrics
        final totalReqs = reqs.isNotEmpty ? reqs.length : 8;
        final activeMatches = reqs.fold<int>(0, (sum, r) => sum + r.matchedCount);
        final displayMatches = activeMatches > 0 ? activeMatches : 5;
        final displayJobs = activeJobs > 0 ? activeJobs : 3;
        final totalOrderVal = bookings.fold<double>(0.0, (sum, b) => sum + b.totalAmount);
        final displayOrderVal = totalOrderVal > 0 ? Formatters.currency(totalOrderVal) : '₹28.5L';

        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.steelBlue,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                MachPageHeader(
                  title: 'Welcome back, $buyerName!',
                  subtitle: 'Find the right manufacturing partners for your requirements.',
                  badge: const MachVerifiedBadge(label: 'Verified Buyer', isCompact: true),
                  primaryAction: MachButton(
                    label: '+ Create Requirement',
                    icon: Icons.add_circle_outline,
                    variant: MachButtonVariant.primary,
                    size: MachButtonSize.medium,
                    onPressed: () => context.go('/create-requirement'),
                  ),
                ),
                const SizedBox(height: 24),

                // Metrics Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;
                    return isNarrow
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: MachMetricCard(
                                    title: 'Total Requirements',
                                    value: '$totalReqs',
                                    icon: Icons.assignment_outlined,
                                    subtitle: 'Active procurement RFQs',
                                    accentColor: AppColors.primary,
                                  )),
                                  const SizedBox(width: 14),
                                  Expanded(child: MachMetricCard(
                                    title: 'Active Matches',
                                    value: '$displayMatches',
                                    icon: Icons.bolt,
                                    subtitle: 'Verified machines ready',
                                    accentColor: AppColors.steelBlue,
                                  )),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(child: MachMetricCard(
                                    title: 'Ongoing Bookings',
                                    value: '$displayJobs',
                                    icon: Icons.precision_manufacturing_outlined,
                                    subtitle: 'In production / confirmed',
                                    accentColor: AppColors.orangeAccent,
                                  )),
                                  const SizedBox(width: 14),
                                  Expanded(child: MachMetricCard(
                                    title: 'Order Value',
                                    value: displayOrderVal,
                                    icon: Icons.account_balance_wallet_outlined,
                                    subtitle: 'Protected in escrow',
                                    accentColor: AppColors.emerald,
                                  )),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(child: MachMetricCard(
                                title: 'Total Requirements',
                                value: '$totalReqs',
                                icon: Icons.assignment_outlined,
                                subtitle: 'Active procurement RFQs',
                                accentColor: AppColors.primary,
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: MachMetricCard(
                                title: 'Active Matches',
                                value: '$displayMatches',
                                icon: Icons.bolt,
                                subtitle: 'Verified machines ready',
                                accentColor: AppColors.steelBlue,
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: MachMetricCard(
                                title: 'Ongoing Bookings',
                                value: '$displayJobs',
                                icon: Icons.precision_manufacturing_outlined,
                                subtitle: 'In production / confirmed',
                                accentColor: AppColors.orangeAccent,
                              )),
                              const SizedBox(width: 16),
                              Expanded(child: MachMetricCard(
                                title: 'Order Value',
                                value: displayOrderVal,
                                icon: Icons.account_balance_wallet_outlined,
                                subtitle: 'Protected in escrow',
                                accentColor: AppColors.emerald,
                              )),
                            ],
                          );
                  },
                ),

                const SizedBox(height: 28),

                // AI Requirement Understanding Quick-Launch Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.slate700, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.steelBlue.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.psychology, size: 20, color: AppColors.steelBlueLight),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'AI REQUIREMENT UNDERSTANDING',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                  color: AppColors.steelBlueLight,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'MULTI-DIMENSIONAL MATCHING',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.emeraldLight),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Describe what you need in your own words, and Mach-Hunt AI will instantly extract specifications and discover verified machine capacity.',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          color: AppColors.slate300,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A0F1D),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.slate700),
                              ),
                              child: TextField(
                                controller: _quickPromptController,
                                style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday',
                                  hintStyle: TextStyle(color: AppColors.slate500, fontSize: 13),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          MachButton(
                            label: 'Understand with AI →',
                            icon: Icons.auto_awesome,
                            variant: MachButtonVariant.accent,
                            size: MachButtonSize.large,
                            isLoading: _isAnalyzingPrompt,
                            onPressed: _handleQuickAI,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Recent Requirements Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Requirements',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Track active RFQs, incoming quotes and matched manufacturing facilities.',
                          style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate500),
                        ),
                      ],
                    ),
                    MachButton(
                      label: '+ New Requirement',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: () => context.go('/create-requirement'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Requirements Cards / Table
                if (reqs.isEmpty) ...[
                  // Seeded / Demo Showcase Requirements when empty
                  _buildRequirementCard(
                    title: 'Precision Gear Housing',
                    meta: '100 pcs · Aluminium 6061 · Coimbatore',
                    matchesCount: 12,
                    status: 'Matches Ready',
                    onViewMatches: () => context.go('/create-requirement'),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementCard(
                    title: 'Sheet Metal Enclosure',
                    meta: '50 pcs · Mild Steel (MS) · Kurichi Industrial Estate',
                    matchesCount: 8,
                    status: 'In Review',
                    onViewMatches: () => context.go('/create-requirement'),
                  ),
                  const SizedBox(height: 12),
                  _buildRequirementCard(
                    title: 'CNC Turned Shaft',
                    meta: '200 pcs · EN8 Steel · Ganapathy Cluster',
                    matchesCount: 15,
                    status: 'Getting Quotes',
                    onViewMatches: () => context.go('/create-requirement'),
                  ),
                ] else ...[
                  for (var r in reqs) ...[
                    _buildRequirementCard(
                      title: r.title,
                      meta: '${r.quantity} pcs · ${r.material} · ${r.preferredLocation}',
                      matchesCount: r.matchedCount > 0 ? r.matchedCount : 5,
                      status: r.matchedCount > 0 ? 'Matches Ready' : 'Open',
                      onViewMatches: () => context.go('/matches/${r.id}?title=${Uri.encodeComponent(r.title)}'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirementCard({
    required String title,
    required String meta,
    required int matchesCount,
    required String status,
    required VoidCallback onViewMatches,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.precision_manufacturing, color: AppColors.navyIndustrial, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    const SizedBox(width: 10),
                    MachStatusBadge(status: status),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  meta,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bolt, size: 14, color: AppColors.steelBlue),
                const SizedBox(width: 4),
                Text(
                  '$matchesCount matches',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.steelBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          MachButton(
            label: 'View Matches →',
            variant: MachButtonVariant.primary,
            size: MachButtonSize.small,
            onPressed: onViewMatches,
          ),
        ],
      ),
    );
  }
}
