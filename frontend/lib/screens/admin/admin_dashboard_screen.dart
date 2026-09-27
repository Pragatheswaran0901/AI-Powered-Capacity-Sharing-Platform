import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/constants/app_typography.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/widgets/app_button.dart';
import 'package:machhunt/core/widgets/app_card.dart';
import 'package:machhunt/core/widgets/status_badge.dart';
import 'package:machhunt/models/admin_metrics_model.dart';
import 'package:machhunt/state/admin_state.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    await adminState.fetchMetrics();
    await adminState.fetchQueue();
  }

  void _verifyItem(VerificationQueueItemModel item, bool approve) async {
    final status = approve ? 'VERIFIED' : 'REJECTED';
    bool ok = false;
    if (item.entityType == 'BUSINESS') {
      ok = await adminState.verifyBusiness(item.id, status, remarks: approve ? 'Verified by Admin' : 'Documents incomplete');
    } else {
      ok = await adminState.verifyMachine(item.id, status, remarks: approve ? 'Inspection approved' : 'Calibration certificate missing');
    }

    if (mounted && ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.entityName} marked as $status!'),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: adminState,
      builder: (context, _) {
        final m = adminState.metrics;
        final queue = adminState.queue;

        return RefreshIndicator(
          onRefresh: _loadAdminData,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Platform Administration & Oversight', style: AppTypography.displayMedium),
                        SizedBox(height: 4),
                        Text(
                          'Mach-Hunt MSME Ecosystem Metrics, Auditing & Verification Queue',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    AppButton(
                      label: 'Refresh Data',
                      icon: Icons.refresh,
                      variant: AppButtonVariant.secondary,
                      onPressed: _loadAdminData,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Metrics Grid
                if (m != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Total Platform GMV',
                          value: Formatters.currency(m.totalGmvInr),
                          icon: Icons.currency_rupee,
                          color: AppColors.success,
                          subtitle: 'Escrow volume transacted',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Registered MSMEs',
                          value: '${m.totalMsmes}',
                          icon: Icons.business,
                          color: AppColors.primary,
                          subtitle: '${m.totalProviders} providers, ${m.totalSeekers} seekers',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Machinery Fleet',
                          value: '${m.activeMachines}',
                          icon: Icons.precision_manufacturing,
                          color: AppColors.secondary,
                          subtitle: '${m.activeRequirements} active requirements',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildMetricCard(
                          title: 'Matching Accuracy',
                          value: '${m.matchSuccessRatePercent.toInt()}%',
                          icon: Icons.radar,
                          color: AppColors.info,
                          subtitle: '${m.completedJobs} completed jobs',
                        ),
                      ),
                    ],
                  ),
                ] else if (adminState.isLoading) ...[
                  const Center(child: CircularProgressIndicator()),
                ],
                const SizedBox(height: 32),

                // Verification Queue Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Verification & Compliance Queue (${queue.length})', style: AppTypography.titleLarge),
                  ],
                ),
                const SizedBox(height: 16),

                if (queue.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.verified_user, size: 48, color: AppColors.success),
                          const SizedBox(height: 12),
                          const Text('All Verification Requests Cleared', style: AppTypography.titleMedium),
                          const SizedBox(height: 4),
                          const Text(
                            'No pending MSME businesses or machine listings require compliance verification.',
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: queue.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, idx) {
                      final item = queue[idx];
                      return AppCard(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (item.entityType == 'BUSINESS' ? AppColors.primary : AppColors.secondary).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                item.entityType == 'BUSINESS' ? Icons.storefront : Icons.precision_manufacturing,
                                color: item.entityType == 'BUSINESS' ? AppColors.primary : AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(item.entityName, style: AppTypography.titleSmall),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.entityType,
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      StatusBadge(status: item.verificationStatus),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item.ownerName} • ${item.gstinOrCategory ?? item.phone}',
                                    style: AppTypography.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text('Submitted: ${item.submittedAt}', style: AppTypography.caption),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _verifyItem(item, false),
                                  icon: const Icon(Icons.close, size: 16, color: AppColors.error),
                                  label: const Text('Reject', style: TextStyle(color: AppColors.error)),
                                ),
                                const SizedBox(width: 10),
                                AppButton(
                                  label: 'Approve & Verify',
                                  icon: Icons.check,
                                  onPressed: () => _verifyItem(item, true),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTypography.bodySmall),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headlineMedium),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.caption),
        ],
      ),
    );
  }
}
