import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_card.dart';
import 'package:machhunt/core/design_system/mach_page_header.dart';
import 'package:machhunt/core/design_system/mach_text_field.dart';
import 'package:machhunt/state/provider_state.dart';
import 'package:machhunt/state/auth_state.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController(text: 'HAAS Automation');
  final _modelController = TextEditingController(text: 'VF-2SS');
  final _yearController = TextEditingController(text: '2023');
  final _dimensionsController = TextEditingController(text: '762 x 406 x 508 mm');
  final _toleranceController = TextEditingController(text: '±0.005 mm');
  final _hourlyRateController = TextEditingController(text: '950');
  final _minJobController = TextEditingController(text: '2500');
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedCategory = 'CNC Milling';
  String _selectedMaterial = 'Aluminium 6061';
  bool _operatorAvailable = true;

  final List<String> _categories = [
    'CNC Milling',
    'CNC Turning',
    'Laser Cutting',
    'VMC Machining',
    'Lathe',
    'Wire EDM',
    'Sheet Metal Fabrication',
    'MIG Welding',
  ];

  final List<String> _materials = [
    'Aluminium 6061',
    'Stainless Steel 304',
    'Mild Steel',
    'Brass',
    'Copper',
    'Delrin',
    'Titanium',
  ];

  @override
  void initState() {
    super.initState();
    if (authState.currentBusiness != null) {
      _addressController.text = authState.currentBusiness!.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _dimensionsController.dispose();
    _toleranceController.dispose();
    _hourlyRateController.dispose();
    _minJobController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final rate = double.tryParse(_hourlyRateController.text) ?? 950.0;
    final minJob = double.tryParse(_minJobController.text) ?? 2500.0;
    final year = int.tryParse(_yearController.text) ?? 2023;

    final success = await providerState.addMachine(
      name: _nameController.text.trim(),
      category: _selectedCategory,
      manufacturer: _manufacturerController.text.trim(),
      model: _modelController.text.trim(),
      year: year,
      description: _descController.text.trim(),
      dimensionsCapacity: _dimensionsController.text.trim(),
      precisionTolerance: _toleranceController.text.trim(),
      hourlyPrice: rate,
      minJobValue: minJob,
      operatorAvailable: _operatorAvailable,
      locationAddress: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : (authState.currentBusiness?.address ?? 'SIDCO Industrial Estate, Coimbatore'),
      latitude: authState.currentBusiness?.latitude ?? 11.0168,
      longitude: authState.currentBusiness?.longitude ?? 76.9558,
      photos: [
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800',
      ],
      capabilities: [
        {
          'process': _selectedCategory,
          'material': _selectedMaterial,
          'min_tolerance_mm': 0.005,
          'max_dimension_x': 800.0,
          'max_dimension_y': 500.0,
          'max_dimension_z': 500.0,
        },
      ],
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Machine added and listed on capacity catalog!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/my-machines');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(providerState.errorMessage ?? 'Failed to list machine'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 780),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MachPageHeader(
                title: 'Add Manufacturing Machine',
                subtitle: 'List your idle shop-floor capacity so seekers can discover and book production slots.',
                primaryAction: MachButton(
                  label: 'Back to Fleet',
                  icon: Icons.arrow_back,
                  variant: MachButtonVariant.outline,
                  onPressed: () => context.go('/my-machines'),
                ),
              ),
              const SizedBox(height: 24),

              MachCard(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'BASIC INFORMATION',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      MachTextField(
                        label: 'Machine Name / Listing Title',
                        hint: 'e.g. HAAS VF-2SS Super-Speed 4-Axis VMC',
                        controller: _nameController,
                        prefixIcon: const Icon(Icons.precision_manufacturing_outlined, size: 18),
                        validator: (val) => val == null || val.isEmpty ? 'Machine title is required.' : null,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Machine Category',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedCategory,
                                      isExpanded: true,
                                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: GoogleFonts.inter(fontSize: 13.5)))).toList(),
                                      onChanged: (val) => setState(() => _selectedCategory = val ?? 'CNC Milling'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Primary Material Supported',
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.slate200),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedMaterial,
                                      isExpanded: true,
                                      items: _materials.map((m) => DropdownMenuItem(value: m, child: Text(m, style: GoogleFonts.inter(fontSize: 13.5)))).toList(),
                                      onChanged: (val) => setState(() => _selectedMaterial = val ?? 'Aluminium 6061'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'HARDWARE & PRECISION SPECIFICATIONS',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: MachTextField(
                              label: 'Manufacturer',
                              hint: 'e.g. HAAS, Mazak, BFW',
                              controller: _manufacturerController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MachTextField(
                              label: 'Model',
                              hint: 'e.g. VF-2SS, Chakra BMV',
                              controller: _modelController,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MachTextField(
                              label: 'Year',
                              hint: '2023',
                              controller: _yearController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: MachTextField(
                              label: 'Bed Envelope (X x Y x Z)',
                              hint: '762 x 406 x 508 mm',
                              controller: _dimensionsController,
                              prefixIcon: const Icon(Icons.aspect_ratio, size: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MachTextField(
                              label: 'Precision Tolerance',
                              hint: '±0.005 mm',
                              controller: _toleranceController,
                              prefixIcon: const Icon(Icons.straighten, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        'COMMERCIAL TERMS & LOCATION',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppColors.slate500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: MachTextField(
                              label: 'Hourly Rate (₹ INR / Hour)',
                              hint: '950',
                              controller: _hourlyRateController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.currency_rupee, size: 18),
                              validator: (val) => val == null || val.isEmpty ? 'Hourly rate is required.' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MachTextField(
                              label: 'Minimum Order Value (₹ INR)',
                              hint: '2500',
                              controller: _minJobController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.payments_outlined, size: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      MachTextField(
                        label: 'Workshop / Shop Floor Location',
                        hint: 'Plot No., Industrial Estate, Coimbatore',
                        controller: _addressController,
                        prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
                      ),
                      const SizedBox(height: 16),

                      MachTextField(
                        label: 'Technical Description & Tooling Notes',
                        hint: 'Spindle RPM, magazine capacity, tool probe type, coolant setup, CAD/CAM support...',
                        controller: _descController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.slate50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.slate200),
                        ),
                        child: SwitchListTile(
                          value: _operatorAvailable,
                          onChanged: (val) => setState(() => _operatorAvailable = val),
                          title: Text(
                            'Dedicated Machinist / Operator Included',
                            style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial),
                          ),
                          subtitle: Text(
                            'Experienced CAM programmer & machinist will operate the machine during booked slots',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate500),
                          ),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.steelBlue,
                        ),
                      ),
                      const SizedBox(height: 28),

                      ListenableBuilder(
                        listenable: providerState,
                        builder: (context, _) {
                          return MachButton(
                            label: 'Publish Machine Listing',
                            icon: Icons.check_circle_outline,
                            variant: MachButtonVariant.accent,
                            size: MachButtonSize.large,
                            isLoading: providerState.isLoading,
                            onPressed: _handleSubmit,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
