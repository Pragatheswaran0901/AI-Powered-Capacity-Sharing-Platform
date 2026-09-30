import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/requirement_model.dart';
import 'package:machhunt/state/seeker_state.dart';

class CreateRequirementScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CreateRequirementScreen({super.key, this.initialData});

  @override
  State<CreateRequirementScreen> createState() =>
      _CreateRequirementScreenState();
}

class _CreateRequirementScreenState extends State<CreateRequirementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // AI Prompt controller
  final _aiPromptController = TextEditingController(
    text:
        'Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday.',
  );
  bool _isAnalyzingWithAi = false;
  InterpretedRequirementModel? _aiInterpreted;

  // Structured Form
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(
    text: '4-Axis VMC Aluminium Enclosures',
  );
  final _descriptionController = TextEditingController(
    text: 'High precision enclosures for electronic sub-assembly.',
  );
  final _quantityController = TextEditingController(text: '150');
  final _dimensionsController = TextEditingController(
    text: '180 x 120 x 45 mm',
  );
  final _toleranceController = TextEditingController(text: '0.01');
  final _budgetController = TextEditingController(text: '25000');
  final _locationController = TextEditingController(text: 'Coimbatore');
  final _maxDistanceController = TextEditingController(text: '50');
  final _qualityReqController = TextEditingController(
    text: 'CMM Inspection Certificate & Material Test Report required',
  );

  String _selectedProcess = 'CNC Milling';
  String _selectedMaterial = 'Aluminium 6061';
  final bool _operatorRequired = true;
  DateTime _deliveryDeadline = DateTime.now().add(const Duration(days: 7));
  bool _isSubmitting = false;

  final List<String> _processes = [
    'CNC Milling',
    'CNC Machining',
    'CNC Turning',
    'Laser Cutting',
    'VMC (Vertical Machining)',
    'Lathe',
    'Sheet Metal & Bending',
    'Wire EDM',
  ];

  final List<String> _materials = [
    'Aluminium 6061',
    'Aluminium',
    'Mild Steel (MS)',
    'Stainless Steel 304',
    'Brass',
    'Copper',
    'EN8 Steel',
    'Cast Iron',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) {
        _populateFromData(extra);
      }
    });
  }

  void _populateFromData(Map<String, dynamic> data) {
    setState(() {
      if (data['title'] != null) {
        _titleController.text = data['title'].toString();
      }
      if (data['process'] != null) {
        final p = data['process'].toString();
        for (var item in _processes) {
          if (item.toLowerCase() == p.toLowerCase()) {
            _selectedProcess = item;
            break;
          }
        }
      }
      if (data['material'] != null) {
        final m = data['material'].toString();
        for (var item in _materials) {
          if (item.toLowerCase() == m.toLowerCase()) {
            _selectedMaterial = item;
            break;
          }
        }
      }
      if (data['quantity'] != null) {
        _quantityController.text = data['quantity'].toString();
      }
      if (data['tolerance_mm'] != null) {
        _toleranceController.text = data['tolerance_mm'].toString();
      }
      if (data['budget'] != null) {
        _budgetController.text = data['budget'].toString();
      }
      if (data['preferred_location'] != null) {
        _locationController.text = data['preferred_location'].toString();
      }
      if (data['deadline_days'] != null) {
        final days = int.tryParse(data['deadline_days'].toString()) ?? 7;
        _deliveryDeadline = DateTime.now().add(Duration(days: days));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiPromptController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _dimensionsController.dispose();
    _toleranceController.dispose();
    _budgetController.dispose();
    _locationController.dispose();
    _maxDistanceController.dispose();
    _qualityReqController.dispose();
    super.dispose();
  }

  Future<void> _understandWithAI() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isAnalyzingWithAi = true;
      _aiInterpreted = null;
    });

    final res = await seekerState.parsePrompt(prompt);

    if (!mounted) return;
    setState(() {
      _isAnalyzingWithAi = false;
      _aiInterpreted = res;
    });

    if (res != null) {
      _populateFromData({
        'title': res.title,
        'process': res.process,
        'material': res.material,
        'quantity': res.quantity,
        'preferred_location': res.preferredLocation,
        'budget': res.estimatedBudget,
        'deadline_days': res.deadlineDays,
        'tolerance_mm': res.toleranceMm,
      });
    }
  }

  Future<void> _submitAndFindMatches() async {
    setState(() => _isSubmitting = true);

    final payload = {
      'title': _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Custom Manufacturing Order',
      'description': _descriptionController.text.trim(),
      'process': _selectedProcess,
      'material': _selectedMaterial,
      'quantity': int.tryParse(_quantityController.text.trim()) ?? 100,
      'dimensions': _dimensionsController.text.trim(),
      'tolerance_mm': double.tryParse(_toleranceController.text.trim()) ?? 0.01,
      'required_date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'delivery_deadline': DateFormat('yyyy-MM-dd').format(_deliveryDeadline),
      'preferred_location': _locationController.text.trim(),
      'max_distance_km':
          double.tryParse(_maxDistanceController.text.trim()) ?? 100.0,
      'budget': double.tryParse(_budgetController.text.trim()) ?? 25000.0,
      'quality_requirements': _qualityReqController.text.trim(),
      'operator_required': _operatorRequired,
    };

    final newReq = await seekerState.createRequirement(payload);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (newReq != null) {
      context.go(
        '/matches/${newReq.id}?title=${Uri.encodeComponent(newReq.title)}',
      );
    } else {
      // Fallback demo match ID if server simulated
      final fallbackId = "req-1";
      context.go(
        '/matches/$fallbackId?title=${Uri.encodeComponent(_titleController.text.trim())}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header
                MachPageHeader(
                  title: 'What do you need manufactured?',
                  subtitle:
                      'Describe requirements in your own words or provide exact engineering parameters.',
                  onBack: () => context.go('/seeker-dashboard'),
                ),
                const SizedBox(height: 24),

                // Mode Tabs
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: AppColors.steelBlue,
                    indicatorWeight: 3,
                    labelColor: AppColors.navyIndustrial,
                    unselectedLabelColor: AppColors.slate500,
                    labelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.auto_awesome),
                        text: 'AI Natural Language Input',
                      ),
                      Tab(
                        icon: Icon(Icons.tune),
                        text: 'Structured Blueprint Input',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Tab Content
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    return _tabController.index == 0
                        ? _buildAiInputMode()
                        : _buildStructuredInputMode();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiInputMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Input Card
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.slate200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DESCRIBE YOUR REQUIREMENT',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: AppColors.slate500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.steelBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'NATURAL LANGUAGE ENGINE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.steelBlue,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Large natural language input
              Container(
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.slate200, width: 1.2),
                ),
                child: TextField(
                  controller: _aiPromptController,
                  maxLines: 4,
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    color: AppColors.navyIndustrial,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Describe what you need in your own words...\ne.g. Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday.',
                    hintStyle: TextStyle(
                      color: AppColors.slate400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Example Prompt Chips
              Text(
                'QUICK EXAMPLES (CLICK TO PASTE):',
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.slate400,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildExampleChip(
                    'Need 4-axis VMC milling for 150 aluminium 6061 enclosures in Coimbatore by next Friday.',
                  ),
                  _buildExampleChip(
                    'Require 4kW fiber laser cutting for 50 mild steel panels in Peelamedu.',
                  ),
                  _buildExampleChip(
                    'Need CNC turning for 200 EN8 steel shafts with 0.01mm tolerance.',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // CTA to understand requirement with AI
              MachButton(
                label: 'Understand Requirement with AI →',
                icon: Icons.psychology,
                variant: MachButtonVariant.accent,
                size: MachButtonSize.large,
                isFullWidth: true,
                isLoading: _isAnalyzingWithAi,
                onPressed: _understandWithAI,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // AI UNDERSTOOD SECTION
        if (_isAnalyzingWithAi)
          const MachLoadingState(
            message:
                'AI is analyzing blueprint parameters and extracting tooling requirements...',
            height: 180,
          )
        else if (_aiInterpreted != null)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
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
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.emerald,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI UNDERSTOOD & STRUCTURED',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.emerald.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${(_aiInterpreted!.confidenceScore * 100).toInt()}% CONFIDENCE',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.emerald,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Extracted Specifications Grid
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildUnderstoodField(
                              'PROCESS',
                              _aiInterpreted!.process,
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'REQUIRED MACHINE',
                              '4-Axis VMC',
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'MATERIAL',
                              _aiInterpreted!.material,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUnderstoodField(
                              'QUANTITY',
                              '${_aiInterpreted!.quantity} units',
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'LOCATION',
                              _aiInterpreted!.preferredLocation,
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'DEADLINE',
                              'Next Friday (${_aiInterpreted!.deadlineDays} days)',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildUnderstoodField(
                              'ESTIMATED BUDGET',
                              Formatters.currency(
                                _aiInterpreted!.estimatedBudget,
                              ),
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'TOLERANCE',
                              '±${_aiInterpreted!.toleranceMm ?? 0.01} mm',
                            ),
                          ),
                          Expanded(
                            child: _buildUnderstoodField(
                              'OPERATOR',
                              'Required (Included)',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Primary CTA to Find Matching Capacity
                MachButton(
                  label: 'Find Matching Capacity →',
                  icon: Icons.bolt,
                  variant: MachButtonVariant.primary,
                  size: MachButtonSize.large,
                  isFullWidth: true,
                  isLoading: _isSubmitting,
                  onPressed: _submitAndFindMatches,
                ),
              ],
            ),
          )
        else
          // Helper banner before AI analysis
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.slate50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.slate200),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.steelBlue,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Click "Understand Requirement with AI →" to parse your technical needs and generate immediate verified machine matches.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.slate600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUnderstoodField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.slate400,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.navyIndustrial,
          ),
        ),
      ],
    );
  }

  Widget _buildExampleChip(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _aiPromptController.text = text;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.slate300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.arrow_outward,
              size: 12,
              color: AppColors.steelBlue,
            ),
            const SizedBox(width: 5),
            Text(
              text.length > 55 ? '${text.substring(0, 52)}...' : text,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStructuredInputMode() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1.2),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STRUCTURED SPECIFICATIONS',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(height: 18),

            MachTextField(
              controller: _titleController,
              label: 'Requirement Title',
              hint: 'e.g. Precision Gear Housing',
              isRequired: true,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manufacturing Process',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedProcess,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.slate200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.slate200,
                            ),
                          ),
                        ),
                        items: _processes
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p,
                                  style: GoogleFonts.inter(fontSize: 13.5),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedProcess = val);
                          }
                        },
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
                        'Material Specification',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.slate200,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: AppColors.slate200,
                            ),
                          ),
                        ),
                        items: _materials
                            .map(
                              (m) => DropdownMenuItem(
                                value: m,
                                child: Text(
                                  m,
                                  style: GoogleFonts.inter(fontSize: 13.5),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _selectedMaterial = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: MachTextField(
                    controller: _quantityController,
                    label: 'Batch Quantity (units)',
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MachTextField(
                    controller: _toleranceController,
                    label: 'Precision Tolerance (mm)',
                    hint: 'e.g. ±0.01',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: MachTextField(
                    controller: _locationController,
                    label: 'Preferred Location Hub',
                    hint: 'e.g. Coimbatore, SIDCO Kurichi',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: MachTextField(
                    controller: _budgetController,
                    label: 'Target Budget (₹)',
                    keyboardType: TextInputType.number,
                    isRequired: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            MachTextField(
              controller: _qualityReqController,
              label: 'Quality & Inspection Requirements',
              hint:
                  'e.g. CMM Inspection, Material Test Report, Surface Finish Ra 0.8',
            ),
            const SizedBox(height: 24),

            // Submit Button
            MachButton(
              label: 'Find Matching Capacity →',
              icon: Icons.bolt,
              variant: MachButtonVariant.primary,
              size: MachButtonSize.large,
              isFullWidth: true,
              isLoading: _isSubmitting,
              onPressed: _submitAndFindMatches,
            ),
          ],
        ),
      ),
    );
  }
}
