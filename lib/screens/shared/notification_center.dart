import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../models/notification_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/block_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../utils/display_name.dart';

/// Screen that lists all notifications addressed to the signed-in user.
///
/// Notifications are streamed live from Firestore, filtered to hide anything
/// sent by blocked users, and sorted newest-first. The header offers a
/// "mark all as read" action.
class NotificationCenter extends StatelessWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    // Live stream of the user's notifications. If nobody is signed in, emit a
    // single empty list so the UI simply shows the empty state.
    //
    // Sorting is done client-side (rather than with orderBy) so the query only
    // needs a single equality filter and no composite Firestore index.
    final stream = uid == null
        ? Stream<List<NotificationModel>>.value([])
        : FirebaseFirestore.instance
            .collection('notifications')
            .where('recipientUid', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => NotificationModel.fromFirestore(doc))
                .toList()
              // Newest notifications first.
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));

    return StreamBuilder<List<NotificationModel>>(
      stream: stream,
      builder: (context, snapshot) {
        // Rebuild whenever the block list changes so newly blocked users'
        // notifications disappear immediately.
        final blocked = context.watch<BlockProvider>().blockedUids;
        // Drop notifications from blocked senders. Notifications with no
        // sender (system messages) are always kept.
        final notifications = (snapshot.data ?? [])
            .where((n) => n.senderUid.isEmpty || !blocked.contains(n.senderUid))
            .toList();
        final unread = notifications.where((n) => !n.isRead).length;
        final t = context.l10n;

        return AppLayout(
          title: t.notifCenterTitle,
          subtitle: t.notifCenterUnread(unread),
          currentRoute: '/notifications',
          // Header action: mark every unread notification as read.
          action: TextButton(
            onPressed: () async {
              if (uid == null) return;
              // Fetch only unread docs and flip them in a single atomic batch
              // to avoid one write per notification.
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
            child: Text(t.notifCenterMarkAllRead, style: TextStyle(color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A), fontSize: 13)),
          ),
          // Card container: hard-edged (blurRadius 0) drop shadow gives the
          // app's "offset" card look.
          child: Container(
            decoration: BoxDecoration(color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: notifications.isEmpty
                // Empty state: icon + "no notifications" message.
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.notifications_off_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                        const SizedBox(height: 12),
                        Text(t.notifCenterEmpty, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                      ],
                    ),
                  )
                // Non-empty: render every notification as a tile.
                : Column(
                    children: notifications.map((n) => _NotificationTile(notification: n)).toList(),
                  ),
          ),
        );
      },
    );
  }
}

/// A single row in the notification list.
///
/// Shows a type-specific icon, the message, a timestamp and an unread dot.
/// Tapping marks the notification as read and navigates to its target page.
class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Pick the icon and accent color based on the notification's payload type.
    // Unknown types fall back to a neutral grey bell.
    final (icon, color) = switch (notification.payloadType) {
      'listing' => (Icons.storefront_outlined, const Color(0xFF16A34A)),
      'request' => (Icons.assignment_outlined, const Color(0xFF2563EB)),
      'pickup' => (Icons.local_shipping_outlined, const Color(0xFFEA580C)),
      'cancellation' => (Icons.cancel_outlined, const Color(0xFFDC2626)),
      _ => (Icons.notifications_outlined, const Color(0xFF757575)),
    };

    // Background: plain card color when read; a green tint highlights unread.
    final bg = notification.isRead ? (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF)) : (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7));

    return GestureDetector(
      onTap: () async {
        // Mark as read on first tap (skip the write if it's already read).
        if (!notification.isRead) {
          await FirebaseFirestore.instance
              .collection('notifications')
              .doc(notification.id)
              .update({'isRead': true});
        }
        // The widget may have been removed while awaiting the write.
        if (!context.mounted) return;
        final auth = context.read<AuthProvider>();
        // Resolve the destination route, taking the user's current mode
        // (e.g. donor vs consumer) into account.
        final target = notification.routeFor(auth.user?.mode);
        // Cross-module tap (e.g. donor tapping a notification whose exact
        // target lives in the consumer module): flip the module first so the
        // go() below lands on the real page instead of a same-module guess.
        // rider/admin are app-level roles with a fixed nav, so a target in
        // another module is opened as-is.
        final owner = modeForRoute(target);
        if (owner != null) auth.switchToMode(owner);
        if (!context.mounted) return;
        context.go(target);
      },
      child: Container(
        color: bg,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular icon badge tinted with the type's accent color.
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 14),
            // Message + timestamp column takes all remaining width.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text; older notifications may contain legacy
                  // formatting, so it's cleaned up before display. Unread
                  // messages are slightly bolder.
                  Text(
                    sanitizeLegacyNotificationMessage(notification.message),
                    style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFE5E5E5) : const Color(0xFF525252), fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500)),
                  const SizedBox(height: 4),
                  // Timestamp formatted as "HH:mm · d/M/yyyy".
                  Text(
                    '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')} · ${notification.createdAt.day}/${notification.createdAt.month}/${notification.createdAt.year}',
                    style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  ),
                ],
              ),
            ),
            // Small green dot indicating an unread notification.
            if (!notification.isRead)
              Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle)),
          ],
        ),
      ),
    );
  }
}