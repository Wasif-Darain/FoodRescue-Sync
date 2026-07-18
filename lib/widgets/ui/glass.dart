import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted, translucent "Liquid Glass" surface. Kept deliberately light
/// (modest blur + cheap tint/border) so it can sit on the app's persistent
/// chrome without taxing the system. Reads the current brightness to pick a
/// sensible tint automatically.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? tint;
  final double? opacity;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final double? height;
  final double? width;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = 14,
    this.tint,
    this.opacity,
    this.border,
    this.boxShadow,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(18);
    final baseTint = tint ?? Colors.white;
    final usedOpacity = opacity ?? (isDark ? 0.10 : 0.55);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          height: height,
          width: width,
          margin: margin,
          padding: padding,
          decoration: BoxDecoration(
            color: baseTint.withValues(alpha: usedOpacity),
            borderRadius: radius,
            border: border ??
                Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.6),
                  width: 1,
                ),
            boxShadow: boxShadow ??
                [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
          ),
          child: child,
        ),
      ),
    );
  }
}