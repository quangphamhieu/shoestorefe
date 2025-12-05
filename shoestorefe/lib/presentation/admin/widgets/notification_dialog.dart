import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/provider/notification_provider.dart';
import '../../../../domain/entities/notification.dart' as domain;

class NotificationPanel extends StatelessWidget {
  final VoidCallback onDismiss;
  const NotificationPanel({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        width: 420,
        height: 600, // Chiều cao cố định
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    'Thông báo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            // Notifications list - scrollable
            Expanded(
              child:
                  provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : provider.notifications.isEmpty
                      ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Không có thông báo nào',
                            style: TextStyle(color: Color(0xFF94A3B8)),
                          ),
                        ),
                      )
                      : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: provider.notifications.length,
                        separatorBuilder:
                            (context, index) => const Divider(
                              height: 1,
                              thickness: 0.3,
                              color: Color(0xFFE2E8F0),
                            ),
                        itemBuilder: (context, index) {
                          final notification = provider.notifications[index];
                          final isUnread = provider.unreadNotifications
                              .contains(notification);
                          return _NotificationItem(
                            notification: notification,
                            isUnread: isUnread,
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final domain.Notification notification;
  final bool isUnread;

  const _NotificationItem({required this.notification, required this.isUnread});

  String _getTypeIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'promotion':
        return '🎉';
      case 'order':
        return '📦';
      case 'receipt':
        return '📄';
      default:
        return '🔔';
    }
  }

  Color _getTypeColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'promotion':
        return const Color(0xFF0F9D58);
      case 'order':
        return const Color(0xFF2563EB);
      case 'receipt':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isUnread ? const Color(0xFFEFF6FF).withOpacity(0.3) : Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getTypeColor(notification.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _getTypeIcon(notification.type),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                    color:
                        isUnread
                            ? const Color(0xFF1F2933)
                            : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.5,
                  ),
                  maxLines: null,
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
