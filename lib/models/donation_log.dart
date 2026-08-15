import 'package:cloud_firestore/cloud_firestore.dart';

class DonationLogModel {
  final String id;
  final String donorId;
  final String recipientId;
  final String listingId;
  final double totalWeightKg;
  final Map<String, double> itemSummary;
  final DateTime completedAt;

  DonationLogModel({
    required this.id,
    required this.donorId,
    required this.recipientId,
    required this.listingId,
    required this.totalWeightKg,
    required this.itemSummary,
    required this.completedAt,
  });

  factory DonationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final completed = data['completedAt'];
    final rawSummary = data['itemSummary'] as Map<String, dynamic>? ?? {};
    return DonationLogModel(
      id: doc.id,
      donorId: data['donorId'] as String? ?? '',
      recipientId: data['recipientId'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      totalWeightKg: (data['totalWeight'] as num?)?.toDouble() ?? 0,
      itemSummary: rawSummary.map((k, v) => MapEntry(k, (v as num).toDouble())),
      completedAt: completed is Timestamp ? completed.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'recipientId': recipientId,
      'listingId': listingId,
      'totalWeight': totalWeightKg,
      'itemSummary': itemSummary,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }
}