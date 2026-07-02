import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _auth = AuthProvider();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _auth,
      child: MaterialApp.router(
        title: 'FoodRescue Sync',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16A34A)),
          fontFamily: 'Roboto',
          useMaterial3: true,
        ),
        routerConfig: buildRouter(_auth),
      ),
    );
  }
}
