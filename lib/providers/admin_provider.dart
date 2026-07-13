import 'package:flutter/foundation.dart';
import '../data/mock_data.dart';
import '../models/models.dart';

class AdminProvider extends ChangeNotifier {
  final List<RegisteredAccount> _accounts = List.of(mockAccounts);

  List<RegisteredAccount> get accounts => List.unmodifiable(_accounts);

  void setStatus(int id, AccountStatus status) {
    final i = _accounts.indexWhere((a) => a.id == id);
    if (i == -1) return;
    _accounts[i] = _accounts[i].copyWith(status: status);
    notifyListeners();
  }

  void removeAccount(int id) {
    _accounts.removeWhere((a) => a.id == id);
    notifyListeners();
  }
}
