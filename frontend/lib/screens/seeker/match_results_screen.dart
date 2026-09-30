import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/models/requirement_model.dart';
import 'package:machhunt/state/seeker_state.dart';

class MatchResultsScreen extends StatefulWidget {
  final String requirementId;
  final String requirementTitle;

  const MatchResultsScreen({
    super.key,
    required this.requirementId,
    required this.requirementTitle,
  });

  @override
  State<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends State<MatchResultsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _requirementController;
  late final TextEditingController _quantityController;
  late final TextEditingController _budgetController;
  late final TextEditingController _aiPromptController;

  String _selectedProcess = 'CNC Milling';
  String _selectedMaterial = 'Aluminium';
  String _selectedLocation = 'Coimbatore';

  String _activeRequirementId = '';
  bool _showAiParser = false;
  bool _isParsingAi = false;
  bool _isSearching = false;
  final Set<String> _selectedForComparison = {};

  static const List<String> _processes = [
    'CNC Milling',
    'CNC Turning',
    'CNC Machining',
    'VMC Machining',
    'Laser Cutting',
    'Lathe',
    'Wire EDM',
    'Sheet Metal Fabrication',
    'MIG Welding',
    'TIG Welding',
    'Grinding',
  ];

  static const List<String> _materials = [
    'Aluminium',
    'Aluminium 6061',
    'Mild Steel',
    'Stainless Steel 304',
    'Stainless Steel 316',
    'Brass',
    'Copper',
    'EN8 Steel',
    'Cast Iron',
    'Delrin',
    'Titanium',
  ];

  static const List<String> _locations = [
    'Coimbatore',
    'Ganapathy',
    'SIDCO Kurichi',
    'Peelamedu',
    'Saravanampatti',
    'Hosur',
    'Chennai',
    'Ambattur',
    'Guindy',
    'Sriperumbudur',
    'Salem',
    'Tiruppur',
    'Erode',
    'Madurai',
    'Trichy',
    'Bengaluru',
  ];

  @override
  void initState() {
    super.initState();
    _activeRequirementId = widget.requirementId;
    _requirementController = TextEditingController(
      text:
          widget.requirementTitle.isNotEmpty &&
              widget.requirementTitle != 'Capacity Matches'
          ? widget.requirementTitle
          : '500 Aluminium Components',
    );
    _quantityController = TextEditingController(text: '500');
    _budgetController = TextEditingController(text: '25000');
    _aiPromptController = TextEditingController();

    _initializeData();
  }

  @override
  void dispose() {
    _requirementController.dispose();
    _quantityController.dispose();
    _budgetController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isSearching = true);

    // Load requirement details if an ID was passed
    if (_activeRequirementId.isNotEmpty) {
      final req = await seekerState.fetchRequirementDetail(
        _activeRequirementId,
      );
      if (req != null && mounted) {
        _populateFieldsFromRequirement(req);
      }
      await seekerState.fetchMatches(_activeRequirementId);
    } else if (seekerState.activeRequirement != null) {
      final req = seekerState.activeRequirement!;
      _activeRequirementId = req.id;
      _populateFieldsFromRequirement(req);
      await seekerState.fetchMatches(_activeRequirementId);
    } else {
      await seekerState.fetchMyRequirements();
      if (seekerState.myRequirements.isNotEmpty) {
        final req = seekerState.myRequirements.first;
        _activeRequirementId = req.id;
        if (mounted) _populateFieldsFromRequirement(req);
        await seekerState.fetchMatches(_activeRequirementId);
      }
    }

    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  void _populateFieldsFromRequirement(RequirementModel req) {
    setState(() {
      if (req.title.trim().isNotEmpty) {
        _requirementController.text = req.title.trim();
      }
      _selectedProcess = _resolveDropdownOption(
        req.process,
        _processes,
        'CNC Milling',
      );
      _selectedMaterial = _resolveDropdownOption(
        req.material,
        _materials,
        'Aluminium',
      );
      _quantityController.text = req.quantity.toString();
      _budgetController.text = req.budget.round().toString();
      _selectedLocation = _resolveLocationOption(req.preferredLocation);
    });
  }

  String _resolveDropdownOption(
    String value,
    List<String> options,
    String fallback,
  ) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return fallback;
    for (final opt in options) {
      if (opt.toLowerCase() == trimmed.toLowerCase()) return opt;
    }
    for (final opt in options) {
      if (opt.toLowerCase().contains(trimmed.toLowerCase()) ||
          trimmed.toLowerCase().contains(opt.toLowerCase())) {
        return opt;
      }
    }
    return fallback;
  }

  String _resolveLocationOption(String loc) {
    final trimmed = loc.trim();
    if (trimmed.isEmpty) return 'Coimbatore';
    for (final opt in _locations) {
      if (opt.toLowerCase() == trimmed.toLowerCase()) return opt;
    }
    for (final opt in _locations) {
      if (trimmed.toLowerCase().contains(opt.toLowerCase())) return opt;
    }
    return 'Coimbatore';
  }

  Future<void> _handleAiParse() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty || _isParsingAi) return;

    setState(() => _isParsingAi = true);
    final parsed = await seekerState.parsePrompt(prompt);
    if (!mounted) return;

    setState(() => _isParsingAi = false);

    if (parsed != null) {
      setState(() {
        _requirementController.text = parsed.title;
        _selectedProcess = _resolveDropdownOption(
          parsed.process,
          _processes,
          _selectedProcess,
        );
        _selectedMaterial = _resolveDropdownOption(
          parsed.material,
          _materials,
          _selectedMaterial,
        );
        _quantityController.text = parsed.quantity.toString();
        _budgetController.text = parsed.estimatedBudget.round().toString();
        _selectedLocation = _resolveLocationOption(parsed.preferredLocation);
        _showAiParser = false;
      });
    }
  }

  Future<void> _handleFindMatchingMachines() async {
    if (_isSearching) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSearching = true);

    final reqTitle = _requirementController.text.trim();
    final qty = int.parse(_quantityController.text.trim());
    final rawBudget = _budgetController.text
        .replaceAll(',', '')
        .replaceAll('₹', '')
        .trim();
    final budget = double.parse(rawBudget);

    final now = DateTime.now();
    final payload = <String, dynamic>{
      'title': reqTitle,
      'description':
          '$qty units of $_selectedMaterial via $_selectedProcess in $_selectedLocation.',
      'process': _selectedProcess,
      'material': _selectedMaterial,
      'quantity': qty,
      'dimensions': '150 x 80 x 25 mm',
      'tolerance_mm': 0.01,
      'required_date': DateFormat('yyyy-MM-dd').format(now),
      'delivery_deadline': DateFormat(
        'yyyy-MM-dd',
      ).format(now.add(const Duration(days: 7))),
      'preferred_location': _selectedLocation,
      'max_distance_km': 100.0,
      'budget': budget,
      'quality_requirements':
          'Standard ISO inspection & tolerance verification',
      'operator_required': true,
    };

    final createdReq = await seekerState.createRequirement(payload);
    if (!mounted) return;

    if (createdReq != null) {
      _activeRequirementId = createdReq.id;
      await seekerState.fetchMatches(createdReq.id);
    } else if (_activeRequirementId.isNotEmpty) {
      await seekerState.fetchMatches(_activeRequirementId);
    }

    if (mounted) {
      setState(() => _isSearching = false);
    }
  }

  void _toggleComparison(String machineId) {
    setState(() {
      if (_selectedForComparison.contains(machineId)) {
        _selectedForComparison.remove(machineId);
      } else {
        if (_selectedForComparison.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can compare up to 3 machines at once.'),
            ),
          );
          return;
        }
        _selectedForComparison.add(machineId);
      }
    });
  }

  Future<void> _goToComparison() async {
    if (_selectedForComparison.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 2 machines to compare.'),
        ),
      );
      return;
    }

    final reqId = _activeRequirementId.isNotEmpty
        ? _activeRequirementId
        : (seekerState.activeRequirement?.id ?? '');

    final success = await seekerState.compareMachines(
      reqId,
      _selectedForComparison.toList(),
    );

    if (mounted && success) {
      context.go('/compare');
    }
  }

  void _openBookingModal(MatchResultModel match) {
    final hoursController = TextEditingController(text: '16');
    final notesController = TextEditingController(
      text:
          'Manufacturing requirement: ${_requirementController.text.trim()} ($_selectedProcess • $_selectedMaterial)',
    );
    DateTime startDate = DateTime.now().add(const Duration(days: 1));
    DateTime endDate = DateTime.now().add(const Duration(days: 3));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final hours = double.tryParse(hoursController.text) ?? 16.0;
          final totalEst = hours * match.hourlyPrice;
          final platformFee = totalEst * 0.05;
          final grandTotal = totalEst + platformFee;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.steelBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.precision_manufacturing_rounded,
                    color: AppColors.steelBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Capacity: ${match.machineName}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navyIndustrial,
                        ),
                      ),
                      Text(
                        'Capacity Provider: ${match.businessName}',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.slate50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SLOT RATE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate400,
                                ),
                              ),
                              Text(
                                '${Formatters.currency(match.hourlyPrice)}/hr',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.steelBlue,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'MATCH SCORE',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate400,
                                ),
                              ),
                              Text(
                                '${match.matchPercentage}% Match',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.emerald,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    MachTextField(
                      controller: hoursController,
                      label: 'Required Machine Hours',
                      hint: '16',
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setDlgState(() {}),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 180),
                                ),
                              );
                              if (d != null) setDlgState(() => startDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'Start Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                startDate.toIso8601String().split('T').first,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: ctx,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime.now().add(
                                  const Duration(days: 180),
                                ),
                              );
                              if (d != null) setDlgState(() => endDate = d);
                            },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                              ),
                              child: Text(
                                endDate.toIso8601String().split('T').first,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    MachTextField(
                      controller: notesController,
                      label: 'Production Notes / Instructions',
                      hint:
                          'Tolerances, inspection requirements, delivery notes...',
                      maxLines: 2,
                    ),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: AppColors.slate200),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Capacity Cost ($hours hrs × ${Formatters.currency(match.hourlyPrice)}):',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slate600,
                          ),
                        ),
                        Text(
                          Formatters.currency(totalEst),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Protection & Escrow Fee (5%):',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slate600,
                          ),
                        ),
                        Text(
                          Formatters.currency(platformFee),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Amount:',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                        Text(
                          Formatters.currency(grandTotal),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.steelBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(color: AppColors.slate500),
                ),
              ),
              MachButton(
                label: 'Confirm Capacity Booking',
                icon: Icons.check_rounded,
                variant: MachButtonVariant.secondary,
                size: MachButtonSize.medium,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final reqId = _activeRequirementId.isNotEmpty
                      ? _activeRequirementId
                      : (seekerState.activeRequirement?.id ?? '');
                  final success = await seekerState.requestBooking(
                    requirementId: reqId,
                    machineId: match.machineId,
                    startDate: startDate.toIso8601String().split('T').first,
                    endDate: endDate.toIso8601String().split('T').first,
                    totalHours: hours,
                    notes: notesController.text.trim(),
                  );
                  if (mounted && success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Manufacturing capacity booked! Capacity provider has been notified.',
                        ),
                        backgroundColor: AppColors.emerald,
                      ),
                    );
                    context.go('/bookings');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: seekerState,
      builder: (context, _) {
        final matches = seekerState.currentMatches;
        final isLoading = _isSearching || seekerState.isLoading;
        final hasError =
            seekerState.errorMessage != null && !isLoading && matches.isEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. TOP: REQUIREMENT SEARCH / MATCHING PANEL
                        _buildRequirementSearchPanel(isLoading),
                        const SizedBox(height: 28),

                        // 2. MIDDLE: RECOMMENDED MANUFACTURING CAPACITY HEADER
                        _buildResultsHeader(matches.length),
                        const SizedBox(height: 18),

                        // 3. BOTTOM: LOADING / ERROR / ZERO MATCHES / RESPONSIVE GRID
                        if (isLoading)
                          const MachLoadingState(
                            message:
                                'Finding matching manufacturing capacity...',
                            height: 280,
                          )
                        else if (hasError)
                          MachErrorState(
                            title:
                                'Unable to find matching manufacturing capacity.',
                            message: 'Please try again.',
                            onRetry: () {
                              if (_activeRequirementId.isNotEmpty) {
                                seekerState.fetchMatches(_activeRequirementId);
                              } else {
                                _handleFindMatchingMachines();
                              }
                            },
                          )
                        else if (matches.isEmpty)
                          _buildZeroMatchesState()
                        else
                          _buildResponsiveMatchesGrid(matches),
                      ],
                    ),
                  ),
                ),
              ),

              // Floating Compare Bar when 1+ machines are selected
              if (_selectedForComparison.isNotEmpty)
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.navyIndustrial,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.compare_arrows_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '${_selectedForComparison.length} ${_selectedForComparison.length == 1 ? "Machine" : "Machines"} Selected for Comparison',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          MachButton(
                            label:
                                'Compare Capacity (${_selectedForComparison.length}/3)',
                            variant: MachButtonVariant.secondary,
                            size: MachButtonSize.small,
                            onPressed: _goToComparison,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequirementSearchPanel(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Optional AI Natural Language Parser Toggle Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.precision_manufacturing_outlined,
                      size: 17,
                      color: AppColors.steelBlue,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'MANUFACTURING REQUIREMENT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _showAiParser = !_showAiParser),
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppColors.steelBlue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showAiParser
                              ? 'Hide AI Natural Language Input'
                              : 'Describe in Natural Language (AI)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.steelBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_showAiParser) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _aiPromptController,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.navyIndustrial,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'e.g. I need 500 aluminium brackets CNC machined within 7 days in Coimbatore...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: AppColors.slate400,
                          ),
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    MachButton(
                      label: _isParsingAi ? 'Parsing...' : 'Parse with AI',
                      icon: Icons.auto_awesome,
                      variant: MachButtonVariant.secondary,
                      size: MachButtonSize.small,
                      isLoading: _isParsingAi,
                      onPressed: _handleAiParse,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Responsive 6-Field Grid: Requirement | Process | Material | Quantity | Budget | Location
            LayoutBuilder(
              builder: (context, constraints) {
                final reqField = _buildInputControl(
                  label: 'Requirement',
                  child: TextFormField(
                    key: const Key('requirement_input'),
                    controller: _requirementController,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter requirement'
                        : null,
                    decoration: _inputDecoration(
                      hintText: '500 Aluminium Components',
                    ),
                  ),
                );

                final processField = _buildInputControl(
                  label: 'Process',
                  child: DropdownButtonFormField<String>(
                    key: const Key('process_dropdown'),
                    initialValue: _processes.contains(_selectedProcess)
                        ? _selectedProcess
                        : _processes.first,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    decoration: _inputDecoration(),
                    items: _processes
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(p, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedProcess = val);
                    },
                  ),
                );

                final materialField = _buildInputControl(
                  label: 'Material',
                  child: DropdownButtonFormField<String>(
                    key: const Key('material_dropdown'),
                    initialValue: _materials.contains(_selectedMaterial)
                        ? _selectedMaterial
                        : _materials.first,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    decoration: _inputDecoration(),
                    items: _materials
                        .map(
                          (m) => DropdownMenuItem(
                            value: m,
                            child: Text(m, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedMaterial = val);
                    },
                  ),
                );

                final quantityField = _buildInputControl(
                  label: 'Quantity',
                  child: TextFormField(
                    key: const Key('quantity_input'),
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      if (n == null || n <= 0) return 'Invalid';
                      return null;
                    },
                    decoration: _inputDecoration(hintText: '500'),
                  ),
                );

                final budgetField = _buildInputControl(
                  label: 'Budget (₹)',
                  child: TextFormField(
                    key: const Key('budget_input'),
                    controller: _budgetController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    validator: (v) {
                      final cleaned = (v ?? '')
                          .replaceAll(',', '')
                          .replaceAll('₹', '')
                          .trim();
                      final n = double.tryParse(cleaned);
                      if (n == null || n <= 0) return 'Invalid';
                      return null;
                    },
                    decoration: _inputDecoration(
                      hintText: '25,000',
                      prefixText: '₹ ',
                    ),
                  ),
                );

                final locationField = _buildInputControl(
                  label: 'Location',
                  child: DropdownButtonFormField<String>(
                    key: const Key('location_dropdown'),
                    initialValue: _locations.contains(_selectedLocation)
                        ? _selectedLocation
                        : _locations.first,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.slate500,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                    decoration: _inputDecoration(),
                    items: _locations
                        .map(
                          (loc) => DropdownMenuItem(
                            value: loc,
                            child: Text(loc, overflow: TextOverflow.ellipsis),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedLocation = val);
                    },
                  ),
                );

                if (constraints.maxWidth >= 960) {
                  // Desktop: 6 fields in a single row
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 22, child: reqField),
                      const SizedBox(width: 12),
                      Expanded(flex: 16, child: processField),
                      const SizedBox(width: 12),
                      Expanded(flex: 15, child: materialField),
                      const SizedBox(width: 12),
                      Expanded(flex: 11, child: quantityField),
                      const SizedBox(width: 12),
                      Expanded(flex: 13, child: budgetField),
                      const SizedBox(width: 12),
                      Expanded(flex: 15, child: locationField),
                    ],
                  );
                } else if (constraints.maxWidth >= 600) {
                  // Tablet: 3 columns x 2 rows
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: reqField),
                          const SizedBox(width: 12),
                          Expanded(child: processField),
                          const SizedBox(width: 12),
                          Expanded(child: materialField),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: quantityField),
                          const SizedBox(width: 12),
                          Expanded(child: budgetField),
                          const SizedBox(width: 12),
                          Expanded(child: locationField),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Mobile: stacked vertically
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      reqField,
                      const SizedBox(height: 12),
                      processField,
                      const SizedBox(height: 12),
                      materialField,
                      const SizedBox(height: 12),
                      quantityField,
                      const SizedBox(height: 12),
                      budgetField,
                      const SizedBox(height: 12),
                      locationField,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 18),

            // Full-width Primary Search Button
            SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.steelBlue.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  key: const Key('find_matching_machines_button'),
                  onPressed: isLoading ? null : _handleFindMatchingMachines,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isLoading) ...[
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Finding Matching Capacity...',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ] else ...[
                        const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Find Matching Machines',
                          style: GoogleFonts.inter(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputControl({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({String? hintText, String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      prefixStyle: GoogleFonts.inter(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: AppColors.navyIndustrial,
      ),
      hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.slate200, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.steelBlue, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.2),
      ),
    );
  }

  Widget _buildResultsHeader(int matchCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 680;

        final titleAndFormula = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Recommended Manufacturing Capacity',
                    style: GoogleFonts.inter(
                      fontSize: isCompact ? 18 : 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.navyIndustrial,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message:
                      'Match score is calculated using capability, availability, distance, cost and provider reliability.',
                  child: Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Ranked formula: Capability (40%) + Availability (20%) + Distance (15%) + Cost (15%) + Reliability (10%)',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
          ],
        );

        final matchCountBadge = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.slate200),
          ),
          child: Text(
            'Found $matchCount ${matchCount == 1 ? "Match" : "Matches"}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyIndustrial,
            ),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleAndFormula,
              const SizedBox(height: 10),
              matchCountBadge,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: titleAndFormula),
            const SizedBox(width: 16),
            matchCountBadge,
          ],
        );
      },
    );
  }

  Widget _buildZeroMatchesState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.search_off_rounded,
                  size: 30,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No suitable manufacturing capacity found.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navyIndustrial,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try:\n• increasing your budget\n• changing location\n• selecting another process',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: AppColors.slate600,
                ),
              ),
              const SizedBox(height: 18),
              MachButton(
                label: 'Modify Requirement',
                icon: Icons.edit_outlined,
                variant: MachButtonVariant.outline,
                size: MachButtonSize.small,
                onPressed: () => context.go('/create-requirement'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveMatchesGrid(List<MatchResultModel> matches) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns;
        if (constraints.maxWidth >= 960) {
          columns = 3; // Desktop: 3 cards per row
        } else if (constraints.maxWidth >= 620) {
          columns = 2; // Tablet: 2 cards per row
        } else {
          columns = 1; // Mobile: 1 card per row
        }

        const double spacing = 18.0;
        final rows = <Widget>[];

        for (int i = 0; i < matches.length; i += columns) {
          final rowItems = matches.skip(i).take(columns).toList();
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: spacing),
                    Expanded(
                      child: j < rowItems.length
                          ? MachMatchCard(
                              matchPercentage: rowItems[j].matchPercentage,
                              businessName: rowItems[j].businessName,
                              machineName: rowItems[j].machineName,
                              machineCategory: rowItems[j].machineCategory,
                              manufacturer: rowItems[j].manufacturer,
                              model: rowItems[j].model,
                              year: rowItems[j].year,
                              locationAddress: rowItems[j].locationAddress,
                              hourlyPrice: rowItems[j].hourlyPrice,
                              capabilityScore:
                                  rowItems[j].scoreBreakdown.capabilityScore,
                              availabilityScore:
                                  rowItems[j].scoreBreakdown.availabilityScore,
                              distanceScore:
                                  rowItems[j].scoreBreakdown.distanceScore,
                              costScore: rowItems[j].scoreBreakdown.costScore,
                              reliabilityScore:
                                  rowItems[j].scoreBreakdown.reliabilityScore,
                              distanceKm: rowItems[j].scoreBreakdown.distanceKm,
                              matchReasons: rowItems[j].matchReasons,
                              capabilities: rowItems[j].capabilities,
                              isVerified: rowItems[j].isVerified,
                              operatorAvailable: rowItems[j].operatorAvailable,
                              status: rowItems[j].status,
                              rating: rowItems[j].averageRating,
                              completedJobs: rowItems[j].completedJobs,
                              isSelectedForComparison: _selectedForComparison
                                  .contains(rowItems[j].machineId),
                              onToggleComparison: (_) =>
                                  _toggleComparison(rowItems[j].machineId),
                              onBook: () => _openBookingModal(rowItems[j]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
          if (i + columns < matches.length) {
            rows.add(const SizedBox(height: spacing));
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows,
        );
      },
    );
  }
}
