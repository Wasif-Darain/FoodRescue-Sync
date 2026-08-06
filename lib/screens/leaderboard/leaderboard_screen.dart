import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/stat_card.dart';
import '../../providers/auth_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _timeFrame = 'Weekly';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final topDonors = _getMockDonors(_timeFrame);
    final topConsumers = _getMockConsumers(_timeFrame);
    final myDonorRank = _getMyDonorRank(_timeFrame);
    final myConsumerRank = _getMyConsumerRank(_timeFrame);
    final periodLabel = _timeFrame == 'Weekly' ? 'week' : _timeFrame == 'Monthly' ? 'month' : 'year';

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
                          'You\'re ranked #$myDonorRank among donors and #$myConsumerRank among consumers this $periodLabel.',
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
          ResponsiveGrid(
            children: [
              StatCard(
                label: 'My Donor Rank',
                value: '#$myDonorRank',
                icon: const Icon(Icons.volunteer_activism_outlined),
                color: 'green',
                subtitle: 'Top 10 this $periodLabel',
              ),
              StatCard(
                label: 'My Consumer Rank',
                value: '#$myConsumerRank',
                icon: const Icon(Icons.restaurant_outlined),
                color: 'blue',
                subtitle: 'Top 10 this $periodLabel',
              ),
              StatCard(
                label: 'Donations Made',
                value: _getMyDonations(_timeFrame),
                icon: const Icon(Icons.favorite_outlined),
                color: 'red',
                subtitle: 'This $periodLabel',
              ),
              StatCard(
                label: 'Items Rescued',
                value: _getMyConsumptions(_timeFrame),
                icon: const Icon(Icons.eco_outlined),
                color: 'orange',
                subtitle: 'This $periodLabel',
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;

            final donorsSection = _LeaderboardSection(
              title: 'Top Donors',
              icon: Icons.volunteer_activism_outlined,
              iconColor: const Color(0xFF16A34A),
              data: topDonors,
              myRank: myDonorRank,
            );

            final consumersSection = _LeaderboardSection(
              title: 'Top Consumers',
              icon: Icons.restaurant_outlined,
              iconColor: const Color(0xFF2563EB),
              data: topConsumers,
              myRank: myConsumerRank,
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

  int _getMyDonorRank(String timeFrame) {
    return switch (timeFrame) {
      'Monthly' => 3,
      'Yearly' => 5,
      _ => 2,
    };
  }

  int _getMyConsumerRank(String timeFrame) {
    return switch (timeFrame) {
      'Monthly' => 4,
      'Yearly' => 6,
      _ => 3,
    };
  }

  int _getMyDonations(String timeFrame) {
    return switch (timeFrame) {
      'Monthly' => 42,
      'Yearly' => 180,
      _ => 12,
    };
  }

  int _getMyConsumptions(String timeFrame) {
    return switch (timeFrame) {
      'Monthly' => 35,
      'Yearly' => 150,
      _ => 10,
    };
  }

  List<Map<String, dynamic>> _getMockDonors(String timeFrame) {
    final mockData = {
      'Weekly': [
        {'name': 'Karim Ahmed', 'count': 45, 'org': 'Green Kitchen Restaurant', 'trend': 12},
        {'name': 'Rafiq Chowdhury', 'count': 30, 'org': 'Dhaka Bakery House', 'trend': 8},
        {'name': 'Habib Rahman', 'count': 20, 'org': 'Star Caterers', 'trend': -3},
        {'name': 'Nasir Uddin', 'count': 15, 'org': 'Honest Grocery', 'trend': 5},
        {'name': 'Farhan Islam', 'count': 12, 'org': 'Bismillah Catering', 'trend': 2},
      ],
      'Monthly': [
        {'name': 'Karim Ahmed', 'count': 120, 'org': 'Green Kitchen Restaurant', 'trend': 25},
        {'name': 'Rafiq Chowdhury', 'count': 90, 'org': 'Dhaka Bakery House', 'trend': 15},
        {'name': 'Habib Rahman', 'count': 60, 'org': 'Star Caterers', 'trend': -8},
        {'name': 'Nasir Uddin', 'count': 45, 'org': 'Honest Grocery', 'trend': 10},
        {'name': 'Farhan Islam', 'count': 38, 'org': 'Bismillah Catering', 'trend': 6},
      ],
      'Yearly': [
        {'name': 'Karim Ahmed', 'count': 500, 'org': 'Green Kitchen Restaurant', 'trend': 80},
        {'name': 'Rafiq Chowdhury', 'count': 300, 'org': 'Dhaka Bakery House', 'trend': 45},
        {'name': 'Habib Rahman', 'count': 200, 'org': 'Star Caterers', 'trend': -20},
        {'name': 'Nasir Uddin', 'count': 150, 'org': 'Honest Grocery', 'trend': 30},
        {'name': 'Farhan Islam', 'count': 120, 'org': 'Bismillah Catering', 'trend': 18},
      ],
    };
    return mockData[timeFrame]!;
  }

  List<Map<String, dynamic>> _getMockConsumers(String timeFrame) {
    final mockData = {
      'Weekly': [
        {'name': 'Farida Begum', 'count': 35, 'org': 'Dhaka Food Bank', 'trend': 10},
        {'name': 'Shakil Hasan', 'count': 25, 'org': 'Hunger Help BD', 'trend': 6},
        {'name': 'Tanvir Ahmed', 'count': 15, 'org': 'Al-Amin Shelter', 'trend': -2},
        {'name': 'Rina Akter', 'count': 12, 'org': 'Rahim Uddin', 'trend': 4},
        {'name': 'Anika Sultana', 'count': 9, 'org': 'Community Kitchen', 'trend': 1},
      ],
      'Monthly': [
        {'name': 'Farida Begum', 'count': 100, 'org': 'Dhaka Food Bank', 'trend': 22},
        {'name': 'Shakil Hasan', 'count': 70, 'org': 'Hunger Help BD', 'trend': 14},
        {'name': 'Tanvir Ahmed', 'count': 50, 'org': 'Al-Amin Shelter', 'trend': -5},
        {'name': 'Rina Akter', 'count': 40, 'org': 'Rahim Uddin', 'trend': 8},
        {'name': 'Anika Sultana', 'count': 32, 'org': 'Community Kitchen', 'trend': 3},
      ],
      'Yearly': [
        {'name': 'Farida Begum', 'count': 400, 'org': 'Dhaka Food Bank', 'trend': 60},
        {'name': 'Shakil Hasan', 'count': 250, 'org': 'Hunger Help BD', 'trend': 35},
        {'name': 'Tanvir Ahmed', 'count': 150, 'org': 'Al-Amin Shelter', 'trend': -12},
        {'name': 'Rina Akter', 'count': 120, 'org': 'Rahim Uddin', 'trend': 20},
        {'name': 'Anika Sultana', 'count': 95, 'org': 'Community Kitchen', 'trend': 8},
      ],
    };
    return mockData[timeFrame]!;
  }
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
  final List<Map<String, dynamic>> data;
  final int myRank;

  const _LeaderboardSection({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.data,
    required this.myRank,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          ...data.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final rank = index + 1;
            final isTop3 = rank <= 3;
            final trend = user['trend'] as int;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] as String,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user['org'] as String,
                            style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user['count']} items',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              trend >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                              size: 10,
                              color: trend >= 0 ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${trend.abs()}%',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: trend >= 0 ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ],
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
                    'Your current position',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFF4ADE80) : const Color(0xFF15803D)),
                  ),
                ),
                Text(
                  '#$myRank',
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