import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItemModel {
  final String id;
  final String donorId;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final DateTime? expirationDate;
  final bool isSurplus;
  final String? barcode;
  final String? imageUrl;

  InventoryItemModel({
    required this.id,
    required this.donorId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    this.expirationDate,
    required this.isSurplus,
    this.barcode,
    this.imageUrl,
  });

  factory InventoryItemModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final expDate = data['expirationDate'];
    return InventoryItemModel(
      id: doc.id,
      donorId: data['donorId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toDouble() ?? 0,
      unit: data['unit'] as String? ?? 'kg',
      expirationDate: expDate is Timestamp ? expDate.toDate() : null,
      isSurplus: data['isSurplus'] as bool? ?? false,
      barcode: data['barcode'] as String?,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'expirationDate': expirationDate == null ? null : Timestamp.fromDate(expirationDate!),
      'isSurplus': isSurplus,
      'barcode': barcode,
      'imageUrl': imageUrl,
    };
  }
}