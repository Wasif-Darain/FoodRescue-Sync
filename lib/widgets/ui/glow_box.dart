import 'package:flutter/material.dart';

/// Dark surface + neon glow decoration used across the app's cards and
/// option tiles. Pass the tile's accent color to get a matching glow.
BoxDecoration glowDecoration(Color accent, {double radius = 12, double alpha = 0.55}) {
  return BoxDecoration(
    color: const Color(0xFF141416),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: accent.withValues(alpha: alpha)),
    boxShadow: [
      BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 16, spreadRadius: 0.5),
    ],
  );
}
