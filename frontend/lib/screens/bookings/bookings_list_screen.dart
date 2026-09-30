import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/design_system/mach_button.dart';
import 'package:machhunt/core/design_system/mach_card.dart';
import 'package:machhunt/core/design_system/mach_domain_cards.dart';
import 'package:machhunt/core/design_system/mach_feedback_states.dart';
import 'package:machhunt/core/design_system/mach_page_header.dart';
import 'package:machhunt/core/design_system/mach_text_field.dart';
import 'package:machhunt/core/utils/formatters.dart';
import 'package:machhunt/models/booking_model.dart';
import 'package:machhunt/state/auth_state.dart';
import 'package:machhunt/state/seeker_state.dart';
import 'package:machhunt/state/provider_state.dart';

class BookingsListScreen extends StatefulWidget {
  const BookingsListScreen({super.key});

  @override
  State<BookingsListScreen> createState() => _BookingsListScreenState();
}

class _BookingsListScreenState extends State<BookingsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    if (authState.isProvider) {
      await providerState.fetchIncomingRequests();
    } else {
      await seekerState.fetchMyBookings();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _showReviewDialog(BookingModel booking) {
    int rating = 5;
    final reviewController = TextEditingController(
      text:
          'Superb precision machining quality. Held tight tolerances of ±0.005mm and dispatched 1 day ahead of schedule.',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 10),
                Text(
                  'Rate & Review MSME Partner',
                  style: GoogleFonts.inter(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navyIndustrial,
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${booking.id.substring(0, booking.id.length > 8 ? 8 : booking.id.length)}: ${booking.requirementTitle ?? "Manufacturing Order"}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Machine: ${booking.machineName ?? "Shop Machine"}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Overall Performance Score:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.navyIndustrial,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      return IconButton(
                        icon: Icon(
                          starNum <= rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () => setDlgState(() => rating = starNum),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),
                  MachTextField(
                    controller: reviewController,
                    label:
                        'Feedback on Precision, Speed, Tolerance & Reliability',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              MachButton(
                label: 'Cancel',
                variant: MachButtonVariant.outline,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              MachButton(
                label: 'Submit Review',
                icon: Icons.check,
                variant: MachButtonVariant.primary,
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final ok = await seekerState.submitReview(
                    bookingId: booking.id,
                    rating: rating,
                    reviewText: reviewController.text.trim(),
                  );
                  if (ok && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Review published! MSME partner reliability index updated.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    _loadBookings();
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEscrowPaymentDialog(BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.steelBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: AppColors.steelBlue,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Lock & Deposit Escrow',
              style: GoogleFonts.inter(
                fontSize: 16.5,
                fontWeight: FontWeight.w700,
                color: AppColors.navyIndustrial,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contract Ref: #${booking.id.substring(0, booking.id.length > 8 ? 8 : booking.id.length)}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.slate200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Machine Capacity Fee:',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.slate600,
                          ),
                        ),
                        Text(
                          Formatters.currency(booking.totalAmount),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
                          'Platform Protection Fee:',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                        Text(
                          Formatters.currency(booking.commissionAmount),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.slate500,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20, color: AppColors.slate200),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Escrow Commitment:',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyIndustrial,
                          ),
                        ),
                        Text(
                          Formatters.currency(booking.totalAmount),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.steelBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.emeraldBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.emeraldLight.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user,
                      color: AppColors.emeraldVerified,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Protection Guarantee',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Your funds remain locked in platform escrow until the manufactured batch passes quality inspection.',
                            style: GoogleFonts.inter(
                              fontSize: 11.5,
                              height: 1.4,
                              color: AppColors.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          MachButton(
            label: 'Cancel',
            variant: MachButtonVariant.outline,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          MachButton(
            label: 'Deposit to Escrow',
            icon: Icons.lock,
            variant: MachButtonVariant.accent,
            onPressed: () async {
              Navigator.of(ctx).pop();
              final ok = await seekerState.confirmEscrow(booking.id);
              if (ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Escrow funded! Provider has been notified to set up machine and begin production.',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadBookings();
              }
            },
          ),
        ],
      ),
    );
  }

  List<BookingModel> _getFilteredBookings(
    List<BookingModel> list,
    int tabIndex,
    bool isProvider,
  ) {
    switch (tabIndex) {
      case 1: // Action Required
        if (isProvider) {
          return list
              .where(
                (b) =>
                    b.status == 'PENDING' ||
                    b.status == 'REQUESTED' ||
                    b.status == 'CONFIRMED',
              )
              .toList();
        } else {
          return list.where((b) => b.status == 'ACCEPTED').toList();
        }
      case 2: // In Production
        return list
            .where((b) => b.status == 'IN_PROGRESS' || b.status == 'CONFIRMED')
            .toList();
      case 3: // Completed
        return list.where((b) => b.status == 'COMPLETED').toList();
      default:
        return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isProvider = authState.isProvider;
    final List<BookingModel> rawBookings = isProvider
        ? providerState.incomingRequests
        : seekerState.myBookings;
    final List<BookingModel> allBookings = rawBookings;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MachPageHeader(
            title: isProvider
                ? 'Incoming Production Bookings'
                : 'My Capacity Contracts',
            subtitle:
                'Track lifecycle progress, milestone inspection sign-offs, and escrow payment protection.',
            primaryAction: MachButton(
              label: 'Refresh',
              icon: Icons.refresh,
              variant: MachButtonVariant.outline,
              onPressed: _loadBookings,
            ),
          ),
          const SizedBox(height: 20),

          // Tab Filter Navigation
          MachCard(
            padding: const EdgeInsets.all(6),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              indicator: BoxDecoration(
                color: AppColors.navyIndustrial,
                borderRadius: BorderRadius.circular(6),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.slate600,
              labelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'All Contracts'),
                Tab(text: 'Action Required'),
                Tab(text: 'In Production'),
                Tab(text: 'Completed'),
              ],
              onTap: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const MachLoadingState(
              message: 'Retrieving capacity contracts and escrow records...',
            )
          else ...[
            Builder(
              builder: (context) {
                final filtered = _getFilteredBookings(
                  allBookings,
                  _tabController.index,
                  isProvider,
                );
                if (filtered.isEmpty) {
                  return MachEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No Contracts Found',
                    message:
                        'No capacity bookings currently match this filter. When orders progress, they will appear here.',
                    actionLabel: 'Refresh Bookings',
                    onAction: _loadBookings,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 18),
                  itemBuilder: (context, idx) {
                    final b = filtered[idx];
                    return MachBookingCard(
                      bookingId: b.id,
                      requirementTitle:
                          b.requirementTitle ?? 'Precision Machining Contract',
                      machineName: b.machineName ?? 'Machinery',
                      partnerName: isProvider
                          ? (b.seekerName ?? 'MSME Buyer')
                          : (b.businessName ??
                                b.providerName ??
                                'MSME Partner'),
                      isProvider: isProvider,
                      startDate: b.startDate,
                      endDate: b.endDate,
                      totalHours: b.totalHours,
                      totalAmount: isProvider
                          ? b.providerPayout
                          : b.totalAmount,
                      status: b.status,
                      escrowStatus: b.escrowStatus,
                      onAccept:
                          (isProvider &&
                              (b.status == 'PENDING' ||
                                  b.status == 'REQUESTED'))
                          ? () async {
                              final ok = await providerState.acceptRequest(
                                b.id,
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order accepted!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _loadBookings();
                              }
                            }
                          : null,
                      onReject:
                          (isProvider &&
                              (b.status == 'PENDING' ||
                                  b.status == 'REQUESTED'))
                          ? () async {
                              final ok = await providerState.rejectRequest(
                                b.id,
                                reason: 'Capacity occupied',
                              );
                              if (ok && context.mounted) _loadBookings();
                            }
                          : null,
                      onConfirmEscrow: (!isProvider && b.status == 'ACCEPTED')
                          ? () => _showEscrowPaymentDialog(b)
                          : null,
                      onStartProduction: (isProvider && b.status == 'CONFIRMED')
                          ? () async {
                              final ok = await providerState.startProduction(
                                b.id,
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Production started on machine bed!',
                                    ),
                                    backgroundColor: AppColors.info,
                                  ),
                                );
                                _loadBookings();
                              }
                            }
                          : null,
                      onComplete: (b.status == 'IN_PROGRESS')
                          ? () async {
                              final ok = await seekerState.markCompleted(b.id);
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Job marked completed and escrow released!',
                                    ),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                                _loadBookings();
                              }
                            }
                          : null,
                      onReview: (!isProvider && b.status == 'COMPLETED')
                          ? () => _showReviewDialog(b)
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
