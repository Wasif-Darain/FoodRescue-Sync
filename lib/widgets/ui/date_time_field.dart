import 'package:flutter/material.dart';

/// Opens a calendar date picker followed by a clock time picker, both
/// themed with [accent], and returns the combined DateTime (or null if
/// cancelled at either step).
Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
  DateTime? firstDate,
  DateTime? lastDate,
  TimeOfDay defaultTime = const TimeOfDay(hour: 18, minute: 0),
  Color accent = const Color(0xFF16A34A),
}) async {
  final now = DateTime.now();
  ThemeData themed(BuildContext ctx) => Theme.of(ctx).copyWith(colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: accent));

  final date = await showDatePicker(
    context: context,
    initialDate: initial ?? now.add(const Duration(days: 3)),
    firstDate: firstDate ?? now.subtract(const Duration(days: 1)),
    lastDate: lastDate ?? now.add(const Duration(days: 730)),
    builder: (ctx, child) => Theme(data: themed(ctx), child: child!),
  );
  if (date == null || !context.mounted) return null;

  final time = await showTimePicker(
    context: context,
    initialTime: initial != null ? TimeOfDay.fromDateTime(initial) : defaultTime,
    builder: (ctx, child) => Theme(data: themed(ctx), child: child!),
  );
  if (!context.mounted) return null;

  return DateTime(date.year, date.month, date.day, time?.hour ?? defaultTime.hour, time?.minute ?? defaultTime.minute);
}

/// Tappable field styled like a text input that shows the picked date/time
/// (or a placeholder) and opens [onTap] — pair with [pickDateTime].
class DateTimeField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  const DateTimeField({super.key, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? null
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')} · ${TimeOfDay.fromDateTime(value!).format(context)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF525252))),
        const SizedBox(height: 4),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 15, color: Color(0xFF757575)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text ?? 'Pick date & time',
                    style: TextStyle(fontSize: 13, color: text == null ? const Color(0xFFBFBFBF) : const Color(0xFF121212)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.timer_outlined, size: 15, color: Color(0xFF757575)),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
