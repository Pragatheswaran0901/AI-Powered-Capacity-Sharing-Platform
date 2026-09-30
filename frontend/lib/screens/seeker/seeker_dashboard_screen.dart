import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/booking_model.dart';
import 'package:machhunt/models/machine_model.dart';
import 'package:machhunt/models/match_model.dart';
import 'package:machhunt/state/auth_state.dart';
import 'package:machhunt/state/seeker_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:machhunt/core/config/maps_config.dart';
import 'package:machhunt/core/widgets/mach_hunt_map.dart';

class SeekerDashboardScreen extends StatefulWidget {
  const SeekerDashboardScreen({super.key});

  @override
  State<SeekerDashboardScreen> createState() => _SeekerDashboardScreenState();
}

class _SeekerDashboardScreenState extends State<SeekerDashboardScreen> {
  final _formKey = GlobalKey<FormState>();

  // 6 Structured Search Fields
  final _reqController = TextEditingController(
    text: '500 Aluminium Components',
  );
  final _quantityController = TextEditingController(text: '500');
  final _budgetController = TextEditingController(text: '25000');

  String _selectedProcess = 'CNC Milling';
  String _selectedMaterial = 'Aluminium';
  String _selectedLocation = 'Coimbatore';
  String? _selectedIndustry;

  // AI Natural Language Assistant
  final _aiPromptController = TextEditingController(
    text:
        'Need 500 aluminium brackets CNC machined within 7 days in Coimbatore',
  );
  bool _showAiPanel = false;
  bool _isParsingAi = false;
  bool _hasSearched = false;

  // Comparison tracking
  final Set<String> _selectedCompareIds = {};

  // Google Maps State & Card Synchronization
  final GlobalKey<MachHuntMapState> _mapKey = GlobalKey<MachHuntMapState>();
  String? _highlightedMachineId;

  final List<String> _processes = [
    'CNC Milling',
    'CNC Turning',
    'CNC Machining',
    'Laser Cutting',
    'VMC (Vertical Machining)',
    'Lathe',
    'Sheet Metal Fabrication',
    'Grinding',
    'Wire EDM',
  ];

  final List<String> _materials = [
    'Aluminium',
    'Aluminium 6061',
    'Mild Steel',
    'Stainless Steel 304',
    'Stainless Steel 316',
    'Brass',
    'Copper',
    'EN8 Steel',
    'Cast Iron',
    'Titanium',
  ];

  final List<String> _locations = [
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
    _loadInitialData();
  }

  @override
  void dispose() {
    _reqController.dispose();
    _quantityController.dispose();
    _budgetController.dispose();
    _aiPromptController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await seekerState.fetchIndustries();
    await seekerState.fetchMyRequirements();
    await seekerState.fetchMyBookings();
    await seekerState.fetchAvailableMachines(
      location: _selectedLocation,
      industry: _selectedIndustry,
    );

    // If seeker has an active requirement, populate form and pre-load matches
    if (seekerState.activeRequirement != null) {
      final req = seekerState.activeRequirement!;
      _reqController.text = req.title;
      _quantityController.text = req.quantity.toString();
      _budgetController.text = req.budget.toInt().toString();

      for (final p in _processes) {
        if (p.toLowerCase() == req.process.toLowerCase()) {
          _selectedProcess = p;
          break;
        }
      }
      for (final m in _materials) {
        if (m.toLowerCase() == req.material.toLowerCase()) {
          _selectedMaterial = m;
          break;
        }
      }
      for (final l in _locations) {
        if (l.toLowerCase() == req.preferredLocation.toLowerCase()) {
          _selectedLocation = l;
          break;
        }
      }

      // Fetch matches for active requirement with selected location
      _hasSearched = true;
      await seekerState.fetchMatches(req.id, location: _selectedLocation);
    }
  }

  String _getTimeGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Future<void> _handleAiParse() async {
    final prompt = _aiPromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isParsingAi = true);
    final parsed = await seekerState.parsePrompt(prompt);
    if (!mounted) return;
    setState(() => _isParsingAi = false);

    if (parsed != null) {
      setState(() {
        if (parsed.title.isNotEmpty) {
          _reqController.text = parsed.title;
        }
        if (parsed.quantity > 0) {
          _quantityController.text = parsed.quantity.toString();
        }
        if (parsed.estimatedBudget > 0) {
          _budgetController.text = parsed.estimatedBudget.toInt().toString();
        }

        for (final p in _processes) {
          if (p.toLowerCase().contains(parsed.process.toLowerCase()) ||
              parsed.process.toLowerCase().contains(p.toLowerCase())) {
            _selectedProcess = p;
            break;
          }
        }
        for (final m in _materials) {
          if (m.toLowerCase().contains(parsed.material.toLowerCase()) ||
              parsed.material.toLowerCase().contains(m.toLowerCase())) {
            _selectedMaterial = m;
            break;
          }
        }
        for (final l in _locations) {
          if (l.toLowerCase().contains(
                parsed.preferredLocation.toLowerCase(),
              ) ||
              parsed.preferredLocation.toLowerCase().contains(
                l.toLowerCase(),
              )) {
            _selectedLocation = l;
            break;
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '✓ Requirement specifications parsed and loaded into search fields.',
          ),
          backgroundColor: AppColors.emeraldDark,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleFindMatchingMachines() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = int.tryParse(_quantityController.text.trim()) ?? 1;
    final budget = double.tryParse(_budgetController.text.trim()) ?? 10000.0;
    final title = _reqController.text.trim();

    final payload = {
      'title': title,
      'description':
          'Manufacturing requirement for $qty units of $_selectedMaterial via $_selectedProcess in $_selectedLocation.',
      'process': _selectedProcess,
      'material': _selectedMaterial,
      'quantity': qty,
      'budget': budget,
      'preferred_location': _selectedLocation,
      'required_date': DateTime.now().toIso8601String().split('T').first,
      'delivery_deadline': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String()
          .split('T')
          .first,
      'max_distance_km': 100.0,
      'operator_required': true,
    };

    setState(() => _hasSearched = true);
    final newReq = await seekerState.createRequirement(payload);
    if (!mounted) return;

    if (newReq != null) {
      await seekerState.fetchMatches(
        newReq.id,
        location: _selectedLocation,
        industry: _selectedIndustry,
      );
      final coords = MapsConfig.getCoordinatesForLocation(_selectedLocation);
      _mapKey.currentState?.animateToLocation(
        coords,
        zoom: MapsConfig.defaultZoom,
      );
    }
  }

  Future<void> _handleLocationChange(String newLoc) async {
    setState(() {
      _selectedLocation = newLoc;
      _selectedCompareIds.clear();
      _highlightedMachineId = null;
    });
    seekerState.setSelectedLocation(newLoc);

    // Animate map to selected location
    final coords = MapsConfig.getCoordinatesForLocation(newLoc);
    _mapKey.currentState?.animateToLocation(
      coords,
      zoom: MapsConfig.defaultZoom,
    );

    // Fetch capacity for the new location from shared backend
    await seekerState.fetchAvailableMachines(
      location: newLoc,
      industry: _selectedIndustry,
    );

    if (seekerState.activeRequirement != null) {
      await seekerState.fetchMatches(
        seekerState.activeRequirement!.id,
        location: newLoc,
        industry: _selectedIndustry,
      );
    } else if (seekerState.myRequirements.isNotEmpty) {
      final req = seekerState.myRequirements.first;
      seekerState.setActiveRequirement(req);
      await seekerState.fetchMatches(
        req.id,
        location: newLoc,
        industry: _selectedIndustry,
      );
    }
  }

  Future<void> _handleIndustryChange(String? newInd) async {
    setState(() {
      _selectedIndustry = newInd;
      _selectedCompareIds.clear();
      _highlightedMachineId = null;
    });
    seekerState.setSelectedIndustry(newInd);

    await seekerState.fetchAvailableMachines(
      location: _selectedLocation,
      industry: newInd,
    );

    if (seekerState.activeRequirement != null) {
      await seekerState.fetchMatches(
        seekerState.activeRequirement!.id,
        location: _selectedLocation,
        industry: newInd,
      );
    } else if (seekerState.myRequirements.isNotEmpty) {
      final req = seekerState.myRequirements.first;
      seekerState.setActiveRequirement(req);
      await seekerState.fetchMatches(
        req.id,
        location: _selectedLocation,
        industry: newInd,
      );
    }
  }

  void _handleToggleCompare(String machineId, bool selected) {
    setState(() {
      if (selected) {
        if (_selectedCompareIds.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can compare up to 3 machines simultaneously.'),
              backgroundColor: AppColors.navyIndustrial,
            ),
          );
          return;
        }
        _selectedCompareIds.add(machineId);
      } else {
        _selectedCompareIds.remove(machineId);
      }
    });
  }

  Future<String?> _resolveValidRequirementId({String? fallbackTitle}) async {
    // 1. If activeRequirement is set and belongs to this user's requirements, return its id
    if (seekerState.activeRequirement != null &&
        seekerState.myRequirements.any((r) => r.id == seekerState.activeRequirement!.id)) {
      return seekerState.activeRequirement!.id;
    }

    // 2. If user already has requirements, use the first one and set it as active
    if (seekerState.myRequirements.isNotEmpty) {
      final req = seekerState.myRequirements.first;
      seekerState.setActiveRequirement(req);
      return req.id;
    }

    // 3. Otherwise create a requirement for this authenticated seeker from current form values
    final qty = int.tryParse(_quantityController.text.trim()) ?? 100;
    final budget = double.tryParse(_budgetController.text.trim()) ?? 25000.0;
    final title = _reqController.text.trim().isNotEmpty
        ? _reqController.text.trim()
        : (fallbackTitle ?? '500 Aluminium Brackets (CNC Machining)');

    final newReq = await seekerState.createRequirement({
      'title': title,
      'description':
          'Manufacturing requirement for $qty units of $_selectedMaterial via $_selectedProcess in $_selectedLocation.',
      'process': _selectedProcess,
      'material': _selectedMaterial,
      'quantity': qty,
      'budget': budget,
      'preferred_location': _selectedLocation,
      'required_date': DateTime.now().toIso8601String().split('T').first,
      'delivery_deadline': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String()
          .split('T')
          .first,
      'max_distance_km': 100.0,
      'operator_required': true,
    });

    return newReq?.id;
  }

  Future<void> _handleBookCapacity(MatchResultModel match) async {
    final reqId = await _resolveValidRequirementId(
      fallbackTitle: 'Manufacturing Requirement for ${match.machineName}',
    );
    if (reqId == null || reqId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please specify requirement details before booking.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final qty = int.tryParse(_quantityController.text.trim()) ?? 100;
    final estimatedHours = (qty * 0.1).clamp(4.0, 80.0);
    final startDate = DateTime.now().add(const Duration(days: 1));
    final endDate = startDate.add(const Duration(days: 3));

    final success = await seekerState.requestBooking(
      requirementId: reqId,
      machineId: match.machineId,
      startDate: startDate.toIso8601String().split('T').first,
      endDate: endDate.toIso8601String().split('T').first,
      totalHours: estimatedHours,
      notes: 'Booked directly via Seeker Capacity Discovery Workspace.',
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Booking request for "${match.machineName}" sent to ${match.businessName}!',
          ),
          backgroundColor: AppColors.emeraldDark,
          action: SnackBarAction(
            label: 'View Bookings',
            textColor: Colors.white,
            onPressed: () => context.go('/bookings'),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            seekerState.errorMessage ?? 'Failed to submit booking request.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authState.currentUser;
    final biz = authState.currentBusiness;
    final userName =
        biz?.name ??
        (user?.fullName.isNotEmpty ?? false
            ? user!.fullName
            : 'Procurement Partner');

    return ListenableBuilder(
      listenable: seekerState,
      builder: (context, _) {
        final matches = seekerState.currentMatches;
        final availableMachines = seekerState.availableMachines;
        final myReqs = seekerState.myRequirements;
        final myBookings = seekerState.myBookings;
        final isLoading = seekerState.isLoading;

        // Metric counts
        final activeReqCount = myReqs
            .where((r) => r.status == 'OPEN' || r.status == 'ACTIVE')
            .length;
        final activeBookingsCount = myBookings
            .where(
              (b) =>
                  b.status == 'IN_PROGRESS' ||
                  b.status == 'CONFIRMED' ||
                  b.status == 'PENDING',
            )
            .length;
        final availableMatchesCount = matches.isNotEmpty
            ? matches.length
            : (availableMachines.isNotEmpty
                  ? availableMachines.length
                  : myReqs.fold<int>(0, (sum, r) => sum + r.matchedCount));

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _loadInitialData,
            color: AppColors.steelBlue,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. DASHBOARD HEADER: GREETING & SUMMARY PILLS
                  _buildDashboardHeader(
                    userName: userName,
                    activeReqCount: activeReqCount,
                    activeBookingsCount: activeBookingsCount,
                    availableMatchesCount: availableMatchesCount,
                  ),
                  const SizedBox(height: 18),

                  // 2. PRIMARY REQUIREMENT SEARCH / CONTROL PANEL
                  _buildRequirementSearchPanel(isLoading),
                  const SizedBox(height: 24),

                  // 3. AVAILABLE CAPACITY MAP (Google Maps Platform)
                  _buildCapacityMapSection(
                    matches,
                    availableMachines,
                    isLoading,
                  ),
                  const SizedBox(height: 28),

                  // 4. RECOMMENDED MANUFACTURING CAPACITY SECTION
                  _buildRecommendedCapacitySection(
                    matches,
                    availableMachines,
                    isLoading,
                  ),
                  const SizedBox(height: 36),

                  // 5. LOWER DASHBOARD: ACTIVE BOOKINGS / RECENT ACTIVITY
                  _buildActiveBookingsSection(myBookings),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // FLOATING COMPARE BAR IF MACHINES SELECTED
          bottomNavigationBar: _selectedCompareIds.length >= 2
              ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navyIndustrial,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.compare_arrows_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedCompareIds.length} capacity options selected',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () =>
                                  setState(() => _selectedCompareIds.clear()),
                              child: Text(
                                'Clear',
                                style: GoogleFonts.inter(
                                  color: AppColors.slate300,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            MachButton(
                              label: 'Compare Now →',
                              variant: MachButtonVariant.primary,
                              size: MachButtonSize.small,
                              onPressed: () async {
                                final reqId =
                                    seekerState.activeRequirement?.id ?? '';
                                final ok = await seekerState.compareMachines(
                                  reqId,
                                  _selectedCompareIds.toList(),
                                );
                                if (ok && context.mounted) {
                                  context.go('/compare');
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTopLocationSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate300, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ['Coimbatore', 'Tiruppur'].contains(_selectedLocation)
              ? _selectedLocation
              : 'Coimbatore',
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20,
            color: AppColors.secondarySlate,
          ),
          isDense: true,
          style: GoogleFonts.inter(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
          items: const [
            DropdownMenuItem(
              value: 'Coimbatore',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.machBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Coimbatore',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Tiruppur',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: AppColors.machBlue,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Tiruppur',
                    style: TextStyle(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          onChanged: (newLoc) {
            if (newLoc != null && newLoc != _selectedLocation) {
              _handleLocationChange(newLoc);
            }
          },
        ),
      ),
    );
  }

  // =========================================================================
  // 1. DASHBOARD HEADER
  // =========================================================================
  Widget _buildDashboardHeader({
    required String userName,
    required int activeReqCount,
    required int activeBookingsCount,
    required int availableMatchesCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 720;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${_getTimeGreeting()}, $userName',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        _buildTopLocationSelector(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Find manufacturing capacity for your next production requirement.',
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.secondarySlate,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => context.go('/my-requirements'),
                        icon: const Icon(
                          Icons.assignment_outlined,
                          size: 16,
                          color: AppColors.machBlue,
                        ),
                        label: Text(
                          'My Requirements',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.machBlue,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.machBlue,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTimeGreeting()}, $userName',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find manufacturing capacity for your next production requirement.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTopLocationSelector(),
                      const SizedBox(width: 12),
                      TextButton.icon(
                        onPressed: () => context.go('/my-requirements'),
                        icon: const Icon(
                          Icons.assignment_outlined,
                          size: 16,
                          color: AppColors.machBlue,
                        ),
                        label: Text(
                          'My Requirements',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.machBlue,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.machBlue,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Summary Metric Pills
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildSummaryPill(
                label: 'Active Requirements',
                count: '$activeReqCount',
                icon: Icons.assignment_outlined,
                accentColor: AppColors.machBlue,
                onTap: () => context.go('/my-requirements'),
              ),
              _buildSummaryPill(
                label: 'Active Bookings',
                count: '$activeBookingsCount',
                icon: Icons.precision_manufacturing_outlined,
                accentColor: AppColors.machOrange,
                onTap: () => context.go('/bookings'),
              ),
              _buildSummaryPill(
                label: 'Available Matches',
                count: '$availableMatchesCount',
                icon: Icons.bolt_rounded,
                accentColor: AppColors.successGreen,
                onTap: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required String count,
    required IconData icon,
    required Color accentColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: accentColor),
            const SizedBox(width: 6),
            Text(
              count,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.secondarySlate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // 2. PRIMARY REQUIREMENT SEARCH / CONTROL PANEL
  // =========================================================================
  Widget _buildRequirementSearchPanel(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // AI Assistant Toggle Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.machBlue,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'What do you need to manufacture?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryNavy,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => setState(() => _showAiPanel = !_showAiPanel),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4.5,
                    ),
                    decoration: BoxDecoration(
                      color: _showAiPanel
                          ? AppColors.machBlue.withValues(alpha: 0.1)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _showAiPanel
                            ? AppColors.machBlue
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 13,
                          color: AppColors.machBlue,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _showAiPanel
                              ? 'Hide AI Assistant'
                              : '✨ Parse with AI',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.machBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Collapsible AI Assistant Box
            if (_showAiPanel) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.slate700),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.psychology_outlined,
                          size: 16,
                          color: AppColors.steelBlueLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Natural Language Requirement Parser',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.steelBlueLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _aiPromptController,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'e.g. Need 500 aluminium brackets CNC machined within 7 days in Coimbatore',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.slate400,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFF1E293B),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(
                                  color: AppColors.slate600,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        MachButton(
                          label: 'Auto-Fill',
                          icon: Icons.auto_awesome,
                          variant: MachButtonVariant.accent,
                          size: MachButtonSize.small,
                          isLoading: _isParsingAi,
                          onPressed: _handleAiParse,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 7-Field Responsive Grid (with Industry from Master 33 Sectors)
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                if (width >= 1040) {
                  // Desktop: 2 balanced rows
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildRequirementField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child: _buildIndustryDropdown()),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildProcessDropdown()),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildMaterialDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildQuantityField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child: _buildBudgetField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 4, child: _buildLocationDropdown()),
                        ],
                      ),
                    ],
                  );
                } else if (width >= 620) {
                  // Tablet: 2 rows
                  return Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 4, child: _buildRequirementField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child: _buildIndustryDropdown()),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child: _buildProcessDropdown()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildMaterialDropdown()),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildQuantityField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: _buildBudgetField()),
                          const SizedBox(width: 10),
                          Expanded(flex: 3, child: _buildLocationDropdown()),
                        ],
                      ),
                    ],
                  );
                } else {
                  // Mobile: stacked
                  return Column(
                    children: [
                      _buildRequirementField(),
                      const SizedBox(height: 10),
                      _buildIndustryDropdown(),
                      const SizedBox(height: 10),
                      _buildProcessDropdown(),
                      const SizedBox(height: 10),
                      _buildMaterialDropdown(),
                      const SizedBox(height: 10),
                      _buildQuantityField(),
                      const SizedBox(height: 10),
                      _buildBudgetField(),
                      const SizedBox(height: 10),
                      _buildLocationDropdown(),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 18),

            // Large Primary Button: Find Matching Machines
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: isLoading ? null : _handleFindMatchingMachines,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                label: Text(
                  isLoading
                      ? 'Finding Matching Capacity...'
                      : 'Find Matching Machines',
                  style: GoogleFonts.inter(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.machBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Field Builders ---

  Widget _buildRequirementField() {
    return _wrapField(
      label: 'Requirement',
      child: TextFormField(
        controller: _reqController,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration('e.g. 500 Aluminium Components'),
        validator: (v) =>
            v == null || v.trim().isEmpty ? 'Enter requirement' : null,
      ),
    );
  }

  Widget _buildProcessDropdown() {
    return _wrapField(
      label: 'Process',
      child: DropdownButtonFormField<String>(
        value: _processes.contains(_selectedProcess)
            ? _selectedProcess
            : _processes.first,
        isExpanded: true,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration(null),
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
  }

  Widget _buildMaterialDropdown() {
    return _wrapField(
      label: 'Material',
      child: DropdownButtonFormField<String>(
        value: _materials.contains(_selectedMaterial)
            ? _selectedMaterial
            : _materials.first,
        isExpanded: true,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration(null),
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
  }

  Widget _buildQuantityField() {
    return _wrapField(
      label: 'Quantity',
      child: TextFormField(
        controller: _quantityController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration('500'),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Qty required';
          final n = int.tryParse(v.trim());
          if (n == null || n <= 0) return 'Valid qty';
          return null;
        },
      ),
    );
  }

  Widget _buildBudgetField() {
    return _wrapField(
      label: 'Budget (₹)',
      child: TextFormField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration('25000'),
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'Budget required';
          final n = double.tryParse(v.trim());
          if (n == null || n <= 0) return 'Valid budget';
          return null;
        },
      ),
    );
  }

  Widget _buildIndustryDropdown() {
    final industries = seekerState.industries;
    return _wrapField(
      label: 'Industry (33 Master Sectors)',
      child: DropdownButtonFormField<String?>(
        value: _selectedIndustry,
        isExpanded: true,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration(null),
        items: [
          const DropdownMenuItem<String?>(
            value: null,
            child: Text('All Industries', overflow: TextOverflow.ellipsis),
          ),
          ...industries.map(
            (ind) => DropdownMenuItem<String?>(
              value: ind,
              child: Text(ind, overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
        onChanged: (val) {
          _handleIndustryChange(val);
        },
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return _wrapField(
      label: 'Location',
      child: DropdownButtonFormField<String>(
        value: _locations.contains(_selectedLocation)
            ? _selectedLocation
            : _locations.first,
        isExpanded: true,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryNavy,
        ),
        decoration: _inputDecoration(null),
        items: _locations
            .map(
              (l) => DropdownMenuItem(
                value: l,
                child: Text(l, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: (val) {
          if (val != null) {
            _handleLocationChange(val);
          }
        },
      ),
    );
  }

  Widget _wrapField({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.secondarySlate,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedSlate,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.machBlue, width: 1.5),
      ),
    );
  }

  // =========================================================================
  // 3. AVAILABLE CAPACITY MAP (Google Maps Platform)
  // =========================================================================
  Widget _buildCapacityMapSection(
    List<MatchResultModel> matches,
    List<MachineModel> availableMachines,
    bool isLoading,
  ) {
    final markers = _buildMapMarkers(matches, availableMachines);
    final centerCoords = MapsConfig.getCoordinatesForLocation(
      _selectedLocation,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final mapHeight = isMobile ? 320.0 : 440.0;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Map Header Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: AppColors.machBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.map_rounded,
                              size: 18,
                              color: AppColors.machBlue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Available Manufacturing Capacity',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryNavy,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.emeraldDark.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: AppColors.emeraldDark,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Live Marketplace',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.emeraldDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Interactive Tamil Nadu capacity discovery • Tap pins for machine specs & booking',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.mutedSlate,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Location Pill & Marker Count
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.pin_drop_rounded,
                            size: 14,
                            color: AppColors.machBlue,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${markers.length} Active Pins',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.machBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.lightBorder),

              // Interactive Google Map Widget (Bounded Height)
              MachHuntMap(
                key: _mapKey,
                initialCenter: centerCoords,
                initialZoom: MapsConfig.defaultZoom,
                height: mapHeight,
                markers: markers,
                selectedMarkerId: _highlightedMachineId,
                isLoading: isLoading,
                locationName: _selectedLocation,
                onMarkerSelected: (marker) {
                  setState(() {
                    _highlightedMachineId = marker.id;
                  });
                },
                onBookCapacity: (marker) {
                  _onMarkerBookCapacity(marker);
                },
                onCompareCapacity: (marker) {
                  _handleToggleCompare(
                    marker.id,
                    !_selectedCompareIds.contains(marker.id),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<MachMapMarker> _buildMapMarkers(
    List<MatchResultModel> matches,
    List<MachineModel> availableMachines,
  ) {
    final markers = <MachMapMarker>[];
    final cityCoords = MapsConfig.getCoordinatesForLocation(_selectedLocation);

    if (matches.isNotEmpty) {
      for (int i = 0; i < matches.length; i++) {
        final m = matches[i];
        double lat;
        double lng;

        if (m.latitude != null && m.longitude != null) {
          lat = m.latitude!;
          lng = m.longitude!;
        } else {
          // Deterministic dispersion around city center
          final angle = (i * 2 * math.pi) / math.max(matches.length, 1);
          final radius = 0.012 * (1.0 + (i % 3) * 0.35);
          lat = cityCoords.latitude + radius * math.sin(angle);
          lng = cityCoords.longitude + radius * math.cos(angle) * 1.05;
        }

        markers.add(
          MachMapMarker(
            id: m.machineId,
            title: m.machineName,
            subtitle: m.businessName,
            category: m.machineCategory,
            hourlyPrice: m.hourlyPrice,
            latitude: lat,
            longitude: lng,
            distanceKm: m.scoreBreakdown.distanceKm,
            matchPercentage: m.matchPercentage,
            isAvailable: true,
            mapsUrl: m.googleMapsLink,
            companyName: m.companyName,
            industry: m.industry,
            city: m.city,
            originalData: m,
          ),
        );
      }
    } else if (availableMachines.isNotEmpty) {
      for (int i = 0; i < availableMachines.length; i++) {
        final mach = availableMachines[i];
        double lat;
        double lng;

        if (mach.latitude != 0.0 && mach.longitude != 0.0) {
          lat = mach.latitude;
          lng = mach.longitude;
        } else {
          final angle =
              (i * 2 * math.pi) / math.max(availableMachines.length, 1);
          final radius = 0.012 * (1.0 + (i % 3) * 0.35);
          lat = cityCoords.latitude + radius * math.sin(angle);
          lng = cityCoords.longitude + radius * math.cos(angle) * 1.05;
        }

        markers.add(
          MachMapMarker(
            id: mach.id,
            title: mach.name,
            subtitle: mach.businessName ?? 'Verified Capacity Partner',
            category: mach.category,
            hourlyPrice: mach.hourlyPrice,
            latitude: lat,
            longitude: lng,
            distanceKm: null,
            matchPercentage: null,
            isAvailable: mach.status.toUpperCase() == 'ACTIVE' ||
                mach.status.toUpperCase() == 'AVAILABLE',
            mapsUrl: mach.googleMapsLink,
            companyName: mach.companyName,
            industry: mach.industry,
            city: mach.city,
            originalData: mach,
          ),
        );
      }
    }

    return markers;
  }

  Future<void> _onMarkerBookCapacity(MachMapMarker marker) async {
    if (marker.originalData is MatchResultModel) {
      await _handleBookCapacity(marker.originalData as MatchResultModel);
    } else if (marker.originalData is MachineModel) {
      final mach = marker.originalData as MachineModel;
      final reqId = await _resolveValidRequirementId(
        fallbackTitle: 'Manufacturing Requirement for ${mach.name}',
      );
      if (reqId == null || reqId.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please specify requirement details before booking.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      final startDate = DateTime.now().add(const Duration(days: 1));
      final endDate = startDate.add(const Duration(days: 3));

      final success = await seekerState.requestBooking(
        requirementId: reqId,
        machineId: mach.id,
        startDate: startDate.toIso8601String().split('T').first,
        endDate: endDate.toIso8601String().split('T').first,
        totalHours: 20.0,
        notes: 'Booked directly via Seeker Capacity Discovery Map.',
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✓ Booking request for "${mach.name}" sent to ${mach.businessName ?? "partner"}!',
            ),
            backgroundColor: AppColors.emeraldDark,
            action: SnackBarAction(
              label: 'View Bookings',
              textColor: Colors.white,
              onPressed: () => context.go('/bookings'),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              seekerState.errorMessage ?? 'Failed to submit booking request.',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onCardTapped(String machineId, double? lat, double? lng) {
    setState(() {
      _highlightedMachineId = machineId;
    });
    if (lat != null && lng != null) {
      _mapKey.currentState?.animateToLocation(LatLng(lat, lng), zoom: 13.5);
    } else {
      final cityCoords = MapsConfig.getCoordinatesForLocation(
        _selectedLocation,
      );
      _mapKey.currentState?.animateToLocation(cityCoords, zoom: 13.0);
    }
  }

  // =========================================================================
  // 4. RECOMMENDED MANUFACTURING CAPACITY SECTION
  // =========================================================================
  Widget _buildRecommendedCapacitySection(
    List<MatchResultModel> matches,
    List<MachineModel> availableMachines,
    bool isLoading,
  ) {
    final matchCount = matches.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Section Title + Formula Explanation + Match Count Badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Manufacturing Capacity',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        'Showing capacity in: ',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.secondarySlate,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Text(
                          '📍 $_selectedLocation',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.machBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Ranked formula: Capability (40%) + Availability (20%) + Distance (15%) + Cost (15%) + Reliability (10%)',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.mutedSlate,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Tooltip(
                        message:
                            'Deterministic multi-dimensional matching evaluated across process/material capabilities (40%), verified time slots (20%), geographic proximity (15%), budget ceiling (15%), and past job reliability (10%).',
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 13.5,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondarySlate,
                  ),
                  children: [
                    const TextSpan(text: 'Found '),
                    TextSpan(
                      text: '$matchCount',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                    TextSpan(text: matchCount == 1 ? ' Match' : ' Matches'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Grid of Recommendation Cards or Empty / Loading States
        if (isLoading) ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.machBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Finding capacity in $_selectedLocation...',
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (matches.isEmpty) ...[
          _buildZeroMatchesState(),
        ] else ...[
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 960 ? 3 : (width >= 620 ? 2 : 1);

              return _buildCardGrid(matches, crossAxisCount);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildCardGrid(List<MatchResultModel> matches, int crossAxisCount) {
    final rows = <Widget>[];
    for (int i = 0; i < matches.length; i += crossAxisCount) {
      final chunk = matches.skip(i).take(crossAxisCount).toList();
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (int j = 0; j < chunk.length; j++) ...[
                  if (j > 0) const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _onCardTapped(
                        chunk[j].machineId,
                        chunk[j].latitude,
                        chunk[j].longitude,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _highlightedMachineId == chunk[j].machineId
                                ? AppColors.machBlue
                                : Colors.transparent,
                            width: 2.0,
                          ),
                          boxShadow: _highlightedMachineId == chunk[j].machineId
                              ? [
                                  BoxShadow(
                                    color: AppColors.machBlue.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: CapacityMatchCard.fromMatch(
                          match: chunk[j],
                          isSelectedForComparison: _selectedCompareIds.contains(
                            chunk[j].machineId,
                          ),
                          onToggleComparison: (val) => _handleToggleCompare(
                            chunk[j].machineId,
                            val ?? false,
                          ),
                          onBook: () => _handleBookCapacity(chunk[j]),
                        ),
                      ),
                    ),
                  ),
                ],
                // Pad empty slots in last row if needed
                for (int p = 0; p < crossAxisCount - chunk.length; p++) ...[
                  const SizedBox(width: 16),
                  const Expanded(child: SizedBox()),
                ],
              ],
            ),
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _buildZeroMatchesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.precision_manufacturing_outlined,
              size: 32,
              color: AppColors.mutedSlate,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _hasSearched
                ? 'No suitable manufacturing capacity found in $_selectedLocation.'
                : 'Enter your requirement above to find matching capacity',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNavy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _hasSearched
                ? 'Try adjusting your process, material, quantity, budget, or preferred location.'
                : 'Mach-Hunt will search active, verified machine fleet availability matching your exact engineering parameters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.mutedSlate,
              height: 1.4,
            ),
          ),
          if (_hasSearched && _selectedLocation != 'Coimbatore') ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _handleLocationChange('Coimbatore'),
              icon: const Icon(
                Icons.location_on,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                'Search Coimbatore',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.machBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // 4. LOWER DASHBOARD: ACTIVE BOOKINGS / RECENT ACTIVITY
  // =========================================================================
  Widget _buildActiveBookingsSection(List<BookingModel> bookings) {
    final activeBookings = bookings
        .where(
          (b) =>
              b.status.toUpperCase() == 'IN_PROGRESS' ||
              b.status.toUpperCase() == 'CONFIRMED' ||
              b.status.toUpperCase() == 'PENDING',
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Bookings & Production Activity',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Live orders currently in production or awaiting provider confirmation.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.secondarySlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context.go('/bookings'),
              child: Text(
                'View All Bookings →',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.machBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (activeBookings.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.mutedSlate,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No active bookings in progress',
                        style: GoogleFonts.inter(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select a recommended machine above and click "Book Capacity" to begin production.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.mutedSlate,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          for (final b in activeBookings.take(3)) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing,
                      color: AppColors.machBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              b.requirementTitle ?? 'Production Order',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                            const SizedBox(width: 8),
                            MachStatusBadge(status: b.status),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${b.machineName ?? "Machinery"} • ${b.businessName ?? b.providerName ?? "Provider"} • ${b.startDate} to ${b.endDate}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondarySlate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(b.totalAmount),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => context.go('/bookings'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'View Details',
                          style: GoogleFonts.inter(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.machBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}
