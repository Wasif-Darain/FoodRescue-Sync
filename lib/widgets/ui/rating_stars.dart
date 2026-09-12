import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../l10n/l10n_ext.dart';
import '../../services/listing_image_manager.dart';
import 'image_thumbnail.dart';

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
  Uint8List? _imageBytes;
  String? _imageUrl;
  Uint8List? _videoBytes;
  String? _videoUrl;
  bool _uploadingMedia = false;
  final _imageManager = ListingImageManager();

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
      // Upload image if selected
      if (_imageBytes != null && _imageUrl == null) {
        setState(() => _uploadingMedia = true);
        _imageUrl = await _imageManager.uploadBytes(_imageBytes!, filename: 'review_${widget.pickupId ?? raterUid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
        setState(() => _uploadingMedia = false);
      }
      // Upload video if selected
      if (_videoBytes != null && _videoUrl == null) {
        setState(() => _uploadingMedia = true);
        _videoUrl = await _uploadVideoBytes(_videoBytes!, filename: 'review_${widget.pickupId ?? raterUid}_${DateTime.now().millisecondsSinceEpoch}.mp4');
        setState(() => _uploadingMedia = false);
      }

      await firestore.collection('reviews').add({
        'targetUid': widget.targetUid,
        'raterUid': raterUid,
        'raterName': raterName,
        'rating': _rating,
        'reviewText': _reviewCtrl.text.trim().isEmpty ? null : _reviewCtrl.text.trim(),
        'imageUrl': _imageUrl,
        'videoUrl': _videoUrl,
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

  /// Uploads video bytes to Cloudinary's video upload endpoint.
  Future<String> _uploadVideoBytes(Uint8List bytes, {String filename = 'upload.mp4'}) async {
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/${ListingImageManager.cloudName}/video/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = ListingImageManager.uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: filename));
    final response = await request.send().timeout(const Duration(seconds: 60));
    final responseBody = await response.stream.bytesToString();
    final json = jsonDecode(responseBody) as Map<String, dynamic>;
    final url = json['secure_url'] as String?;
    if (url == null) {
      throw Exception('Cloudinary video upload failed: ${json['error']?['message'] ?? responseBody}');
    }
    return url;
  }

  Future<void> _pickMedia({required bool isVideo}) async {
    final picker = ImagePicker();
    try {
      if (isVideo) {
        final file = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(seconds: 30));
        if (file == null) return;
        final bytes = await file.readAsBytes();
        setState(() {
          _videoBytes = bytes;
          _videoUrl = null;
        });
      } else {
        final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 85);
        if (file == null) return;
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageUrl = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick media: $e')));
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
            if (_imageUrl != null || _imageBytes != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ImageThumbnail(imageUrl: _imageUrl, imageBytes: _imageBytes, size: 80),
              ),
            ],
            if (_videoUrl != null || _videoBytes != null) ...[
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.videocam, color: Color(0xFF16A34A), size: 32),
                ),
              ),
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
          const SizedBox(height: 10),
          // Image and video attachment buttons
          Row(
            children: [
              _MediaButton(
                icon: Icons.photo_outlined,
                label: 'Photo',
                onTap: _uploadingMedia ? null : () => _pickMedia(isVideo: false),
              ),
              const SizedBox(width: 8),
              _MediaButton(
                icon: Icons.videocam_outlined,
                label: 'Video',
                onTap: _uploadingMedia ? null : () => _pickMedia(isVideo: true),
              ),
            ],
          ),
          // Media previews
          if (_imageBytes != null || _imageUrl != null || _videoBytes != null || _videoUrl != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (_imageBytes != null || _imageUrl != null) ...[
                  Stack(
                    children: [
                      ImageThumbnail(imageUrl: _imageUrl, imageBytes: _imageBytes, size: 56),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _imageBytes = null;
                            _imageUrl = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                ],
                if (_videoBytes != null || _videoUrl != null) ...[
                  Stack(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Icon(Icons.videocam, size: 24, color: Color(0xFF16A34A))),
                      ),
                      Positioned(
                        top: -8,
                        right: -8,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _videoBytes = null;
                            _videoUrl = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(color: Color(0xFFDC2626), shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
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

class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _MediaButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: const Color(0xFF525252)),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
            ],
          ),
        ),
      ),
    );
  }
}