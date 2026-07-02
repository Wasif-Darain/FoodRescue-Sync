import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = mockNotifications.where((n) => !n.isRead).length;

    return AppLayout(
      title: 'Notifications',
      subtitle: '$unread unread notifications',
      currentRoute: '/notifications',
      action: TextButton(onPressed: () {}, child: const Text('Mark all read', style: TextStyle(color: Color(0xFF16A34A), fontSize: 13))),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
        child: Column(
          children: mockNotifications.map((n) => _NotificationTile(notification: n)).toList(),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (notification.type) {
      NotificationType.listing => (Icons.storefront_outlined,        const Color(0xFF16A34A)),
      NotificationType.request => (Icons.assignment_outlined,        const Color(0xFF2563EB)),
      NotificationType.pickup  => (Icons.local_shipping_outlined,    const Color(0xFFEA580C)),
      NotificationType.system  => (Icons.notifications_outlined,     const Color(0xFF6B7280)),
    };
    final bg = notification.isRead ? Colors.white : const Color(0xFFF0FDF4);

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(notification.message, style: TextStyle(fontSize: 13, color: const Color(0xFF374151), fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500)),
                const SizedBox(height: 4),
                Text(
                  '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')} · ${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
                ),
              ],
            ),
          ),
          if (!notification.isRead)
            Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
        ],
      ),
    );
  }
}
