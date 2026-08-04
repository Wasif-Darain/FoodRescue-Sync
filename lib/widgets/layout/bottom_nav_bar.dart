import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/models.dart';
import '../ui/animated_tap.dart';
import '../ui/glass.dart';

class _NavItem {
  final String route;
  final IconData icon;
  final String label;
  const _NavItem(this.route, this.icon, this.label);
}

const _donorLeft = [
  _NavItem('/donor', Icons.dashboard_outlined, 'Dashboard'),
  _NavItem('/donor/inventory', Icons.inventory_2_outlined, 'Inventory'),
];

const _donorRight = [
  _NavItem('/donor/expiry', Icons.timer_outlined, 'Expiry'),
  _NavItem('/donor/donation-log', Icons.receipt_long_outlined, 'Donations'),
];

const _donorMenu = [
  _NavItem('/profile', Icons.person_outlined, 'Profile & Settings'),
];

const _consumerLeft = [
  _NavItem('/consumer', Icons.storefront_outlined, 'Marketplace'),
  _NavItem('/consumer/radar', Icons.map_outlined, 'Radar'),
];

const _consumerRight = [
  _NavItem('/consumer/requests', Icons.assignment_outlined, 'Requests'),
  _NavItem('/consumer/pickups', Icons.local_shipping_outlined, 'Pickups'),
];

const _consumerMenu = [
  _NavItem('/profile', Icons.person_outlined, 'Profile & Settings'),
];

const _adminNav = [
  _NavItem('/admin', Icons.dashboard_outlined, 'Overview'),
  _NavItem('/admin/accounts', Icons.people_outline, 'Accounts'),
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

bool _isActive(String currentRoute, String route) =>
    currentRoute == route ||
    (route != '/donor' && route != '/consumer' && currentRoute.startsWith(route));

/// A wide, softly-flared circular notch — built with the same tangent-circle
/// construction Flutter's own CircularNotchedRectangle uses (real arc, not an
/// approximated curve), just with a bigger radius and a wider flare so it
/// reads as a gentle wave instead of a tight cutout.
class WaveNotchedShape extends NotchedShape {
  const WaveNotchedShape();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double notchRadius = guest.width / 2.0 + 16;
    const double s1 = 32.0;
    const double s2 = 4.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset> p = List<Offset>.filled(6, Offset.zero);
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, p2yA) : Offset(p2xB, p2yB);
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[1].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    for (int i = 0; i < p.length; i += 1) {
      p[i] += guest.center;
    }

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[0].dx, p[0].dy)
      ..quadraticBezierTo(p[1].dx, p[1].dy, p[2].dx, p[2].dy)
      ..arcToPoint(p[3], radius: Radius.circular(notchRadius), clockwise: false)
      ..quadraticBezierTo(p[4].dx, p[4].dy, p[5].dx, p[5].dy)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}

/// Raised center "Add" button, docked into the bottom app bar's notch.
class NavFab extends StatelessWidget {
  final String currentRoute;
  const NavFab({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AuthProvider>().user!.mode;
    if (mode == UserMode.admin) return const SizedBox.shrink();
    final isDonor = mode == UserMode.donor;
    final isPlusPage = currentRoute == '/donor/create-listing' || currentRoute == '/consumer/bulk-request';

    if (isPlusPage) {
      return const FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        disabledElevation: 0,
        onPressed: null,
        child: null,
      );
    }

    return AnimatedTap(
      pressedScale: 0.88,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, t, child) => Transform.scale(scale: t, child: child),
        child: FloatingActionButton(
          shape: const CircleBorder(),
          backgroundColor: const Color(0xFFE53238),
          foregroundColor: Colors.white,
          elevation: 3,
          onPressed: () => context.go(isDonor ? '/donor/create-listing' : '/consumer/bulk-request'),
          child: const Icon(Icons.add, size: 28),
        ),
      ),
    );
  }
}

/// The 4 most-used destinations for the current mode, 2 either side of the FAB.
/// Notifications and Profile live in the header instead (bell + hamburger).
class BottomNavBar extends StatelessWidget {
  final String currentRoute;
  const BottomNavBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<AuthProvider>().user!.mode;
    final isDark = context.watch<ThemeProvider>().isDark;

    if (mode == UserMode.admin) {
      return _GlassBottomBar(
        isDark: isDark,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in _adminNav)
              _NavIconButton(
                icon: item.icon,
                label: item.label,
                isActive: _isActive(currentRoute, item.route),
                isDark: isDark,
                onTap: () => context.go(item.route),
              ),
          ],
        ),
      );
    }

    final isDonor = mode == UserMode.donor;
    final left = isDonor ? _donorLeft : _consumerLeft;
    final right = isDonor ? _donorRight : _consumerRight;

    return _GlassBottomBar(
      isDark: isDark,
      shape: const WaveNotchedShape(),
      notchMargin: 6,
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final item in left)
                  _NavIconButton(
                    icon: item.icon,
                    label: item.label,
                    isActive: _isActive(currentRoute, item.route),
                    isDark: isDark,
                    onTap: () => context.go(item.route),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 80),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final item in right)
                  _NavIconButton(
                    icon: item.icon,
                    label: item.label,
                    isActive: _isActive(currentRoute, item.route),
                    isDark: isDark,
                    onTap: () => context.go(item.route),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _NavIconButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? const Color(0xFFE53238)
        : (isDark ? Colors.white : Colors.black);
    return AnimatedTap(
      pressedScale: 0.85,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isActive ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(fontSize: 9, color: color, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(label),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opens the "everything else" sheet — Profile, mode switch, secondary
/// destinations, logout. Triggered from the hamburger icon in the header.
void showNavMenuSheet(BuildContext context) {
  final auth = context.read<AuthProvider>();
  final user = auth.user!;
  final isAdmin = user.mode == UserMode.admin;
  final isDonor = user.mode == UserMode.donor;
  final menu = isAdmin ? const <_NavItem>[] : (isDonor ? _donorMenu : _consumerMenu);
  final accent = isDonor ? const Color(0xFF16A34A) : const Color(0xFFEA580C);
  final accentBg = isDonor ? const Color(0xFFDCFCE7) : const Color(0xFFFFE3CC);

  final theme = context.read<ThemeProvider>();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (sheetContext) => GlassContainer(
      margin: EdgeInsets.zero,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      padding: const EdgeInsets.only(bottom: 8),
      tint: theme.isDark ? Colors.black : Colors.white,
      opacity: theme.isDark ? 0.55 : 0.6,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: theme.isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFFDCFCE7), shape: BoxShape.circle),
                    child: Center(child: Text(user.name[0], style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: theme.isDark ? Colors.white : const Color(0xFF121212))),
                        Text(isAdmin ? 'Administrator' : (_accountTypeLabel[user.accountType] ?? ''), style: const TextStyle(fontSize: 12, color: Color(0xFF757575))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Theme toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Material(
                color: theme.isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFEFF3F0),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => theme.toggle(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(theme.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                          style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.w600, fontSize: 13)),
                        Icon(theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18, color: const Color(0xFF16A34A)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Material(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      final wasDonor = auth.user!.mode == UserMode.donor;
                      auth.toggleMode();
                      // Land on the new mode's primary tab (Dashboard / Marketplace).
                      context.go(wasDonor ? '/consumer' : '/donor');
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isDonor ? 'Switch to Consumer Mode' : 'Switch to Donor Mode', style: TextStyle(color: accent, fontWeight: FontWeight.w600, fontSize: 13)),
                          Icon(Icons.swap_horiz, size: 18, color: accent),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  for (final item in menu)
                    ListTile(
                      leading: Icon(item.icon, size: 20, color: const Color(0xFF757575)),
                      title: Text(item.label, style: const TextStyle(fontSize: 14)),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        context.go(item.route);
                      },
                    ),
                ],
              ),
            ),
            const Divider(color: Color(0xFFE2E2E2), height: 1),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                title: const Text('Logout', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  auth.logout();
                  context.go('/');
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// A frosted, floating bottom bar. Wraps the children in a [GlassContainer]
/// and uses a clipped [BottomAppBar] so the notch shape still applies.
class _GlassBottomBar extends StatelessWidget {
  final bool isDark;
  final NotchedShape? shape;
  final double notchMargin;
  final Widget child;

  const _GlassBottomBar({
    required this.isDark,
    required this.child,
    this.shape,
    this.notchMargin = 6,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: shape,
      notchMargin: notchMargin,
      color: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: GlassContainer(
          height: 56,
          borderRadius: BorderRadius.circular(28),
          padding: EdgeInsets.zero,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          child: Center(child: child),
        ),
      ),
    );
  }
}
