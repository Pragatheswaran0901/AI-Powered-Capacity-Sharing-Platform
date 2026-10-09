import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/widgets/app_background.dart';
import 'package:machhunt/state/auth_state.dart';

/// Mach-Hunt Enterprise Onboarding & Intent Selection Screen.
///
/// Features:
/// - Premium industrial AI SaaS aesthetic (#102A43 navy, #2563EB electric blue, #F97316 orange).
/// - Technical blueprint background grid with subtle ambient lighting.
/// - Clear brand identity, progress indicator, and headline: "Power Your Next Manufacturing Move".
/// - Highly interactive Capacity Provider and Capacity Seeker cards with staggered entrance,
///   smooth hover lift, glowing borders, animated arrow CTAs, and full keyboard accessibility.
/// - Preserves exact authentication state, onboarding auto-initialization, role switching,
///   and router navigation.
class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _hoveredRole;
  String? _focusedRole;
  String? _selectedRole;
  bool _isLoading = false;

  late final AnimationController _entranceController;
  late final Animation<double> _headerFadeAnimation;
  late final Animation<Offset> _headerSlideAnimation;
  late final Animation<double> _providerFadeAnimation;
  late final Animation<Offset> _providerSlideAnimation;
  late final Animation<double> _seekerFadeAnimation;
  late final Animation<Offset> _seekerSlideAnimation;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // Staggered entrance curves
    _headerFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.12),
      end: Offset.zero,
    ).animate(_headerFadeAnimation);

    _providerFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.20, 0.70, curve: Curves.easeOutCubic),
    );
    _providerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.10),
      end: Offset.zero,
    ).animate(_providerFadeAnimation);

    _seekerFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOutCubic),
    );
    _seekerSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.10),
      end: Offset.zero,
    ).animate(_seekerFadeAnimation);

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _selectRole(String role) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _selectedRole = role;
    });

    try {
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
    } catch (e) {
      debugPrint('[RoleSelectionScreen] Error selecting role: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (role == 'PROVIDER') {
      try {
        context.go('/provider-dashboard');
      } catch (e) {
        debugPrint('[RoleSelectionScreen] Navigation error: $e');
      }
    } else {
      try {
        context.go('/seeker-dashboard');
      } catch (e) {
        debugPrint('[RoleSelectionScreen] Navigation error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isReducedMotion = mediaQuery.disableAnimations;
    final screenWidth = mediaQuery.size.width;
    final isDesktop = screenWidth >= 768;
    final user = authState.currentUser;

    if (isReducedMotion && !_entranceController.isCompleted) {
      _entranceController.value = 1.0;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: IconButton(
            tooltip: 'Back to Login',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: Color(0xFF102A43),
              ),
            ),
            onPressed: _isLoading
                ? null
                : () {
                    try {
                      context.go('/login');
                    } catch (_) {}
                  },
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Compact Mach-Hunt brand emblem
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNavy.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.precision_manufacturing_rounded,
                size: 16,
                color: Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'MACH-HUNT',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.20),
                ),
              ),
              child: Text(
                'ENTERPRISE',
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          if (user != null) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.email,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      await authState.logout();
                      if (context.mounted) {
                        try {
                          context.go('/login');
                        } catch (_) {}
                      }
                    },
              icon: const Icon(
                Icons.logout_rounded,
                size: 15,
                color: Color(0xFF64748B),
              ),
              label: Text(
                'Sign Out',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: Stack(
          children: [
            // Subtle industrial blueprint grid overlay
            Positioned.fill(
              child: CustomPaint(
                painter: const _IndustrialGridPainter(),
              ),
            ),

            // Main Content Area
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 980),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Header section with animated slide and fade
                        AnimatedBuilder(
                          animation: _headerFadeAnimation,
                          builder: (context, child) {
                            return Opacity(
                              opacity: isReducedMotion ? 1.0 : _headerFadeAnimation.value,
                              child: Transform.translate(
                                offset: isReducedMotion
                                    ? Offset.zero
                                    : Offset(0, _headerSlideAnimation.value.dy * 50),
                                child: child,
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              // Elegant onboarding progress indicator pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  alignment: WrapAlignment.center,
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF2563EB),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "STEP 1 OF 2",
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                            color: const Color(0xFF2563EB),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "•",
                                      style: TextStyle(
                                        color: const Color(0xFF64748B).withValues(alpha: 0.5),
                                      ),
                                    ),
                                    Text(
                                      "INTENT & ROLE SELECTION",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: AppColors.primaryNavy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),

                              // Clear primary headline
                              Text(
                                "Power Your Next Manufacturing Move",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: isDesktop ? 34 : 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.8,
                                  height: 1.18,
                                  color: const Color(0xFF102A43),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Supporting explanatory text
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 640),
                                child: Text(
                                  "Select how your business will operate on the Mach-Hunt shared capacity network. You can seamlessly switch modes anytime from your dashboard.",
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                    color: const Color(0xFF52657A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Role Selection Cards Section
                        if (_isLoading) ...[
                          _buildLoadingWorkspaceState(),
                        ] else ...[
                          isDesktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildAnimatedCard(
                                        animation: _providerFadeAnimation,
                                        slideAnimation: _providerSlideAnimation,
                                        isReducedMotion: isReducedMotion,
                                        child: _buildRoleCard(
                                          roleId: 'PROVIDER',
                                          title: 'Capacity Provider',
                                          subtitle: 'Turn Idle Capacity Into Opportunity',
                                          description:
                                              'Connect with MSMEs seeking your manufacturing capabilities and monetize available machine time.',
                                          ctaLabel: 'List Your Capacity',
                                          icon: Icons.precision_manufacturing_rounded,
                                          accentColor: const Color(0xFFF97316),
                                          badgeLabel: 'MONETIZE CAPACITY',
                                          features: const [
                                            'List CNC, VMC, turning, and laser equipment',
                                            'Publish machine availability and shift calendars',
                                            'Receive procurement requests',
                                            'Manage orders and milestones',
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: _buildAnimatedCard(
                                        animation: _seekerFadeAnimation,
                                        slideAnimation: _seekerSlideAnimation,
                                        isReducedMotion: isReducedMotion,
                                        child: _buildRoleCard(
                                          roleId: 'SEEKER',
                                          title: 'Capacity Seeker',
                                          subtitle: 'Find the Right Manufacturing Partner',
                                          description:
                                              'Discover suitable manufacturers based on your production requirements, capabilities, and location.',
                                          ctaLabel: 'Find Manufacturing Partners',
                                          icon: Icons.travel_explore_rounded,
                                          accentColor: const Color(0xFF2563EB),
                                          badgeLabel: 'AI-POWERED SOURCING',
                                          features: const [
                                            'Describe requirements in plain English',
                                            'Extract manufacturing requirements using AI',
                                            'Compare matching manufacturers',
                                            'Track procurement requests and milestones',
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _buildAnimatedCard(
                                      animation: _providerFadeAnimation,
                                      slideAnimation: _providerSlideAnimation,
                                      isReducedMotion: isReducedMotion,
                                      child: _buildRoleCard(
                                        roleId: 'PROVIDER',
                                        title: 'Capacity Provider',
                                        subtitle: 'Turn Idle Capacity Into Opportunity',
                                        description:
                                            'Connect with MSMEs seeking your manufacturing capabilities and monetize available machine time.',
                                        ctaLabel: 'List Your Capacity',
                                        icon: Icons.precision_manufacturing_rounded,
                                        accentColor: const Color(0xFFF97316),
                                        badgeLabel: 'MONETIZE CAPACITY',
                                        features: const [
                                          'List CNC, VMC, turning, and laser equipment',
                                          'Publish machine availability and shift calendars',
                                          'Receive procurement requests',
                                          'Manage orders and milestones',
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    _buildAnimatedCard(
                                      animation: _seekerFadeAnimation,
                                      slideAnimation: _seekerSlideAnimation,
                                      isReducedMotion: isReducedMotion,
                                      child: _buildRoleCard(
                                        roleId: 'SEEKER',
                                        title: 'Capacity Seeker',
                                        subtitle: 'Find the Right Manufacturing Partner',
                                        description:
                                            'Discover suitable manufacturers based on your production requirements, capabilities, and location.',
                                        ctaLabel: 'Find Manufacturing Partners',
                                        icon: Icons.travel_explore_rounded,
                                        accentColor: const Color(0xFF2563EB),
                                        badgeLabel: 'AI-POWERED SOURCING',
                                        features: const [
                                          'Describe requirements in plain English',
                                          'Extract manufacturing requirements using AI',
                                          'Compare matching manufacturers',
                                          'Track procurement requests and milestones',
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                        ],

                        const SizedBox(height: 36),

                        // Subtle industrial network footer tag
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              size: 14,
                              color: Color(0xFF16A34A),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                "Unified MSME Ecosystem: Switch between Provider and Seeker anytime from your dashboard.",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF64748B),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard({
    required Animation<double> animation,
    required Animation<Offset> slideAnimation,
    required bool isReducedMotion,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, c) {
        return Opacity(
          opacity: isReducedMotion ? 1.0 : animation.value,
          child: Transform.translate(
            offset: isReducedMotion
                ? Offset.zero
                : Offset(0, slideAnimation.value.dy * 40),
            child: c,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildRoleCard({
    required String roleId,
    required String title,
    required String subtitle,
    required String description,
    required String ctaLabel,
    required IconData icon,
    required Color accentColor,
    required String badgeLabel,
    required List<String> features,
  }) {
    final isHovered = _hoveredRole == roleId;
    final isFocused = _focusedRole == roleId;
    final isSelected = _selectedRole == roleId;
    final isProvider = roleId == 'PROVIDER';

    // Warm or cool card gradient tones
    final topGradientColor = isProvider
        ? const Color(0xFFFFF7ED) // Orange tint
        : const Color(0xFFEFF6FF); // Blue tint

    return FocusableActionDetector(
      onFocusChange: (focused) {
        setState(() => _focusedRole = focused ? roleId : null);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hoveredRole = roleId),
        onExit: (_) => setState(() => _hoveredRole = null),
        child: GestureDetector(
          onTap: _isLoading ? null : () => _selectRole(roleId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(
              0,
              (isHovered || isFocused) ? -6 : 0,
              0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: (isHovered || isFocused || isSelected)
                    ? accentColor
                    : const Color(0xFFE2E8F0),
                width: (isHovered || isFocused || isSelected) ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isHovered || isFocused)
                      ? accentColor.withValues(alpha: 0.18)
                      : Colors.black.withValues(alpha: 0.04),
                  blurRadius: (isHovered || isFocused) ? 24 : 12,
                  offset: (isHovered || isFocused)
                      ? const Offset(0, 12)
                      : const Offset(0, 4),
                ),
                if (isHovered || isFocused)
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(17),
              child: Stack(
                children: [
                  // Subtle top ambient gradient wash
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            topGradientColor.withValues(
                              alpha: isHovered ? 0.85 : 0.45,
                            ),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Card Content
                  Padding(
                    padding: EdgeInsets.all(
                      MediaQuery.of(context).size.width >= 900 ? 28.0 : 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Animated Icon Container + Industrial Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Animated Icon Container
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: (isHovered || isFocused)
                                    ? accentColor
                                    : accentColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: accentColor.withValues(
                                    alpha: (isHovered || isFocused) ? 0.3 : 0.2,
                                  ),
                                ),
                                boxShadow: (isHovered || isFocused)
                                    ? [
                                        BoxShadow(
                                          color: accentColor.withValues(alpha: 0.30),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: AnimatedScale(
                                  duration: const Duration(milliseconds: 240),
                                  scale: (isHovered || isFocused) ? 1.08 : 1.0,
                                  child: Icon(
                                    icon,
                                    size: 28,
                                    color: (isHovered || isFocused)
                                        ? Colors.white
                                        : accentColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Industrial Badge
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: accentColor.withValues(alpha: 0.22),
                                  ),
                                ),
                                child: Text(
                                  badgeLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        // Title
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                            color: const Color(0xFF102A43),
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Description
                        Text(
                          description,
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: const Color(0xFF52657A),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Thin engineering divider
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 18),

                        // Features List
                        for (final feature in features) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 2),
                                  width: 17,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.check_rounded,
                                      size: 12,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Interactive CTA Button
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 48,
                          decoration: BoxDecoration(
                            color: accentColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: accentColor.withValues(
                                  alpha: (isHovered || isFocused) ? 0.35 : 0.20,
                                ),
                                blurRadius: (isHovered || isFocused) ? 14 : 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: _isLoading ? null : () => _selectRole(roleId),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        ctaLabel,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    AnimatedSlide(
                                      duration: const Duration(milliseconds: 200),
                                      offset: (isHovered || isFocused)
                                          ? const Offset(0.35, 0.0)
                                          : Offset.zero,
                                      child: const Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingWorkspaceState() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 500),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              strokeWidth: 3.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                _selectedRole == 'PROVIDER'
                    ? const Color(0xFFF97316)
                    : const Color(0xFF2563EB),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Configuring Your MSME Workspace",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF102A43),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedRole == 'PROVIDER'
                ? "Setting up machinery catalog, scheduling calendars, and capacity engine..."
                : "Initializing AI requirement parser, location discovery, and matching matrix...",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              height: 1.45,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle industrial blueprint technical grid background
class _IndustrialGridPainter extends CustomPainter {
  const _IndustrialGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = const Color(0xFF64748B).withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    const step = 36.0;

    for (double x = 18.0; x < size.width; x += step) {
      for (double y = 18.0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    // Top-left subtle ambient orange glow
    final orangeGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF97316).withValues(alpha: 0.06),
          const Color(0xFFF97316).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.2),
          radius: size.width * 0.35,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      size.width * 0.35,
      orangeGlowPaint,
    );

    // Bottom-right subtle ambient blue glow
    final blueGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.06),
          const Color(0xFF2563EB).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.85, size.height * 0.75),
          radius: size.width * 0.35,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      size.width * 0.35,
      blueGlowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
