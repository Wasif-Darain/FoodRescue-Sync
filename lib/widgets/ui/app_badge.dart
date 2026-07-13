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
      BadgeVariant.orange => (const Color(0xFFFFE3CC), const Color(0xFFC2410C)),
      BadgeVariant.blue   => (const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
      BadgeVariant.red    => (const Color(0xFFFEE2E2), const Color(0xFFDC2626)),
      BadgeVariant.gray   => (const Color(0xFFE2E2E2), const Color(0xFF525252)),
    };
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 250),
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
        child: Text(label),
      ),
    );
  }
}
