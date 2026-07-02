import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/models.dart';

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  const _NavItem(this.route, this.icon, this.label);
}

const _donorNav = [
  _NavItem('/donor', Icons.dashboard_outlined, 'Dashboard'),
  _NavItem('/donor/inventory', Icons.inventory_2_outlined, 'Inventory'),
  _NavItem('/donor/expiry', Icons.timer_outlined, 'Expiry Tracker'),
  _NavItem('/donor/create-listing', Icons.add_circle_outline, 'Create Listing'),
  _NavItem('/donor/images', Icons.image_outlined, 'Image Manager'),
  _NavItem('/donor/donation-log', Icons.receipt_long_outlined, 'Donation Log'),
];

const _consumerNav = [
  _NavItem('/consumer', Icons.storefront_outlined, 'Marketplace'),
  _NavItem('/consumer/radar', Icons.map_outlined, 'Surplus Radar'),
  _NavItem('/consumer/bulk-request', Icons.list_alt_outlined, 'Bulk Request'),
  _NavItem('/consumer/requests', Icons.assignment_outlined, 'My Requests'),
  _NavItem('/consumer/pickups', Icons.local_shipping_outlined, 'Pickups'),
];

const _sharedBottom = [
  _NavItem('/notifications', Icons.notifications_outlined, 'Notifications'),
  _NavItem('/profile', Icons.person_outlined, 'Profile & Settings'),
];

const _accountTypeLabel = {
  AccountType.restaurant: 'Restaurant',
  AccountType.caterer: 'Caterer',
  AccountType.store: 'Store',
  AccountType.ngo: 'NGO',
  AccountType.foodBank: 'Food Bank',
  AccountType.shelter: 'Shelter',
  AccountType.individual: 'Individual',
};

class Sidebar extends StatelessWidget {
  final String currentRoute;
  const Sidebar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    final isDonor = user.mode == UserMode.donor;
    final navItems = isDonor ? _donorNav : _consumerNav;
    final accent = isDonor ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
    final accentBg = isDonor ? const Color(0xFFDCFCE7) : const Color(0xFFFFF7ED);

    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: const Color(0xFF16A34A), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.eco, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FoodRescue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                    Text('Sync', style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          // User + mode toggle
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), shape: BoxShape.circle),
                      child: Center(child: Text(user.name[0], style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF111827)), overflow: TextOverflow.ellipsis),
                          Text(_accountTypeLabel[user.accountType] ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => auth.toggleMode(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isDonor ? 'Donor Mode' : 'Consumer Mode', style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 12)),
                        Icon(Icons.swap_horiz, size: 16, color: accent),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Tap to switch mode', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              ],
            ),
          ),
          // Nav
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: Column(
                children: [
                  ...navItems.map((item) => _NavTile(item: item, current: currentRoute, accent: accent, accentBg: accentBg, isDonor: isDonor)),
                  const SizedBox(height: 12),
                  Container(height: 1, color: const Color(0xFFF3F4F6), margin: const EdgeInsets.symmetric(vertical: 4)),
                  ..._sharedBottom.map((item) => _NavTile(
                    item: item,
                    current: currentRoute,
                    accent: const Color(0xFF16A34A),
                    accentBg: const Color(0xFFDCFCE7),
                    isDonor: true,
                    badge: item.route == '/notifications' ? 3 : null,
                  )),
                ],
              ),
            ),
          ),
          // Logout
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFF3F4F6)))),
            child: ListTile(
              onTap: () {
                auth.logout();
                context.go('/');
              },
              leading: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 18),
              title: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w500)),
              dense: true,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              hoverColor: const Color(0xFFFEF2F2),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final _NavItem item;
  final String current;
  final Color accent;
  final Color accentBg;
  final bool isDonor;
  final int? badge;

  const _NavTile({required this.item, required this.current, required this.accent, required this.accentBg, required this.isDonor, this.badge});

  @override
  Widget build(BuildContext context) {
    final isActive = current == item.route || (item.route != '/donor' && item.route != '/consumer' && current.startsWith(item.route));
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      decoration: BoxDecoration(
        color: isActive ? accentBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        onTap: () => context.go(item.route),
        leading: Icon(item.icon, size: 18, color: isActive ? accent : const Color(0xFF6B7280)),
        title: Text(item.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isActive ? accent : const Color(0xFF374151))),
        trailing: badge != null ? Container(
          width: 18, height: 18,
          decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
          child: Center(child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 10))),
        ) : null,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
