import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatusModel { pending, accepted, rejected, completed }

class RequestModel {
  final String id;
  final String consumerId;
  final String listingId;
  final double requestedQuantity;
  final String unit;
  final RequestStatusModel status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RequestModel({
    required this.id,
    required this.consumerId,
    required this.listingId,
    required this.requestedQuantity,
    required this.unit,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory RequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final created = data['createdAt'];
    final updated = data['updatedAt'];
    return RequestModel(
      id: doc.id,
      consumerId: data['consumerId'] as String? ?? '',
      listingId: data['listingId'] as String? ?? '',
      requestedQuantity: (data['requestedQuantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      status: RequestStatusModel.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'pending'),
        orElse: () => RequestStatusModel.pending,
      ),
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      updatedAt: updated is Timestamp ? updated.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'consumerId': consumerId,
      'listingId': listingId,
      'requestedQuantity': requestedQuantity,
      'unit': unit,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }
}