import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/donor_provider.dart';
import 'providers/consumer_provider.dart';
import 'providers/theme_provider.dart';
import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _admin = AdminProvider();
    _donor = DonorProvider();
    _consumer = ConsumerProvider();
    _theme = ThemeProvider();
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
      ],
      child: Builder(
        builder: (context) {
          final themeMode = context.watch<ThemeProvider>().mode;
          return MaterialApp.router(
            title: 'FoodRescue Sync',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: _lightGlassTheme(),
            darkTheme: _darkGlassTheme(),
            routerConfig: buildRouter(_auth),
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
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);
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
    bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.transparent, elevation: 0),
  );
}

ThemeData _darkGlassTheme() {
  const seed = Color(0xFF16A34A);
  final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
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
    bottomAppBarTheme: const BottomAppBarThemeData(color: Colors.transparent, elevation: 0),
  );
}
