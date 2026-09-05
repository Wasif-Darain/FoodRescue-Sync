import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/stat_card.dart';
import '../../widgets/ui/responsive_grid.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/user_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../widgets/ui/detail_sheet.dart';
import '../../widgets/ui/block_button.dart';
import '../../widgets/ui/report_button.dart';
import '../../widgets/ui/rating_stars.dart';
import '../../models/donation_log.dart';
import '../../models/models.dart';
import '../../models/pickup.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';
import '../../providers/block_provider.dart';
import '../../widgets/ui/live_tracking_map.dart';
import '../../l10n/l10n_ext.dart';

class DonorDashboard extends StatelessWidget {
  const DonorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final donor = context.watch<DonorProvider>();
    final t = context.l10n;
    final blocked = context.watch<BlockProvider>().blockedUids;
    final myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final recentDonationsStream = myUid.isEmpty
        ? Stream<List<DonationLogModel>>.value([])
        : FirebaseFirestore.instance
            .collection('donation_logs')
            .where('donorId', isEqualTo: myUid)
            .snapshots()
            .map((snap) => (snap.docs
                    .map((doc) => DonationLogModel.fromFirestore(doc))
                    .toList()
                  ..sort((a, b) => b.completedAt.compareTo(a.completedAt)))
                .take(5)
                .toList());
    final activePickupsStream = myUid.isEmpty
        ? Stream<List<PickupModel>>.value([])
        : FirebaseFirestore.instance
            .collection('pickups')
            .where('donorId', isEqualTo: myUid)
            .snapshots()
            .map((snap) => snap.docs
                .map((doc) => PickupModel.fromFirestore(doc))
                .where((p) => p.status != PickupStatusModel.completed && p.status != PickupStatusModel.cancelled)
                .toList());
    final recentlyCompletedPickupsStream = myUid.isEmpty
        ? Stream<List<PickupModel>>.value([])
        : FirebaseFirestore.instance
            .collection('pickups')
            .where('donorId', isEqualTo: myUid)
            .snapshots()
            .map((snap) => (snap.docs
                    .map((doc) => PickupModel.fromFirestore(doc))
                    .where((p) => p.status == PickupStatusModel.completed && p.distributionPhotoUrl != null)
                    .toList()
                  ..sort((a, b) => (b.completedAt ?? DateTime(0)).compareTo(a.completedAt ?? DateTime(0))))
                .take(5)
                .toList());

    return StreamBuilder<List<InventoryItem>>(
      stream: donor.inventoryStream,
      builder: (context, inventorySnapshot) {
        final inventory = inventorySnapshot.data ?? donor.inventory;
        final surplusItems = inventory.where((i) => i.isSurplus).toList();
        final now = DateTime.now();
        final expiringToday = inventory.where((i) {
          final diff = i.expiryDate.difference(now);
          return diff.inSeconds > 0 && diff.inHours < 24;
        }).toList();

        return StreamBuilder<List<Listing>>(
          stream: donor.listingsStream,
          builder: (context, listingsSnapshot) {
            final listings = listingsSnapshot.data ?? donor.listings;
            final activeListings = listings
                .where((l) => l.status == ListingStatus.active)
                .take(3)
                .toList();
            final totalDonatedKg = inventory.fold<double>(
              0,
              (acc, item) => acc + item.quantity * 0.5,
            );

            return AppLayout(
              title: t.donorDashTitle,
              subtitle: t.donorDashSubtitle,
              currentRoute: '/donor',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                    child: Text(t.donorDashGreeting(user.name.split(' ').first), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 8),
                                  UserBadge(label: t.donorDashContributor, isLegend: false, fontSize: 9),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                surplusItems.isEmpty
                                    ? t.donorDashInventoryGreatShape
                                    : t.donorDashItemsReady(surplusItems.length),
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
                  ResponsiveGrid(
                    children: [
                      StatCard(
                        label: t.donorDashTotalItems,
                        value: inventory.length,
                        icon: const Icon(Icons.inventory_2_outlined),
                        color: 'blue',
                      ),
                      StatCard(
                        label: t.donorDashSurplusTagged,
                        value: surplusItems.length,
                        icon: const Icon(Icons.warning_amber_outlined),
                        color: 'orange',
                        subtitle: t.donorDashNeedRedistribution,
                      ),
                      StatCard(
                        label: t.donorDashActiveListings,
                        value: listings.where((l) => l.status == ListingStatus.active).length,
                        icon: const Icon(Icons.trending_up),
                        color: 'green',
                      ),
                      StatCard(
                        label: t.donorDashFoodSavedKg,
                        value: totalDonatedKg.toStringAsFixed(1),
                        icon: const Icon(Icons.favorite_outlined),
                        color: 'red',
                        subtitle: t.donorDashEstimated,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 700;

                    final leftColumn = Column(
                      children: [
                        StreamBuilder<List<PickupModel>>(
                          stream: activePickupsStream,
                          builder: (context, activePickupsSnap) {
                            final activePickups = activePickupsSnap.data ?? [];
                            if (activePickups.isEmpty) return const SizedBox.shrink();
                            return Column(
                              children: [
                                _SectionCard(
                                  title: t.donorDashActivePickups,
                                  icon: Icons.local_shipping_outlined,
                                  child: Column(
                                    children: activePickups
                                        .map((p) => _ActivePickupRow(pickup: p))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                        StreamBuilder<List<PickupModel>>(
                          stream: recentlyCompletedPickupsStream,
                          builder: (context, completedSnap) {
                            final recentlyCompleted = completedSnap.data ?? [];
                            if (recentlyCompleted.isEmpty) return const SizedBox.shrink();
                            return Column(
                              children: [
                                _SectionCard(
                                  title: t.donorDashVerifyDistribution,
                                  icon: Icons.fact_check_outlined,
                                  child: Column(
                                    children: recentlyCompleted
                                        .map((p) => _CompletedPickupRow(pickup: p))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                        if (expiringToday.isNotEmpty) ...[
                          _SectionCard(
                            title: t.donorDashExpiringToday,
                            icon: Icons.timer_outlined,
                            titleColor: const Color(0xFFEF4444),
                            action: TextButton(
                              onPressed: () => context.go('/donor/expiry'),
                              child: Text(t.commonViewAll),
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
                          title: t.donorDashActiveListings,
                          icon: Icons.storefront_outlined,
                          action: TextButton(
                            onPressed: () => context.go('/donor/create-listing'),
                            child: Text(t.donorDashCreateNew),
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
                          title: t.donorDashQuickActions,
                          icon: Icons.bolt_outlined,
                          child: Column(
                            children: [
                              _QuickAction(
                                icon: Icons.timer_outlined,
                                label: t.donorDashCheckExpiry,
                                color: const Color(0xFFEA580C),
                                onTap: () => context.go('/donor/expiry'),
                              ),
                              _QuickAction(
                                icon: Icons.receipt_long_outlined,
                                label: t.donorDashDonationLog,
                                color: const Color(0xFF16A34A),
                                onTap: () => context.go('/donor/donation-log'),
                              ),
                              _QuickAction(
                                icon: Icons.emoji_events_outlined,
                                label: t.donorDashRewards,
                                color: const Color(0xFFF59E0B),
                                onTap: () => context.go('/rewards'),
                              ),
                              _QuickAction(
                                icon: Icons.leaderboard_outlined,
                                label: t.donorDashLeaderboard,
                                color: const Color(0xFF6B7280),
                                onTap: () => context.go('/leaderboard'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionCard(
                          title: t.donorDashRecentDonations,
                          icon: Icons.volunteer_activism_outlined,
                          child: StreamBuilder<List<DonationLogModel>>(
                            stream: recentDonationsStream,
                            builder: (context, snap) {
                              final logs = snap.data ?? [];
                              if (logs.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Text(
                                    t.donorDashNoDonationHistory,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF757575),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: logs
                                    .map(
                                      (l) => _RecentDonationRow(
                                        log: l,
                                        isBlocked: blocked.contains(
                                          l.recipientId,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
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
          },
        );
      },
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
                context.l10n.donorDashQtyLabel(item.category, item.quantity),
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
            ],
          ),
        ),
        AppBadge(label: context.l10n.donorDashExpiresToday, variant: BadgeVariant.red),
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
                context.l10n.donorDashQtyLabel(listing.category, listing.quantity),
                style: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
              ),
              const SizedBox(height: 4),
              CountdownTimer(expiry: listing.pickupEnd, fontSize: 9),
            ],
          ),
        ),
        AppBadge(
          label: listing.listingType == ListingType.donation
              ? context.l10n.commonFree
              : '৳${listing.price.toInt()}',
          variant: listing.listingType == ListingType.donation
              ? BadgeVariant.green
              : BadgeVariant.orange,
        ),
      ],
    ),
  );
}

class _ActivePickupRow extends StatelessWidget {
  final PickupModel pickup;
  const _ActivePickupRow({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final hasRider = pickup.volunteerDriverId != null && pickup.volunteerDriverId!.isNotEmpty;
    final canTrack = hasRider || pickup.isSelfPickup;
    final (statusLabel, variant) = switch (pickup.status) {
      PickupStatusModel.enRoute      => (t.pickupStatusEnRoute, BadgeVariant.orange),
      PickupStatusModel.pickedUp     => (t.pickupStatusPickedUp, BadgeVariant.purple),
      PickupStatusModel.delivered    => (t.pickupStatusDelivered, BadgeVariant.teal),
      PickupStatusModel.distributing => (t.pickupStatusDistributing, BadgeVariant.amber),
      _ => (t.pickupStatusScheduled, BadgeVariant.blue),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.pickupHashId(pickup.id),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasRider) ...[
                  const SizedBox(height: 2),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance.collection('users').doc(pickup.volunteerDriverId).snapshots(),
                    builder: (context, riderSnap) {
                      final riderName = riderSnap.data?.data()?['name'] as String? ?? '…';
                      return Text(t.pickupAssignedTo(riderName), style: const TextStyle(fontSize: 11, color: Color(0xFF757575)));
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppBadge(label: statusLabel, variant: variant),
          if (canTrack) ...[
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => showLiveTrackingMap(context, pickup.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFF2563EB)),
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              child: Text(t.trackButton, style: const TextStyle(fontSize: 11.5)),
            ),
          ],
        ],
      ),
    );
  }
}

/// A completed pickup whose distribution proof photo is in — lets the donor
/// open the photo full-screen, rate the consumer, or block/report them if
/// the proof doesn't match what was claimed.
class _CompletedPickupRow extends StatelessWidget {
  final PickupModel pickup;
  const _CompletedPickupRow({required this.pickup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final consumerId = pickup.consumerId ?? '';
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262626) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: InteractiveViewer(child: Image.network(pickup.distributionPhotoUrl!)),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(pickup.distributionPhotoUrl!, width: 64, height: 64, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickup.listingTitle?.isNotEmpty == true ? pickup.listingTitle! : t.pickupHashId(pickup.id),
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (consumerId.isNotEmpty)
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance.collection('users').doc(consumerId).snapshots(),
                        builder: (context, snap) {
                          final name = snap.data?.data()?['name'] as String? ?? '…';
                          return Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(t.pickupAssignedTo(name), style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          RatingStars(reviewLabel: t.donorRateConsumer),
          if (consumerId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(children: [
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').doc(consumerId).snapshots(),
                builder: (context, snap) {
                  final name = snap.data?.data()?['name'] as String? ?? '';
                  return BlockButton(targetUid: consumerId, targetLabel: name);
                },
              ),
              const SizedBox(width: 8),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance.collection('users').doc(consumerId).snapshots(),
                builder: (context, snap) {
                  final name = snap.data?.data()?['name'] as String? ?? '';
                  return ReportButton(targetUid: consumerId, targetLabel: name, pickupId: pickup.id);
                },
              ),
            ]),
          ],
        ],
      ),
    );
  }
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

class _RecentDonationRow extends StatelessWidget {
  final DonationLogModel log;
  final bool isBlocked;
  const _RecentDonationRow({required this.log, required this.isBlocked});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;
    final date =
        '${log.completedAt.day}/${log.completedAt.month}/${log.completedAt.year}';
    final items = log.itemSummary.entries
        .map((e) => '${e.key} (${e.value.toStringAsFixed(1)} kg)')
        .join(', ');
    return InkWell(
      onTap: () => showListingDetailSheet(
        context,
        title: '${log.totalWeightKg.toStringAsFixed(1)} kg',
        subtitle: date,
        donorId: log.recipientId,
        rows: [
          DetailRow(
            Icons.person_outline,
            'Recipient',
            log.recipientId.isEmpty ? '-' : log.recipientId,
          ),
          if (items.isNotEmpty)
            DetailRow(Icons.inventory_2_outlined, 'Items', items),
          DetailRow(
            Icons.check_circle_outline,
            'Status',
            t.donationLogCompleted,
          ),
        ],
        menuActions: log.recipientId.isEmpty
            ? const <SheetMenuItem>[]
            : <SheetMenuItem>[
                blockSheetMenuItem(
                  context,
                  targetUid: log.recipientId,
                  targetLabel: log.recipientId,
                ),
              ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2),
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${log.totalWeightKg.toStringAsFixed(1)} kg → ${log.recipientId}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF121212),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            if (isBlocked)
              AppBadge(label: t.blockBlocked, variant: BadgeVariant.red),
          ],
        ),
      ),
    );
  }
}