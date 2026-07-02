import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../widgets/ui/app_badge.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';

class SurplusRadar extends StatelessWidget {
  const SurplusRadar({super.key});

  @override
  Widget build(BuildContext context) {
    final sorted = [...mockListings]..sort((a, b) => (a.distance ?? 99).compareTo(b.distance ?? 99));

    return AppLayout(
      title: 'Surplus Radar',
      subtitle: 'Discover surplus food near you',
      currentRoute: '/consumer/radar',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Map placeholder
          Expanded(
            flex: 3,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFBFDBFE), Color(0xFF93C5FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.map_outlined, size: 64, color: Color(0xFF1D4ED8)),
                    SizedBox(height: 12),
                    Text('Interactive Map', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                    SizedBox(height: 4),
                    Text('Dhaka, Bangladesh', style: TextStyle(fontSize: 12, color: Color(0xFF2563EB))),
                  ])),
                  // Pins
                  ...sorted.take(5).toList().asMap().entries.map((e) {
                    final offsets = [const Offset(0.35, 0.4), const Offset(0.6, 0.55), const Offset(0.45, 0.65), const Offset(0.7, 0.35), const Offset(0.25, 0.6)];
                    final offset = offsets[e.key % offsets.length];
                    final isDonation = e.value.listingType == ListingType.donation;
                    return Positioned(
                      left: MediaQuery.of(context).size.width * 0.3 * offset.dx,
                      top: 500 * offset.dy,
                      child: GestureDetector(
                        onTap: () {},
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Text(isDonation ? 'FREE' : '৳${e.value.price.toInt()}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          Container(width: 2, height: 8, color: isDonation ? const Color(0xFF16A34A) : const Color(0xFFEA580C)),
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                        ]),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Listing panel
          SizedBox(
            width: 280,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE5E7EB))),
                  child: const Row(children: [
                    Icon(Icons.sort, size: 16, color: Color(0xFF6B7280)),
                    SizedBox(width: 8),
                    Text('Nearest first', style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
                  ]),
                ),
                const SizedBox(height: 12),
                ...sorted.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFF3F4F6))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(child: Text(l.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        AppBadge(label: l.listingType == ListingType.donation ? 'FREE' : '৳${l.price.toInt()}', variant: l.listingType == ListingType.donation ? BadgeVariant.green : BadgeVariant.orange),
                      ]),
                      const SizedBox(height: 6),
                      Text(l.donorName, style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF6B7280)),
                        const SizedBox(width: 4),
                        Text('${l.distance} km away', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ]),
                    ]),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
