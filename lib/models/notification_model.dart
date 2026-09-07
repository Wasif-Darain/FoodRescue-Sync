import 'package:cloud_firestore/cloud_firestore.dart';
import 'models.dart';

/// Screen to open when a notification of [payloadType] is tapped, given the
/// current user's [mode] — notifications (both the Firestore doc and the
/// push payload) only carry a type, not an explicit target, so the
/// destination is inferred from type + role. e.g. a donor's 'request'
/// notification means "someone acted on your listing", so it opens the
/// donor's consumers screen; the same type for a consumer means "your
/// request changed", so it opens their request tracker instead.
String notificationRouteFor(String payloadType, UserMode? mode) {
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

class NotificationModel {
  final String id;
  final String recipientUid;
  final String senderUid;
  final String payloadType;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientUid,
    this.senderUid = '',
    required this.payloadType,
    required this.message,
    required this.isRead,
    required this.createdAt,
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
    );
  }

  /// See [notificationRouteFor].
  String routeFor(UserMode? mode) => notificationRouteFor(payloadType, mode);

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
