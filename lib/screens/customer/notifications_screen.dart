import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../providers/data_provider.dart';
import '../../widgets/custom_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    // If today, show only time (without seconds)
    if (notificationDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }

    // If this week, show day name
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    if (notificationDate.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        notificationDate.isBefore(weekEnd.add(const Duration(days: 1)))) {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[dateTime.weekday - 1];
    }

    // If more than a week, show date only
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = Provider.of<DataProvider>(context);
    final notifications = data.notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7), // Light gray background
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.bellOff,
                      size: 56, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text('No notifications', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('You are all caught up!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Dismissible(
                  key: Key(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: Icon(
                      LucideIcons.trash2,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return true; // Delete immediately without confirmation
                  },
                  onDismissed: (direction) {
                    data.deleteNotification(n.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Notification deleted'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: CustomCard(
                    color: Colors.white, // White background for notification tiles
                    elevation: 2, // Little elevation for the tiles
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          n.isRead ? LucideIcons.bell : LucideIcons.bellRing,
                          color: n.isRead
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title,
                                  style: theme.textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(n.message,
                                  style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatNotificationTime(n.createdAt),
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant)),
                                  if (!n.isRead)
                                    TextButton(
                                      onPressed: () =>
                                          data.markNotificationAsRead(n.id),
                                      child: const Text('Mark as read'),
                                    ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
