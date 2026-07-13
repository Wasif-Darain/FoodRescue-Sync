import 'package:flutter/material.dart';

/// Wraps [child] with a quick scale-down-on-press micro-interaction.
/// Uses a [Listener] instead of a [GestureDetector] so it only observes
/// raw pointer events and never steals the tap from the child underneath
/// (InkWell ripples, FloatingActionButton, ElevatedButton all keep working).
class AnimatedTap extends StatefulWidget {
  final Widget child;
  final double pressedScale;

  const AnimatedTap({super.key, required this.child, this.pressedScale = 0.92});

  @override
  State<AnimatedTap> createState() => _AnimatedTapState();
}

class _AnimatedTapState extends State<AnimatedTap> {
  bool _pressed = false;

  void _set(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
