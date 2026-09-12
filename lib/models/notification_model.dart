import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

/// Screen to open when a notification of [payloadType] is tapped, given the
/// current user's [mode] — notifications (both the Firestore doc and the
/// push payload) only carry a type, not an explicit target, so the
/// destination is inferred from type + role. e.g. a donor's 'request'
/// notification means "someone acted on your listing", so it opens the
/// donor's consumers screen; the same type for a consumer means "your
/// request changed", so it opens their request tracker instead.
///
/// [targetRoute], when present on the notification document, is the exact
/// page the sender intended (e.g. `/consumer/requests` for a direct-donation
/// offer) and takes precedence over the inferred fallback below.
String notificationRouteFor(String payloadType, UserMode? mode,
    {String? targetRoute}) {
  if (targetRoute != null && targetRoute.isNotEmpty) return targetRoute;
  switch (payloadType) {
    case 'listing':
      return '/consumer';
    case 'request':
      return mode == UserMode.donor ? '/donor/consumers' : '/consumer/requests';
    case 'pickup':
    case 'cancellation':
      return switch (mode) {
        UserMode.donor => '/donor/donation-log',
        UserMode.rider => '/rider',
        _ => '/consumer/pickups',
      };
    default:
      return '/notifications';
  }
}

/// The [UserMode] that owns [route], or null for shared routes that exist in
/// every module (e.g. `/notifications`). Used to detect cross-module taps —
/// e.g. a donor tapping a notification whose target is `/consumer/requests`.
UserMode? modeForRoute(String route) {
  if (route.startsWith('/donor')) return UserMode.donor;
  if (route.startsWith('/consumer')) return UserMode.consumer;
  if (route.startsWith('/rider')) return UserMode.rider;
  if (route.startsWith('/admin')) return UserMode.admin;
  return null;
}

class NotificationModel {
  final String id;
  final String recipientUid;
  final String senderUid;
  final String payloadType;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  /// Exact page the sender intended this notification to open, when known
  /// (e.g. `/consumer/requests` for a direct-donation offer). Older
  /// notifications written before this field existed won't have it — the
  /// route then falls back to the payloadType + role inference.
  final String? targetRoute;

  NotificationModel({
    required this.id,
    required this.recipientUid,
    this.senderUid = '',
    required this.payloadType,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.targetRoute,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final created = data['createdAt'];
    return NotificationModel(
      id: doc.id,
      recipientUid: data['recipientUid'] as String? ?? '',
      senderUid: data['senderUid'] as String? ?? '',
      payloadType: data['payloadType'] as String? ?? 'system',
      message: data['message'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      targetRoute: data['targetRoute'] as String?,
    );
  }

  /// See [notificationRouteFor].
  String routeFor(UserMode? mode) =>
      notificationRouteFor(payloadType, mode, targetRoute: targetRoute);

  Map<String, dynamic> toMap() {
    return {
      'recipientUid': recipientUid,
      'payloadType': payloadType,
      'message': message,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
