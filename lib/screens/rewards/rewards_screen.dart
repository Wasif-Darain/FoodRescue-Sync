import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/app_badge.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

String _levelLabel(AppLocalizations t, String level) => switch (level) {
  'Platinum' => t.levelPlatinum,
  'Gold' => t.levelGold,
  'Silver' => t.levelSilver,
  'Bronze' => t.levelBronze,
  _ => t.levelNovice,
};

String _timeframeLabel(AppLocalizations t, String tf) => switch (tf) {
  'Weekly' => t.rewardsTimeframeWeekly,
  'Monthly' => t.rewardsTimeframeMonthly,
  _ => t.rewardsTimeframeYearly,
};

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String _timeFrame = 'Weekly';

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

  String _periodLabel(AppLocalizations t) =>
      _timeFrame == 'Weekly' ? t.rewardsPeriodWeek : _timeFrame == 'Monthly' ? t.rewardsPeriodMonth : t.rewardsPeriodYear;

  Future<_RewardsData> _loadRewards(String uid) async {
    final firestore = FirebaseFirestore.instance;
    final now = DateTime.now();
    final periodStart = Timestamp.fromDate(now.subtract(_periodStart));

    final donationSnap = await firestore
        .collection('donation_logs')
        .where('donorId', isEqualTo: uid)
        .where('completedAt', isGreaterThanOrEqualTo: periodStart)
        .get();

    final pickupSnap = await firestore
        .collection('pickups')
        .where('consumerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .where('completedAt', isGreaterThanOrEqualTo: periodStart)
        .get();

    final allDonationSnap = await firestore
        .collection('donation_logs')
        .where('donorId', isEqualTo: uid)
        .get();

    final donationsThisPeriod = donationSnap.docs.length;
    final pickupsThisPeriod = pickupSnap.docs.length;
    final totalWeight = allDonationSnap.docs.fold<double>(
      0,
      (acc, doc) => acc + (((doc.data()['totalWeight'] as num?)?.toDouble()) ?? 0),
    );

    final pointsThisPeriod = donationsThisPeriod * 10 + pickupsThisPeriod * 5;

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

    return FutureBuilder<_RewardsData>(
      future: _loadRewards(uid),
      builder: (context, snapshot) {
        final rewards = snapshot.data ??
            _RewardsData(periodPoints: 0, totalDonations: 0, periodPickups: 0, totalWeight: 0, totalLogs: 0, level: 'Novice');

        final (weekly, monthly, yearly) = (
          rewards.periodPoints,
          rewards.periodPoints * 4,
          rewards.periodPoints * 52,
        );
        final thisPeriodPoints = _timeFrame == 'Weekly' ? weekly : _timeFrame == 'Monthly' ? monthly : yearly;
        final rescuedMeals = rewards.totalDonations + rewards.periodPickups;

        return AppLayout(
          title: t.rewardsTitle,
          subtitle: t.rewardsSubtitle,
          currentRoute: '/rewards',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HoverScale(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.rewardsGreeting(user.name.split(' ').first), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(
                              t.rewardsEarnedSummary(thisPeriodPoints, _periodLabel(t), _levelLabel(t, rewards.level)),
                              style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: rewards.totalWeight > 0 ? (rewards.totalWeight / 1000).clamp(0.0, 1.0) : 0.0,
                                minHeight: 8,
                                backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0),
                                valueColor: const AlwaysStoppedAnimation(Color(0xFF16A34A)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              t.rewardsKgSavedToward(rewards.totalWeight.toStringAsFixed(0)),
                              style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFF7ED), borderRadius: const BorderRadius.all(Radius.circular(14))),
                        child: const Icon(Icons.emoji_events_outlined, color: Color(0xFFF59E0B), size: 26),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final tf in ['Weekly', 'Monthly', 'Yearly']) ...[
                      if (tf != 'Weekly') const SizedBox(width: 8),
                      _TimeFrameChip(label: _timeframeLabel(t, tf), selected: _timeFrame == tf, onTap: () => setState(() => _timeFrame = tf)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ResponsiveGrid(
                children: [
                  StatCard(
                    label: t.rewardsPointsThisPeriod(_periodLabel(t)),
                    value: thisPeriodPoints,
                    icon: const Icon(Icons.star_outlined),
                    color: 'yellow',
                    subtitle: t.rewardsFromRealActivity,
                  ),
                  StatCard(
                    label: t.rewardsCurrentLevel,
                    value: _levelLabel(t, rewards.level),
                    icon: const Icon(Icons.trending_up),
                    color: 'blue',
                    subtitle: t.rewardsPointsNow(thisPeriodPoints),
                  ),
                  StatCard(
                    label: t.rewardsRescuedMeals,
                    value: rescuedMeals,
                    icon: const Icon(Icons.eco_outlined),
                    color: 'green',
                    subtitle: t.rewardsDonationsPlusPickups,
                  ),
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
              _buildBadges(rewards),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadges(_RewardsData rewards) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(t.rewardsBadges, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
            Text(t.rewardsUnlocked(_countAchieved(rewards)), style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
          ],
        ),
        const SizedBox(height: 12),
        ResponsiveGrid(
          minItemWidth: 220,
          children: _computeBadges(context.l10n, rewards).map((badge) => _HoverScale(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(badge.icon, size: 24, color: badge.achieved ? badge.color : const Color(0xFFBFBFBF)),
                      const Spacer(),
                      if (badge.achieved) AppBadge(label: t.rewardsAchieved, variant: BadgeVariant.green)
                      else AppBadge(label: t.rewardsLocked, variant: BadgeVariant.gray),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(badge.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: badge.achieved ? (isDark ? Colors.white : const Color(0xFF121212)) : const Color(0xFF9CA3AF))),
                  const SizedBox(height: 4),
                  Text(badge.description, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  int _countAchieved(_RewardsData rewards) => _computeBadges(context.l10n, rewards).where((b) => b.achieved).length;

  List<_Badge> _computeBadges(AppLocalizations t, _RewardsData rewards) {
    return [
      _Badge(
        name: t.badgeFirstDonationName,
        description: t.badgeFirstDonationDesc,
        icon: Icons.military_tech,
        color: const Color(0xFFF59E0B),
        achieved: rewards.totalLogs >= 1,
      ),
      _Badge(
        name: t.badgeActiveSaverName,
        description: t.badgeActiveSaverDesc,
        icon: Icons.volunteer_activism_outlined,
        color: const Color(0xFF16A34A),
        achieved: rewards.totalDonations >= 10,
      ),
      _Badge(
        name: t.badgeMealRescuerName,
        description: t.badgeMealRescuerDesc,
        icon: Icons.eco_outlined,
        color: const Color(0xFF2563EB),
        achieved: rewards.periodPickups >= 5,
      ),
      _Badge(
        name: t.badge100kgName,
        description: t.badge100kgDesc,
        icon: Icons.favorite_outline,
        color: const Color(0xFF7C3AED),
        achieved: rewards.totalWeight >= 100,
      ),
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

class _RewardsData {
  final int periodPoints;
  final int totalDonations;
  final int periodPickups;
  final double totalWeight;
  final int totalLogs;
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? (isDark ? Colors.white : const Color(0xFF121212)) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? (isDark ? Colors.white : const Color(0xFF121212)) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? (isDark ? const Color(0xFF121212) : Colors.white) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
          ),
        ),
      ),
    );
  }
}

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
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
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