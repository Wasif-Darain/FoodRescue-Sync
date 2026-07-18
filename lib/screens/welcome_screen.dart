import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ui/glass.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE8F5EC), Color(0xFFF4F7F5), Color(0xFFFEF1E6)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo.png', width: 56, height: 56),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FoodRescue', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF121212))),
                            Text('Sync', style: TextStyle(fontSize: 16, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Fight Food Waste in Bangladesh',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF121212)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A real-time logistics platform connecting food donors with organizations and consumers — ensuring surplus food reaches those who need it before it\'s wasted.',
                      style: TextStyle(fontSize: 16, color: Color(0xFF52525B), height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    // Mode tiles — 2x2 layout: feature cards on one diagonal, images on the other
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const donorImage = 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=900&q=80';
                        const consumerImage = 'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=900&q=80';
                        final isWide = constraints.maxWidth >= 720;
                        final donor = _ModeCard(
                          icon: Icons.restaurant_menu,
                          title: 'Donor Mode',
                          subtitle: 'Restaurants · Caterers · Stores',
                          description: 'List surplus food for donation or discounted sale. Manage inventory, track expiry, and log donations.',
                          features: const ['Inventory management', 'Flash sales & donations', 'Expiry tracking', 'Donation log'],
                          accentColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          compact: !isWide,
                          onTap: () => context.go('/login'),
                        );
                        final consumer = _ModeCard(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Consumer Mode',
                          subtitle: 'NGOs · Food Banks · Shelters · Individuals',
                          description: 'Browse and claim surplus food nearby. Submit bulk requests, coordinate pickups, and track your impact.',
                          features: const ['Discount marketplace', 'Bulk food requests', 'Surplus radar map', 'Pickup coordination'],
                          accentColor: const Color(0xFFEA580C),
                          bgColor: const Color(0xFFFFE3CC),
                          compact: !isWide,
                          onTap: () => context.go('/login'),
                        );
                        final donorTile = _ModeImageTile(
                          imageUrl: donorImage,
                          label: 'Donor Mode',
                          icon: Icons.restaurant_menu,
                          accentColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          onTap: () => context.go('/login'),
                        );
                        final consumerTile = _ModeImageTile(
                          imageUrl: consumerImage,
                          label: 'Consumer Mode',
                          icon: Icons.shopping_bag_outlined,
                          accentColor: const Color(0xFFEA580C),
                          bgColor: const Color(0xFFFFE3CC),
                          onTap: () => context.go('/login'),
                        );
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: isWide ? 20 : 14,
                          mainAxisSpacing: isWide ? 20 : 14,
                          childAspectRatio: isWide ? 1.05 : 0.42,
                          children: [donor, donorTile, consumerTile, consumer],
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    // CTA buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go('/login'),
                          icon: const Icon(Icons.arrow_forward, size: 18),
                          label: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => context.go('/login'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: const BorderSide(color: Color(0xFF16A34A)),
                          ),
                          child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF16A34A))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Stats
                    Row(
                      children: [
                        _StatBox(value: '500+', label: 'Meals Rescued Daily'),
                        const SizedBox(width: 16),
                        _StatBox(value: '120+', label: 'Food Donors'),
                        const SizedBox(width: 16),
                        _StatBox(value: '45+', label: 'Partner Organizations'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<String> features;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback? onTap;
  final bool compact;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.accentColor,
    required this.bgColor,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 16.0 : 24.0;
    final iconBox = compact ? 44.0 : 52.0;
    final iconGlyph = compact ? 22.0 : 26.0;
    final titleSize = compact ? 16.0 : 18.0;
    final descSize = compact ? 11.0 : 13.0;
    final featSize = compact ? 11.0 : 13.0;
    final gap = compact ? 10.0 : 14.0;

    final card = GlassContainer(
      padding: EdgeInsets.all(pad),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8)),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: iconBox, height: iconBox,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accentColor, size: iconGlyph),
          ),
          SizedBox(height: gap),
          Text(title, style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, color: const Color(0xFF121212))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF52525B))),
          SizedBox(height: compact ? 8 : 10),
          Text(description, style: TextStyle(fontSize: descSize, color: const Color(0xFF52525B), height: 1.5)),
          SizedBox(height: gap),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 14, color: accentColor),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: TextStyle(fontSize: featSize, color: const Color(0xFF3F3F46)))),
              ],
            ),
          )),
        ],
      ),
    );
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}

class _ModeImageTile extends StatelessWidget {
  final String imageUrl;
  final String label;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _ModeImageTile({
    required this.imageUrl,
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.18), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: bgColor,
                child: Center(child: Icon(icon, size: 48, color: accentColor)),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.15), Colors.black.withValues(alpha: 0.55)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.85), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    if (onTap == null) return tile;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: tile),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF52525B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}