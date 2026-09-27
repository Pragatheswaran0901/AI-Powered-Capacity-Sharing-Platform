import 'package:flutter/material.dart';
import 'package:machhunt/core/constants/api_endpoints.dart';
import 'package:machhunt/core/constants/app_colors.dart';
import 'package:machhunt/core/constants/app_typography.dart';
import 'package:machhunt/core/network/api_client.dart';
import 'package:machhunt/core/widgets/app_button.dart';
import 'package:machhunt/core/widgets/app_card.dart';
import 'package:machhunt/models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final res = await apiClient.get(ApiEndpoints.notifications);
      if (res is List) {
        setState(() {
          _notifications = res.map((e) => NotificationModel.fromJson(e)).toList();
        });
      }
    } catch (_) {
      // Handled
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await apiClient.post(ApiEndpoints.readAllNotifications);
      await _fetchNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read.')),
        );
      }
    } catch (_) {}
  }

  Future<void> _markSingleAsRead(String id) async {
    try {
      await apiClient.post(ApiEndpoints.markNotificationRead(id));
      await _fetchNotifications();
    } catch (_) {}
  }

  IconData _getIconForEvent(String type) {
    switch (type.toUpperCase()) {
      case 'BOOKING_REQUEST':
        return Icons.bookmark_border;
      case 'BOOKING_ACCEPTED':
        return Icons.check_circle_outline;
      case 'BOOKING_CONFIRMED':
        return Icons.lock_outline;
      case 'PRODUCTION_STARTED':
        return Icons.play_arrow;
      case 'JOB_COMPLETED':
        return Icons.verified;
      case 'REVIEW_RECEIVED':
        return Icons.star_border;
      default:
        return Icons.notifications_none;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notifications & Alerts', style: AppTypography.displayMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time events: booking requests, escrow updates, and production milestones',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
              if (unreadCount > 0)
                AppButton(
                  label: 'Mark All Read ($unreadCount)',
                  icon: Icons.done_all,
                  variant: AppButtonVariant.secondary,
                  onPressed: _markAllAsRead,
                ),
            ],
          ),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_notifications.isEmpty)
            AppCard(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.notifications_off_outlined, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text('No Notifications Yet', style: AppTypography.titleMedium),
                    const SizedBox(height: 4),
                    const Text(
                      'You will receive notifications when providers accept requests or milestone payments update.',
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final item = _notifications[idx];
                final icon = _getIconForEvent(item.eventType);

                return InkWell(
                  onTap: () {
                    if (!item.isRead) _markSingleAsRead(item.id);
                  },
                  child: AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: item.isRead ? Colors.grey.shade100 : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            icon,
                            color: item.isRead ? AppColors.textMuted : AppColors.primary,
                            size: 22,
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
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (!item.isRead) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(item.message, style: AppTypography.bodySmall),
                              const SizedBox(height: 6),
                              Text(
                                item.createdAt.contains('T') ? item.createdAt.split('T').first : item.createdAt,
                                style: AppTypography.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
