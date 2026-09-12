import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A star rating + optional written review one user leaves for another
/// after a pickup, written by `rating_stars.dart` and read back out on the
/// target's admin profile (and, in aggregate, on their user doc).
class ReviewModel {
  final String id;
  final String targetUid;
  final String raterUid;
  final String raterName;
  final int rating;
  final String? reviewText;
  final String? imageUrl;
  final String? videoUrl;
  final String? pickupId;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.targetUid,
    required this.raterUid,
    required this.raterName,
    required this.rating,
    this.reviewText,
    this.imageUrl,
    this.videoUrl,
    this.pickupId,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return ReviewModel(
      id: doc.id,
      targetUid: data['targetUid'] as String? ?? '',
      raterUid: data['raterUid'] as String? ?? '',
      raterName: data['raterName'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      reviewText: data['reviewText'] as String?,
      imageUrl: data['imageUrl'] as String?,
      videoUrl: data['videoUrl'] as String?,
      pickupId: data['pickupId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'targetUid': targetUid,
      'raterUid': raterUid,
      'raterName': raterName,
      'rating': rating,
      'reviewText': reviewText,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'pickupId': pickupId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
