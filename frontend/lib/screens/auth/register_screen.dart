import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/constants/app_typography.dart';
import 'package:machhunt/core/widgets/app_button.dart';
import 'package:machhunt/core/widgets/app_card.dart';
import 'package:machhunt/core/widgets/app_text_field.dart';
import 'package:machhunt/state/auth_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'SEEKER';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await authState.register(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      context.go('/onboarding-business');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authState.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AppCard(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.go('/login'),
                        ),
                        const SizedBox(width: 8),
                        const Text('Register MSME Account', style: AppTypography.displayMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Join Tamil Nadu\'s trusted manufacturing capacity-sharing network.', style: AppTypography.bodyMedium),
                    const SizedBox(height: 24),

                    // Role selection toggle
                    const Text('I am registering as:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedRole = 'SEEKER'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'SEEKER' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedRole == 'SEEKER' ? AppColors.primary : AppColors.border,
                                  width: _selectedRole == 'SEEKER' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.search, color: _selectedRole == 'SEEKER' ? AppColors.primary : AppColors.textMuted),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Capacity Seeker',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == 'SEEKER' ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text('I need parts made', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedRole = 'PROVIDER'),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedRole == 'PROVIDER' ? AppColors.primary.withOpacity(0.08) : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _selectedRole == 'PROVIDER' ? AppColors.primary : AppColors.border,
                                  width: _selectedRole == 'PROVIDER' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.precision_manufacturing, color: _selectedRole == 'PROVIDER' ? AppColors.primary : AppColors.textMuted),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Capacity Provider',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _selectedRole == 'PROVIDER' ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text('I own machines', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    AppTextField(
                      label: 'Full Name / Contact Person',
                      hint: 'e.g. Senthil Kumar',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline, size: 18),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Work Email Address',
                      hint: 'name@company.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined, size: 18),
                      validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Phone Number',
                      hint: '+91 98421 98765',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.phone_outlined, size: 18),
                      validator: (val) => val == null || val.length < 10 ? 'Enter 10-digit mobile number' : null,
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Create Password',
                      hint: 'Minimum 6 characters',
                      controller: _passwordController,
                      obscureText: true,
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      validator: (val) => val == null || val.length < 6 ? 'Minimum 6 characters' : null,
                    ),
                    const SizedBox(height: 24),

                    ListenableBuilder(
                      listenable: authState,
                      builder: (context, _) {
                        return AppButton(
                          label: 'Create Account & Continue',
                          isLoading: authState.isLoading,
                          onPressed: _handleRegister,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already registered? ", style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('Sign In', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        ),
                      ],
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
