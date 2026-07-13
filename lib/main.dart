import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/admin_provider.dart';
import 'providers/donor_provider.dart';
import 'router.dart';

void main() {
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

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
    _admin = AdminProvider();
    _donor = DonorProvider();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _auth),
        ChangeNotifierProvider.value(value: _admin),
        ChangeNotifierProvider.value(value: _donor),
      ],
      child: MaterialApp.router(
        title: 'FoodRescue Sync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF16A34A),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        routerConfig: buildRouter(_auth),
      ),
    );
  }
}
