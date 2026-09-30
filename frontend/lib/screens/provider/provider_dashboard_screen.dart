import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/models/booking_model.dart';
import 'package:machhunt/state/provider_state.dart';
import 'package:machhunt/state/auth_state.dart';

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await providerState.fetchMyMachines();
    await providerState.fetchIncomingRequests();
  }

  List<MachineModel> _getEffectiveMachines(List<MachineModel> apiMachines) {
    return apiMachines;
  }

  List<BookingModel> _getEffectiveRequests(List<BookingModel> apiRequests) {
    return apiRequests
        .where((b) => b.status == 'PENDING' || b.status == 'REQUESTED')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final biz = authState.currentBusiness;
    final providerName =
        biz?.name ??
        (user?.fullName.isNotEmpty ?? false
            ? user!.fullName
            : "MSME Provider");

    return ListenableBuilder(
      listenable: providerState,
      builder: (context, _) {
        final rawMachines = providerState.myMachines;
        final rawRequests = providerState.incomingRequests;
        final machines = _getEffectiveMachines(rawMachines);
        final requests = _getEffectiveRequests(rawRequests);

        final totalMachines = machines.length;
        final activeRequests = requests.length;
        final ongoingJobs = rawRequests
            .where((b) => b.status == 'IN_PROGRESS' || b.status == 'CONFIRMED')
            .length;
        final displayJobs = ongoingJobs;
        final totalEarned = Formatters.currency(providerState.totalEarnings);


        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.steelBlue,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                MachPageHeader(
                  title: 'Welcome back, $providerName!',
                  subtitle:
                      'Manage your capacity, view requests and grow your business.',
                  badge: const MachVerifiedBadge(
                    label: 'Verified Manufacturer',
                    isCompact: true,
                  ),
                  primaryAction: MachButton(
                    label: '+ Add Machine',
                    icon: Icons.add,
                    variant: MachButtonVariant.accent,
                    size: MachButtonSize.medium,
                    onPressed: () => context.go('/add-machine'),
                  ),
                  secondaryActions: [
                    MachButton(
                      label: 'Manage Availability',
                      icon: Icons.calendar_month_outlined,
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.medium,
                      onPressed: () {
                        if (machines.isNotEmpty) {
                          context.go(
                            '/machine-availability/${machines.first.id}?name=${Uri.encodeComponent(machines.first.name)}',
                          );
                        }
                      },
                    ),
                    MachButton(
                      label: 'View Bookings',
                      icon: Icons.receipt_long_outlined,
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.medium,
                      onPressed: () => context.go('/bookings'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 4 Metric Cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 800;
                    return isNarrow
                        ? Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: MachMetricCard(
                                      title: 'Machines Listed',
                                      value: '$totalMachines',
                                      icon: Icons
                                          .precision_manufacturing_outlined,
                                      subtitle: 'Fleet equipment verified',
                                      accentColor: AppColors.machBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: MachMetricCard(
                                      title: 'Active Requests',
                                      value: '$activeRequests',
                                      icon: Icons.inbox_outlined,
                                      subtitle: 'Seekers awaiting quote',
                                      accentColor: AppColors.machOrange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: MachMetricCard(
                                      title: 'Ongoing Bookings',
                                      value: '$displayJobs',
                                      icon: Icons.play_circle_outline,
                                      subtitle: 'Spindles currently running',
                                      accentColor: AppColors.machBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: MachMetricCard(
                                      title: 'Estimated Earnings',
                                      value: totalEarned,
                                      icon:
                                          Icons.account_balance_wallet_outlined,
                                      subtitle: 'Net provider payouts',
                                      accentColor: AppColors.successGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: MachMetricCard(
                                  title: 'Machines Listed',
                                  value: '$totalMachines',
                                  icon: Icons.precision_manufacturing_outlined,
                                  subtitle: 'Fleet equipment verified',
                                  accentColor: AppColors.machBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MachMetricCard(
                                  title: 'Active Requests',
                                  value: '$activeRequests',
                                  icon: Icons.inbox_outlined,
                                  subtitle: 'Seekers awaiting quote',
                                  accentColor: AppColors.machOrange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MachMetricCard(
                                  title: 'Ongoing Bookings',
                                  value: '$displayJobs',
                                  icon: Icons.play_circle_outline,
                                  subtitle: 'Spindles currently running',
                                  accentColor: AppColors.machBlue,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MachMetricCard(
                                  title: 'Estimated Earnings',
                                  value: totalEarned,
                                  icon: Icons.account_balance_wallet_outlined,
                                  subtitle: 'Net provider payouts',
                                  accentColor: AppColors.successGreen,
                                ),
                              ),
                            ],
                          );
                  },
                ),

                const SizedBox(height: 32),

                // Recent Requests Section (Priority!)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Incoming Requests',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Capacity seekers requesting immediate production time on your equipment.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                    MachButton(
                      label: 'View All Requests',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: () => context.go('/bookings'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Incoming Requests Cards
                if (requests.isEmpty)
                  const MachEmptyState(
                    title: 'No pending requests',
                    message:
                        'New capacity requests will appear here when seekers match your machines.',
                  )
                else
                  for (var req in requests) ...[
                    _buildIncomingRequestCard(req),
                    const SizedBox(height: 14),
                  ],

                const SizedBox(height: 32),

                // Your Machines Fleet Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Demo Marketplace Capacity Fleet',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFBFDBFE),
                                ),
                              ),
                              child: Text(
                                '$totalMachines Listings',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.machBlue,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Assigned demo manufacturing capacity listings linked to real Tamil Nadu industrial facilities.',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                    MachButton(
                      label: '+ Add Machine',
                      icon: Icons.add,
                      variant: MachButtonVariant.accent,
                      size: MachButtonSize.small,
                      onPressed: () => context.go('/add-machine'),
                    ),
                  ],
                ),
                // Machines Grid
                if (machines.isEmpty)
                  const MachEmptyState(
                    title: 'No machinery listed',
                    message:
                        'Add your first manufacturing machine to start publishing capacity to the marketplace.',
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 900 ? 2 : 1;
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (var m in machines)
                            SizedBox(
                              width:
                                  (constraints.maxWidth - (columns - 1) * 16) /
                                  columns,
                              child: MachMachineCard.fromModel(
                                machine: m,
                                onManageAvailability: () => context.go(
                                  '/machine-availability/${m.id}?name=${Uri.encodeComponent(m.name)}',
                                ),
                                onViewDetails: () => context.go(
                                  '/machine-availability/${m.id}?name=${Uri.encodeComponent(m.name)}',
                                ),
                              ),
                            ),
                        ],
                      );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncomingRequestCard(BookingModel req) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.machOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.bolt,
              color: AppColors.machOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          req.requirementTitle ?? 'Component Machining Job',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 10),
                        MachStatusBadge(status: req.status),
                      ],
                    ),
                    Text(
                      Formatters.currency(req.providerPayout),
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Buyer: ${req.seekerName ?? "Verified Seeker"} · Machine: ${req.machineName ?? "Machinery"}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${req.totalHours} planned operating hours · Dates: ${req.startDate} to ${req.endDate}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.mutedSlate,
                  ),
                ),
                if (req.notes != null && req.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Notes: "${req.notes!}"',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: AppColors.mutedSlate,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    MachButton(
                      label: 'Decline',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await providerState.rejectRequest(
                          req.id,
                          reason: 'Machine occupied on schedule.',
                        );
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text('Request declined.')),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    MachButton(
                      label: 'Send Quote',
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.small,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Custom quote of ${Formatters.currency(req.totalAmount)} sent to buyer.',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    MachButton(
                      label: 'Accept Request',
                      icon: Icons.check,
                      variant: MachButtonVariant.accent,
                      size: MachButtonSize.small,
                      onPressed: () async {
                        final success = await providerState.acceptRequest(
                          req.id,
                        );
                        if (mounted && success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Request accepted! Seeker notified to fund escrow.',
                              ),
                              backgroundColor: AppColors.successGreen,
                            ),
                          );
                        }
                      },
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
