import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

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
    final filtered = mockListings.where((l) {
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
          // Search + filter bar
          Row(children: [
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: const Row(children: [
                Icon(Icons.search, size: 18, color: Color(0xFF9CA3AF)),
                SizedBox(width: 8),
                Expanded(child: TextField(
                  decoration: InputDecoration(hintText: 'Search food listings...', border: InputBorder.none, hintStyle: TextStyle(fontSize: 13, color: Color(0xFFD1D5DB))),
                )),
              ]),
            )),
            const SizedBox(width: 12),
            ...[('All', Icons.grid_view_outlined), ('Free', Icons.favorite_outline), ('Sale', Icons.local_offer_outlined)].map((f) {
              final isSelected = _filter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _filter = f.$1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB), width: isSelected ? 2 : 1),
                    ),
                    child: Row(children: [
                      Icon(f.$2, size: 14, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF6B7280)),
                      const SizedBox(width: 4),
                      Text(f.$1, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? const Color(0xFF16A34A) : const Color(0xFF374151))),
                    ]),
                  ),
                ),
              );
            }),
          ]),
          const SizedBox(height: 14),
          // Category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF16A34A) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB)),
                      ),
                      child: Text(cat, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white : const Color(0xFF374151))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Grid
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
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFF3F4F6))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDonation ? [const Color(0xFFD1FAE5), const Color(0xFFA7F3D0)] : [const Color(0xFFFED7AA), const Color(0xFFFDBA74)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: Stack(children: [
              Center(child: Icon(isDonation ? Icons.favorite_outline : Icons.local_offer_outlined, size: 40, color: isDonation ? const Color(0xFF059669) : const Color(0xFFEA580C))),
              Positioned(top: 10, left: 10, child: AppBadge(label: isDonation ? 'FREE' : '৳${listing.price.toInt()}', variant: isDonation ? BadgeVariant.green : BadgeVariant.orange)),
              Positioned(top: 10, right: 10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const Icon(Icons.location_on, size: 10, color: Color(0xFF6B7280)),
                  const SizedBox(width: 2),
                  Text('${listing.distance} km', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                ]),
              )),
            ]),
          ),
          // Details
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(listing.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827)), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(listing.donorName, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
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
    );
  }
}
