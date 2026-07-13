import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Renders a picked photo (bytes), a network photo (url), or a placeholder
/// icon — in that priority order — inside a rounded square.
class ImageThumbnail extends StatelessWidget {
  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  const ImageThumbnail({super.key, this.imageUrl, this.imageBytes, this.size = 44});

  @override
  Widget build(BuildContext context) {
    Widget image;
    if (imageBytes != null) {
      image = Image.memory(imageBytes!, fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image_outlined, size: 18, color: Color(0xFFBFBFBF)),
        loadingBuilder: (context, child, progress) => progress == null
            ? child
            : const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    } else {
      image = const Icon(Icons.image_outlined, size: 18, color: Color(0xFFBFBFBF));
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(width: size, height: size, color: const Color(0xFFF5F5F5), child: image),
    );
  }
}
