import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;
  final DocumentReference? profileRef;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.profileRef,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'consumer',
      profileRef: data['profileRef'] as DocumentReference?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'profileRef': profileRef,
    };
  }
}