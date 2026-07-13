import 'package:flutter/material.dart';

/// Lays out equal-sized cards in as many columns as comfortably fit the
/// available width, wrapping to more rows on narrow (phone) screens instead
/// of squeezing every card into one row like [Row] + [Expanded] would.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double minItemWidth;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.minItemWidth = 150,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxColumns = ((constraints.maxWidth + spacing) / (minItemWidth + spacing))
            .floor()
            .clamp(1, children.length);
        final itemWidth = (constraints.maxWidth - spacing * (maxColumns - 1)) / maxColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (i, c) in children.indexed)
              SizedBox(width: itemWidth, child: _StaggeredEntrance(index: i, child: c)),
          ],
        );
      },
    );
  }
}

/// Fades + slides a grid item in shortly after mount, staggered by [index]
/// so a row of cards animates in like a small cascade rather than all at once.
class _StaggeredEntrance extends StatefulWidget {
  final int index;
  final Widget child;
  const _StaggeredEntrance({required this.index, required this.child});

  @override
  State<_StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<_StaggeredEntrance> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 * widget.index.clamp(0, 8)), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.12),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
