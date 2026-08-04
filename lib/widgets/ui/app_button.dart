import 'package:flutter/material.dart';
import 'animated_tap.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool fullWidth;
  final Color? color;
  final bool outlined;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = false,
    this.color,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color ?? (isDark ? const Color(0xFFE5E5E5) : const Color(0xFF121212));
    final fg = color == null ? (isDark ? const Color(0xFF121212) : Colors.white) : Colors.white;
    Widget btn = outlined
        ? OutlinedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              foregroundColor: bg,
              side: BorderSide(color: bg),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          )
        : ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon ?? const SizedBox.shrink(),
            label: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: fg)),
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              elevation: 0,
              shadowColor: bg.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
    btn = AnimatedTap(pressedScale: 0.96, child: btn);
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
