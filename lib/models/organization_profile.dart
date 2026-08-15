import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationProfile {
  final String id;
  final String orgName;
  final String address;
  final String contactEmail;
  final String? contactPhone;
  final bool isVerified;

  OrganizationProfile({
    required this.id,
    required this.orgName,
    required this.address,
    required this.contactEmail,
    this.contactPhone,
    required this.isVerified,
  });

  factory OrganizationProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrganizationProfile(
      id: doc.id,
      orgName: data['orgName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      contactEmail: data['contactEmail'] as String? ?? '',
      contactPhone: data['contactPhone'] as String?,
      isVerified: data['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orgName': orgName,
      'address': address,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'isVerified': isVerified,
    };
  }
}