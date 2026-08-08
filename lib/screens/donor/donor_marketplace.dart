import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/user_badge.dart';
import '../../widgets/ui/countdown_timer.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';
import '../../data/mock_data.dart';

class DonorMarketplace extends StatefulWidget {
  const DonorMarketplace({super.key});

  @override
  State<DonorMarketplace> createState() => _DonorMarketplaceState();
}

class _DonorMarketplaceState extends State<DonorMarketplace> {
  String _selectedCategory = 'All';
  String _filter = 'All';
  String _availabilityFilter = 'All';
  final _categories = ['All', 'Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];
  final String _dummyLocation = 'Gulshan, Dhaka';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().user!;
    final listings = context.watch<DonorProvider>().listings;

    final now = DateTime.now();
    final filtered = listings.where((l) {
      final catMatch = _selectedCategory == 'All' || l.category == _selectedCategory;
      final typeMatch = _filter == 'All' ||
          (_filter == 'Free' && l.listingType == ListingType.donation) ||
          (_filter == 'Sale' && l.listingType == ListingType.flashSale);
      final availMatch = _availabilityFilter == 'All' ||
          (_availabilityFilter == 'Available' && _consumerFor(l.id).isAvailable) ||
          (_availabilityFilter == 'Unavailable' && !_consumerFor(l.id).isAvailable);
      return catMatch && typeMatch && availMatch && l.pickupEnd.isAfter(now);
    }).toList();

    return AppLayout(
      title: 'Marketplace',
      subtitle: 'Assign your listings to available consumers',
      currentRoute: '/donor/marketplace',
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
                        '${listings.length} active listing${listings.length == 1 ? '' : 's'} ready to share.',
                        style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: const Icon(Icons.storefront_outlined, color: Color(0xFF16A34A), size: 26),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF757575)),
                        const SizedBox(width: 2),
                        Text(
                          _dummyLocation,
                          style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
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
                  decoration: InputDecoration(hintText: 'Search your listings...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF))),
                )),
              ]),
            );

            final filterChips = [
              ('All', Icons.grid_view_outlined),
              ('Free', Icons.favorite_outline),
              ('Sale', Icons.local_offer_outlined)
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
                        Icon(f.$2, size: 14, color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                        const SizedBox(width: 4),
                        Text(f.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
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
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _HoverScale(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFE53238) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFFE53238) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Available', 'Unavailable'].map((avail) {
                final isSelected = _availabilityFilter == avail;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _HoverScale(
                    child: GestureDetector(
                      onTap: () => setState(() => _availabilityFilter = avail),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFF16A34A) : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
                        ),
                        child: Row(children: [
                          Icon(
                            avail == 'Available' ? Icons.check_circle_outline : (avail == 'Unavailable' ? Icons.cancel_outlined : Icons.filter_list),
                            size: 13,
                            color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)),
                          ),
                          const SizedBox(width: 4),
                          Text(avail, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF525252)))),
                        ]),
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
                  Text('No listings found', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212))),
                  const SizedBox(height: 4),
                  Text('Create a listing to start sharing food.', style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
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
  }
}

List<RegisteredAccount> get _consumers =>
    mockAccounts.where((a) => a.mode == UserMode.consumer).toList();

RegisteredAccount _consumerFor(int listingId) =>
    _consumers[(listingId - 1) % _consumers.length];

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonation = listing.listingType == ListingType.donation;
    final consumer = _consumerFor(listing.id);
    final isAvailable = consumer.isAvailable;

    final imageUrl = listing.imageUrl ??
        (isDonation
            ? 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80'
            : 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80');

    return _HoverScale(
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
                gradient: LinearGradient(
                  colors: isDonation
                      ? [const Color(0xFFDCFCE7), const Color(0xFFDCFCE7)]
                      : [const Color(0xFFFFE3CC), const Color(0xFFFFE3CC)],
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
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              isDonation ? Icons.favorite_outline : Icons.local_offer_outlined,
                              size: 40,
                              color: isDonation ? const Color(0xFF059669) : const Color(0xFFEA580C),
                            ),
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
                  child: AppBadge(
                    label: isDonation ? 'FREE' : '৳${listing.price.toInt()}',
                    variant: isDonation ? BadgeVariant.green : BadgeVariant.orange,
                  ),
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
                        '${listing.distance} km',
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
                    Text('${listing.category} · Qty: ${listing.quantity}', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575))),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: const Color(0xFFDCFCE7),
                            child: Text(consumer.name[0], style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(consumer.name, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 3),
                                Builder(builder: (context) {
                                  final label = consumerTierLabel(consumerTierFor(consumer));
                                  return UserBadge(label: label, isLegend: label == 'Legend', fontSize: 8);
                                }),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isAvailable ? (isDark ? const Color(0xFF0D2818) : const Color(0xFFDCFCE7)) : (isDark ? const Color(0xFF2A1A0A) : const Color(0xFFFFE3CC)),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                                  ),
                                  child: Text(
                                    isAvailable ? 'Available' : 'Unavailable',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                            : () {
                          if (isAvailable) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${listing.title} donated to ${consumer.name}'),
                              backgroundColor: const Color(0xFF16A34A),
                            ));
                          } else {
                            mockNotifications.insert(0, AppNotification(
                              id: mockNotifications.length + 1,
                              message: '${consumer.name} is now available. Your listing "${listing.title}" can be assigned.',
                              isRead: false,
                              createdAt: DateTime.now(),
                              type: NotificationType.listing,
                            ));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${consumer.name} will be notified when available'),
                              backgroundColor: const Color(0xFF2563EB),
                            ));
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAvailable ? const Color(0xFF16A34A) : const Color(0xFFE53238),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(listing.pickupEnd.isBefore(DateTime.now())
                                ? Icons.timer_off_outlined
                                : (isAvailable ? Icons.volunteer_activism_outlined : Icons.notifications_active_outlined), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              listing.pickupEnd.isBefore(DateTime.now())
                                  ? 'Expired'
                                  : (isAvailable ? 'Donate' : 'Notify When Available'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
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

