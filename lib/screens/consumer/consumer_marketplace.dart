import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../widgets/ui/user_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';

// Main marketplace screen shown to consumers, letting them browse
// nearby surplus food listings (donations and flash sales).
class ConsumerMarketplace extends StatefulWidget {
  const ConsumerMarketplace({super.key});

  @override
  State<ConsumerMarketplace> createState() => _ConsumerMarketplaceState();
}

class _ConsumerMarketplaceState extends State<ConsumerMarketplace> {
  // Currently selected food category filter (e.g. "Bakery", "Dairy").
  String _selectedCategory = 'All';
  // Currently selected listing-type filter ("All", "Free", "Sale").
  String _filter = 'All';
  // Available category chips shown in the horizontal scroll row.
  final _categories = ['All', 'Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];

  // Placeholder location shown under the restaurant icon in the banner.
  final String _dummyLocation = 'Gulshan, Dhaka';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Grab the logged-in user and the list of available listings from providers.
    final user = context.watch<AuthProvider>().user!;
    final listings = context.watch<DonorProvider>().listings;

    // Apply both the category filter and the type filter (Free/Sale) to the listings.
    final filtered = listings.where((l) {
      final catMatch = _selectedCategory == 'All' || l.category == _selectedCategory;
      final typeMatch = _filter == 'All' ||
          (_filter == 'Free' && l.listingType == ListingType.donation) ||
          (_filter == 'Sale' && l.listingType == ListingType.flashSale);
      return catMatch && typeMatch;
    }).toList();

    return AppLayout(
      title: 'Marketplace',
      subtitle: 'Browse nearby surplus food listings',
      currentRoute: '/consumer',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Welcome banner ----
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
                // Left side: greeting text + listing count.
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
                            final label = consumerTierLabel(consumerTierFor(account));
                            return UserBadge(label: label, isLegend: label == 'Legend', fontSize: 9);
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${listings.length} surplus listing${listings.length == 1 ? '' : 's'} near you right now.',
                        style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Right side: restaurant icon badge with location.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: const Icon(Icons.restaurant_outlined, color: Color(0xFFEA580C), size: 26),
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

          // ---- Quick Actions ----
          _SectionCard(
            title: 'Quick Actions',
            icon: Icons.bolt_outlined,
            child: Column(
              children: [
                _QuickAction(
                  icon: Icons.radar_outlined,
                  label: 'Surplus Radar',
                  color: const Color(0xFF2563EB),
                  onTap: () => context.go('/consumer/radar'),
                ),
                _QuickAction(
                  icon: Icons.shopping_cart_outlined,
                  label: 'Bulk Request',
                  color: const Color(0xFFEA580C),
                  onTap: () => context.go('/consumer/bulk-request'),
                ),
                _QuickAction(
                  icon: Icons.history_outlined,
                  label: 'Request Status',
                  color: const Color(0xFF16A34A),
                  onTap: () => context.go('/consumer/requests'),
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

          // ---- Search bar + type filter chips (Free / Sale / All) ----
          Builder(builder: (context) {
            final searchBox = Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE2E2E2))),
              child: Row(children: [
                Icon(Icons.search, size: 18, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  decoration: InputDecoration(hintText: 'Search food listings...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFFBFBFBF))),
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

          // ---- Category filter chips (All / Cooked Meals / Bakery / etc.) ----
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
          const SizedBox(height: 20),

          // ---- Grid of listing cards ----
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 320,
              mainAxisExtent: 320,
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

// Dummy list of Dhaka-area localities used for card display.
const _dummyAreas = [
  'Gulshan 1, Dhaka',
  'Banani, Dhaka',
  'Dhanmondi, Dhaka',
  'Uttara, Dhaka',
  'Mirpur, Dhaka',
  'Bashundhara, Dhaka',
  'Banani Time Square, Dhaka',
  'Mohammadpur, Dhaka',
];

String _dummyAreaFor(String donorName) {
  final index = donorName.hashCode.abs() % _dummyAreas.length;
  return _dummyAreas[index];
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDonation = listing.listingType == ListingType.donation;

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
            // ---- Image header with badges ----
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
            // ---- Card body ----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF121212)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(listing.donorName, style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF757575)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Builder(builder: (context) {
                          final matches = mockAccounts.where((a) => a.mode == UserMode.donor && a.name == listing.donorName);
                          if (matches.isEmpty) return const SizedBox.shrink();
                          final label = donorTierLabel(donorTierFor(matches.first));
                          return Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: UserBadge(label: label, isLegend: label == 'Legend', fontSize: 8),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 11, color: Color(0xFFBFBFBF)),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            _dummyAreaFor(listing.donorName),
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Claimed: ${listing.title}'),
                            backgroundColor: const Color(0xFF16A34A),
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isDonation ? 'Claim Free' : 'Buy Now',
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
    );
  }
}

// Widget definition for _HoverScale
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
              if (action != null) action!,
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