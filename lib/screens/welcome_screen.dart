import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Colors.white, Color(0xFFFFF7ED)],
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
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.eco, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('FoodRescue', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                          Text('Sync', style: TextStyle(fontSize: 16, color: Color(0xFF16A34A), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Fight Food Waste in Bangladesh',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A real-time logistics platform connecting food donors with organizations and consumers — ensuring surplus food reaches those who need it before it\'s wasted.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Mode cards
                  Row(
                    children: [
                      Expanded(child: _ModeCard(
                        icon: Icons.restaurant_menu,
                        title: 'Donor Mode',
                        subtitle: 'Restaurants · Caterers · Stores',
                        description: 'List surplus food for donation or discounted sale. Manage inventory, track expiry, and log donations.',
                        features: const ['Inventory management', 'Flash sales & donations', 'Expiry tracking', 'Donation log'],
                        accentColor: const Color(0xFF16A34A),
                        bgColor: const Color(0xFFF0FDF4),
                      )),
                      const SizedBox(width: 20),
                      Expanded(child: _ModeCard(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Consumer Mode',
                        subtitle: 'NGOs · Food Banks · Shelters · Individuals',
                        description: 'Browse and claim surplus food nearby. Submit bulk requests, coordinate pickups, and track your impact.',
                        features: const ['Discount marketplace', 'Bulk food requests', 'Surplus radar map', 'Pickup coordination'],
                        accentColor: const Color(0xFFEA580C),
                        bgColor: const Color(0xFFFFF7ED),
                      )),
                    ],
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
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF374151))),
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

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.features,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: accentColor, size: 26),
          ),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5)),
          const SizedBox(height: 14),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 14, color: accentColor),
                const SizedBox(width: 8),
                Text(f, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
              ],
            ),
          )),
        ],
      ),
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
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
