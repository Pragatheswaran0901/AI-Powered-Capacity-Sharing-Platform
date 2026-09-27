import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/core/design_system/mach_design_system.dart';
import 'package:machhunt/state/provider_state.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  final String machineId;
  final String machineName;

  const AvailabilityCalendarScreen({
    super.key,
    required this.machineId,
    required this.machineName,
  });

  @override
  State<AvailabilityCalendarScreen> createState() => _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState extends State<AvailabilityCalendarScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _slots = [];

  @override
  void initState() {
    super.initState();
    _fetchCalendar();
  }

  Future<void> _fetchCalendar() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.get(ApiEndpoints.machineAvailability(widget.machineId));
      if (res is List && res.isNotEmpty) {
        _slots = res.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Generate default 14 days schedule
        final today = DateTime.now();
        _slots = List.generate(14, (i) {
          final d = today.add(Duration(days: i));
          final isWeekend = d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
          return {
            'date': DateFormat('yyyy-MM-dd').format(d),
            'start_time': '09:00:00',
            'end_time': '18:00:00',
            'is_available': !isWeekend,
            'reason': !isWeekend ? 'Regular Day Shift (9h Capacity)' : 'Weekend Maintenance',
          };
        });
      }
      setState(() => _isLoading = false);
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSlot(int index) {
    setState(() {
      final current = _slots[index]['is_available'] ?? true;
      _slots[index]['is_available'] = !current;
      _slots[index]['reason'] = !current ? 'Regular Day Shift (9h Capacity)' : 'Blocked / Maintenance';
    });
  }

  Future<void> _saveSchedule() async {
    final success = await providerState.setAvailability(widget.machineId, _slots);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Capacity schedule successfully updated and published!'),
          backgroundColor: AppColors.emerald,
        ),
      );
      context.go('/provider-dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(providerState.errorMessage ?? 'Failed to update schedule.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableCount = _slots.where((s) => s['is_available'] == true).length;
    final totalCount = _slots.isNotEmpty ? _slots.length : 14;
    final idleCapacityPct = ((availableCount / totalCount) * 100).toInt();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MachPageHeader(
                  title: 'Machine Availability & Idle Capacity',
                  subtitle: 'Define working hours, idle shifts, and maintenance windows for ${widget.machineName}.',
                  onBack: () => context.go('/provider-dashboard'),
                  badge: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.emerald.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.flash_on_rounded, size: 14, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Text(
                          '$idleCapacityPct% IDLE CAPACITY AVAILABLE',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.emerald),
                        ),
                      ],
                    ),
                  ),
                  primaryAction: MachButton(
                    label: 'Publish Schedule',
                    icon: Icons.cloud_upload_outlined,
                    variant: MachButtonVariant.accent,
                    size: MachButtonSize.medium,
                    onPressed: _saveSchedule,
                  ),
                ),
                const SizedBox(height: 24),

                // Explanation Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.schedule, color: AppColors.steelBlue, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Visual Capacity Status: Click any date slot to toggle between Idle Available and Blocked.',
                              style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.navyIndustrial),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Green slots broadcast immediate availability to capacity seekers in AI matching.',
                              style: GoogleFonts.inter(fontSize: 12.5, color: AppColors.slate500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const MachLoadingState(message: 'Loading shift schedule...', height: 300)
                else
                  // Grid of Date Slots
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth > 900 ? 3 : (constraints.maxWidth > 600 ? 2 : 1);
                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          for (int i = 0; i < _slots.length; i++)
                            SizedBox(
                              width: (constraints.maxWidth - (columns - 1) * 14) / columns,
                              child: _buildSlotCard(i),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlotCard(int index) {
    final slot = _slots[index];
    final isAvail = slot['is_available'] == true;
    final dateStr = slot['date'] ?? '';
    final reason = slot['reason'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isAvail ? const Color(0xFF86EFAC) : AppColors.slate200,
          width: isAvail ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isAvail ? AppColors.emerald.withValues(alpha: 0.04) : Colors.transparent,
            blurRadius: 6,
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
                dateStr,
                style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.navyIndustrial),
              ),
              MachStatusBadge(status: isAvail ? 'AVAILABLE' : 'BLOCKED'),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAvail ? const Color(0xFFF0FDF4) : AppColors.slate50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  isAvail ? Icons.check_circle : Icons.block,
                  size: 15,
                  color: isAvail ? AppColors.emerald : AppColors.slate400,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAvail ? const Color(0xFF166534) : AppColors.slate500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '09:00 - 18:00 (9h Shift)',
                style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.slate400),
              ),
              InkWell(
                onTap: () => _toggleSlot(index),
                child: Text(
                  isAvail ? 'Block Shift' : 'Mark Available',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isAvail ? AppColors.errorRed : AppColors.steelBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
