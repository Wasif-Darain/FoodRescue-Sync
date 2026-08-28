import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../providers/block_provider.dart';
import 'detail_sheet.dart';

/// Shows a confirm dialog, then toggles the block state for [targetUid].
/// Returns `true` if the block state actually changed, `false` otherwise
/// (cancelled, empty uid, or self-block).
Future<bool> toggleBlockWithConfirm(
  BuildContext context,
  String targetUid,
  String targetLabel,
) async {
  final blocks = context.read<BlockProvider>();
  if (targetUid.isEmpty) return false;
  final isBlocked = blocks.isBlocked(targetUid);
  final t = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isBlocked ? t.blockUnblock : t.blockBlock),
      content: Text(
        isBlocked
            ? t.blockUnblockBody(targetLabel)
            : t.blockBlockBody(targetLabel),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(t.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(isBlocked ? t.blockUnblock : t.blockBlock),
        ),
      ],
    ),
  );
  if (confirmed != true) return false;
  await blocks.toggleBlock(targetUid);
  if (!context.mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isBlocked
            ? t.blockUnblockedSnack(targetLabel)
            : t.blockBlockedSnack(targetLabel),
      ),
      backgroundColor: isBlocked
          ? const Color(0xFF16A34A)
          : const Color(0xFFDC2626),
    ),
  );
  return true;
}

/// Builds a [SheetMenuItem] (meatballs-menu entry) used inside a detail sheet
/// to BLOCK [targetUid]. Blocking makes the entity disappear from the relevant
/// lists, so after a successful block the open sheet is closed immediately.
///
/// Unblocking is intentionally NOT offered here — it lives only on the
/// Privacy & Security page, which shows the entire blocklist.
SheetMenuItem blockSheetMenuItem(
  BuildContext context, {
  required String targetUid,
  required String targetLabel,
}) {
  if (targetUid.isEmpty) {
    return SheetMenuItem(
      icon: Icons.block_outlined,
      label: '',
      color: const Color(0xFFDC2626),
      onTap: () {},
    );
  }
  final t = context.l10n;
  return SheetMenuItem(
    icon: Icons.block_outlined,
    label: t.blockBlock,
    subtitle: t.blockBlockBody(targetLabel),
    color: const Color(0xFFDC2626),
    onTap: () async {
      final blocks = context.read<BlockProvider>();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(t.blockBlock),
          content: Text(t.blockBlockBody(targetLabel)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t.blockBlock),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      await blocks.toggleBlock(targetUid);
      if (!context.mounted) return;
      // Close the detail sheet, then confirm — the entity disappears now.
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.blockBlockedSnack(targetLabel)),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    },
  );
}

class BlockButton extends StatelessWidget {
  final String targetUid;
  final String targetLabel;
  final bool iconOnly;

  const BlockButton({
    super.key,
    required this.targetUid,
    required this.targetLabel,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final blocks = context.watch<BlockProvider>();
    final isBlocked = blocks.isBlocked(targetUid);
    if (targetUid.isEmpty) return const SizedBox.shrink();
    if (iconOnly) {
      return IconButton(
        tooltip: isBlocked
            ? context.l10n.blockUnblock
            : context.l10n.blockBlock,
        icon: Icon(
          isBlocked ? Icons.lock_reset_outlined : Icons.block_outlined,
          size: 18,
          color: isBlocked ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
        onPressed: () =>
            toggleBlockWithConfirm(context, targetUid, targetLabel),
      );
    }
    return OutlinedButton.icon(
      onPressed: () => toggleBlockWithConfirm(context, targetUid, targetLabel),
      style: OutlinedButton.styleFrom(
        foregroundColor: isBlocked
            ? const Color(0xFF16A34A)
            : const Color(0xFFDC2626),
        side: BorderSide(
          color: isBlocked ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: Icon(
        isBlocked ? Icons.lock_reset_outlined : Icons.block_outlined,
        size: 16,
      ),
      label: Text(
        isBlocked ? context.l10n.blockUnblock : context.l10n.blockBlock,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
