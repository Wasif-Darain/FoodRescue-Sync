import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/app_badge.dart';
import '../../providers/auth_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  String _timeFrame = 'Weekly';

  final _certifications = [
    {
      'title': 'Top Donor of the Month',
      'date': 'June 2024',
      'description': 'Awarded for being the top donor in June 2024.',
      'icon': Icons.emoji_events,
      'color': const Color(0xFFFFD700),
      'variant': BadgeVariant.orange,
    },
    {
      'title': 'Top Consumer of the Week',
      'date': 'Week 24, 2024',
      'description': 'Awarded for being the top consumer in Week 24, 2024.',
      'icon': Icons.star,
      'color': const Color(0xFFC0C0C0),
      'variant': BadgeVariant.gray,
    },
  ];

  final _badges = [
    {
      'name': 'Gold Donor',
      'description': 'Donated 100+ items. Your generosity is saving hundreds of meals.',
      'icon': Icons.military_tech,
      'color': const Color(0xFFF59E0B),
      'progress': 1.0,
      'achieved': true,
    },
    {
      'name': 'Silver Consumer',
      'description': 'Consumed 50+ items. Every meal rescued counts.',
      'icon': Icons.workspace_premium,
      'color': const Color(0xFF9CA3AF),
      'progress': 1.0,
      'achieved': true,
    },
    {
      'name': 'Bronze Supporter',
      'description': 'Donated or consumed 20+ items.',
      'icon': Icons.shield_outlined,
      'color': const Color(0xFFD97706),
      'progress': 1.0,
      'achieved': true,
    },
    {
      'name': 'Zero Waste Hero',
      'description': 'Log 150 items across 3 months without a single wasted meal.',
      'icon': Icons.eco_outlined,
      'color': const Color(0xFF16A34A),
      'progress': 0.72,
      'achieved': false,
    },
    {
      'name': 'Community Champion',
      'description': 'Inspire 10 people to join the platform and start rescuing.',
      'icon': Icons.groups_outlined,
      'color': const Color(0xFF2563EB),
      'progress': 0.5,
      'achieved': false,
    },
    {
      'name': 'Night Owl Saver',
      'description': 'Rescue 5 listings during late-night flash sales.',
      'icon': Icons.nights_stay_outlined,
      'color': const Color(0xFF7C3AED),
      'progress': 0.4,
      'achieved': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final totalPoints = 1250;
    final level = 'Gold';

    final (weekly, monthly, yearly) = switch (_timeFrame) {
      'Monthly' => (450, 1250, 5200),
      'Yearly' => (690, 2480, 5200),
      _ => (320, 1250, 5200),
    };
    final thisPeriodPoints = _timeFrame == 'Weekly' ? weekly : _timeFrame == 'Monthly' ? monthly : yearly;
    final rescuedMeals = _timeFrame == 'Weekly' ? 48 : _timeFrame == 'Monthly' ? 186 : 720;
    final periodLabel = _timeFrame == 'Weekly' ? 'week' : _timeFrame == 'Monthly' ? 'month' : 'year';

    return AppLayout(
      title: 'Rewards',
      subtitle: 'Track your achievements and earn badges',
      currentRoute: '/rewards',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HoverScale(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hi, ${user.name.split(' ').first}!', style: const TextStyle(color: Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          'You\'ve earned $thisPeriodPoints points this $periodLabel and reached $level level.',
                          style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: 0.72,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFF0F0F0),
                            valueColor: const AlwaysStoppedAnimation(Color(0xFF16A34A)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '500 pts to Platinum',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(color: Color(0xFFFFF7ED), borderRadius: BorderRadius.all(Radius.circular(14))),
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
                label: 'Total Points',
                value: totalPoints,
                icon: const Icon(Icons.star_outlined),
                color: 'yellow',
                subtitle: 'All time',
              ),
              StatCard(
                label: 'Current Level',
                value: level,
                icon: const Icon(Icons.trending_up),
                color: 'blue',
                subtitle: 'Platinum is next',
              ),
              StatCard(
                label: 'Badges Earned',
                value: 8,
                icon: const Icon(Icons.workspace_premium_outlined),
                color: 'purple',
                subtitle: 'Out of 15 total',
              ),
              StatCard(
                label: 'Certifications',
                value: 4,
                icon: const Icon(Icons.verified_outlined),
                color: 'green',
                subtitle: 'Top positions held',
              ),
            ],
          ),
          const SizedBox(height: 24),
          _HoverScale(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFF121212)),
                      const SizedBox(width: 6),
                      Text('Stat Breakdown — $_timeFrame', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _BreakdownCell(label: 'Donations', value: 22, color: const Color(0xFF16A34A), icon: Icons.volunteer_activism_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _BreakdownCell(label: 'Consumptions', value: 18, color: const Color(0xFF2563EB), icon: Icons.restaurant_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _BreakdownCell(label: 'Flash Sales', value: 9, color: const Color(0xFFEA580C), icon: Icons.local_offer_outlined)),
                  ]),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(child: _MiniStat(label: 'Points this period', value: '$thisPeriodPoints', color: const Color(0xFFF59E0B))),
                    const SizedBox(width: 12),
                    Expanded(child: _MiniStat(label: 'Rescued meals', value: '$rescuedMeals', color: const Color(0xFF16A34A))),
                    const SizedBox(width: 12),
                    Expanded(child: _MiniStat(label: 'CO₂ saved (kg)', value: '182', color: const Color(0xFF2563EB))),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildCertifications(),
          const SizedBox(height: 24),
          _buildBadges(),
        ],
      ),
    );
  }

  Widget _buildCertifications() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xFF121212)),
                  const SizedBox(width: 6),
                  const Text('Certifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212))),
                ],
              ),
              AppBadge(label: '2 New', variant: BadgeVariant.green),
            ],
          ),
          const SizedBox(height: 12),
          ..._certifications.map((cert) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _HoverScale(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E2E2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (cert['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(cert['icon'] as IconData, size: 22, color: cert['color'] as Color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    cert['title']! as String,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF121212)),
                                  ),
                                ),
                                AppBadge(label: cert['date']! as String, variant: cert['variant'] as BadgeVariant),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cert['description']! as String,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Badges', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('8 / 15 unlocked', style: TextStyle(fontSize: 12, color: Color(0xFF757575))),
          ],
        ),
        const SizedBox(height: 12),
        ResponsiveGrid(
          minItemWidth: 220,
          children: _badges.map((badge) {
            final achieved = badge['achieved'] as bool;
            final progress = badge['progress'] as double;
            final color = badge['color'] as Color;

            return _HoverScale(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: achieved ? color.withValues(alpha: 0.15) : const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            badge['icon'] as IconData,
                            size: 24,
                            color: achieved ? color : const Color(0xFFBFBFBF),
                          ),
                        ),
                        const Spacer(),
                        if (achieved)
                          const AppBadge(label: 'Achieved', variant: BadgeVariant.green)
                        else
                          AppBadge(label: 'Locked', variant: BadgeVariant.gray),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      badge['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: achieved ? const Color(0xFF121212) : const Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      badge['description'] as String,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation(achieved ? color : const Color(0xFF9CA3AF)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      achieved ? 'Completed' : '${(progress * 100).toInt()}% complete',
                      style: TextStyle(fontSize: 10, color: achieved ? color : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _TimeFrameChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TimeFrameChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF121212) : const Color(0xFFE2E2E2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF525252),
          ),
        ),
      ),
    );
  }
}

class _BreakdownCell extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _BreakdownCell({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text('$value', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF757575))),
        ],
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