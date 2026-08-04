import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_register_screen.dart';
import 'screens/donor/donor_dashboard.dart';
import 'screens/donor/add_inventory.dart';
import 'screens/donor/expiry_tracker.dart';
import 'screens/donor/create_listing.dart';
import 'screens/donor/listing_image_manager.dart';
import 'screens/donor/donation_log.dart';
import 'screens/consumer/consumer_marketplace.dart';
import 'screens/consumer/surplus_radar.dart';
import 'screens/consumer/bulk_request.dart';
import 'screens/consumer/request_status_tracker.dart';
import 'screens/consumer/pickup_coordination.dart';
import 'screens/shared/notification_center.dart';
import 'screens/shared/profile_settings.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/account_management.dart';
import 'screens/rewards/rewards_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'models/models.dart';

/// Fade + gentle upward slide used for every route so navigating around
/// the app feels like one continuous motion instead of hard page cuts.
CustomTransitionPage<void> _fadeThrough(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}

GoRouter buildRouter(AuthProvider auth) => GoRouter(
  refreshListenable: auth,
  initialLocation: '/',
  redirect: (context, state) {
    final isAuth = auth.isAuthenticated;
    final isPublic = state.matchedLocation == '/' || state.matchedLocation == '/login';
    if (!isAuth && !isPublic) return '/login';
    if (isAuth && isPublic) {
      return switch (auth.user!.mode) {
        UserMode.donor => '/donor',
        UserMode.consumer => '/consumer',
        UserMode.admin => '/admin',
      };
    }
    return null;
  },
  routes: [
    GoRoute(path: '/',      pageBuilder: (_, state) => _fadeThrough(state, const WelcomeScreen())),
    GoRoute(path: '/login', pageBuilder: (_, state) => _fadeThrough(state, const LoginRegisterScreen())),
    // Donor
    GoRoute(path: '/donor',                pageBuilder: (_, state) => _fadeThrough(state, const DonorDashboard())),
    GoRoute(path: '/donor/inventory',      pageBuilder: (_, state) => _fadeThrough(state, const AddInventory())),
    GoRoute(path: '/donor/expiry',         pageBuilder: (_, state) => _fadeThrough(state, const ExpiryTracker())),
    GoRoute(path: '/donor/create-listing', pageBuilder: (_, state) => _fadeThrough(state, const CreateListing())),
    GoRoute(path: '/donor/images',         pageBuilder: (_, state) => _fadeThrough(state, const ListingImageManager())),
    GoRoute(path: '/donor/donation-log',   pageBuilder: (_, state) => _fadeThrough(state, const DonationLogScreen())),
    // Consumer
    GoRoute(path: '/consumer',              pageBuilder: (_, state) => _fadeThrough(state, const ConsumerMarketplace())),
    GoRoute(path: '/consumer/radar',        pageBuilder: (_, state) => _fadeThrough(state, const SurplusRadar())),
    GoRoute(path: '/consumer/bulk-request', pageBuilder: (_, state) => _fadeThrough(state, const BulkRequest())),
    GoRoute(path: '/consumer/requests',     pageBuilder: (_, state) => _fadeThrough(state, const RequestStatusTracker())),
    GoRoute(path: '/consumer/pickups',      pageBuilder: (_, state) => _fadeThrough(state, const PickupCoordination())),
    // Shared
    GoRoute(path: '/notifications', pageBuilder: (_, state) => _fadeThrough(state, const NotificationCenter())),
    GoRoute(path: '/profile',       pageBuilder: (_, state) => _fadeThrough(state, const ProfileSettings())),
    GoRoute(path: '/rewards',       pageBuilder: (_, state) => _fadeThrough(state, const RewardsScreen())),
    GoRoute(path: '/leaderboard',   pageBuilder: (_, state) => _fadeThrough(state, const LeaderboardScreen())),
    // Admin
    GoRoute(path: '/admin',          pageBuilder: (_, state) => _fadeThrough(state, const AdminDashboard())),
    GoRoute(path: '/admin/accounts', pageBuilder: (_, state) => _fadeThrough(state, const AccountManagement())),
  ],
);

