import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/app_badge.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

// ---------------------------------------------------------------------------
// Localization helpers
// ---------------------------------------------------------------------------

/// Maps the internal level key (e.g. 'Gold') to its localized display label.
/// Anything unrecognised is treated as the entry level ("Novice").
String _levelLabel(AppLocalizations t, String level) => switch (level) {
  'Platinum' => t.levelPlatinum,
  'Gold' => t.levelGold,
  'Silver' => t.levelSilver,
  'Bronze' => t.levelBronze,
  _ => t.levelNovice,
};

/// Maps the internal timeframe key (e.g. 'Weekly') to its localized label.
String _timeframeLabel(AppLocalizations t, String tf) => switch (tf) {
  'Weekly' => t.rewardsTimeframeWeekly,
  'Monthly' => t.rewardsTimeframeMonthly,
  _ => t.rewardsTimeframeYearly,
};

// ---------------------------------------------------------------------------
// Shared styling helpers (UI only – no business logic)
// ---------------------------------------------------------------------------

/// Accent color used for each level (chips, certificate, etc.).
Color _levelColor(String level) => switch (level) {
  'Platinum' => const Color(0xFF0891B2),
  'Gold' => const Color(0xFFF59E0B),
  'Silver' => const Color(0xFF9CA3AF),
  'Bronze' => const Color(0xFFB45309),
  _ => const Color(0xFF6B7280),
};

/// The app's standard card look: rounded corners plus a hard-edged
/// (blurRadius 0) offset shadow. Centralised here so every card on this
/// screen stays consistent and the styling isn't repeated in each widget.
BoxDecoration _cardDecoration(
  bool isDark, {
  double radius = 16,
  Gradient? gradient,
  Border? border,
}) {
  return BoxDecoration(
    // A gradient, when supplied, replaces the flat background color.
    color: gradient == null
        ? (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF))
        : null,
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    border: border,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
        offset: const Offset(0, 4),
        blurRadius: 0,
      ),
    ],
  );
}

/// Section title with a small green accent bar on the left and an optional
/// widget (e.g. a counter or badge) aligned to the right.
class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        // Vertical accent bar.
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF16A34A),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF121212),
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

/// Rewards dashboard: shows the user's points, level, rescued meals, weight
/// saved, a certificate (once past Novice) and a grid of achievement badges.
/// A timeframe selector (weekly / monthly / yearly) controls the period used
/// for the points calculation.
class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  /// Currently selected timeframe key: 'Weekly', 'Monthly' or 'Yearly'.
  String _timeFrame = 'Weekly';

  /// Length of the selected period, expressed as a [Duration] counted back
  /// from now (start of this month / start of this year / last 7 days).
  Duration get _periodStart {
    final now = DateTime.now();
    switch (_timeFrame) {
      case 'Monthly':
        return now.difference(DateTime(now.year, now.month, 1));
      case 'Yearly':
        return now.difference(DateTime(now.year, 1, 1));
      default:
        return now.difference(now.subtract(const Duration(days: 7)));
    }
  }

  /// Localized singular period name ("week" / "month" / "year") used in
  /// sentences like "You earned X points this week".
  String _periodLabel(AppLocalizations t) =>
      _timeFrame == 'Weekly' ? t.rewardsPeriodWeek : _timeFrame == 'Monthly' ? t.rewardsPeriodMonth : t.rewardsPeriodYear;

  /// Loads everything the screen needs from Firestore for [uid]:
  ///  * donations and completed pickups inside the selected period,
  ///  * all-time donation weight (used to determine the level).
  ///
  /// Points formula: 10 per donation + 5 per completed pickup.
  Future<_RewardsData> _loadRewards(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    // Firestore timestamp marking the start of the selected period.
    final periodStart = Timestamp.fromDate(now.subtract(_periodStart));

    // Donations made by this user within the period.
    final donationSnap = await firestore
        .collection('donation_logs')
        .where('donorId', isEqualTo: uid)
        .where('completedAt', isGreaterThanOrEqualTo: periodStart)
        .get();

    // Pickups this user completed as a consumer within the period.
    final pickupSnap = await firestore
        .collection('pickups')
        .where('consumerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: periodStart)
        .get();

    // All-time donations (no date filter) – needed for total weight/level.
    final allDonationSnap = await firestore
        .collection('donation_logs')
        .where('donorId', isEqualTo: uid)
        .get();

    final donationsThisPeriod = donationSnap.docs.length;
    final pickupsThisPeriod = pickupSnap.docs.length;
    // Sum the 'totalWeight' field across all donations (missing = 0).
    final totalWeight = allDonationSnap.docs.fold<double>(
      0,
      (acc, doc) => acc + (((doc.data()['totalWeight'] as num?)?.toDouble()) ?? 0),
    );

    final pointsThisPeriod = donationsThisPeriod * 10 + pickupsThisPeriod * 5;

    // Level thresholds by all-time kg donated:
    // 1000+ Platinum, 500+ Gold, 200+ Silver, 50+ Bronze, otherwise Novice.
    final level = totalWeight >= 1000
        ? 'Platinum'
        : totalWeight >= 500
            ? 'Gold'
            : totalWeight >= 200
                ? 'Silver'
                : totalWeight >= 50
                    ? 'Bronze'
                    : 'Novice';

    return _RewardsData(
      periodPoints: pointsThisPeriod,
      totalDonations: donationsThisPeriod,
      periodPickups: pickupsThisPeriod,
      totalWeight: totalWeight,
      totalLogs: donationsThisPeriod + pickupsThisPeriod,
      level: level,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final t = context.l10n;

    // The future is recreated on every build, so changing the timeframe
    // (which calls setState) automatically reloads the data.
    return FutureBuilder<_RewardsData>(
      future: _loadRewards(uid),
      builder: (context, snapshot) {
        // While loading (or on error) fall back to zeroed "Novice" data so the
        // layout renders immediately.
        final rewards = snapshot.data ??
            _RewardsData(periodPoints: 0, totalDonations: 0, periodPickups: 0, totalWeight: 0, totalLogs: 0, level: 'Novice');

        // Points are projected from the loaded period: monthly = weekly x 4,
        // yearly = weekly x 52.
        final (weekly, monthly, yearly) = (
          rewards.periodPoints,
          rewards.periodPoints * 4,
          rewards.periodPoints * 52,
        );
        final thisPeriodPoints = _timeFrame == 'Weekly' ? weekly : _timeFrame == 'Monthly' ? monthly : yearly;
        final rescuedMeals = rewards.totalDonations + rewards.periodPickups;
        final levelColor = _levelColor(rewards.level);

        return AppLayout(
          title: t.rewardsTitle,
          subtitle: t.rewardsSubtitle,
          currentRoute: '/rewards',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thin loading bar; its slot is always reserved so the layout
              // doesn't jump when data arrives.
              SizedBox(
                height: 3,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: const LinearProgressIndicator(
                          minHeight: 3,
                          color: Color(0xFF16A34A),
                          backgroundColor: Colors.transparent,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),

              // ---------------- Hero / summary card ----------------
              _HoverScale(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  // Green gradient (darker in dark mode) makes this the
                  // visual focal point of the screen.
                  decoration: _cardDecoration(
                    isDark,
                    radius: 20,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [Color(0xFF14532D), Color(0xFF052E16)]
                          : const [Color(0xFF22C55E), Color(0xFF15803D)],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Personalised greeting using the first name.
                            Text(
                              t.rewardsGreeting(user.name.split(' ').first),
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            // "You earned N points this <period> · <level>"
                            Text(
                              t.rewardsEarnedSummary(thisPeriodPoints, _periodLabel(t), _levelLabel(t, rewards.level)),
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            // Pill showing the current level with its color dot.
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(color: levelColor, shape: BoxShape.circle),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _levelLabel(t, rewards.level),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Progress toward the 1000 kg top milestone,
                            // clamped to 0–100%.
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: rewards.totalWeight > 0 ? (rewards.totalWeight / 1000).clamp(0.0, 1.0) : 0.0,
                                minHeight: 10,
                                backgroundColor: Colors.white.withValues(alpha: 0.25),
                                valueColor: const AlwaysStoppedAnimation(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.rewardsKgSavedToward(rewards.totalWeight.toStringAsFixed(0)),
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Trophy in a soft circular halo.
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2),
                        ),
                        child: const Icon(Icons.emoji_events, color: Color(0xFFFDE68A), size: 30),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Timeframe selector ----------------
              // Segmented-control style: a rounded track holding equal-width
              // chips. Tapping a chip updates _timeFrame, which triggers a
              // data reload via the FutureBuilder above.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    for (final tf in ['Weekly', 'Monthly', 'Yearly']) ...[
                      if (tf != 'Weekly') const SizedBox(width: 4),
                      Expanded(
                        child: _TimeFrameChip(
                          label: _timeframeLabel(t, tf),
                          selected: _timeFrame == tf,
                          onTap: () => setState(() => _timeFrame = tf),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---------------- Stat cards ----------------
              ResponsiveGrid(
                children: [
                  // Points earned in the selected period.
                  StatCard(
                    label: t.rewardsPointsThisPeriod(_periodLabel(t)),
                    value: thisPeriodPoints,
                    icon: const Icon(Icons.star_outlined),
                    color: 'yellow',
                    subtitle: t.rewardsFromRealActivity,
                  ),
                  // Current level; tapping opens the leaderboard.
                  StatCard(
                    label: t.rewardsCurrentLevel,
                    value: _levelLabel(t, rewards.level),
                    icon: const Icon(Icons.trending_up),
                    color: 'blue',
                    subtitle: t.rewardsPointsNow(thisPeriodPoints),
                    onTap: () => context.go('/leaderboard'),
                  ),
                  // Donations + pickups completed in the period.
                  StatCard(
                    label: t.rewardsRescuedMeals,
                    value: rescuedMeals,
                    icon: const Icon(Icons.eco_outlined),
                    color: 'green',
                    subtitle: t.rewardsDonationsPlusPickups,
                  ),
                  // All-time weight of food saved.
                  StatCard(
                    label: t.rewardsWeightSavedKg,
                    value: rewards.totalWeight.toStringAsFixed(0),
                    icon: const Icon(Icons.favorite_outlined),
                    color: 'red',
                    subtitle: t.rewardsAllTime,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Certificate is only shown once the user has moved past Novice.
              if (rewards.level != 'Novice') _buildCertificate(rewards),
              _buildBadges(rewards),
            ],
          ),
        );
      },
    );
  }

  /// Builds the achievement certificate card shown for Bronze level and above.
  Widget _buildCertificate(_RewardsData rewards) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final user = context.read<AuthProvider>().user;
    final userName = user?.name ?? 'Contributor';
    final levelLabel = _levelLabel(t, rewards.level);
    // Issue date shown on the certificate (today, d/M/yyyy).
    final date = '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}';
    // Gold tone shared by the border, icon and level text.
    final gold = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    final subColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575);
    final textColor = isDark ? Colors.white : const Color(0xFF121212);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row: title + "Earned" badge.
        _SectionHeader(
          title: t.rewardsCertificate,
          trailing: AppBadge(label: t.rewardsCertificateEarned, variant: BadgeVariant.green),
        ),
        const SizedBox(height: 12),
        _HoverScale(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            // Warm parchment-like gradient with a gold border.
            decoration: _cardDecoration(
              isDark,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [Color(0xFF2A1F0A), Color(0xFF1E1E1E)]
                    : const [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
              ),
              border: Border.all(color: gold, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Decorative star row above the medal icon.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 12, color: gold.withValues(alpha: 0.6)),
                    const SizedBox(width: 6),
                    Icon(Icons.star, size: 16, color: gold),
                    const SizedBox(width: 6),
                    Icon(Icons.star, size: 12, color: gold.withValues(alpha: 0.6)),
                  ],
                ),
                const SizedBox(height: 10),
                // Medal icon inside a tinted circle.
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: gold.withValues(alpha: 0.12), shape: BoxShape.circle),
                  child: Icon(Icons.workspace_premium, size: 44, color: gold),
                ),
                const SizedBox(height: 12),
                // Certificate title and level subtitle.
                Text(
                  t.rewardsCertificateTitle,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  t.rewardsCertificateSubtitle(levelLabel),
                  style: TextStyle(fontSize: 12, color: subColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Recipient name – the most prominent text on the card.
                Text(
                  userName,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Summary of kg saved and number of donations.
                Text(
                  t.rewardsCertificateDesc(rewards.totalWeight.toStringAsFixed(0), rewards.totalDonations),
                  style: TextStyle(fontSize: 12, color: subColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Divider(color: gold.withValues(alpha: 0.4)),
                const SizedBox(height: 8),
                // Footer: issue date (left) and level (right).
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t.rewardsCertificateDate, style: TextStyle(fontSize: 10, color: subColor)),
                        Text(date, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(t.rewardsCertificateLevel, style: TextStyle(fontSize: 10, color: subColor)),
                        Text(levelLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: gold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Builds the grid of achievement badges. Unlocked badges are colorful and
  /// outlined in their accent color; locked ones are greyed out.
  Widget _buildBadges(_RewardsData rewards) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with the "N unlocked" counter on the right.
        _SectionHeader(
          title: t.rewardsBadges,
          trailing: Text(
            t.rewardsUnlocked(_countAchieved(rewards)),
            style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
          ),
        ),
        const SizedBox(height: 12),
        ResponsiveGrid(
          minItemWidth: 220,
          children: _computeBadges(context.l10n, rewards).map((badge) => _HoverScale(
            child: Container(
              padding: const EdgeInsets.all(16),
              // Achieved badges get a subtle colored outline.
              decoration: _cardDecoration(
                isDark,
                border: badge.achieved ? Border.all(color: badge.color.withValues(alpha: 0.5), width: 1.5) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Badge icon in a circle tinted with its accent color
                      // (grey when locked).
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: badge.achieved
                              ? badge.color.withValues(alpha: 0.14)
                              : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0)),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(badge.icon, size: 22, color: badge.achieved ? badge.color : const Color(0xFFBFBFBF)),
                      ),
                      const Spacer(),
                      // Status pill: Achieved (green) or Locked (grey).
                      if (badge.achieved) AppBadge(label: t.rewardsAchieved, variant: BadgeVariant.green)
                      else AppBadge(label: t.rewardsLocked, variant: BadgeVariant.gray),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Badge name (dimmed if locked).
                  Text(badge.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: badge.achieved ? (isDark ? Colors.white : const Color(0xFF121212)) : const Color(0xFF9CA3AF))),
                  const SizedBox(height: 4),
                  // How to earn / what the badge means.
                  Text(badge.description, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  /// Number of badges the user has unlocked (for the "N unlocked" counter).
  int _countAchieved(_RewardsData rewards) => _computeBadges(context.l10n, rewards).where((b) => b.achieved).length;

  /// Defines every badge and the condition that unlocks it.
  List<_Badge> _computeBadges(AppLocalizations t, _RewardsData rewards) {
    return [
      // Any activity at all (donation or pickup) in the period.
      _Badge(
        name: t.badgeFirstDonationName,
        description: t.badgeFirstDonationDesc,
        icon: Icons.military_tech,
        color: const Color(0xFFF59E0B),
        achieved: rewards.totalLogs >= 1,
      ),
      // 10 or more donations in the period.
      _Badge(
        name: t.badgeActiveSaverName,
        description: t.badgeActiveSaverDesc,
        icon: Icons.volunteer_activism_outlined,
        color: const Color(0xFF16A34A),
        achieved: rewards.totalDonations >= 10,
      ),
      // 5 or more completed pickups in the period.
      _Badge(
        name: t.badgeMealRescuerName,
        description: t.badgeMealRescuerDesc,
        icon: Icons.eco_outlined,
        color: const Color(0xFF2563EB),
        achieved: rewards.periodPickups >= 5,
      ),
      // 100 kg or more donated all-time.
      _Badge(
        name: t.badge100kgName,
        description: t.badge100kgDesc,
        icon: Icons.favorite_outline,
        color: const Color(0xFF7C3AED),
        achieved: rewards.totalWeight >= 100,
      ),
      // At least one donation in the period.
      _Badge(
        name: t.badgeCommunityStarName,
        description: t.badgeCommunityStarDesc,
        icon: Icons.emoji_events,
        color: const Color(0xFFD97706),
        achieved: rewards.totalDonations >= 1,
      ),
    ];
  }
}

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// A single achievement badge (display info + whether it's unlocked).
class _Badge {
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final bool achieved;

  _Badge({
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.achieved,
  });
}

/// Aggregated reward numbers loaded from Firestore for the selected period.
class _RewardsData {
  /// Points earned in the selected period (10/donation + 5/pickup).
  final int periodPoints;

  /// Donations made in the selected period.
  final int totalDonations;

  /// Completed pickups in the selected period.
  final int periodPickups;

  /// All-time weight donated, in kg.
  final double totalWeight;

  /// Donations + pickups in the period.
  final int totalLogs;

  /// Level key: Novice, Bronze, Silver, Gold or Platinum.
  final String level;

  _RewardsData({
    required this.periodPoints,
    required this.totalDonations,
    required this.periodPickups,
    required this.totalWeight,
    required this.totalLogs,
    required this.level,
  });
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

/// One segment of the timeframe selector. The selected segment is filled
/// green; the others are transparent so the track behind them shows through.
class _TimeFrameChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeFrameChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      // Make the whole segment tappable, including empty space.
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        // Smoothly animates between selected / unselected states.
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF16A34A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
          ),
        ),
      ),
    );
  }
}

/// Wraps a child so it grows slightly (2%) while hovered (desktop/web) or
/// pressed (touch), giving cards a subtle interactive feel.
class _HoverScale extends StatefulWidget {
  final Widget child;

  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Mouse hover (desktop / web).
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        // Press feedback (touch).
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: (_hovered || _pressed) ? 1.02 : 1.0,
          child: widget.child,
        ),
      ),
    );
  }
}