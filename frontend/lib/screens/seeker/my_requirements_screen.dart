import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/models/requirement_model.dart';
import 'package:machhunt/state/seeker_state.dart';

class MyRequirementsScreen extends StatefulWidget {
  const MyRequirementsScreen({super.key});

  @override
  State<MyRequirementsScreen> createState() => _MyRequirementsScreenState();
}

class _MyRequirementsScreenState extends State<MyRequirementsScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Active',
    'Matched',
    'Booked',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _loadRequirements();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRequirements() async {
    await seekerState.fetchMyRequirements();
  }

  List<RequirementModel> _filterRequirements(List<RequirementModel> all) {
    return all.where((req) {
      // 1. Text search
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesQuery =
            req.title.toLowerCase().contains(q) ||
            req.process.toLowerCase().contains(q) ||
            req.material.toLowerCase().contains(q) ||
            req.preferredLocation.toLowerCase().contains(q) ||
            req.id.toLowerCase().contains(q);
        if (!matchesQuery) return false;
      }

      // 2. Status tab filter
      final statusUpper = req.status.toUpperCase();
      switch (_selectedFilter) {
        case 'Active':
          return statusUpper == 'OPEN' ||
              statusUpper == 'ACTIVE' ||
              statusUpper == 'MATCHES_READY';
        case 'Matched':
          return req.matchedCount > 0 || statusUpper == 'MATCHES_READY';
        case 'Booked':
          return statusUpper == 'BOOKED' ||
              statusUpper == 'CONFIRMED' ||
              statusUpper == 'IN_PROGRESS';
        case 'Completed':
          return statusUpper == 'COMPLETED' || statusUpper == 'CLOSED';
        case 'Cancelled':
          return statusUpper == 'CANCELLED';
        case 'All':
        default:
          return true;
      }
    }).toList();
  }

  void _showRequirementDetails(RequirementModel req) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'REQ-${req.id.substring(0, req.id.length > 8 ? 8 : req.id.length).toUpperCase()}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    MachStatusBadge(status: req.status),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              req.title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.navyIndustrial,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              req.description.isNotEmpty
                  ? req.description
                  : 'No detailed description provided.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.slate600,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.slate200),
            const SizedBox(height: 16),
            Wrap(
              spacing: 20,
              runSpacing: 14,
              children: [
                _buildDetailPill('Process', req.process),
                _buildDetailPill('Material', req.material),
                _buildDetailPill('Quantity', '${req.quantity} units'),
                _buildDetailPill('Budget', Formatters.currency(req.budget)),
                _buildDetailPill('Location', req.preferredLocation),
                if (req.toleranceMm != null)
                  _buildDetailPill('Tolerance', '±${req.toleranceMm} mm'),
                if (req.dimensions != null && req.dimensions!.isNotEmpty)
                  _buildDetailPill('Dimensions', req.dimensions!),
                _buildDetailPill(
                  'Operator Required',
                  req.operatorRequired ? 'Yes' : 'No',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: MachButton(
                    label: 'View Matches (${req.matchedCount})',
                    icon: Icons.bolt_rounded,
                    variant: MachButtonVariant.primary,
                    size: MachButtonSize.medium,
                    onPressed: () {
                      Navigator.pop(context);
                      context.go(
                        '/matches/${req.id}?title=${Uri.encodeComponent(req.title)}',
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPill(String label, String value) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.navyIndustrial,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: seekerState,
      builder: (context, _) {
        final allReqs = seekerState.myRequirements;
        final filteredReqs = _filterRequirements(allReqs);
        final isLoading = seekerState.isLoading && allReqs.isEmpty;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _loadRequirements,
            color: AppColors.steelBlue,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  MachPageHeader(
                    title: 'My Requirements',
                    subtitle:
                        'Manage production RFQs, track matching machines, and view booking statuses.',
                    primaryAction: MachButton(
                      label: '+ New Requirement',
                      icon: Icons.add_circle_outline,
                      variant: MachButtonVariant.primary,
                      size: MachButtonSize.medium,
                      onPressed: () => context.go('/create-requirement'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Search + Filter Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search text box
                        TextField(
                          controller: _searchController,
                          onChanged: (val) =>
                              setState(() => _searchQuery = val.trim()),
                          style: GoogleFonts.inter(fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText:
                                'Search requirements by title, process, material, or location...',
                            hintStyle: GoogleFonts.inter(
                              color: AppColors.slate400,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              size: 19,
                              color: AppColors.slate400,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.clear_rounded,
                                      size: 16,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
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
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.steelBlue,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Filter Tabs
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final f in _filters) ...[
                                InkWell(
                                  onTap: () =>
                                      setState(() => _selectedFilter = f),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _selectedFilter == f
                                          ? AppColors.steelBlue
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _selectedFilter == f
                                            ? AppColors.steelBlue
                                            : AppColors.slate200,
                                      ),
                                    ),
                                    child: Text(
                                      f,
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: _selectedFilter == f
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: _selectedFilter == f
                                            ? Colors.white
                                            : AppColors.slate600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Requirements List or Empty State
                  if (isLoading) ...[
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ] else if (filteredReqs.isEmpty) ...[
                    _buildEmptyState(),
                  ] else ...[
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredReqs.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final req = filteredReqs[index];
                        return _buildRequirementCard(req);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 32,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'No requirements matching current filter'
                : 'No requirements created yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.navyIndustrial,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty || _selectedFilter != 'All'
                ? 'Try adjusting your search query or reset the filter tabs.'
                : 'Create your first manufacturing requirement or search available capacity directly on the Dashboard.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.slate500),
          ),
          const SizedBox(height: 20),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'All')
            MachButton(
              label: 'Reset Filters',
              variant: MachButtonVariant.outline,
              size: MachButtonSize.medium,
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedFilter = 'All';
                });
              },
            )
          else
            MachButton(
              label: 'Go to Capacity Discovery',
              icon: Icons.search_rounded,
              variant: MachButtonVariant.primary,
              size: MachButtonSize.medium,
              onPressed: () => context.go('/seeker-dashboard'),
            ),
        ],
      ),
    );
  }

  Widget _buildRequirementCard(RequirementModel req) {
    final reqIdDisplay =
        'REQ-${req.id.substring(0, req.id.length > 8 ? 8 : req.id.length).toUpperCase()}';
    final hasMatches = req.matchedCount > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: ID badge + Status badge + Matching Machines chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.slate100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.slate200),
                    ),
                    child: Text(
                      reqIdDisplay,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MachStatusBadge(status: req.status),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: hasMatches
                      ? const Color(0xFFEFF6FF)
                      : AppColors.slate100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: hasMatches
                        ? AppColors.steelBlue.withValues(alpha: 0.3)
                        : AppColors.slate200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      hasMatches
                          ? Icons.bolt_rounded
                          : Icons.hourglass_empty_rounded,
                      size: 13,
                      color: hasMatches
                          ? AppColors.steelBlue
                          : AppColors.slate500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${req.matchedCount} Matching Machines',
                      style: GoogleFonts.inter(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: hasMatches
                            ? AppColors.steelBlue
                            : AppColors.slate600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2: Title
          Text(
            req.title,
            style: GoogleFonts.inter(
              fontSize: 15.5,
              fontWeight: FontWeight.w800,
              color: AppColors.navyIndustrial,
            ),
          ),
          const SizedBox(height: 6),

          // Row 3: Meta (Process • Material • Qty • Budget • Location)
          Wrap(
            spacing: 12,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.precision_manufacturing_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${req.process} • ${req.material}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Qty: ${req.quantity}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Budget: ${Formatters.currency(req.budget)}',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.navyIndustrial,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.slate500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    req.preferredLocation,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      color: AppColors.slate600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.slate200),
          const SizedBox(height: 12),

          // Row 4: Actions (View Requirement, View Matches)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created: ${req.requiredDate.isNotEmpty ? req.requiredDate.split('T').first : 'Recently'}',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  color: AppColors.slate400,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () => _showRequirementDetails(req),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      'View Requirement',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  MachButton(
                    label: 'View Matches →',
                    variant: MachButtonVariant.primary,
                    size: MachButtonSize.small,
                    onPressed: () => context.go(
                      '/matches/${req.id}?title=${Uri.encodeComponent(req.title)}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
