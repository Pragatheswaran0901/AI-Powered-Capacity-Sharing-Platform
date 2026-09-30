import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_card.dart';
import 'package:machhunt/core/design_system/mach_domain_cards.dart';
import 'package:machhunt/core/design_system/mach_feedback_states.dart';
import 'package:machhunt/core/design_system/mach_page_header.dart';
import 'package:machhunt/core/design_system/mach_text_field.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/state/provider_state.dart';

class MyMachinesScreen extends StatefulWidget {
  const MyMachinesScreen({super.key});

  @override
  State<MyMachinesScreen> createState() => _MyMachinesScreenState();
}

class _MyMachinesScreenState extends State<MyMachinesScreen> {
  String _selectedStatusFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<({String key, String label})> _filterOptions = [
    (key: 'ALL', label: 'All Machines'),
    (key: 'AVAILABLE', label: 'Available'),
    (key: 'BUSY', label: 'Busy'),
    (key: 'MAINTENANCE', label: 'Maintenance'),
    (key: 'OFFLINE', label: 'Offline'),
  ];

  static const List<String> _categories = [
    'CNC Milling',
    'CNC Turning',
    'Laser Cutting',
    'VMC Machining',
    'Lathe',
    'Wire EDM',
    'Sheet Metal Fabrication',
    'MIG Welding',
    'Grinding',
  ];

  static const List<({String value, String label})> _editableStatuses = [
    (value: 'AVAILABLE', label: 'Available'),
    (value: 'BUSY', label: 'Busy'),
    (value: 'MAINTENANCE', label: 'Maintenance'),
    (value: 'OFFLINE', label: 'Offline'),
  ];

  @override
  void initState() {
    super.initState();
    _loadFleet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFleet() async {
    await providerState.fetchMyMachines();
  }

  bool _matchesFilter(MachineModel machine) {
    if (_selectedStatusFilter == 'ALL') return true;
    return machine.normalizedStatus == _selectedStatusFilter;
  }

  bool _matchesSearch(MachineModel machine) {
    if (_searchQuery.isEmpty) return true;
    final q = _searchQuery.toLowerCase();

    if (machine.name.toLowerCase().contains(q)) return true;
    if (machine.category.toLowerCase().contains(q)) return true;
    if (machine.manufacturer?.toLowerCase().contains(q) ?? false) return true;
    if (machine.model?.toLowerCase().contains(q) ?? false) return true;
    if (machine.locationAddress.toLowerCase().contains(q)) return true;

    for (final cap in machine.capabilities) {
      if (cap.process.toLowerCase().contains(q) ||
          cap.material.toLowerCase().contains(q)) {
        return true;
      }
    }

    return false;
  }

  void _resetFilters() {
    setState(() {
      _selectedStatusFilter = 'ALL';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _showEditMachineModal(MachineModel machine) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: machine.name);
    final manufacturerCtrl = TextEditingController(
      text: machine.manufacturer ?? '',
    );
    final modelCtrl = TextEditingController(text: machine.model ?? '');
    final yearCtrl = TextEditingController(
      text: machine.year?.toString() ?? '',
    );
    final rateCtrl = TextEditingController(
      text: machine.hourlyPrice.toStringAsFixed(0),
    );
    final minJobCtrl = TextEditingController(
      text: machine.minJobValue.toStringAsFixed(0),
    );
    final dimensionsCtrl = TextEditingController(
      text: machine.dimensionsCapacity ?? '',
    );
    final toleranceCtrl = TextEditingController(
      text: machine.precisionTolerance ?? '',
    );
    final locationCtrl = TextEditingController(text: machine.locationAddress);
    final descCtrl = TextEditingController(text: machine.description ?? '');

    String selectedCategory = _categories.contains(machine.category)
        ? machine.category
        : _categories.first;
    String selectedStatus =
        _editableStatuses.any((s) => s.value == machine.normalizedStatus)
        ? machine.normalizedStatus
        : 'AVAILABLE';
    bool operatorAvailable = machine.operatorAvailable;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 8,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.steelBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_note_rounded,
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
                          'Edit Machine Listing',
                          style: GoogleFonts.inter(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                        Text(
                          'Update technical specifications, pricing, or operational status.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 560,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(height: 16, color: AppColors.slate200),
                        const SizedBox(height: 8),
                        MachTextField(
                          label: 'Machine Name',
                          controller: nameCtrl,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Machine name is required.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Category',
                                value: selectedCategory,
                                items: [
                                  if (!_categories.contains(machine.category) &&
                                      machine.category.isNotEmpty)
                                    DropdownMenuItem(
                                      value: machine.category,
                                      child: Text(machine.category),
                                    ),
                                  for (final cat in _categories)
                                    DropdownMenuItem(
                                      value: cat,
                                      child: Text(cat),
                                    ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedCategory = val);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildDropdownField(
                                label: 'Operational Status',
                                value: selectedStatus,
                                items: [
                                  for (final st in _editableStatuses)
                                    DropdownMenuItem(
                                      value: st.value,
                                      child: Text(st.label),
                                    ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setModalState(() => selectedStatus = val);
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: MachTextField(
                                label: 'Manufacturer',
                                controller: manufacturerCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MachTextField(
                                label: 'Model',
                                controller: modelCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: MachTextField(
                                label: 'Year',
                                controller: yearCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: MachTextField(
                                label: 'Slot Rate (₹ / hr)',
                                controller: rateCtrl,
                                keyboardType: TextInputType.number,
                                validator: (v) {
                                  final parsed = double.tryParse(v ?? '');
                                  if (parsed == null || parsed <= 0) {
                                    return 'Enter valid rate';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MachTextField(
                                label: 'Min Job Value (₹)',
                                controller: minJobCtrl,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: MachTextField(
                                label: 'Working Envelope',
                                controller: dimensionsCtrl,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: MachTextField(
                                label: 'Precision Tolerance',
                                controller: toleranceCtrl,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        MachTextField(
                          label: 'Shop Floor Location',
                          controller: locationCtrl,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Location is required.'
                              : null,
                        ),
                        const SizedBox(height: 14),
                        MachTextField(
                          label: 'Technical Notes',
                          controller: descCtrl,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: operatorAvailable,
                          activeColor: AppColors.steelBlue,
                          onChanged: (val) =>
                              setModalState(() => operatorAvailable = val),
                          title: Text(
                            'Dedicated Machinist / Operator Included',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navyIndustrial,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                MachButton(
                  label: 'Cancel',
                  variant: MachButtonVariant.outline,
                  onPressed: isSaving ? null : () => Navigator.of(ctx).pop(),
                ),
                MachButton(
                  label: 'Save Changes',
                  icon: Icons.check_rounded,
                  variant: MachButtonVariant.accent,
                  isLoading: isSaving,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    setModalState(() => isSaving = true);

                    final payload = <String, dynamic>{
                      'name': nameCtrl.text.trim(),
                      'category': selectedCategory,
                      'status': selectedStatus,
                      'manufacturer': manufacturerCtrl.text.trim().isEmpty
                          ? null
                          : manufacturerCtrl.text.trim(),
                      'model': modelCtrl.text.trim().isEmpty
                          ? null
                          : modelCtrl.text.trim(),
                      'year': int.tryParse(yearCtrl.text.trim()),
                      'hourly_price':
                          double.tryParse(rateCtrl.text.trim()) ??
                          machine.hourlyPrice,
                      'min_job_value':
                          double.tryParse(minJobCtrl.text.trim()) ??
                          machine.minJobValue,
                      'dimensions_capacity': dimensionsCtrl.text.trim().isEmpty
                          ? null
                          : dimensionsCtrl.text.trim(),
                      'precision_tolerance': toleranceCtrl.text.trim().isEmpty
                          ? null
                          : toleranceCtrl.text.trim(),
                      'location_address': locationCtrl.text.trim(),
                      'description': descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      'operator_available': operatorAvailable,
                    };

                    final ok = await providerState.updateMachine(
                      machine.id,
                      payload,
                    );
                    if (!ctx.mounted) return;
                    Navigator.of(ctx).pop();

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Machine updated successfully.'
                              : (providerState.errorMessage ??
                                    'Unable to update machine.'),
                        ),
                        backgroundColor: ok
                            ? AppColors.emerald
                            : AppColors.errorRed,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.navyIndustrial,
          ),
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
              value: value,
              isExpanded: true,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                color: AppColors.navyIndustrial,
              ),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: providerState,
      builder: (context, _) {
        final allMachines = providerState.myMachines;
        final filteredFleet = allMachines
            .where((m) => _matchesFilter(m) && _matchesSearch(m))
            .toList();

        return Container(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Page Header
                MachPageHeader(
                  title: 'My Machines',
                  subtitle:
                      'Manage production fleet, monitor real-time utilization, and broadcast available capacity slots.',
                  primaryAction: MachButton(
                    label: '+ Add Machine',
                    variant: MachButtonVariant.accent,
                    onPressed: () => context.go('/add-machine'),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Search & Status Filter Toolbar
                _buildSearchAndFilterBar(),
                const SizedBox(height: 24),

                // 3. Content Area: Loading / Error / Empty / Responsive Grid
                if (providerState.isLoading && allMachines.isEmpty)
                  _buildSkeletonGrid()
                else if (providerState.errorMessage != null &&
                    allMachines.isEmpty)
                  MachErrorState(
                    title: 'Unable to load machines.',
                    message: 'Please try again.',
                    onRetry: _loadFleet,
                  )
                else if (allMachines.isEmpty)
                  MachEmptyState(
                    icon: Icons.precision_manufacturing_outlined,
                    title: 'No machines added yet.',
                    message:
                        'Add your first machine to start offering manufacturing capacity.',
                    actionLabel: '+ Add Machine',
                    onAction: () => context.go('/add-machine'),
                  )
                else if (filteredFleet.isEmpty)
                  MachEmptyState(
                    icon: Icons.search_off_rounded,
                    title: _searchQuery.isNotEmpty
                        ? 'No machines found.'
                        : 'No machines match this filter.',
                    message: 'Try changing your search or filters.',
                    actionLabel: 'Reset Filters',
                    onAction: _resetFilters,
                  )
                else
                  _buildResponsiveMachineGrid(filteredFleet),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchAndFilterBar() {
    return MachCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 860;

          final searchBox = TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: AppColors.navyIndustrial,
            ),
            decoration: InputDecoration(
              hintText: 'Search machines by name, category, or brand...',
              hintStyle: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slate400,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 20,
                color: AppColors.slate400,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: AppColors.slate400,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.slate50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.slate200,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppColors.steelBlue,
                  width: 1.5,
                ),
              ),
            ),
          );

          final filterChips = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filterOptions.map((opt) {
                final isSelected = _selectedStatusFilter == opt.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: isSelected
                        ? AppColors.navyIndustrial
                        : AppColors.slate100,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () =>
                          setState(() => _selectedStatusFilter = opt.key),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 8.5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.navyIndustrial
                                : AppColors.slate200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              opt.label,
                              style: GoogleFonts.inter(
                                fontSize: 12.5,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.slate600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [searchBox, const SizedBox(height: 12), filterChips],
            );
          }

          return Row(
            children: [
              Expanded(child: searchBox),
              const SizedBox(width: 16),
              filterChips,
            ],
          );
        },
      ),
    );
  }

  Widget _buildResponsiveMachineGrid(List<MachineModel> machines) {
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

        for (int i = 0; i < machines.length; i += columns) {
          final rowItems = machines.skip(i).take(columns).toList();
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (int j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: spacing),
                    Expanded(
                      child: j < rowItems.length
                          ? MachineCard.fromModel(
                              machine: rowItems[j],
                              onEdit: () => _showEditMachineModal(rowItems[j]),
                              onManageAvailability: () {
                                context.go(
                                  '/machine-availability/${rowItems[j].id}?name=${Uri.encodeComponent(rowItems[j].name)}',
                                );
                              },
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
          if (i + columns < machines.length) {
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

  Widget _buildSkeletonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns;
        if (constraints.maxWidth >= 960) {
          columns = 3;
        } else if (constraints.maxWidth >= 620) {
          columns = 2;
        } else {
          columns = 1;
        }

        const double spacing = 18.0;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < columns; i++) ...[
              if (i > 0) const SizedBox(width: spacing),
              const Expanded(child: _MachineSkeletonCard()),
            ],
          ],
        );
      },
    );
  }
}

class _MachineSkeletonCard extends StatelessWidget {
  const _MachineSkeletonCard();

  Widget _bar({
    required double width,
    required double height,
    double radius = 6,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.slate100,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bar(width: 84, height: 22),
                    _bar(width: 72, height: 22),
                  ],
                ),
                const SizedBox(height: 14),
                _bar(width: double.infinity, height: 18),
                const SizedBox(height: 8),
                _bar(width: 150, height: 14),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bar(width: 140, height: 14),
                    _bar(width: 38, height: 14),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _bar(width: 105, height: 24),
                    _bar(width: 120, height: 24),
                    _bar(width: 95, height: 24),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _bar(width: 120, height: 15),
                    _bar(width: 90, height: 15),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.slate200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(width: 56, height: 10),
                    const SizedBox(height: 6),
                    _bar(width: 80, height: 18),
                  ],
                ),
                Row(
                  children: [
                    _bar(width: 36, height: 36, radius: 8),
                    const SizedBox(width: 8),
                    _bar(width: 36, height: 36, radius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
