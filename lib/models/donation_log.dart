import 'package:cloud_firestore/cloud_firestore.dart';

class DonationLogModel {
  final String id;
  final String donorId;
  final String donorName;
  final String recipientId;
  final String recipientName;
  final String listingId;
  final double totalWeightKg;
  final Map<String, double> itemSummary;
  final DateTime completedAt;

  DonationLogModel({
    required this.id,
    required this.donorId,
    this.donorName = '',
    required this.recipientId,
    this.recipientName = '',
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
      donorName: data['donorName'] as String? ?? '',
      recipientId: data['recipientId'] as String? ?? '',
      recipientName: data['recipientName'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      totalWeightKg: (data['totalWeight'] as num?)?.toDouble() ?? 0,
      itemSummary: rawSummary.map((k, v) => MapEntry(k, (v as num).toDouble())),
      completedAt: completed is Timestamp ? completed.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'listingId': listingId,
      'totalWeight': totalWeightKg,
      'itemSummary': itemSummary,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  /// Returns the recipient display name. Falls back to a trimmed ID or
  /// a generic label if neither is available. The ID is secondary — shown
  /// only when no name was ever persisted.
  String get recipientDisplayName {
    final name = recipientName.trim();
    if (name.isNotEmpty && name != 'You') return name;
    final id = recipientId.trim();
    if (id.isEmpty) return 'A recipient';
    return id;
  }

  /// Returns the donor display name. Falls back to a trimmed ID or
  /// a generic label if neither is available. The ID is secondary — shown
  /// only when no name was ever persisted.
  String get donorDisplayName {
    final name = donorName.trim();
    if (name.isNotEmpty && name != 'You') return name;
    final id = donorId.trim();
    if (id.isEmpty) return 'A donor';
    return id;
  }
}