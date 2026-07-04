import 'package:flutter/material.dart';
import 'sidebar.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0xFF0D1F13), Color(0xFF0A0A0A), Colors.black],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Row(
          children: [
            Sidebar(currentRoute: currentRoute),
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF141416),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFF262626)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF5F5F5),
                              ),
                            ),
                            if (subtitle != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  subtitle!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        ?action,
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
