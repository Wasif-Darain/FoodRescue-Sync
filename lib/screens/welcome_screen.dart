import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../l10n/l10n_ext.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/logo.png',
                              width: 40,
                              height: 40,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'FoodRescue Sync',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.2,
                                color: Color(0xFF121212),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _HeroVisual(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Text('🍽️', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            t.welcomeHowWillYouHelp,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF121212),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _ModeCard(
                                imageUrl:
                                    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
                                icon: Icons.restaurant_menu,
                                title: t.welcomeDonor,
                                subtitle: t.welcomeDonorSubtitle,
                                features: [
                                  t.welcomeFeatureInventory,
                                  t.navDonations,
                                ],
                                accentColor: const Color(0xFF16A34A),
                                radius: const BorderRadius.only(
                                  topLeft: Radius.circular(32),
                                  topRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(14),
                                  bottomRight: Radius.circular(32),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _ModeCard(
                                imageUrl:
                                    'https://images.unsplash.com/photo-1593113598332-cd288d649433?auto=format&fit=crop&w=600&q=80',
                                icon: Icons.volunteer_activism_outlined,
                                title: t.welcomeConsumer,
                                subtitle: t.welcomeConsumerSubtitle,
                                features: [t.navMarketplace, t.navPickups],
                                accentColor: const Color(0xFFEA580C),
                                radius: const BorderRadius.only(
                                  topLeft: Radius.circular(14),
                                  topRight: Radius.circular(32),
                                  bottomLeft: Radius.circular(32),
                                  bottomRight: Radius.circular(14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: _GetStartedBar(
                  label: t.welcomeGetStarted,
                  onTap: () => context.go('/login'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final t = context.l10n;
    return Container(
      height: 230,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1540420773420-3366772f4999?auto=format&fit=crop&w=900&q=80',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFFF0F0F0),
              child: const Icon(
                Icons.eco_outlined,
                size: 48,
                color: Color(0xFF16A34A),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.82),
                ],
                stops: const [0.2, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('stats')
                      .doc('summary')
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data = snapshot.data?.data();
                    String field(String key) {
                      final value = data?[key];
                      if (value == null) return '…';
                      final n = value is num ? value : 0;
                      return '${n.round()}+';
                    }

                    return Row(
                      children: [
                        _StatPill(
                          icon: '🍲',
                          value: field('totalWeightKg'),
                          label: t.welcomeMealsPerDay,
                        ),
                        const SizedBox(width: 8),
                        _StatPill(
                          icon: '🤝',
                          value: field('donorsCount'),
                          label: t.welcomeDonors,
                        ),
                        const SizedBox(width: 8),
                        _StatPill(
                          icon: '❤️',
                          value: field('partnersCount'),
                          label: t.welcomePartners,
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.15,
                      letterSpacing: 0.1,
                    ),
                    children: [
                      TextSpan(text: t.welcomeHeroLine1),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: _HighlightWord(),
                      ),
                      TextSpan(text: t.welcomeHeroLine2),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.welcomeHeroTagline,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightWord extends StatelessWidget {
  const _HighlightWord();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFFE53238),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      context.l10n.welcomeHeroHighlight,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w900,
        color: Colors.white,
      ),
    ),
  );
}

class _StatPill extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$value ',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GetStartedBar extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GetStartedBar({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFE53238),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 20,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF121212),
                  ),
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: const Icon(
                Icons.check,
                color: Color(0xFF16A34A),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String imageUrl;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> features;
  final Color accentColor;
  final BorderRadius radius;

  const _ModeCard({
    required this.imageUrl,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.features,
    required this.accentColor,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: accentColor),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  accentColor.withValues(alpha: 0.95),
                ],
                stops: const [0.2, 0.85],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            // A card this size normally has room to push the text toward the
            // bottom, but on short/wide viewports (e.g. a wide browser
            // window) the content can outgrow the available height. Clip
            // gracefully via a non-scrolling SingleChildScrollView instead of
            // throwing a render overflow.
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: features
                        .map(
                          (f) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
