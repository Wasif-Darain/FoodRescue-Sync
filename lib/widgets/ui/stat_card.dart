import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final Widget icon;
  final String color;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = 'blue',
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = switch (color) {
      'green'  => const Color(0xFF16A34A),
      'orange' => const Color(0xFFEA580C),
      'red'    => const Color(0xFFDC2626),
      'blue'   => const Color(0xFF2563EB),
      _        => const Color(0xFF6B7280),
    };
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
              child: Center(child: IconTheme(data: IconThemeData(color: c, size: 18), child: icon)),
            ),
            const SizedBox(height: 10),
            _AnimatedValue(value: value),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
            ],
          ],
        ),
      ),
    );
  }
}

/// Counts up from 0 to [value] when it's a whole number; otherwise just
/// renders it as-is (e.g. a pre-formatted string like "12kg").
class _AnimatedValue extends StatelessWidget {
  final dynamic value;
  const _AnimatedValue({required this.value});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF121212));
    if (value is int) {
      return TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: value as int),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, v, _) => Text('$v', style: style),
      );
    }
    return Text('$value', style: style);
  }
}
