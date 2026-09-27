import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/constants/app_typography.dart';
import 'package:machhunt/core/widgets/app_button.dart';
import 'package:machhunt/core/widgets/app_card.dart';
import 'package:machhunt/core/widgets/status_badge.dart';
import 'package:machhunt/state/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: authState,
      builder: (context, _) {
        final user = authState.currentUser;
        final biz = authState.currentBusiness;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MSME Profile & Account', style: AppTypography.displayMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Manage your industrial credentials, GST verification, and portal session',
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 24),

                  // User Info Card
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: Text(
                                (user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'U').toUpperCase(),
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user?.fullName ?? 'MSME User', style: AppTypography.titleLarge),
                                  const SizedBox(height: 4),
                                  Text(user?.email ?? '', style: AppTypography.bodySmall),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Role: ${user?.role ?? "SEEKER"}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 16),

                        _buildProfileField('Phone Number', user?.phone ?? 'Not provided'),
                        _buildProfileField('Account Status', user?.isActive == true ? 'Active' : 'Suspended'),
                        _buildProfileField('User ID', user?.id ?? ''),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Business Profile Card
                  if (biz != null)
                    AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(biz.name, style: AppTypography.titleLarge),
                                  const SizedBox(height: 2),
                                  Text('${biz.industry} • ${biz.district}, ${biz.state}', style: AppTypography.bodySmall),
                                ],
                              ),
                              StatusBadge(status: biz.verificationStatus),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.border),
                          const SizedBox(height: 14),

                          _buildProfileField('GSTIN', biz.gstin ?? 'Unregistered MSME'),
                          _buildProfileField('Registered Office', biz.address),
                          _buildProfileField('District & Pincode', '${biz.district} - ${biz.pincode}'),
                          _buildProfileField('State', biz.state),
                          _buildProfileField('Coordinates', '${biz.latitude.toStringAsFixed(4)}° N, ${biz.longitude.toStringAsFixed(4)}° E'),
                          if (biz.description != null && biz.description!.isNotEmpty)
                            _buildProfileField('Profile Description', biz.description!),
                        ],
                      ),
                    )
                  else
                    AppCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('No MSME Business Registered', style: AppTypography.titleMedium),
                          const SizedBox(height: 8),
                          const Text(
                            'Register your manufacturing unit or company to list machinery and receive payments.',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            label: 'Register Business Profile',
                            icon: Icons.add_business,
                            onPressed: () => context.go('/onboarding-business'),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Actions & Sign Out
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.security, color: AppColors.primary),
                          title: const Text('Security & Access', style: AppTypography.labelMedium),
                          subtitle: const Text('JWT 60-min access tokens with refresh token rotation', style: AppTypography.caption),
                        ),
                        const Divider(color: AppColors.border),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.cloud_done_outlined, color: AppColors.success),
                          title: const Text('Backend API Connected', style: AppTypography.labelMedium),
                          subtitle: const Text('FastAPI Engine with PostgreSQL database', style: AppTypography.caption),
                        ),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AppButton(
                              label: 'Log Out of Mach-Hunt',
                              icon: Icons.logout,
                              variant: AppButtonVariant.danger,
                              onPressed: () async {
                                await authState.logout();
                                if (context.mounted) {
                                  context.go('/login');
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
