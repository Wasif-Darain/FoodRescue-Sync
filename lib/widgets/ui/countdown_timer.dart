import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimer extends StatefulWidget {
  final DateTime expiry;
  final double fontSize;
  final String expiredLabel;
  const CountdownTimer({
    super.key,
    required this.expiry,
    this.fontSize = 10,
    this.expiredLabel = 'Expired',
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late DateTime _expiry;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _expiry = widget.expiry;
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiry != widget.expiry) {
      _expiry = widget.expiry;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative) return widget.expiredLabel;
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h ${d.inMinutes % 60}m';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m ${d.inSeconds % 60}s';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds % 60}s';
    return '${d.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diff = _expiry.difference(DateTime.now());
    final isExpired = diff.isNegative;
    final bg = isExpired
        ? (isDark ? const Color(0xFF2A0A0A) : const Color(0xFFFEE2E2))
        : (isDark ? const Color(0xFF0A1A2A) : const Color(0xFFDBEAFE));
    final fg = isExpired
        ? const Color(0xFFEF4444)
        : (isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isExpired ? Icons.timer_off_outlined : Icons.timer_outlined, size: widget.fontSize + 2, color: fg),
          const SizedBox(width: 3),
          Text(_format(diff), style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}
