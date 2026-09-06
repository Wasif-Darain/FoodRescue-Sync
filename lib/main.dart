import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/consumer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/block_provider.dart';
import 'providers/rider_provider.dart';
import 'l10n/gen/app_localizations.dart';
import 'router.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FoodRescueApp());
}

class FoodRescueApp extends StatefulWidget {
  const FoodRescueApp({super.key});

  @override
  State<FoodRescueApp> createState() => _FoodRescueAppState();
}

class _FoodRescueAppState extends State<FoodRescueApp> {
  late final AuthProvider _auth;
  late final AdminProvider _admin;
  late final DonorProvider _donor;
  late final ConsumerProvider _consumer;
  late final ThemeProvider _theme;
  late final NotificationService _notifications;
  late final LocaleProvider _localeProvider;
  late final BlockProvider _blocks;
  late final RiderProvider _rider;
  late final GoRouter _router;
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _admin = AdminProvider();
    _donor = DonorProvider();
    _consumer = ConsumerProvider();
    _theme = ThemeProvider();
    _localeProvider = LocaleProvider();
    _blocks = BlockProvider();
    _rider = RiderProvider();
    // Built once (not inline in build()) so it stays the same instance for
    // the app's lifetime — needed to navigate to it from the notification
    // handlers below, and avoids resetting the nav stack on every rebuild.
    _router = buildRouter(_auth);
    // Set up FCM push notifications (permission, token registration,
    // foreground/background message handling).
    _notifications = NotificationService();
    _notifications.initialize();
    // The OS only shows a push in the tray while the app is backgrounded or
    // terminated — while foregrounded, FCM delivers it silently unless the
    // app surfaces it itself, so show it as an in-app banner here.
    _notifications.foregroundMessages.listen(_onForegroundMessage);
    // Tapping a push (from background, or one that cold-started the app)
    // takes the user to the Notification Center.
    _notifications.messageOpened.listen((_) => _router.go('/notifications'));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifications.checkInitialMessage();
    });
  }

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    final title = notification.title ?? 'FoodRescue Sync';
    final body = notification.body ?? '';
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(body.isEmpty ? title : '$title: $body'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => _router.go('/notifications'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notifications.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _admin),
        ChangeNotifierProvider.value(value: _donor),
        ChangeNotifierProvider.value(value: _consumer),
        ChangeNotifierProvider.value(value: _theme),
        ChangeNotifierProvider.value(value: _localeProvider),
        ChangeNotifierProvider.value(value: _blocks),
        ChangeNotifierProvider.value(value: _rider),
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeProvider>().mode;
          final locale = context.watch<LocaleProvider>().locale;
          return MaterialApp.router(
            title: 'FoodRescue Sync',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: _scaffoldMessengerKey,
            themeMode: themeMode,
            theme: _lightGlassTheme(),
            darkTheme: _darkGlassTheme(),
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

/// Light "Liquid Glass" theme. Frosted translucency is applied per-surface
/// (GlassContainer) so the base theme only sets the tint + material tokens.
ThemeData _lightGlassTheme() {
  const seed = Color(0xFF16A34A);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF4F7F5),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.transparent,
      elevation: 0,
    ),
  );
}

ThemeData _darkGlassTheme() {
  const seed = Color(0xFF16A34A);
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.dark,
  );
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFF0B1410),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.08),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seed,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    bottomAppBarTheme: const BottomAppBarThemeData(
      color: Colors.transparent,
      elevation: 0,
    ),
  );
}
