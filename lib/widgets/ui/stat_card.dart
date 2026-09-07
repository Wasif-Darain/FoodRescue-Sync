import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final dynamic value;
  final Widget icon;
  final String color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = 'blue',
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Center(child: IconTheme(data: IconThemeData(color: c, size: 16), child: icon)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AnimatedValue(value: value),
                        Text(
                          label,
                          style: TextStyle(fontSize: 11.5, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(fontSize: 10.5, color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 11, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                  ],
                ],
              ),
            ),
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212));
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
