import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/core/widgets/app_background.dart';
import 'package:machhunt/state/auth_state.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _hoveredRole;
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() => _isLoading = true);

    final user = authState.currentUser;
    if (user != null) {
      if (!user.isOnboarded) {
        // Auto-initialize base MSME profile for the selected role
        final defaultBizName =
            "${user.fullName.isNotEmpty ? user.fullName : user.email.split('@')[0]} Works";
        await authState.completeOnboarding(
          role: role,
          fullName: user.fullName.isNotEmpty
              ? user.fullName
              : user.email.split('@')[0],
          phone: user.phone.isNotEmpty ? user.phone : "9876543210",
          businessName: defaultBizName,
          industry: role == 'PROVIDER'
              ? 'Precision Machining & Tooling'
              : 'Component Sourcing & Assembly',
          district: 'Coimbatore',
          pincode: '641006',
          address: 'SIDCO Industrial Estate, Coimbatore',
          machineCategories: role == 'PROVIDER'
              ? ['CNC Milling', 'VMC (Vertical Machining)']
              : null,
        );
      } else if (user.role != role) {
        await authState.switchRole(role);
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (role == 'PROVIDER') {
      context.go('/provider-dashboard');
    } else {
      context.go('/seeker-dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.slate700),
          onPressed: () => context.go('/login'),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton.icon(
              onPressed: () async {
                await authState.logout();
                if (context.mounted) context.go('/login');
              },
              icon: const Icon(
                Icons.logout,
                size: 16,
                color: AppColors.slate500,
              ),
              label: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppColors.slate500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.steelBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.steelBlue.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Text(
                        "ONBOARDING & INTENT",
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.steelBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Headline
                    Text(
                      "How will you use Mach-Hunt?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Supporting text
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 540),
                      child: Text(
                        "Choose the option that best describes what you want to do. You can switch roles at any time from your sidebar.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                          height: 1.45,
                          color: AppColors.slate500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    if (_isLoading)
                      const MachLoadingState(
                        message: "Setting up your MSME workspace...",
                        height: 160,
                      )
                    else
                      // Two Large Distinct Cards
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _buildRoleCard(
                                    roleId: 'PROVIDER',
                                    title: 'Capacity Provider',
                                    subtitle: 'Monetize Idle Machinery',
                                    description:
                                        'I have manufacturing capacity available and want to offer it to other MSMEs.',
                                    icon: Icons.factory_outlined,
                                    accentColor: AppColors.orangeAccent,
                                    features: [
                                      'List CNC, VMC, Turning & Laser equipment',
                                      'Publish idle shift calendars',
                                      'Receive verified procurement orders',
                                      'Guaranteed milestone escrow payouts',
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: _buildRoleCard(
                                    roleId: 'SEEKER',
                                    title: 'Capacity Seeker',
                                    subtitle: 'Source Precision Parts',
                                    description:
                                        'I need manufacturing capacity and want to find a suitable manufacturer.',
                                    icon: Icons.search_rounded,
                                    accentColor: AppColors.steelBlue,
                                    features: [
                                      'Describe requirements in plain English',
                                      'AI blueprint extraction & matching',
                                      'Compare 5 deterministic score dimensions',
                                      'Protected escrow payment milestones',
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildRoleCard(
                                  roleId: 'PROVIDER',
                                  title: 'Capacity Provider',
                                  subtitle: 'Monetize Idle Machinery',
                                  description:
                                      'I have manufacturing capacity available and want to offer it to other MSMEs.',
                                  icon: Icons.factory_outlined,
                                  accentColor: AppColors.orangeAccent,
                                  features: [
                                    'List CNC, VMC, Turning & Laser equipment',
                                    'Publish idle shift calendars',
                                    'Receive verified procurement orders',
                                    'Guaranteed milestone escrow payouts',
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildRoleCard(
                                  roleId: 'SEEKER',
                                  title: 'Capacity Seeker',
                                  subtitle: 'Source Precision Parts',
                                  description:
                                      'I need manufacturing capacity and want to find a suitable manufacturer.',
                                  icon: Icons.search_rounded,
                                  accentColor: AppColors.steelBlue,
                                  features: [
                                    'Describe requirements in plain English',
                                    'AI blueprint extraction & matching',
                                    'Compare 5 deterministic score dimensions',
                                    'Protected escrow payment milestones',
                                  ],
                                ),
                              ],
                            ),

                    const SizedBox(height: 32),
                    Text(
                      "Both roles have access to the unified MSME manufacturing network.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required Color accentColor,
    required List<String> features,
  }) {
    final isHovered = _hoveredRole == roleId;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredRole = roleId),
      onExit: (_) => setState(() => _hoveredRole = null),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isHovered ? accentColor : AppColors.slate200,
            width: isHovered ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isHovered
                  ? accentColor.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: isHovered ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Icon + Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: accentColor),
                  ),
                  MachBadge(
                    label: subtitle.toUpperCase(),
                    textColor: accentColor,
                    backgroundColor: accentColor.withValues(alpha: 0.08),
                    borderColor: accentColor.withValues(alpha: 0.2),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Title
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyIndustrial,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  height: 1.45,
                  color: AppColors.slate600,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.slate200),
              const SizedBox(height: 18),

              // Feature bullets
              for (var f in features) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 15,
                        color: accentColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          f,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.slate700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Primary CTA
              MachButton(
                label: 'Continue as $title →',
                icon: Icons.arrow_forward_rounded,
                variant: roleId == 'PROVIDER'
                    ? MachButtonVariant.accent
                    : MachButtonVariant.primary,
                size: MachButtonSize.large,
                isFullWidth: true,
                onPressed: () => _selectRole(roleId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
