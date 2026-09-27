import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/state/auth_state.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.slate200, width: 1)),
          ),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
          child: SafeArea(
            child: Row(
              children: [
                // Mach-Hunt Logo
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MACH-HUNT',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                        Text(
                          'MSME Capacity Platform',
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(),

                // Desktop Navigation Links
                if (isDesktop) ...[
                  _NavLink(label: 'About', onTap: () {}),
                  _NavLink(label: 'How It Works', onTap: () {}),
                  _NavLink(label: 'For Providers', onTap: () {}),
                  _NavLink(label: 'For Seekers', onTap: () {}),
                  const SizedBox(width: 24),
                ],

                // Action CTAs
                MachButton(
                  label: 'Login',
                  variant: MachButtonVariant.outline,
                  size: MachButtonSize.small,
                  onPressed: () => context.go('/login'),
                ),
                const SizedBox(width: 10),
                MachButton(
                  label: 'Get Started',
                  variant: MachButtonVariant.primary,
                  size: MachButtonSize.small,
                  onPressed: () {
                    if (authState.isAuthenticated) {
                      if (authState.isProvider) {
                        context.go('/provider-dashboard');
                      } else {
                        context.go('/seeker-dashboard');
                      }
                    } else {
                      context.go('/login');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HERO SECTION
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=1600'),
                  fit: BoxFit.cover,
                  opacity: 0.12,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: isMobile ? 48 : 80),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(flex: 6, child: _buildHeroLeft(context, isMobile)),
                            const SizedBox(width: 48),
                            Expanded(flex: 5, child: _buildHeroRight(context)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildHeroLeft(context, isMobile),
                            const SizedBox(height: 40),
                            _buildHeroRight(context),
                          ],
                        ),
                ),
              ),
            ),

            // 4 PRODUCT VALUE POINTS SECTION
            Container(
              color: AppColors.slate50,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        'TRUSTED INDUSTRIAL INFRASTRUCTURE',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.steelBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Engineered for Precision Manufacturing',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 22 : 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyIndustrial,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Mach-Hunt closes the gap between idle MSME machine capacity and urgent component requirements.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // 4 Pillars Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final columns = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);
                          return Wrap(
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              _buildValueCard(
                                width: (constraints.maxWidth - (columns - 1) * 20) / columns,
                                icon: Icons.verified_user_outlined,
                                iconColor: AppColors.emerald,
                                title: 'Verified Manufacturers',
                                description: 'Every shop floor and machine is vetted with GSTIN, UDYAM registration, and verified precision specifications.',
                              ),
                              _buildValueCard(
                                width: (constraints.maxWidth - (columns - 1) * 20) / columns,
                                icon: Icons.psychology_outlined,
                                iconColor: AppColors.steelBlue,
                                title: 'AI-Powered Matching',
                                description: 'Natural language parsing maps technical blueprints and tolerances to verified machines across 5 deterministic criteria.',
                              ),
                              _buildValueCard(
                                width: (constraints.maxWidth - (columns - 1) * 20) / columns,
                                icon: Icons.lock_outline,
                                iconColor: AppColors.orangeAccent,
                                title: 'Secure Transactions',
                                description: 'Milestone escrow payment protection ensures buyer peace of mind and guaranteed provider payouts upon completion.',
                              ),
                              _buildValueCard(
                                width: (constraints.maxWidth - (columns - 1) * 20) / columns,
                                icon: Icons.factory_outlined,
                                iconColor: AppColors.navyIndustrial,
                                title: 'Built for MSMEs',
                                description: 'Zero fixed overheads. Monetize idle machine hours and source urgent production capacity on flexible hourly terms.',
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // HOW IT WORKS - DUAL FLOW
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      Text(
                        'SEAMLESS CAPACITY SHARING',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.steelBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How Mach-Hunt Connects MSMEs',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 22 : 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyIndustrial,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 48),

                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildFlowColumn('FOR CAPACITY SEEKERS', Icons.search, [
                                  _FlowStep('1. Describe Your Requirement', 'Type in plain English: "Need 4-axis VMC for 150 aluminium enclosures in Coimbatore."'),
                                  _FlowStep('2. AI Extraction & Blueprint Mapping', 'Platform extracts material, process, tolerance, deadline, and quantity automatically.'),
                                  _FlowStep('3. 5-Dimension AI Matching', 'Inspect ranked matches scored on capability, availability, distance, cost, and reliability.'),
                                  _FlowStep('4. Compare & Escrow Booking', 'Compare technical specs side-by-side, lock dates, and fund protected escrow.'),
                                ], AppColors.steelBlue)),
                                const SizedBox(width: 32),
                                Expanded(child: _buildFlowColumn('FOR CAPACITY PROVIDERS', Icons.precision_manufacturing, [
                                  _FlowStep('1. List Your Machinery', 'Register CNC milling, VMC, laser, or turning equipment with technical envelope and rates.'),
                                  _FlowStep('2. Set Calendar & Idle Shifts', 'Visual schedule builder clearly highlights available operating hours and idle capacity.'),
                                  _FlowStep('3. Receive High-Intent Orders', 'Direct notifications when verified seekers need your exact tooling and capability.'),
                                  _FlowStep('4. Execute & Guaranteed Payout', 'Produce parts, update order milestones, and receive instant platform payouts upon delivery.'),
                                ], AppColors.orangeAccent)),
                              ],
                            )
                          : Column(
                              children: [
                                _buildFlowColumn('FOR CAPACITY SEEKERS', Icons.search, [
                                  _FlowStep('1. Describe Your Requirement', 'Type in plain English: "Need 4-axis VMC for 150 aluminium enclosures in Coimbatore."'),
                                  _FlowStep('2. AI Extraction & Blueprint Mapping', 'Platform extracts material, process, tolerance, deadline, and quantity automatically.'),
                                  _FlowStep('3. 5-Dimension AI Matching', 'Inspect ranked matches scored on capability, availability, distance, cost, and reliability.'),
                                  _FlowStep('4. Compare & Escrow Booking', 'Compare technical specs side-by-side, lock dates, and fund protected escrow.'),
                                ], AppColors.steelBlue),
                                const SizedBox(height: 32),
                                _buildFlowColumn('FOR CAPACITY PROVIDERS', Icons.precision_manufacturing, [
                                  _FlowStep('1. List Your Machinery', 'Register CNC milling, VMC, laser, or turning equipment with technical envelope and rates.'),
                                  _FlowStep('2. Set Calendar & Idle Shifts', 'Visual schedule builder clearly highlights available operating hours and idle capacity.'),
                                  _FlowStep('3. Receive High-Intent Orders', 'Direct notifications when verified seekers need your exact tooling and capability.'),
                                  _FlowStep('4. Execute & Guaranteed Payout', 'Produce parts, update order milestones, and receive instant platform payouts upon delivery.'),
                                ], AppColors.orangeAccent),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),

            // BOTTOM CTA BANNER
            Container(
              width: double.infinity,
              color: AppColors.navyIndustrial,
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 64, vertical: 60),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        'Ready to Transform Your Manufacturing Capacity?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: isMobile ? 22 : 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Join hundreds of precision engineering MSMEs across Coimbatore, Hosur, Chennai, and Tamil Nadu industrial clusters.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14.5,
                          color: AppColors.slate300,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MachButton(
                            label: 'Get Started Now →',
                            variant: MachButtonVariant.accent,
                            size: MachButtonSize.large,
                            onPressed: () => context.go('/login'),
                          ),
                          const SizedBox(width: 14),
                          MachButton(
                            label: 'Login',
                            variant: MachButtonVariant.outline,
                            size: MachButtonSize.large,
                            onPressed: () => context.go('/login'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FOOTER
            Container(
              color: const Color(0xFF090D16),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: Center(
                child: Text(
                  '© 2026 Mach-Hunt Platform. AI-Powered Manufacturing Capacity-Sharing for MSMEs.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.slate500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroLeft(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.steelBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.steelBlue.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt, color: AppColors.steelBlueLight, size: 16),
              const SizedBox(width: 6),
              Text(
                'AI-POWERED MSME CAPACITY PLATFORM',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: AppColors.steelBlueLight,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Manufacturing Capacity, When You Need It.',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 32 : 46,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            height: 1.15,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Connect MSMEs. Share capacity. Find capacity. Build more.',
          style: GoogleFonts.inter(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: AppColors.slate300,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            MachButton(
              label: 'Get Started →',
              variant: MachButtonVariant.accent,
              size: MachButtonSize.large,
              onPressed: () => context.go('/login'),
            ),
            const SizedBox(width: 14),
            MachButton(
              label: 'Learn More',
              variant: MachButtonVariant.outline,
              size: MachButtonSize.large,
              onPressed: () => context.go('/login'),
            ),
          ],
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            _buildStatItem('1,400+', 'Machines Listed'),
            const SizedBox(width: 24),
            _buildStatItem('92%', 'AI Match Precision'),
            const SizedBox(width: 24),
            _buildStatItem('Coimbatore', 'Industrial Hub'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 19, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.slate400),
        ),
      ],
    );
  }

  Widget _buildHeroRight(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navyCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
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
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: AppColors.emerald, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE MATCH ENGINE',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: Colors.white),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.emerald.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                child: Text('98% CONFIDENCE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.emeraldLight)),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.navyIndustrial, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.bolt, size: 16, color: AppColors.amberWarm),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday."',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11.5, color: AppColors.slate300),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Matched Card Preview
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Kovai Precision Works', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.navyIndustrial)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(4)),
                      child: Text('92% MATCH', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('HAAS VF-4SS Super-Speed 4-Axis VMC · Coimbatore', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.slate600)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('₹1,200 / hr', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.steelBlue)),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, size: 13, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Text('Available Tomorrow', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.emerald)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MachButton(
            label: 'Explore Marketplace Now',
            variant: MachButtonVariant.secondary,
            isFullWidth: true,
            size: MachButtonSize.medium,
            onPressed: () => context.go('/login'),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required double width,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(22),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              color: AppColors.navyIndustrial,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.slate500,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowColumn(String title, IconData icon, List<_FlowStep> steps, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 0.5, color: color),
              ),
            ],
          ),
          const SizedBox(height: 20),
          for (var step in steps) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    step.desc,
                    style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate500, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.slate600,
          ),
        ),
      ),
    );
  }
}

class _FlowStep {
  final String title;
  final String desc;
  const _FlowStep(this.title, this.desc);
}
