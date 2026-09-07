import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../l10n/l10n_ext.dart';

/// Small check-circle shown beside a user's name once an admin has approved
/// their account — green for donor/consumer/admin, blue for a rider, so a
/// rider's tick reads as a different (but still trusted) role at a glance.
class VerifiedBadge extends StatelessWidget {
  final UserMode mode;
  final double size;
  const VerifiedBadge({super.key, required this.mode, this.size = 15});

  @override
  Widget build(BuildContext context) {
    final color = mode == UserMode.rider ? const Color(0xFF2563EB) : const Color(0xFF16A34A);
    return Tooltip(
      message: context.l10n.verifiedBadgeTooltip,
      child: Icon(Icons.verified, size: size, color: color),
    );
  }
}
