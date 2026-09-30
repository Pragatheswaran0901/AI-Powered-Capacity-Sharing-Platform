import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:machhunt/core/theme/app_colors.dart';
import 'package:machhunt/core/widgets/app_background.dart';
import 'package:machhunt/state/auth_state.dart';

class BusinessOnboardingScreen extends StatefulWidget {
  const BusinessOnboardingScreen({super.key});

  @override
  State<BusinessOnboardingScreen> createState() =>
      _BusinessOnboardingScreenState();
}

class _BusinessOnboardingScreenState extends State<BusinessOnboardingScreen> {
  int _currentStep = 0; // 0 = Role Selection, 1 = Business Details
  String _selectedRole = 'SEEKER';

  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _industryController = TextEditingController(
    text: 'Precision Machining & Fabrication',
  );
  final _addressController = TextEditingController();
  final _pincodeController = TextEditingController(text: '641006');
  final _descriptionController = TextEditingController();
  String _selectedDistrict = 'Coimbatore';

  final List<String> _districts = [
    'Coimbatore',
    'Chennai',
    'Hosur',
    'Salem',
    'Tiruppur',
    'Erode',
    'Madurai',
    'Trichy',
    'Kanchipuram',
  ];

  // Provider specific tags
  final List<String> _availableCategories = [
    'CNC Milling',
    'VMC (Vertical Machining)',
    'CNC Turning',
    'Fiber Laser Cutting',
    'Wire EDM',
    'Surface Grinding',
  ];
  final Set<String> _selectedCategories = {
    'CNC Milling',
    'VMC (Vertical Machining)',
  };

  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = authState.currentUser;
    if (user != null) {
      _contactPersonController.text = user.fullName.isNotEmpty
          ? user.fullName
          : user.email.split('@')[0];
      _phoneController.text = user.phone;
      if (user.isProvider) {
        _selectedRole = 'PROVIDER';
      }
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _industryController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitOnboarding({bool isSkipping = false}) async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final bizName = _businessNameController.text.trim().isNotEmpty
        ? _businessNameController.text.trim()
        : "${_contactPersonController.text.trim()} Enterprises";
    final phone = _phoneController.text.trim().isNotEmpty
        ? _phoneController.text.trim()
        : "9876543210";
    final contact = _contactPersonController.text.trim().isNotEmpty
        ? _contactPersonController.text.trim()
        : (authState.currentUser?.fullName ?? "MSME Partner");

    final success = await authState.completeOnboarding(
      role: _selectedRole,
      fullName: contact,
      phone: phone,
      businessName: bizName,
      industry: _industryController.text.trim(),
      district: _selectedDistrict,
      pincode: _pincodeController.text.trim(),
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : "Industrial Estate, $_selectedDistrict",
      description: _descriptionController.text.trim(),
      gstin: _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim()
          : null,
      machineCategories: _selectedRole == 'PROVIDER'
          ? _selectedCategories.toList()
          : null,
      primaryProcesses: _selectedRole == 'PROVIDER'
          ? ['Milling', 'Turning']
          : null,
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    if (success) {
      if (_selectedRole == 'PROVIDER') {
        context.go('/provider-dashboard');
      } else {
        context.go('/seeker-dashboard');
      }
    } else {
      setState(() {
        _errorMessage =
            authState.errorMessage ??
            "Failed to complete onboarding. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark ? AppColors.slate700 : AppColors.slate200,
                    ),
                  ),
                  color: isDark ? AppColors.navyCard : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Progress
                        Row(
                          children: [
                            _buildStepIndicator(
                              0,
                              "1. Intent",
                              _currentStep >= 0,
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                color: _currentStep >= 1
                                    ? AppColors.steelBlue
                                    : AppColors.slate300,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                              ),
                            ),
                            _buildStepIndicator(
                              1,
                              "2. Profile",
                              _currentStep >= 1,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.errorRed.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.errorRed.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.errorRed,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Step Content
                        if (_currentStep == 0) _buildStep1RoleSelection(isDark),
                        if (_currentStep == 1)
                          _buildStep2BusinessProfile(isDark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.steelBlue : AppColors.slate300,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              "${step + 1}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? AppColors.steelBlue : AppColors.slate500,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1RoleSelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Welcome to Mach-Hunt",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.navyDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "How do you plan to use the manufacturing platform?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.slate500),
        ),
        const SizedBox(height: 28),

        // Choice 1: Seeker
        _buildRoleCard(
          role: 'SEEKER',
          title: "I need manufacturing capacity",
          subtitle:
              "Outsource components, request quotes, and access idle CNC, VMC, and laser cutting machines with verified precision.",
          icon: Icons.search,
          isDark: isDark,
        ),
        const SizedBox(height: 16),

        // Choice 2: Provider
        _buildRoleCard(
          role: 'PROVIDER',
          title: "I have manufacturing capacity",
          subtitle:
              "List your idle machines, monetize downtime, receive verified job requests, and grow MSME revenue in Tamil Nadu.",
          icon: Icons.precision_manufacturing,
          isDark: isDark,
        ),
        const SizedBox(height: 32),

        ElevatedButton(
          onPressed: () {
            setState(() {
              _currentStep = 1;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.steelBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Continue to Profile",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.steelBlue
                : (isDark ? AppColors.slate700 : AppColors.slate300),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? AppColors.steelBlue.withValues(alpha: 0.08)
              : (isDark
                    ? AppColors.navyDark.withValues(alpha: 0.4)
                    : AppColors.slate100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.steelBlue : AppColors.slate400,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navyDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.slate500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: role,
              groupValue: _selectedRole,
              activeColor: AppColors.steelBlue,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedRole = val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2BusinessProfile(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Business Profile Setup",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Complete your MSME profile for ${_selectedRole == 'PROVIDER' ? 'capacity listing' : 'procurement'}.",
            style: const TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
          const SizedBox(height: 20),

          // Business Name
          _buildTextField(
            "Company / Business Name",
            _businessNameController,
            "e.g. Precision Components Ltd",
            Icons.business,
          ),
          const SizedBox(height: 14),

          // Contact Person & Phone
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "Contact Person",
                  _contactPersonController,
                  "Full name",
                  Icons.person,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Phone Number",
                  _phoneController,
                  "9876543210",
                  Icons.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // District & State
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "District",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDistrict,
                      items: _districts
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedDistrict = val);
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? AppColors.navyDark.withValues(alpha: 0.6)
                            : AppColors.slate100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Pincode",
                  _pincodeController,
                  "641006",
                  Icons.location_on,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // GSTIN & Industry
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  "GSTIN (Optional)",
                  _gstinController,
                  "33AAAAA0000A1Z5",
                  Icons.receipt_long,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  "Industry Sector",
                  _industryController,
                  "Precision Engineering",
                  Icons.category,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Address
          _buildTextField(
            "Factory / Office Address",
            _addressController,
            "Plot / Street / Industrial Area",
            Icons.place,
          ),
          const SizedBox(height: 14),

          // If Provider: Machine categories
          if (_selectedRole == 'PROVIDER') ...[
            const Text(
              "Your Machine Capabilities",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _availableCategories.map((cat) {
                final isSelected = _selectedCategories.contains(cat);
                return FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.steelBlue,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(cat);
                      } else {
                        _selectedCategories.remove(cat);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Buttons: Complete & Skip
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _submitOnboarding(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.steelBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    "Complete Setup & Enter Platform",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
          const SizedBox(height: 10),

          // Progressive Skip
          TextButton(
            onPressed: _isSubmitting
                ? null
                : () => _submitOnboarding(isSkipping: true),
            child: const Text(
              "Set up details later →",
              style: TextStyle(fontSize: 13, color: AppColors.slate500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 18),
            filled: true,
            fillColor: isDark
                ? AppColors.navyDark.withValues(alpha: 0.6)
                : AppColors.slate100,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
