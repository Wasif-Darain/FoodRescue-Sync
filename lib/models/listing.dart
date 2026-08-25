import 'package:cloud_firestore/cloud_firestore.dart';

enum ListingStatusModel { active, claimed, completed, expired }

class ListingModel {
  final String id;
  final String donorId;
  final String title;
  final String description;
  final String category;
  final double price;
  final double quantity;
  final String unit;
  final List<String> photoUrls;
  final List<String> itemIds;
  final DateTime? claimDeadline;
  final ListingStatusModel status;
  final double latitude;
  final double longitude;
  final String? address;
  final String? claimedBy;
  final DateTime createdAt;

  ListingModel({
    required this.id,
    required this.donorId,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.photoUrls,
    required this.itemIds,
    this.claimDeadline,
    required this.status,
    required this.latitude,
    required this.longitude,
    this.address,
    this.claimedBy,
    required this.createdAt,
  });

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final deadline = data['claimDeadline'];
    final created = data['createdAt'];
    return ListingModel(
      id: doc.id,
      donorId: data['donorId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      photoUrls: (data['photoUrls'] as List?)?.cast<String>() ?? [],
      itemIds: (data['itemIds'] as List?)?.cast<String>() ?? [],
      claimDeadline: deadline is Timestamp ? deadline.toDate() : null,
      status: ListingStatusModel.values.firstWhere(
        (e) => e.name == (data['status'] as String? ?? 'active'),
        orElse: () => ListingStatusModel.active,
      ),
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] as String?,
      claimedBy: data['claimedBy'] as String?,
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'photoUrls': photoUrls,
      'itemIds': itemIds,
      'claimDeadline': claimDeadline == null ? null : Timestamp.fromDate(claimDeadline!),
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'claimedBy': claimedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}