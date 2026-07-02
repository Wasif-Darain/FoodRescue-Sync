import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/app_button.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final surplusItems = mockInventory.where((i) => i.isSurplus).toList();
    final now = DateTime.now();
    final expiringToday = mockInventory.where((i) {
      final diff = i.expiryDate.difference(now);
      return diff.inSeconds > 0 && diff.inHours < 24;
    }).toList();
    final activeListings = mockListings
        .where((l) => l.status == ListingStatus.active)
        .take(3)
        .toList();

    return AppLayout(
      title: 'Donor Dashboard',
      subtitle: 'Manage your inventory, listings, and track donations',
      currentRoute: '/donor',
      action: AppButton(
        label: 'New Listing',
        icon: const Icon(Icons.add, size: 16),
        onPressed: () => context.go('/donor/create-listing'),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat cards
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Total Items',
                  value: mockInventory.length,
                  icon: const Icon(Icons.inventory_2_outlined),
                  color: 'blue',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Surplus Tagged',
                  value: surplusItems.length,
                  icon: const Icon(Icons.warning_amber_outlined),
                  color: 'orange',
                  subtitle: 'Need redistribution',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Active Listings',
                  value: activeListings.length,
                  icon: const Icon(Icons.trending_up),
                  color: 'green',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: StatCard(
                  label: 'Total Donated',
                  value: mockDonationLogs.length,
                  icon: const Icon(Icons.favorite_outlined),
                  color: 'red',
                  subtitle: 'This month',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    if (expiringToday.isNotEmpty) ...[
                      _SectionCard(
                        title: 'Expiring Today',
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
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Quick Actions',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SectionCard(
                      title: 'Recent Donations',
                      child: Column(
                        children: mockDonationLogs
                            .take(3)
                            .map((log) => _DonationRow(log: log))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;
  final Color? titleColor;
  const _SectionCard({
    required this.title,
    required this.child,
    this.action,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFF3F4F6)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: titleColor ?? const Color(0xFF111827),
              ),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
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
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    leading: Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 16),
    ),
    title: Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      size: 12,
      color: Color(0xFFD1D5DB),
    ),
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ),
        Text(
          '×${log.quantity}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    ),
  );
}
