import 'package:flutter/material.dart';

enum BadgeVariant { green, orange, blue, red, gray, purple, teal, amber }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const AppBadge({super.key, required this.label, this.variant = BadgeVariant.green});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg) = switch (variant) {
      BadgeVariant.green  => (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7), isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
      BadgeVariant.orange => (isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFE3CC), isDark ? const Color(0xFFF97316) : const Color(0xFFC2410C)),
      BadgeVariant.blue   => (isDark ? const Color(0xFF0A1A2A) : const Color(0xFFDBEAFE), isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8)),
      BadgeVariant.red    => (isDark ? const Color(0xFF2A0A0A) : const Color(0xFFFEE2E2), isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626)),
      BadgeVariant.gray   => (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E2E2), isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
      BadgeVariant.purple => (isDark ? const Color(0xFF2A1A3F) : const Color(0xFFEDE9FE), isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED)),
      BadgeVariant.teal   => (isDark ? const Color(0xFF0A2A26) : const Color(0xFFCCFBF1), isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488)),
      BadgeVariant.amber  => (isDark ? const Color(0xFF2A2007) : const Color(0xFFFEF3C7), isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309)),
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
