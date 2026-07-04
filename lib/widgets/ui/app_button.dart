import 'package:flutter/material.dart';

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
    final bg = color ?? const Color(0xFF16A34A);
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
            label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: bg.withValues(alpha: 0.6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
    final glowed = outlined
        ? btn
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: onPressed == null ? null : [BoxShadow(color: bg.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 0.5)],
            ),
            child: btn,
          );
    return fullWidth ? SizedBox(width: double.infinity, child: glowed) : glowed;
  }
}
