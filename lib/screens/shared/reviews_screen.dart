import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import '../../models/review.dart';
import '../../widgets/layout/app_layout.dart';

/// Shows all reviews the current user has received (as the review target),
/// including any attached image/video from Cloudinary.
class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Empty string means "not signed in".
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Live stream of reviews where the current user is the target.
    // If signed out, emit an empty list so the empty state is shown.
    final reviewsStream = uid.isEmpty
        ? Stream<List<ReviewModel>>.value([])
        : FirebaseFirestore.instance
            .collection('reviews')
            .where('targetUid', isEqualTo: uid)
            .snapshots()
            .map((snap) {
            final reviews = snap.docs
                .map((doc) => ReviewModel.fromFirestore(doc))
                .toList()
              // Sorted client-side (newest first) so the query needs no
              // composite Firestore index.
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return reviews;
          });

    return AppLayout(
      title: 'My Reviews',
      subtitle: 'Reviews others have left for you',
      currentRoute: '/profile/reviews',
      child: StreamBuilder<List<ReviewModel>>(
        stream: reviewsStream,
        builder: (context, snapshot) {
          // Show a spinner until the first snapshot arrives.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data ?? [];
          // Empty state: star icon + "No reviews yet".
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_outline, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                  const SizedBox(height: 12),
                  Text('No reviews yet', style: TextStyle(fontSize: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                ],
              ),
            );
          }
          // Scrollable list of reviews with a divider between each.
          return ListView.separated(
            itemCount: reviews.length,
            separatorBuilder: (_, __) => Divider(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
            itemBuilder: (_, i) => _ReviewRow(review: reviews[i]),
          );
        },
      ),
    );
  }
}

/// One review entry: rating, reviewer name, date, optional text, and
/// optional image/video attachments.
class _ReviewRow extends StatelessWidget {
  final ReviewModel review;
  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF121212);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: star + "n/5", reviewer name, and date pushed to the
          // far right by the Spacer.
          Row(children: [
            Icon(Icons.star, size: 14, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text('${review.rating}/5', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
            const SizedBox(width: 8),
            Text(review.raterName, style: TextStyle(fontSize: 11, color: subColor)),
            const Spacer(),
            // Date formatted as yyyy-MM-dd (zero-padded month/day).
            Text(
              '${review.createdAt.year}-${review.createdAt.month.toString().padLeft(2, '0')}-${review.createdAt.day.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 10, color: subColor),
            ),
          ]),
          // Optional written review text.
          if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.reviewText!, style: TextStyle(fontSize: 13, color: textColor)),
          ],
          // Optional image: shown as a cropped thumbnail; tap to open a
          // full-size, zoomable/pannable preview in a dialog.
          if (review.imageUrl != null && review.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (_) => Dialog(
                  child: InteractiveViewer(child: Image.network(review.imageUrl!)),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  review.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Fallback placeholder if the image fails to load.
                  errorBuilder: (_, __, ___) => Container(
                    height: 60,
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                    child: const Center(child: Icon(Icons.broken_image_outlined, size: 24, color: Color(0xFFBFBFBF))),
                  ),
                ),
              ),
            ),
          ],
          // Optional video: there's no inline player yet, so show a small
          // "Video attached" row whose button opens a dialog with the URL.
          if (review.videoUrl != null && review.videoUrl!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam, size: 18, color: Color(0xFF16A34A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Video attached', style: TextStyle(fontSize: 12, color: textColor)),
                  ),
                  TextButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Review Video'),
                        content: Text(review.videoUrl!),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    child: const Text('View', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}