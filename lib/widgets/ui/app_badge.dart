import 'package:flutter/material.dart';

enum BadgeVariant { green, orange, blue, red, gray }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const AppBadge({super.key, required this.label, this.variant = BadgeVariant.green});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      BadgeVariant.green  => (const Color(0xFFDCFCE7), const Color(0xFF15803D)),
      BadgeVariant.orange => (const Color(0xFFFFF7ED), const Color(0xFFEA580C)),
      BadgeVariant.blue   => (const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
      BadgeVariant.red    => (const Color(0xFFFEF2F2), const Color(0xFFDC2626)),
      BadgeVariant.gray   => (const Color(0xFFF9FAFB), const Color(0xFF374151)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
