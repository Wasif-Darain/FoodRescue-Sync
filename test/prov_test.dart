import 'package:flutter_test/flutter_test.dart';
import 'package:foodrescue_sync/providers/block_provider.dart';
import 'package:foodrescue_sync/providers/auth_provider.dart';
import 'package:foodrescue_sync/providers/consumer_provider.dart';
import 'package:foodrescue_sync/providers/theme_provider.dart';
import 'package:foodrescue_sync/providers/locale_provider.dart';
void main() {
  test('construct providers', () {
    final b = BlockProvider();
    final a = AuthProvider();
    final c = ConsumerProvider();
    final t = ThemeProvider();
    final l = LocaleProvider();
    expect(true, true);
  });
}
