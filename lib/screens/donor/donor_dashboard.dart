import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/user_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final donor = context.watch<DonorProvider>();
    final surplusItems = donor.inventory.where((i) => i.isSurplus).toList();
    final now = DateTime.now();
    final expiringToday = donor.inventory.where((i) {
      final diff = i.expiryDate.difference(now);
      return diff.inSeconds > 0 && diff.inHours < 24;
    }).toList();
    final activeListings = donor.listings
        .where((l) => l.status == ListingStatus.active)
        .take(3)
        .toList();

    return AppLayout(
      title: 'Donor Dashboard',
      subtitle: 'Manage your inventory, listings, and track donations',
      currentRoute: '/donor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome banner
          Container(
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
                      Row(
                        children: [
                          Flexible(
                            child: Text('Hi, ${user.name.split(' ').first}!', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Builder(builder: (context) {
                            final account = mockAccounts.firstWhere((a) => a.name == user.name, orElse: () => mockAccounts.first);
                            final label = donorTierLabel(donorTierFor(account));
                            return UserBadge(label: label, isLegend: label == 'Legend', fontSize: 9);
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        surplusItems.isEmpty
                            ? 'Your inventory is in great shape today.'
                            : '${surplusItems.length} item${surplusItems.length == 1 ? '' : 's'} ready to redistribute today.',
                        style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: const Icon(Icons.eco_outlined, color: Color(0xFF16A34A), size: 26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stat cards
          ResponsiveGrid(
            children: [
              StatCard(
                label: 'Total Items',
                value: donor.inventory.length,
                icon: const Icon(Icons.inventory_2_outlined),
                color: 'blue',
              ),
              StatCard(
                label: 'Surplus Tagged',
                value: surplusItems.length,
                icon: const Icon(Icons.warning_amber_outlined),
                color: 'orange',
                subtitle: 'Need redistribution',
              ),
              StatCard(
                label: 'Active Listings',
                value: activeListings.length,
                icon: const Icon(Icons.trending_up),
                color: 'green',
              ),
              StatCard(
                label: 'Total Donated',
                value: mockDonationLogs.length,
                icon: const Icon(Icons.favorite_outlined),
                color: 'red',
                subtitle: 'This month',
              ),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 700;

            final leftColumn = Column(
              children: [
                if (expiringToday.isNotEmpty) ...[
                  _SectionCard(
                    title: 'Expiring Today',
                    icon: Icons.timer_outlined,
                    titleColor: const Color(0xFFEF4444),
                    action: TextButton(
                      onPressed: () => context.go('/donor/expiry'),
                      child: const Text('View all'),
                    ),
                    child: Column(
                      children: expiringToday
                          .map((item) => _InventoryRow(item: item))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                _SectionCard(
                  title: 'Active Listings',
                  icon: Icons.storefront_outlined,
                  action: TextButton(
                    onPressed: () => context.go('/donor/create-listing'),
                    child: const Text('Create new'),
                  ),
                  child: Column(
                    children: activeListings
                        .map((l) => _ListingRow(listing: l))
                        .toList(),
                  ),
                ),
              ],
            );

            final rightColumn = Column(
              children: [
                _SectionCard(
                  title: 'Quick Actions',
                  icon: Icons.bolt_outlined,
                  child: Column(
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Add Inventory',
                        color: const Color(0xFF2563EB),
                        onTap: () => context.go('/donor/inventory'),
                      ),
                      _QuickAction(
                        icon: Icons.timer_outlined,
                        label: 'Check Expiry',
                        color: const Color(0xFFEA580C),
                        onTap: () => context.go('/donor/expiry'),
                      ),
                                            _QuickAction(
                        icon: Icons.receipt_long_outlined,
                        label: 'Donation Log',
                        color: const Color(0xFF16A34A),
                        onTap: () => context.go('/donor/donation-log'),
                      ),
                      _QuickAction(
                        icon: Icons.emoji_events_outlined,
                        label: 'Rewards',
                        color: const Color(0xFFF59E0B),
                        onTap: () => context.go('/rewards'),
                      ),
                      _QuickAction(
                        icon: Icons.leaderboard_outlined,
                        label: 'Leaderboard',
                        color: const Color(0xFF6B7280),
                        onTap: () => context.go('/leaderboard'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _SectionCard(
                  title: 'Recent Donations',
                  icon: Icons.volunteer_activism_outlined,
                  child: Column(
                    children: mockDonationLogs
                        .take(3)
                        .map((log) => _DonationRow(log: log))
                        .toList(),
                  ),
                ),
              ],
            );

            if (isNarrow) {
              return Column(
                children: [leftColumn, const SizedBox(height: 20), rightColumn],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: leftColumn),
                const SizedBox(width: 20),
                Expanded(child: rightColumn),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;
  final Widget? action;
  final Color? titleColor;
  const _SectionCard({
    required this.title,
    required this.child,
    this.icon,
    this.action,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = titleColor ?? (isDark ? Colors.white : const Color(0xFF121212));
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
                  if (icon != null) ...[
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
                  ),
                ],
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final InventoryItem item;
  const _InventoryRow({required this.item});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                '${item.category} · Qty: ${item.quantity}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
        AppBadge(label: 'Expires today', variant: BadgeVariant.red),
      ],
    ),
  );
}

class _ListingRow extends StatelessWidget {
  final Listing listing;
  const _ListingRow({required this.listing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                listing.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                '${listing.category} · Qty: ${listing.quantity}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 4),
              CountdownTimer(expiry: listing.pickupEnd, fontSize: 9),
            ],
          ),
        ),
        AppBadge(
          label: listing.listingType == ListingType.donation
              ? 'FREE'
              : '৳${listing.price.toInt()}',
          variant: listing.listingType == ListingType.donation
              ? BadgeVariant.green
              : BadgeVariant.orange,
        ),
      ],
    ),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: Color(0xFFBFBFBF),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _DonationRow extends StatelessWidget {
  final DonationLog log;
  const _DonationRow({required this.log});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                log.itemName,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                log.recipientOrg,
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
        Text(
          '×${log.quantity}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF525252),
          ),
        ),
      ],
    ),
  );
}
