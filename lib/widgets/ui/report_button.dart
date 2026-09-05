import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../l10n/l10n_ext.dart';

/// Opens a dialog for reporting a mismatch (e.g. a distribution proof photo
/// that doesn't match what was claimed) against [targetUid], and writes it
/// to the `reports` collection for later review.
Future<void> showReportDialog(
  BuildContext context, {
  required String targetUid,
  required String targetLabel,
  String? pickupId,
}) async {
  final t = context.l10n;
  final reasonCtrl = TextEditingController();
  final reason = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.reportDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.reportDialogBody(targetLabel), style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(hintText: t.reportDialogHint, border: const OutlineInputBorder()),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(t.commonCancel)),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, reasonCtrl.text.trim()),
          child: Text(t.reportSubmit),
        ),
      ],
    ),
  );
  reasonCtrl.dispose();
  if (reason == null) return;
  if (!context.mounted) return;
  if (reason.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.reportReasonRequiredError)));
    return;
  }
  final me = FirebaseAuth.instance.currentUser?.uid;
  await FirebaseFirestore.instance.collection('reports').add({
    'reporterId': me,
    'reportedUid': targetUid,
    'reportedLabel': targetLabel,
    'pickupId': pickupId,
    'reason': reason,
    'status': 'open',
    'createdAt': FieldValue.serverTimestamp(),
  });
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(t.reportSubmittedSnack),
    backgroundColor: const Color(0xFFDC2626),
  ));
}

class ReportButton extends StatelessWidget {
  final String targetUid;
  final String targetLabel;
  final String? pickupId;

  const ReportButton({super.key, required this.targetUid, required this.targetLabel, this.pickupId});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    if (targetUid.isEmpty) return const SizedBox.shrink();
    return OutlinedButton.icon(
      onPressed: () => showReportDialog(context, targetUid: targetUid, targetLabel: targetLabel, pickupId: pickupId),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFB45309),
        side: const BorderSide(color: Color(0xFFB45309)),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.flag_outlined, size: 16),
      label: Text(t.reportButton, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
