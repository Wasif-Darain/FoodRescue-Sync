import 'package:cloud_firestore/cloud_firestore.dart';

enum PickupStatusModel { scheduled, enRoute, completed, cancelled }

class PickupModel {
  final String id;
  final String requestId;
  final String? listingId;
  final String? consumerId;
  final String? donorName;
  final String? listingTitle;
  final String? volunteerDriverId;
  final DateTime? scheduledTime;
  final DateTime? completedAt;
  final PickupStatusModel status;
  final double latitude;
  final double longitude;
  final String? address;

  PickupModel({
    required this.id,
    required this.requestId,
    this.listingId,
    this.consumerId,
    this.donorName,
    this.listingTitle,
    this.volunteerDriverId,
    this.scheduledTime,
    this.completedAt,
    required this.status,
    this.latitude = 0,
    this.longitude = 0,
    this.address,
  });

  factory PickupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final scheduled = data['scheduledTime'];
    final completed = data['completedAt'];
    return PickupModel(
      id: doc.id,
      requestId: data['requestId'] as String? ?? '',
      listingId: data['listingId'] as String?,
      consumerId: data['consumerId'] as String?,
      donorName: data['donorName'] as String?,
      listingTitle: data['listingTitle'] as String?,
      volunteerDriverId: data['volunteerDriverId'] as String?,
      scheduledTime: scheduled is Timestamp ? scheduled.toDate() : null,
      completedAt: completed is Timestamp ? completed.toDate() : null,
      status: PickupStatusModel.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'scheduled'),
        orElse: () => PickupStatusModel.scheduled,
      ),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'consumerId': consumerId,
      'volunteerDriverId': volunteerDriverId,
      'scheduledTime': scheduledTime == null ? null : Timestamp.fromDate(scheduledTime!),
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }
}