import 'package:cloud_firestore/cloud_firestore.dart';

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
