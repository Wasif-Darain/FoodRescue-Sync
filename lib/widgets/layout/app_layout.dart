import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_bar.dart';
import '../../data/mock_data.dart';
import '../ui/animated_tap.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String? subtitle;
  final Widget? action;
  final String currentRoute;

  const AppLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentRoute,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final unread = mockNotifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      floatingActionButton: const NavFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(currentRoute: currentRoute),
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF121212),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              subtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ?action,
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    badgeCount: unread,
                    onTap: () => context.go('/notifications'),
                  ),
                  const SizedBox(width: 8),
                  _HeaderIconButton(
                    icon: Icons.menu,
                    onTap: () => showNavMenuSheet(context),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E2E2)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  const _HeaderIconButton({required this.icon, required this.onTap, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return AnimatedTap(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFF121212), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: Container(
                    key: ValueKey(badgeCount),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    decoration: const BoxDecoration(color: Color(0xFFE53238), shape: BoxShape.circle),
                    child: Text(
                      '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
