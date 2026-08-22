import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../models/notification_model.dart';

class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final stream = uid == null
        ? Stream<List<NotificationModel>>.value([])
        : FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientUid', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

    return StreamBuilder<List<NotificationModel>>(
      stream: stream,
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];
        final unread = notifications.where((n) => !n.isRead).length;

        return AppLayout(
          title: 'Notifications',
          subtitle: '$unread unread notifications',
          currentRoute: '/notifications',
          action: TextButton(
            onPressed: () async {
              if (uid == null) return;
              final batch = FirebaseFirestore.instance.batch();
              final query = await FirebaseFirestore.instance
                  .collection('notifications')
                  .where('recipientUid', isEqualTo: uid)
                  .where('isRead', isEqualTo: false)
                  .get();
              for (final doc in query.docs) {
                batch.update(doc.reference, {'isRead': true});
              }
              await batch.commit();
            },
            child: Text('Mark all read', style: TextStyle(color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), fontSize: 13)),
          ),
          child: Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: notifications.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                        const SizedBox(height: 12),
                        Text('No notifications', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                      ],
                    ),
                  )
                : Column(
                    children: notifications.map((n) => _NotificationTile(notification: n)).toList(),
                  ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (icon, color) = switch (notification.payloadType) {
      'listing' => (Icons.storefront_outlined, const Color(0xFF16A34A)),
      'request' => (Icons.assignment_outlined, const Color(0xFF2563EB)),
      'pickup' => (Icons.local_shipping_outlined, const Color(0xFFEA580C)),
      _ => (Icons.notifications_outlined, const Color(0xFF757575)),
    };
    final bg = notification.isRead ? (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7));

    return GestureDetector(
      onTap: () async {
        if (notification.isRead) return;
        await FirebaseFirestore.instance
            .collection('notifications')
            .doc(notification.id)
            .update({'isRead': true});
      },
      child: Container(
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
                  Text(notification.message, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFE5E5E5) : const Color(0xFF525252), fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')} · ${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}