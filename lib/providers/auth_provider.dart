import 'dart:math';
import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  static const mockAdminEmail = 'admin@foodrescuesync.com';
  static const mockAdminPassword = 'Admin@123';

  AppUser? _user;
  String? _resetEmail;
  String? _resetOtp;
  DateTime? _resetOtpExpiresAt;
  bool _isResetOtpVerified = false;

  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;
  String? get resetEmail => _resetEmail;

  bool isMockAdminCredential(String email, String password) =>
      email.trim().toLowerCase() == mockAdminEmail &&
      password == mockAdminPassword;

  /// Creates a short-lived recovery code. Replace the delivery hook in this
  /// method with a backend/API call before production use; OTPs must never be
  /// generated or stored on the client in a real application.
  String requestPasswordReset(String email) {
    _resetEmail = email.trim().toLowerCase();
    _resetOtp = (100000 + Random.secure().nextInt(900000)).toString();
    _resetOtpExpiresAt = DateTime.now().add(const Duration(minutes: 10));
    _isResetOtpVerified = false;
    notifyListeners();
    return _resetOtp!;
  }

  bool verifyPasswordResetOtp(String otp) {
    final isValid =
        _resetOtp != null &&
        _resetOtpExpiresAt != null &&
        DateTime.now().isBefore(_resetOtpExpiresAt!) &&
        otp.trim() == _resetOtp;
    _isResetOtpVerified = isValid;
    notifyListeners();
    return isValid;
  }

  bool resetPassword(String password) {
    if (!_isResetOtpVerified || password.length < 8) return false;

    // TODO: Send the new password (securely hashed) to the authentication API.
    // This demo does not persist credentials locally.
    _resetEmail = null;
    _resetOtp = null;
    _resetOtpExpiresAt = null;
    _isResetOtpVerified = false;
    notifyListeners();
    return true;
  }

  void login(
    String email,
    String password,
    AccountType accountType,
    String name,
  ) {
    _user = AppUser(
      id: 1,
      name: name.isEmpty ? 'User' : name,
      email: email,
      accountType: accountType,
      mode: UserMode.donor,
    );
    notifyListeners();
  }

  void loginAsAdmin() {
    _user = AppUser(
      id: 0,
      name: 'Admin',
      email: 'admin@foodrescuesync.com',
      accountType: AccountType.individual,
      mode: UserMode.admin,
    );
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }

  /// Updates the current user's own RegisteredAccount location in place, so
  /// every screen reading the shared `mockAccounts` list (not just this
  /// provider's watchers) picks up the change on its next rebuild.
  void updateOwnLocation({
    required double lat,
    required double lng,
    required String address,
  }) {
    if (_user == null) return;
    final i = mockAccounts.indexWhere((a) => a.name == _user!.name);
    if (i == -1) return;
    mockAccounts[i] = mockAccounts[i].copyWith(latitude: lat, longitude: lng, address: address);
    notifyListeners();
  }

  void toggleMode() {
    if (_user != null) {
      _user = _user!.copyWith(
        mode: _user!.mode == UserMode.donor
            ? UserMode.consumer
            : UserMode.donor,
      );
      notifyListeners();
    }
  }
}
