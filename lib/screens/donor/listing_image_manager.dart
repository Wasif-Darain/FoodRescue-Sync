import 'package:flutter/material.dart';
import '../../widgets/layout/app_layout.dart';
import '../../data/mock_data.dart';

class ListingImageManager extends StatelessWidget {
  const ListingImageManager({super.key});

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Image Manager',
      subtitle: 'Manage photos for your food listings',
      currentRoute: '/donor/images',
      child: Column(
        children: mockListings.map((listing) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), offset: const Offset(0, 4), blurRadius: 0)],),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(listing.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF121212)))),
                    Text(listing.category, style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Upload placeholder
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F0F0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E2E2), style: BorderStyle.solid),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 28, color: Color(0xFF757575)),
                            SizedBox(height: 4),
                            Text('Add Photo', style: TextStyle(fontSize: 11, color: Color(0xFF757575))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Gradient placeholder images
                    ...List.generate(2, (i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Stack(
                        children: [
                          Container(
                            width: 100, height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: i == 0
                                    ? [const Color(0xFFDCFCE7), const Color(0xFFDCFCE7)]
                                    : [const Color(0xFFFFE3CC), const Color(0xFFFFE3CC)],
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.fastfood_outlined, size: 36, color: i == 0 ? const Color(0xFF059669) : const Color(0xFFEA580C)),
                          ),
                          Positioned(
                            top: 6, right: 6,
                            child: GestureDetector(
                              onTap: () {},
                              child: Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
                                child: const Icon(Icons.close, size: 12, color: Color(0xFF525252)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),
        )).toList(),
      ),
    );
  }
}
