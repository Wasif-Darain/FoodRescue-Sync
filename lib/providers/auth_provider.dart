import 'package:flutter/foundation.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  void login(String email, String password, AccountType accountType, String name) {
    _user = AppUser(
      id: 1,
      name: name.isEmpty ? 'User' : name,
      email: email,
      accountType: accountType,
      mode: UserMode.donor,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  void toggleMode() {
    if (_user != null) {
      _user = _user!.copyWith(
        mode: _user!.mode == UserMode.donor ? UserMode.consumer : UserMode.donor,
      );
      notifyListeners();
    }
  }
}
