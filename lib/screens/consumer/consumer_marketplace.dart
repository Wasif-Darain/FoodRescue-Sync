import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
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
  // TODO: replace with the user's real location once it's available from
  // the backend (e.g. a `location` field on AppUser, or device GPS).
  final String _dummyLocation = 'Gulshan, Dhaka';

  @override
  Widget build(BuildContext context) {
    // Grab the logged-in user and the list of available listings from providers.
    final user = context.watch<AuthProvider>().user!;
    final listings = context.watch<DonorProvider>().listings;

    // Apply both the category filter and the type filter (Free/Sale) to the listings.
    final filtered = listings.where((l) {
      final catMatch = _selectedCategory == 'All' || l.category == _selectedCategory;
      final typeMatch = _filter == 'All' || (_filter == 'Free' && l.listingType == ListingType.donation) || (_filter == 'Sale' && l.listingType == ListingType.flashSale);
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
          // Greets the user by first name and shows how many listings are nearby.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],
            ),
            child: Row(
              children: [
                // Left side: greeting text + listing count.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${user.name.split(' ').first}!', style: const TextStyle(color: Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '${listings.length} surplus listing${listings.length == 1 ? '' : 's'} near you right now.',
                        style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Right side: restaurant icon badge, now with the user's
                // location displayed underneath it.
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Restaurant icon container (unchanged visual style).
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                      child: const Icon(Icons.restaurant_outlined, color: Color(0xFFEA580C), size: 26),
                    ),
                    const SizedBox(height: 6),
                    // Location label shown under the restaurant icon.
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF757575)),
                        const SizedBox(width: 2),
                        Text(
                          // TODO: replace with the user's real location once
                          // AppUser exposes a location field from the backend.
                          _dummyLocation,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF757575), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ---- Search bar + type filter chips (Free / Sale / All) ----
          // Responsive: stacks vertically on narrow screens, horizontal on wider ones.
          Builder(builder: (context) {
            // Search input box.
            final searchBox = Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E2E2))),
              child: const Row(children: [
                Icon(Icons.search, size: 18, color: Color(0xFF757575)),
                SizedBox(width: 8),
                Expanded(child: TextField(
                  decoration: InputDecoration(hintText: 'Search food listings...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: Color(0xFFBFBFBF))),
                )),
              ]),
            );

            // Build the "All / Free / Sale" filter chips.
            final filterChips = [('All', Icons.grid_view_outlined), ('Free', Icons.favorite_outline), ('Sale', Icons.local_offer_outlined)].map((f) {
              final isSelected = _filter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _HoverScale(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFDCFCE7) : const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE2E2E2), width: isSelected ? 2 : 1),
                      ),
                      child: Row(children: [
                        Icon(f.$2, size: 14, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF757575)),
                        const SizedBox(width: 4),
                        Text(f.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF525252))),
                      ]),
                    ),
                  ),
                ),
              );
            }).toList();

            // On narrow screens, stack the search box above the chips (horizontally scrollable).
            // On wider screens, place them side by side in one row.
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
                          color: isSelected ? const Color(0xFFE53238) : const Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFFE53238) : const Color(0xFFE2E2E2)),
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF525252))),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // ---- Grid of listing cards ----
          // Auto-fills columns based on available width (max 320px per card).
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, mainAxisExtent: 296, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _ListingCard(listing: filtered[i]),
          ),
        ],
      ),
    );
  }
}

// Dummy list of Dhaka-area localities used to give each listing card a
// distinct-looking location line under the donor name.
// TODO: remove this once real addresses come from the backend.
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

// Picks a dummy area for a given donor name, deterministically, so the same
// donor always shows the same locality instead of a random one each rebuild.
String _dummyAreaFor(String donorName) {
  final index = donorName.hashCode.abs() % _dummyAreas.length;
  return _dummyAreas[index];
}

// A single card representing one food listing (donation or flash sale)
// in the marketplace grid.
class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDonation = listing.listingType == ListingType.donation;

    // Use the listing's own image if provided, otherwise fall back to a
    // stock photo depending on whether it's a donation or a paid sale.
    final imageUrl = listing.imageUrl ??
        (isDonation
            ? 'https://images.unsplash.com/photo-1547592180-85f173990554?auto=format&fit=crop&w=900&q=80'
            : 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=900&q=80');

    return _HoverScale(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E2E2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Image header with badges ----
            Container(
              height: 120,
              decoration: BoxDecoration(
                // Soft background tint behind the image, color-coded by listing type.
                gradient: LinearGradient(
                  colors: isDonation ? [const Color(0xFFDCFCE7), const Color(0xFFDCFCE7)] : [const Color(0xFFFFE3CC), const Color(0xFFFFE3CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(children: [
                // Listing photo (from memory if locally picked, otherwise from network).
                Positioned.fill(
                  child: listing.imageBytes != null
                      ? Image.memory(listing.imageBytes!, fit: BoxFit.cover)
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          // Fallback icon if the network image fails to load.
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(isDonation ? Icons.favorite_outline : Icons.local_offer_outlined, size: 40, color: isDonation ? const Color(0xFF059669) : const Color(0xFFEA580C)),
                          ),
                        ),
                ),
                // Darkening gradient overlay so the badges/text stay readable over any photo.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                // Top-left badge: "FREE" for donations, or the price in Taka for sales.
                Positioned(top: 10, left: 10, child: AppBadge(label: isDonation ? 'FREE' : '৳${listing.price.toInt()}', variant: isDonation ? BadgeVariant.green : BadgeVariant.orange)),
                // Top-right badge: distance from the current user, in km.
                Positioned(top: 10, right: 10, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.location_on, size: 10, color: Colors.white70),
                    const SizedBox(width: 2),
                    Text('${listing.distance} km', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white)),
                  ]),
                )),
              ]),
            ),
            // ---- Card body: title, donor name, and action button ----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF121212)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(listing.donorName, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    const SizedBox(height: 2),
                    // Dummy locality shown under the donor name, e.g. "Gulshan 1, Dhaka".
                    // TODO: replace with a real address/area field once the
                    // Listing model exposes one from the backend.
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
                    // Claim/Buy button — label and color depend on listing type.
                    SizedBox(width: double.infinity, child: ElevatedButton(
                      onPressed: () {
                        // TODO: hook this up to real claim/purchase logic; currently just a toast.
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
                      child: Text(isDonation ? 'Claim Free' : 'Buy Now', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    )),
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

// Wraps a child widget with a subtle scale-up animation on hover (desktop/web)
// or press (touch), giving cards and chips a bit of tactile feedback.
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