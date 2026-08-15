import 'package:flutter/material.dart';
import '../../models/models.dart';

String donorTierLabel(DonorTier tier) => switch (tier) {
  DonorTier.novice => 'Novice',
  DonorTier.contributor => 'Contributor',
  DonorTier.provider => 'Provider',
  DonorTier.patron => 'Patron',
  DonorTier.master => 'Master',
  DonorTier.legend => 'Legend',
};

String consumerTierLabel(ConsumerTier tier) => switch (tier) {
  ConsumerTier.novice => 'Novice',
  ConsumerTier.scout => 'Scout',
  ConsumerTier.saver => 'Saver',
  ConsumerTier.rescuer => 'Rescuer',
  ConsumerTier.master => 'Master',
  ConsumerTier.legend => 'Legend',
};

DonorTier donorTierFor(RegisteredAccount a) {
  if (a.listingsCreated >= 250 || a.kgSaved >= 1500) {
    if (a.fulfillmentRate >= 95 && a.rating >= 4.7) return DonorTier.legend;
  }
  if (a.listingsCreated >= 120 || a.kgSaved >= 750) {
    if (a.fulfillmentRate >= 95 && a.rating >= 4.5 && a.reviewCount >= 10) return DonorTier.master;
  }
  if (a.listingsCreated >= 50 || a.kgSaved >= 300) {
    if (a.fulfillmentRate >= 90 && a.rating >= 4.2 && a.reviewCount >= 5) return DonorTier.patron;
  }
  if (a.listingsCreated >= 20 || a.kgSaved >= 100) {
    if (a.fulfillmentRate >= 85 && a.rating >= 3.8 && a.reviewCount >= 3) return DonorTier.provider;
  }
  if (a.listingsCreated >= 5 || a.kgSaved >= 25) {
    if (a.fulfillmentRate >= 80) return DonorTier.contributor;
  }
  return DonorTier.novice;
}

String pickupPreferenceLabel(PickupPreference p) => switch (p) {
  PickupPreference.self => 'Self Pickup',
  PickupPreference.management => 'Management Pickup',
  PickupPreference.rider => 'Rider Delivery',
};

IconData pickupPreferenceIcon(PickupPreference p) => switch (p) {
  PickupPreference.self => Icons.person_outline,
  PickupPreference.management => Icons.apartment_outlined,
  PickupPreference.rider => Icons.moped_outlined,
};

ConsumerTier consumerTierFor(RegisteredAccount a) {
  if (a.mealsRescued >= 100) {
    if (a.onTimePickupRate >= 98 && a.rating >= 4.7) return ConsumerTier.legend;
  }
  if (a.mealsRescued >= 50) {
    if (a.onTimePickupRate >= 95 && a.rating >= 4.5 && a.reviewCount >= 10) return ConsumerTier.master;
  }
  if (a.mealsRescued >= 25) {
    if (a.onTimePickupRate >= 90 && a.rating >= 4.2 && a.reviewCount >= 5) return ConsumerTier.rescuer;
  }
  if (a.mealsRescued >= 10) {
    if (a.onTimePickupRate >= 85 && a.rating >= 3.8 && a.reviewCount >= 3) return ConsumerTier.saver;
  }
  if (a.mealsRescued >= 3) return ConsumerTier.scout;
  return ConsumerTier.novice;
}

class UserBadge extends StatelessWidget {
  final String label;
  final bool isLegend;
  final double fontSize;
  const UserBadge({super.key, required this.label, required this.isLegend, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final (bg, fg, border) = switch (label) {
      'Novice' => (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E2E2), isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252), isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D4)),
      'Contributor' || 'Scout' => (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7), isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D), isDark ? const Color(0xFF16A34A) : const Color(0xFF86EFAC)),
      'Provider' || 'Saver' => (isDark ? const Color(0xFF0A1A2A) : const Color(0xFFDBEAFE), isDark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8), isDark ? const Color(0xFF3B82F6) : const Color(0xFF93C5FD)),
      'Patron' || 'Rescuer' => (isDark ? const Color(0xFF1E1B2A) : const Color(0xFFEDE9FE), isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9), isDark ? const Color(0xFF8B5CF6) : const Color(0xFFC4B5FD)),
      'Master' => (isDark ? const Color(0xFF2A1F0A) : const Color(0xFFFEF3C7), isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309), isDark ? const Color(0xFFF59E0B) : const Color(0xFFFDE68A)),
      'Legend' => (isDark ? const Color(0xFF2A0A0A) : const Color(0xFFFEE2E2), isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626), isDark ? const Color(0xFFEF4444) : const Color(0xFFFCA5A5)),
      _ => (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE2E2E2), isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252), isDark ? const Color(0xFF3F3F46) : const Color(0xFFD4D4D4)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        gradient: isLegend
            ? LinearGradient(colors: [bg, fg.withValues(alpha: 0.15)], begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        boxShadow: isLegend
            ? [BoxShadow(color: fg.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 1))]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: fontSize + 2, color: fg),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}