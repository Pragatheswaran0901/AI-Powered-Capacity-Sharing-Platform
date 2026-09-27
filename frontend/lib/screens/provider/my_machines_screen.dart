import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_badges.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_card.dart';
import 'package:machhunt/core/design_system/mach_domain_cards.dart';
import 'package:machhunt/core/design_system/mach_feedback_states.dart';
import 'package:machhunt/core/design_system/mach_page_header.dart';
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

  final List<String> _filterOptions = ['ALL', 'AVAILABLE', 'BUSY', 'MAINTENANCE', 'OFFLINE'];

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

  List<MachineModel> _getDemoFallbackFleet() {
    return [
      MachineModel(
        id: 'demo-m1',
        businessId: 'demo-biz-1',
        name: 'HAAS VF-2SS Super-Speed 4-Axis VMC',
        category: 'CNC Milling',
        manufacturer: 'HAAS Automation',
        model: 'VF-2SS',
        year: 2023,
        description: 'High-speed 12,000 RPM spindle, wireless probe, 30+1 side-mount tool changer. Optimized for precision aerospace & automotive components.',
        dimensionsCapacity: '762 x 406 x 508 mm',
        precisionTolerance: '±0.005 mm',
        hourlyPrice: 950.0,
        minJobValue: 3500.0,
        status: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        operatorAvailable: true,
        locationAddress: 'SIDCO Industrial Estate, Kurichi, Coimbatore',
        latitude: 10.9500,
        longitude: 76.9700,
        averageRating: 4.9,
        completedJobs: 84,
      ),
      MachineModel(
        id: 'demo-m2',
        businessId: 'demo-biz-1',
        name: 'Mazak Quick Turn 250MSY CNC Turning Center',
        category: 'CNC Turning',
        manufacturer: 'Yamazaki Mazak',
        model: 'QT-250MSY',
        year: 2022,
        description: 'Multi-tasking turning center with milling spindle and Y-axis. Handles high-tensile steel, titanium, and bronze shafts.',
        dimensionsCapacity: 'Ø 380 mm x 500 mm length',
        precisionTolerance: '±0.008 mm',
        hourlyPrice: 850.0,
        minJobValue: 2800.0,
        status: 'BUSY',
        verificationStatus: 'VERIFIED',
        operatorAvailable: true,
        locationAddress: 'SIDCO Industrial Estate, Kurichi, Coimbatore',
        latitude: 10.9500,
        longitude: 76.9700,
        averageRating: 4.8,
        completedJobs: 112,
      ),
      MachineModel(
        id: 'demo-m3',
        businessId: 'demo-biz-1',
        name: 'Bystronic BySprint Fiber 3015 6kW Laser',
        category: 'Laser Cutting',
        manufacturer: 'Bystronic',
        model: 'BySprint 3015 Fiber',
        year: 2021,
        description: 'Fiber laser cutting for sheets up to 25mm mild steel, 20mm stainless steel, and 12mm aluminium with nitrogen clean cut.',
        dimensionsCapacity: '3000 x 1500 mm bed',
        precisionTolerance: '±0.05 mm',
        hourlyPrice: 1200.0,
        minJobValue: 5000.0,
        status: 'AVAILABLE',
        verificationStatus: 'VERIFIED',
        operatorAvailable: true,
        locationAddress: 'SIDCO Industrial Estate, Kurichi, Coimbatore',
        latitude: 10.9500,
        longitude: 76.9700,
        averageRating: 4.9,
        completedJobs: 146,
      ),
      MachineModel(
        id: 'demo-m4',
        businessId: 'demo-biz-1',
        name: 'BFW Chakra BMV 60+ Heavy Duty VMC',
        category: 'VMC Machining',
        manufacturer: 'Bharat Fritz Werner (BFW)',
        model: 'Chakra BMV 60+',
        year: 2020,
        description: 'Rigid cast-iron column design for cast iron housing and forging dies milling with high chip-removal rates.',
        dimensionsCapacity: '1050 x 610 x 610 mm',
        precisionTolerance: '±0.010 mm',
        hourlyPrice: 780.0,
        minJobValue: 2500.0,
        status: 'MAINTENANCE',
        verificationStatus: 'VERIFIED',
        operatorAvailable: false,
        locationAddress: 'SIDCO Industrial Estate, Kurichi, Coimbatore',
        latitude: 10.9500,
        longitude: 76.9700,
        averageRating: 4.7,
        completedJobs: 67,
      ),
    ];
  }

  void _showMachineSpecsModal(MachineModel machine) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.steelBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.precision_manufacturing, color: AppColors.steelBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    machine.name,
                    style: GoogleFonts.inter(fontSize: 16.5, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial),
                  ),
                  Text(
                    '${machine.manufacturer ?? "Manufacturer"} · ${machine.model ?? "Model"}',
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.slate500),
                  ),
                ],
              ),
            ),
            MachStatusBadge(status: machine.status),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 20, color: AppColors.slate200),
                Text(
                  'TECHNICAL SPECIFICATIONS',
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.slate500),
                ),
                const SizedBox(height: 12),
                _buildSpecRow('Machine Category', machine.category),
                _buildSpecRow('Year of Manufacture', machine.year?.toString() ?? '2022'),
                _buildSpecRow('Working Envelope (X x Y x Z)', machine.dimensionsCapacity ?? 'Standard bed'),
                _buildSpecRow('Achievable Tolerance', machine.precisionTolerance ?? '±0.01 mm'),
                _buildSpecRow('Hourly Machine Rate', '₹${machine.hourlyPrice.toStringAsFixed(0)} / hr'),
                _buildSpecRow('Minimum Order Value', '₹${machine.minJobValue.toStringAsFixed(0)}'),
                _buildSpecRow('Dedicated Machinist / Operator', machine.operatorAvailable ? 'Provided by Shop Floor' : 'Seeker to Supply Machinist'),
                _buildSpecRow('Shop Floor Location', machine.locationAddress),
                const SizedBox(height: 14),
                if (machine.description != null && machine.description!.isNotEmpty) ...[
                  Text(
                    'OPERATIONAL NOTES',
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.slate500),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.slate50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Text(
                      machine.description!,
                      style: GoogleFonts.inter(fontSize: 13, height: 1.5, color: AppColors.slate700),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          MachButton(
            label: 'Close',
            variant: MachButtonVariant.outline,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          MachButton(
            label: 'Manage Availability',
            icon: Icons.calendar_month,
            variant: MachButtonVariant.primary,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go('/machine-availability/${machine.id}?name=${Uri.encodeComponent(machine.name)}');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate600)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.navyIndustrial),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: providerState,
      builder: (context, _) {
        final rawFleet = providerState.myMachines.isNotEmpty ? providerState.myMachines : _getDemoFallbackFleet();

        final filteredFleet = rawFleet.where((m) {
          final matchesStatus = _selectedStatusFilter == 'ALL' || m.status.toUpperCase() == _selectedStatusFilter;
          final matchesSearch = _searchQuery.isEmpty ||
              m.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              m.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (m.manufacturer?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          return matchesStatus && matchesSearch;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MachPageHeader(
                title: 'My Machines',
                subtitle: 'Manage production fleet, monitor real-time utilization, and broadcast available capacity slots.',
                primaryAction: MachButton(
                  label: 'Add Machine',
                  icon: Icons.add,
                  variant: MachButtonVariant.accent,
                  onPressed: () => context.go('/add-machine'),
                ),
              ),
              const SizedBox(height: 20),

              // Filter & Search Toolbar
              MachCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search machines by name, category, or brand...',
                          hintStyle: GoogleFonts.inter(fontSize: 13, color: AppColors.slate400),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.slate400),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterOptions.map((opt) {
                          final isSelected = _selectedStatusFilter == opt;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: ChoiceChip(
                              label: Text(
                                opt == 'ALL' ? 'All Machines' : opt[0] + opt.substring(1).toLowerCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? Colors.white : AppColors.slate600,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: AppColors.navyIndustrial,
                              backgroundColor: AppColors.slate100,
                              onSelected: (_) => setState(() => _selectedStatusFilter = opt),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (providerState.isLoading)
                const MachLoadingState(message: 'Loading shop floor machines...')
              else if (filteredFleet.isEmpty)
                MachEmptyState(
                  icon: Icons.precision_manufacturing_outlined,
                  title: 'No Machines Match Filter',
                  message: 'Try clearing the search query or changing the operational status filter.',
                  actionLabel: 'Reset Filters',
                  onAction: () {
                    setState(() {
                      _selectedStatusFilter = 'ALL';
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredFleet.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, idx) {
                    final machine = filteredFleet[idx];
                    return MachMachineCard(
                      name: machine.name,
                      category: machine.category,
                      manufacturer: machine.manufacturer,
                      model: machine.model,
                      hourlyPrice: machine.hourlyPrice,
                      location: machine.locationAddress,
                      dimensions: machine.dimensionsCapacity,
                      tolerance: machine.precisionTolerance,
                      status: machine.status,
                      isVerified: machine.isVerified,
                      onManageAvailability: () {
                        context.go('/machine-availability/${machine.id}?name=${Uri.encodeComponent(machine.name)}');
                      },
                      onEdit: () => _showMachineSpecsModal(machine),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
