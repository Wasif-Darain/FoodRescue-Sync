import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../widgets/ui/date_time_field.dart';
import '../../widgets/ui/location_picker.dart';
import '../../widgets/ui/detail_sheet.dart';
import '../../models/listing.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/consumer_provider.dart';
import '../../l10n/l10n_ext.dart';
import '../../l10n/gen/app_localizations.dart';

class ConsumerMarketplace extends StatefulWidget {
  const ConsumerMarketplace({super.key});

  @override
  State<ConsumerMarketplace> createState() => _ConsumerMarketplaceState();
}

class _ConsumerMarketplaceState extends State<ConsumerMarketplace> {
  String _selectedCategory = 'All';
  String _filter = 'All';

  List<(String, String)> _categories(AppLocalizations t) => [
    ('All', t.mktCatAll),
    ('Cooked Meals', t.mktCatCookedMeals),
    ('Bakery', t.mktCatBakery),
    ('Dairy', t.mktCatDairy),
    ('Produce', t.mktCatProduce),
    ('Grains', t.mktCatGrains),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final consumer = context.watch<ConsumerProvider>();
    final t = context.l10n;

    final now = DateTime.now();
    return StreamBuilder<List<ListingModel>>(
      stream: consumer.availableListingsStream,
      builder: (context, snapshot) {
        final listings = (snapshot.data ?? [])
            .where((l) =>
                l.status == ListingStatusModel.active &&
                l.quantity > 0 &&
                (l.claimDeadline == null || l.claimDeadline!.isAfter(now)))
            .toList();
        final filtered = listings.map((l) => Listing(
          id: int.tryParse(l.id) ?? 0,
          docId: l.id,
          donorId: int.tryParse(l.donorId) ?? 0,
          donorName: l.donorId,
          title: l.title,
          description: l.description,
          price: l.price,
          quantity: l.quantity.toInt(),
          listingType: ListingType.donation,
          pickupStart: l.claimDeadline ?? now,
          pickupEnd: l.claimDeadline ?? now.add(const Duration(hours: 4)),
          latitude: l.latitude,
          longitude: l.longitude,
          status: ListingStatus.active,
          category: l.category,
          imageUrl: l.photoUrls.isNotEmpty ? l.photoUrls.first : null,
          imageCount: l.photoUrls.length,
          address: l.address,
        )).where((l) {
          final catMatch = _selectedCategory == 'All' || l.category == _selectedCategory;
          final typeMatch = _filter == 'All' ||
              (_filter == 'Free' && l.listingType == ListingType.donation);
          return catMatch && typeMatch && l.pickupEnd.isAfter(now) && l.status == ListingStatus.active;
        }).toList();

        return AppLayout(
          title: t.mktTitle,
          subtitle: t.mktSubtitle,
          currentRoute: '/consumer',
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
                          Text(t.mktGreeting(user.name.split(' ').first), style: TextStyle(color: isDark ? Colors.white : const Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(
                            t.mktListingsNear(listings.length),
                            style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: const Icon(Icons.restaurant_outlined, color: Color(0xFFEA580C), size: 26),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _SectionCard(
                title: t.mktQuickActions,
                icon: Icons.bolt_outlined,
                child: Column(
                  children: [
                    _QuickAction(
                      icon: Icons.radar_outlined,
                      label: t.mktSurplusRadar,
                      color: const Color(0xFF2563EB),
                      onTap: () => context.go('/consumer/radar'),
                    ),
                    _QuickAction(
                      icon: Icons.shopping_cart_outlined,
                      label: t.mktBulkRequest,
                      color: const Color(0xFFEA580C),
                      onTap: () => context.go('/consumer/bulk-request'),
                    ),
                    _QuickAction(
                      icon: Icons.history_outlined,
                      label: t.mktRequestStatus,
                      color: const Color(0xFF16A34A),
                      onTap: () => context.go('/consumer/requests'),
                    ),
                    _QuickAction(
                      icon: Icons.emoji_events_outlined,
                      label: t.mktRewards,
                      color: const Color(0xFFF59E0B),
                      onTap: () => context.go('/rewards'),
                    ),
                    _QuickAction(
                      icon: Icons.leaderboard_outlined,
                      label: t.mktLeaderboard,
                      color: const Color(0xFF6B7280),
                      onTap: () => context.go('/leaderboard'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Builder(builder: (context) {
                final searchBox = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                  child: Row(children: [
                    Icon(Icons.search, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(
                      decoration: InputDecoration(hintText: t.mktSearchHint, border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF))),
                    )),
                  ]),
                );

                final filterChips = [
                  ('All', t.mktFilterAll, Icons.grid_view_outlined),
                  ('Free', t.mktFilterFree, Icons.favorite_outline),
                  ('Sale', t.mktFilterSale, Icons.local_offer_outlined)
                ].map((f) {
                  final isSelected = _filter == f.$1;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _HoverScale(
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7)) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)), width: isSelected ? 2 : 1),
                          ),
                          child: Row(children: [
                            Icon(f.$3, size: 14, color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                            const SizedBox(width: 4),
                            Text(f.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
                          ]),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxWidth < 480) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        searchBox,
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(children: filterChips),
                        ),
                      ],
                    );
                  }
                  return Row(children: [Expanded(child: searchBox), ...filterChips]);
                });
              }),
              const SizedBox(height: 14),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories(t).map((cat) {
                    final isSelected = _selectedCategory == cat.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _HoverScale(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedCategory = cat.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE53238) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? const Color(0xFFE53238) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                            ),
                            child: Text(cat.$2, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.storefront_outlined, size: 48, color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFBFBFBF)),
                      const SizedBox(height: 12),
                      Text(t.mktNoListings, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                      const SizedBox(height: 4),
                      Text(t.mktCheckBackSoon, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisExtent: 380,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => _ListingCard(listing: filtered[i]),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _dummyAreaFor(AppLocalizations t, String donorName) {
  final areas = [
    t.areaGulshan,
    t.areaBanani,
    t.areaDhanmondi,
    t.areaUttara,
    t.areaMirpur,
    t.areaBashundhara,
    t.areaMohammadpur,
  ];
  final index = donorName.hashCode.abs() % areas.length;
  return areas[index];
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  void _showClaimSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final consumer = context.read<ConsumerProvider>();
    final t = context.l10n;
    String? deliveryAddress = context.read<AuthProvider>().address;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(listing.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF121212))),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                    onPressed: () => Navigator.pop(sheetContext),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(listing.donorName, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              const SizedBox(height: 4),
              Text(listing.description, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              const SizedBox(height: 12),
              Row(children: [
                AppBadge(label: t.commonFree, variant: BadgeVariant.green),
                const SizedBox(width: 8),
                AppBadge(label: t.mktQtyBadge(listing.quantity), variant: BadgeVariant.blue),
                const SizedBox(width: 8),
                AppBadge(label: t.mktKmBadge(listing.distance.toString()), variant: BadgeVariant.gray),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF757575)),
                const SizedBox(width: 4),
                Text(t.mktPickupBy(
                    '${listing.pickupEnd.hour.toString().padLeft(2, '0')}:${listing.pickupEnd.minute.toString().padLeft(2, '0')}',
                    '${listing.pickupEnd.day}/${listing.pickupEnd.month}/${listing.pickupEnd.year}'),
                  style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
              ]),
              const SizedBox(height: 12),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  final picked = await pickLocation(sheetContext);
                  if (picked == null) return;
                  setSheetState(() => deliveryAddress = picked.address);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
                  ),
                  child: Row(children: [
                    Icon(Icons.local_shipping_outlined, size: 15, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        deliveryAddress ?? t.mktDeliveryAddressHint,
                        style: TextStyle(fontSize: 12.5, color: deliveryAddress == null ? const Color(0xFFBFBFBF) : (isDark ? Colors.white : const Color(0xFF121212))),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.edit_outlined, size: 14, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final success = await consumer.claimListing(listing.docId ?? '', listing.quantity, deliveryAddress: deliveryAddress);
                    if (!context.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? t.mktClaimedMsg(listing.title) : t.mktClaimFailedMsg(listing.title)),
                      backgroundColor: success ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(t.mktClaimNow, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final picked = await pickDateTime(sheetContext, initial: DateTime.now().add(const Duration(hours: 1)));
                    if (picked == null) return;
                    if (!context.mounted) return;
                    final success = await consumer.claimListing(listing.docId ?? '', listing.quantity, scheduledTime: picked, deliveryAddress: deliveryAddress);
                    if (!context.mounted) return;
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(success ? t.mktScheduledMsg(listing.title) : t.mktClaimFailedMsg(listing.title)),
                      backgroundColor: success ? const Color(0xFF2563EB) : const Color(0xFFDC2626),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(t.mktSchedulePickup, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = context.l10n;

    final imageUrl = listing.imageUrl ??
        'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80';

    return _HoverScale(
      child: GestureDetector(
        onTap: () => showListingDetailSheet(
          context,
          title: listing.title,
          subtitle: t.mktListedBy(listing.donorName),
          donorId: listing.donorName,
          rows: [
            DetailRow(Icons.category_outlined, t.mktDetailCategory, ''),
            DetailRow(Icons.inventory_2_outlined, t.mktDetailQuantity, '${listing.quantity}'),
            DetailRow(Icons.payments_outlined, t.mktDetailPrice, listing.listingType == ListingType.donation ? t.commonFreeLabel : '৳${listing.price.toStringAsFixed(0)}'),
            DetailRow(Icons.schedule_outlined, t.mktDetailPickupWindow, '${listing.pickupStart.hour.toString().padLeft(2, '0')}:${listing.pickupStart.minute.toString().padLeft(2, '0')} – ${listing.pickupEnd.hour.toString().padLeft(2, '0')}:${listing.pickupEnd.minute.toString().padLeft(2, '0')} · ${listing.pickupEnd.day}/${listing.pickupEnd.month}/${listing.pickupEnd.year}'),
            if (listing.address != null) DetailRow(Icons.location_on_outlined, t.mktDetailAddress, listing.address!),
          ],
        ),
        child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFDCFCE7), Color(0xFFDCFCE7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(children: [
                Positioned.fill(
                  child: listing.imageBytes != null
                      ? Image.memory(listing.imageBytes!, fit: BoxFit.cover)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.favorite_outline, size: 40, color: Color(0xFF059669)),
                          ),
                        ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.15),
                          Colors.black.withValues(alpha: 0.5),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Row(children: [
                    AppBadge(label: t.commonFree, variant: BadgeVariant.green),
                    if (listing.imageCount > 1) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(children: [
                          const Icon(Icons.photo_library_outlined, size: 10, color: Colors.white70),
                          const SizedBox(width: 3),
                          Text('${listing.imageCount}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
                        ]),
                      ),
                    ],
                  ]),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.location_on, size: 10, color: Colors.white70),
                      const SizedBox(width: 2),
                      Text(
                        t.mktKmBadge(listing.distance.toString()),
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(listing.donorName, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 11, color: Color(0xFFBFBFBF)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address ?? _dummyAreaFor(t, listing.donorName),
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CountdownTimer(expiry: listing.pickupEnd),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: listing.pickupEnd.isBefore(DateTime.now())
                            ? null
                            : () => _showClaimSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          listing.pickupEnd.isBefore(DateTime.now())
                              ? t.mktExpired
                              : t.mktClaimFree,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : const Color(0xFF121212);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.14),
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 12),
          child,
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