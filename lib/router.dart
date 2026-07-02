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

GoRouter buildRouter(AuthProvider auth) => GoRouter(
  refreshListenable: auth,
  initialLocation: '/',
  redirect: (context, state) {
    final isAuth = auth.isAuthenticated;
    final isPublic = state.matchedLocation == '/' || state.matchedLocation == '/login';
    if (!isAuth && !isPublic) return '/login';
    if (isAuth && isPublic) return auth.user!.mode.name == 'donor' ? '/donor' : '/consumer';
    return null;
  },
  routes: [
    GoRoute(path: '/',      builder: (_, _) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, _) => const LoginRegisterScreen()),
    // Donor
    GoRoute(path: '/donor',                builder: (_, _) => const DonorDashboard()),
    GoRoute(path: '/donor/inventory',      builder: (_, _) => const AddInventory()),
    GoRoute(path: '/donor/expiry',         builder: (_, _) => const ExpiryTracker()),
    GoRoute(path: '/donor/create-listing', builder: (_, _) => const CreateListing()),
    GoRoute(path: '/donor/images',         builder: (_, _) => const ListingImageManager()),
    GoRoute(path: '/donor/donation-log',   builder: (_, _) => const DonationLogScreen()),
    // Consumer
    GoRoute(path: '/consumer',              builder: (_, _) => const ConsumerMarketplace()),
    GoRoute(path: '/consumer/radar',        builder: (_, _) => const SurplusRadar()),
    GoRoute(path: '/consumer/bulk-request', builder: (_, _) => const BulkRequest()),
    GoRoute(path: '/consumer/requests',     builder: (_, _) => const RequestStatusTracker()),
    GoRoute(path: '/consumer/pickups',      builder: (_, _) => const PickupCoordination()),
    // Shared
    GoRoute(path: '/notifications', builder: (_, _) => const NotificationCenter()),
    GoRoute(path: '/profile',       builder: (_, _) => const ProfileSettings()),
  ],
);
