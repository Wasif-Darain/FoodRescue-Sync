import 'package:flutter/material.dart';

enum BadgeVariant { green, orange, blue, red, gray }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const AppBadge({super.key, required this.label, this.variant = BadgeVariant.green});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (variant) {
      BadgeVariant.green  => (const Color(0xFF14301F), const Color(0xFF4ADE80)),
      BadgeVariant.orange => (const Color(0xFF2A1B0D), const Color(0xFFFB923C)),
      BadgeVariant.blue   => (const Color(0xFF11223A), const Color(0xFF60A5FA)),
      BadgeVariant.red    => (const Color(0xFF3A1919), const Color(0xFFF87171)),
      BadgeVariant.gray   => (const Color(0xFF262626), const Color(0xFFB0B3B8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: fg.withValues(alpha: 0.3), blurRadius: 8)],
      ),
      child: Text(label, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
