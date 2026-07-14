import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';
import '../../providers/donor_provider.dart';

class ConsumerMarketplace extends StatefulWidget {
  const ConsumerMarketplace({super.key});

  @override
  State<ConsumerMarketplace> createState() => _ConsumerMarketplaceState();
}

class _ConsumerMarketplaceState extends State<ConsumerMarketplace> {
  String _selectedCategory = 'All';
  String _filter = 'All';
  final _categories = ['All', 'Cooked Meals', 'Bakery', 'Dairy', 'Produce', 'Grains'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final listings = context.watch<DonorProvider>().listings;
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
          // Welcome banner
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, ${user.name.split(' ').first} 👋', style: const TextStyle(color: Color(0xFF121212), fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        '${listings.length} surplus listing${listings.length == 1 ? '' : 's'} near you right now.',
                        style: const TextStyle(color: Color(0xFF757575), fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: const BoxDecoration(color: Color(0xFFF5F5F5), borderRadius: BorderRadius.all(Radius.circular(14))),
                  child: const Icon(Icons.restaurant_outlined, color: Color(0xFFEA580C), size: 26),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Builder(builder: (context) {
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, mainAxisExtent: 280, crossAxisSpacing: 16, mainAxisSpacing: 16),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _ListingCard(listing: filtered[i]),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  final Listing listing;
  const _ListingCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final isDonation = listing.listingType == ListingType.donation;
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
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDonation ? [const Color(0xFFDCFCE7), const Color(0xFFDCFCE7)] : [const Color(0xFFFFE3CC), const Color(0xFFFFE3CC)],
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
                            child: Icon(isDonation ? Icons.favorite_outline : Icons.local_offer_outlined, size: 40, color: isDonation ? const Color(0xFF059669) : const Color(0xFFEA580C)),
                          ),
                        ),
                ),
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
                Positioned(top: 10, left: 10, child: AppBadge(label: isDonation ? 'FREE' : '৳${listing.price.toInt()}', variant: isDonation ? BadgeVariant.green : BadgeVariant.orange)),
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF121212)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(listing.donorName, style: const TextStyle(fontSize: 11, color: Color(0xFF757575))),
                    const Spacer(),
                    SizedBox(width: double.infinity, child: ElevatedButton(
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
