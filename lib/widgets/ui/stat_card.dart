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
    final bg = switch (color) {
      'green'  => const Color(0xFFDCFCE7),
      'orange' => const Color(0xFFFFF7ED),
      'red'    => const Color(0xFFFEE2E2),
      'blue'   => const Color(0xFFDBEAFE),
      _        => const Color(0xFFF3F4F6),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
            child: Center(child: IconTheme(data: IconThemeData(color: c, size: 18), child: icon)),
          ),
          const SizedBox(height: 10),
          Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ],
      ),
    );
  }
}
