import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/state/auth_state.dart';

class _DemoAccount {
  final String name;
  final String email;
  final String password;
  final String roleLabel;
  final IconData icon;

  const _DemoAccount({
    required this.name,
    required this.email,
    required this.password,
    required this.roleLabel,
    required this.icon,
  });
}

const List<_DemoAccount> _demoAccounts = [
  _DemoAccount(
    name: 'Janika',
    email: 'janika@machhunt.demo',
    password: 'password123',
    roleLabel: 'Capacity Provider (Kovai Precision Works)',
    icon: Icons.factory_outlined,
  ),
  _DemoAccount(
    name: 'Pragatheswaran',
    email: 'pragatheswaran@machhunt.demo',
    password: 'password123',
    roleLabel: 'Capacity Provider',
    icon: Icons.precision_manufacturing_outlined,
  ),
  _DemoAccount(
    name: 'Jayanth',
    email: 'jayanth@machhunt.demo',
    password: 'password123',
    roleLabel: 'Capacity Seeker',
    icon: Icons.search_rounded,
  ),
  _DemoAccount(
    name: 'Reethika',
    email: 'reethika@machhunt.demo',
    password: 'password123',
    roleLabel: 'Capacity Seeker',
    icon: Icons.business_center_outlined,
  ),
];

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDemoAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Select Demo Account",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyIndustrial,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Tap a demo user to populate credentials into the sign-in form.",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 18),
              ..._demoAccounts.map((account) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Icon(account.icon, color: AppColors.primary, size: 20),
                    ),
                    title: Text(
                      account.name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          account.email,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: AppColors.slate600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          account.roleLabel,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.steelBlue,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.slate400,
                    ),
                    onTap: () {
                      setState(() {
                        _emailController.text = account.email;
                        _passwordController.text = account.password;
                        _errorMessage = null;
                      });
                      Navigator.of(ctx).pop();
                    },
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    final clean = email.trim();
    if (clean.isEmpty) return false;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(clean);
  }

  Future<void> _handleSignIn() async {
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = "Email address is required.");
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _errorMessage = "Please enter a valid email address.");
      return;
    }

    if (password.isEmpty) {
      setState(() => _errorMessage = "Password is required.");
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await authState.login(email, password);

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      context.go('/role-selection');
    } else {
      setState(() {
        _errorMessage = authState.errorMessage ?? "Invalid email or password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.slate200, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Brand Logo & Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.precision_manufacturing,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "MACH-HUNT",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.navyIndustrial,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Manufacturing capacity,\nwhen you need it.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: AppColors.slate200),
                    const SizedBox(height: 24),

                    // Welcome Subhead
                    Text(
                      "Welcome to Mach-Hunt",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyIndustrial,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Sign in to continue",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.slate600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Error Alert Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(Icons.error_outline, size: 18, color: AppColors.errorRed),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  color: AppColors.errorRed,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    MachTextField(
                      controller: _emailController,
                      label: "Work or Company Email",
                      hint: "your@company.com",
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline, size: 18, color: AppColors.slate400),
                      onChanged: (_) {
                        if (_errorMessage != null) setState(() => _errorMessage = null);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Password Field
                    MachTextField(
                      controller: _passwordController,
                      label: "Password",
                      hint: "••••••••",
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.slate400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          size: 18,
                          color: AppColors.slate400,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      onChanged: (_) {
                        if (_errorMessage != null) setState(() => _errorMessage = null);
                      },
                    ),

                    const SizedBox(height: 24),

                    // [ Sign In ] Action Button
                    MachButton(
                      label: "Sign In",
                      variant: MachButtonVariant.primary,
                      size: MachButtonSize.large,
                      isFullWidth: true,
                      isLoading: _isSubmitting,
                      onPressed: _handleSignIn,
                    ),

                    const SizedBox(height: 12),

                    // [ Use Demo Account ] Action Button
                    MachButton(
                      label: "Use Demo Account",
                      variant: MachButtonVariant.outline,
                      size: MachButtonSize.large,
                      isFullWidth: true,
                      icon: Icons.account_circle_outlined,
                      onPressed: _showDemoAccountPicker,
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
}
