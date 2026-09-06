import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';

/// Prompts for a mandatory cancellation reason before a claim/assignment is
/// cancelled — used by both the consumer (cancelling a claim) and the rider
/// (cancelling an accepted pickup) so the other side always knows why an
/// item was reopened. Returns the trimmed reason, or `null` if the user
/// backed out.
Future<String?> showCancellationReasonDialog(
  BuildContext context, {
  required String title,
  required String confirmLabel,
}) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final t = dialogContext.l10n;
        final reason = controller.text.trim();
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: t.cancelReasonHint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.commonClose),
            ),
            ElevatedButton(
              onPressed: reason.isEmpty
                  ? null
                  : () => Navigator.pop(dialogContext, reason),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    ),
  );
}
