import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';

class RatingStars extends StatefulWidget {
  final double? initialRating;
  final double size;
  final String? reviewLabel;
  /// Uid of the user this review is about. Reviews are only persisted (to
  /// the `reviews` collection, plus an aggregate on `users/{targetUid}`)
  /// when this is non-empty — pass '' to keep the widget purely cosmetic
  /// when the target can't be resolved.
  final String targetUid;
  final String? pickupId;
  const RatingStars({
    super.key,
    this.initialRating,
    this.size = 28,
    this.reviewLabel,
    this.targetUid = '',
    this.pickupId,
  });

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  int _rating = 0;
  bool _submitted = false;
  bool _submitting = false;
  final _reviewCtrl = TextEditingController();

  Future<void> _submit() async {
    if (widget.targetUid.isEmpty) {
      setState(() => _submitted = true);
      return;
    }
    setState(() => _submitting = true);
    final raterUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final raterName = FirebaseAuth.instance.currentUser?.displayName ?? '';
    final firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('reviews').add({
        'targetUid': widget.targetUid,
        'raterUid': raterUid,
        'raterName': raterName,
        'rating': _rating,
        'reviewText': _reviewCtrl.text.trim().isEmpty ? null : _reviewCtrl.text.trim(),
        'pickupId': widget.pickupId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await firestore.collection('users').doc(widget.targetUid).update({
        'ratingSum': FieldValue.increment(_rating),
        'reviewCount': FieldValue.increment(1),
      });
    } catch (_) {
      // The review UI is a nice-to-have on top of the core pickup flow —
      // fail silently rather than blocking the user on a write hiccup.
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
          _submitted = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating?.round() ?? 0;
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  String get _label {
    final t = context.l10n;
    if (_rating == 0) return t.ratingTapToRate;
    if (_rating <= 1) return t.ratingPoor;
    if (_rating <= 2) return t.ratingFair;
    if (_rating <= 3) return t.ratingGood;
    if (_rating <= 4) return t.ratingVeryGood;
    return t.ratingExcellent;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final bg = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    final text = isDark ? const Color(0xFFE5E5E5) : const Color(0xFF525252);
    final muted = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);

    if (_submitted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A)),
                const SizedBox(width: 8),
                Text(t.ratingSubmitted, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A))),
                const Spacer(),
                Text('$_rating/5', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
              ],
            ),
            if (_reviewCtrl.text.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_reviewCtrl.text.trim(), style: TextStyle(fontSize: 12, color: text)),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.reviewLabel ?? t.ratingRateExperience, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: text)),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: () => setState(() => _rating = i),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      i <= _rating ? Icons.star : Icons.star_border,
                      size: widget.size,
                      color: i <= _rating ? const Color(0xFFF59E0B) : muted,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(_label, style: TextStyle(fontSize: 12, color: muted, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _reviewCtrl,
            maxLines: 2,
            maxLength: 200,
            decoration: InputDecoration(
              hintText: t.ratingWriteReview,
              hintStyle: TextStyle(fontSize: 12, color: muted),
              counterText: '',
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF16A34A), width: 2)),
            ),
            style: TextStyle(fontSize: 12, color: text),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _rating == 0 || _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _submitting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(t.ratingSubmit, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}