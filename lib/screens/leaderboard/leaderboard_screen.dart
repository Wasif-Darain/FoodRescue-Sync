import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
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

  Stream<List<_LeaderEntry>> _donorsStream() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('donation_logs')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(_periodStart)))
        .snapshots()
        .map((snap) {
      final counts = <String, int>{};
      final names = <String, String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final donorId = data['donorId'] as String? ?? currentUid ?? '';
        counts[donorId] = (counts[donorId] ?? 0) + 1;
        names[donorId] = data['donorName'] as String? ?? 'Donor';
      }
      final entries = counts.entries
          .map((e) => _LeaderEntry(id: e.key, name: names[e.key] ?? 'Donor', count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return entries;
    });
  }

  Stream<List<_LeaderEntry>> _consumersStream() {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('pickups')
        .where('completedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now().subtract(_periodStart)))
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .map((snap) {
      final counts = <String, int>{};
      final names = <String, String>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final consumerId = data['consumerId'] as String? ?? currentUid ?? '';
        counts[consumerId] = (counts[consumerId] ?? 0) + 1;
        names[consumerId] = data['consumerName'] as String? ?? 'Consumer';
      }
      final entries = counts.entries
          .map((e) => _LeaderEntry(id: e.key, name: names[e.key] ?? 'Consumer', count: e.value))
          .toList()
        ..sort((a, b) => b.count.compareTo(a.count));
      return entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final periodLabel = _timeFrame == 'Weekly' ? 'week' : _timeFrame == 'Monthly' ? 'month' : 'year';
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return AppLayout(
      title: 'Leaderboard',
      subtitle: 'Top donors and consumers this $periodLabel',
      currentRoute: '/leaderboard',
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
                        Text('Hi, ${user.name.split(' ').first}!', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          'See who\'s leading this $periodLabel.',
                          style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: const BorderRadius.all(Radius.circular(14))),
                    child: const Icon(Icons.leaderboard_outlined, color: Color(0xFF2563EB), size: 26),
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
                  _TimeFrameChip(
                    label: tf,
                    selected: _timeFrame == tf,
                    onTap: () => setState(() => _timeFrame = tf),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;

            final donorsSection = StreamBuilder<List<_LeaderEntry>>(
              stream: _donorsStream(),
              builder: (context, snapshot) => _LeaderboardSection(
                title: 'Top Donors',
                icon: Icons.volunteer_activism_outlined,
                iconColor: const Color(0xFF16A34A),
                data: snapshot.data ?? [],
                myId: currentUid,
                periodLabel: periodLabel,
              ),
            );

            final consumersSection = StreamBuilder<List<_LeaderEntry>>(
              stream: _consumersStream(),
              builder: (context, snapshot) => _LeaderboardSection(
                title: 'Top Consumers',
                icon: Icons.restaurant_outlined,
                iconColor: const Color(0xFF2563EB),
                data: snapshot.data ?? [],
                myId: currentUid,
                periodLabel: periodLabel,
              ),
            );

            if (isNarrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [donorsSection, const SizedBox(height: 20), consumersSection],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: donorsSection),
                const SizedBox(width: 20),
                Expanded(child: consumersSection),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LeaderEntry {
  final String id;
  final String name;
  final int count;
  const _LeaderEntry({required this.id, required this.name, required this.count});
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

class _LeaderboardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<_LeaderEntry> data;
  final String myId;
  final String periodLabel;

  const _LeaderboardSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.data,
    required this.myId,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final top = data.take(5).toList();
    final myRankIndex = data.indexWhere((e) => e.id == myId);
    final myRank = myRankIndex >= 0 ? myRankIndex + 1 : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: iconColor),
                  const SizedBox(width: 6),
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF121212))),
                ],
              ),
              AppBadge(label: 'Top 5', variant: BadgeVariant.green),
            ],
          ),
          const SizedBox(height: 12),
          if (top.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text('No activity this $periodLabel.', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              ),
            )
          else
            ...top.asMap().entries.map((entry) {
              final index = entry.key;
              final entryData = entry.value;
              final rank = index + 1;
              final isTop3 = rank <= 3;

              return _HoverScale(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTop3 ? _getRankColor(index).withValues(alpha: 0.06) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTop3 ? _getRankColor(index).withValues(alpha: 0.4) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                    ),
                  ),
                  child: Row(
                    children: [
                      _RankBadge(rank: rank, color: _getRankColor(index)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entryData.name,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${entryData.count} items',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF16A34A).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle),
                  child: const Center(
                    child: Text('YOU', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    myRank == null ? 'No activity this $periodLabel' : 'Your current position',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
                  ),
                ),
                Text(
                  myRank == null ? '—' : '#$myRank',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    return switch (index) {
      0 => const Color(0xFFF59E0B),
      1 => const Color(0xFF9CA3AF),
      2 => const Color(0xFFD97706),
      _ => const Color(0xFF6B7280),
    };
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;
  final Color color;

  const _RankBadge({required this.rank, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTop3 = rank <= 3;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isTop3 ? color : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0)),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: isTop3
            ? Icon(
                switch (rank) {
                  1 => Icons.emoji_events,
                  2 => Icons.workspace_premium,
                  _ => Icons.military_tech,
                },
                size: 18,
                color: Colors.white,
              )
            : Text(
                '$rank',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
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