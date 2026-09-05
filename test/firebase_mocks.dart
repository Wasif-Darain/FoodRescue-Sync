import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// A fake [FirebasePlatform] that satisfies `Firebase.initializeApp()`
/// entirely in memory, with no platform channel involved — so plain
/// `flutter_test` runs (no real Firebase project, network, or native setup)
/// can construct anything that just needs `Firebase.app()` to exist, e.g.
/// to build a `FirebaseAuth.instance`.
class _FakeFirebasePlatform extends FirebasePlatform
    with MockPlatformInterfaceMixin {
  final List<FirebaseAppPlatform> _apps = [];

  @override
  List<FirebaseAppPlatform> get apps => List.unmodifiable(_apps);

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final existing = _apps.where((a) => a.name == appName);
    if (existing.isNotEmpty) return existing.first;
    final app = FirebaseAppPlatform(
      appName,
      options ??
          const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
          ),
    );
    _apps.add(app);
    return app;
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _apps.firstWhere(
      (a) => a.name == name,
      orElse: () => throw FirebaseException(
        plugin: 'core',
        code: 'no-app',
        message: 'No Firebase App "$name" has been created.',
      ),
    );
  }
}

/// A fake [FirebaseAuthPlatform] with nobody ever signed in and no listener
/// streams that touch a real platform channel — enough for any provider
/// that just wants `FirebaseAuth.instance` to exist and subscribe to
/// `authStateChanges()` without erroring.
class _FakeFirebaseAuthPlatform extends FirebaseAuthPlatform
    with MockPlatformInterfaceMixin {
  _FakeFirebaseAuthPlatform() : super();

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) => this;

  @override
  FirebaseAuthPlatform setInitialValues({
    PigeonUserDetails? currentUser,
    String? languageCode,
  }) =>
      this;

  @override
  UserPlatform? get currentUser => null;

  @override
  String? get languageCode => null;

  @override
  Stream<UserPlatform?> authStateChanges() => const Stream.empty();

  @override
  Stream<UserPlatform?> idTokenChanges() => const Stream.empty();

  @override
  Stream<UserPlatform?> userChanges() => const Stream.empty();
}

/// Installs fake [FirebasePlatform] and [FirebaseAuthPlatform] backing
/// implementations so `Firebase.initializeApp()` and `FirebaseAuth.instance`
/// both work entirely in memory, with no real platform channel involved.
/// Call this once, then `await Firebase.initializeApp();`.
void setupFirebaseCoreMocks() {
  FirebasePlatform.instance = _FakeFirebasePlatform();
  FirebaseAuthPlatform.instance = _FakeFirebaseAuthPlatform();
}
