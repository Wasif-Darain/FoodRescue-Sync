import 'package:cloud_firestore/cloud_firestore.dart';

/// A user-filed complaint against another user, written by
/// `report_button.dart` and surfaced back out to admins here.
class ReportModel {
  final String id;
  final String reporterId;
  final String reportedUid;
  final String reportedLabel;
  final String? pickupId;
  final String reason;
  final String status;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedUid,
    required this.reportedLabel,
    this.pickupId,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReportModel(
      id: doc.id,
      reporterId: data['reporterId'] as String? ?? '',
      reportedUid: data['reportedUid'] as String? ?? '',
      reportedLabel: data['reportedLabel'] as String? ?? '',
      pickupId: data['pickupId'] as String?,
      reason: data['reason'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
