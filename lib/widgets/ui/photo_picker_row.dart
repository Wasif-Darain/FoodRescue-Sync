import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_thumbnail.dart';

/// Thumbnail preview + "Camera" / "Gallery" buttons for attaching a photo
/// from the device. Controlled component: the caller owns [imageBytes] and
/// receives updates via [onChanged].
class PhotoPickerRow extends StatefulWidget {
  final Uint8List? imageBytes;
  final ValueChanged<Uint8List?> onChanged;
  const PhotoPickerRow({super.key, required this.imageBytes, required this.onChanged});

  @override
  State<PhotoPickerRow> createState() => _PhotoPickerRowState();
}

class _PhotoPickerRowState extends State<PhotoPickerRow> {
  bool _picking = false;

  Future<void> _pick(ImageSource source) async {
    setState(() => _picking = true);
    try {
      final file = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();
      widget.onChanged(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not access ${source == ImageSource.camera ? 'camera' : 'gallery'}: $e')));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ImageThumbnail(imageBytes: widget.imageBytes, size: 56),
      const SizedBox(width: 10),
      Expanded(
        child: Row(children: [
          Expanded(
            child: _PhotoSourceButton(
              icon: Icons.photo_camera_outlined,
              label: 'Camera',
              busy: _picking,
              onTap: () => _pick(ImageSource.camera),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _PhotoSourceButton(
              icon: Icons.photo_library_outlined,
              label: 'Gallery',
              busy: _picking,
              onTap: () => _pick(ImageSource.gallery),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _PhotoSourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;
  const _PhotoSourceButton({required this.icon, required this.label, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F5F5),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: busy ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: busy
              ? const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18, color: const Color(0xFF525252)),
                    const SizedBox(height: 2),
                    Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
                  ],
                ),
        ),
      ),
    );
  }
}
