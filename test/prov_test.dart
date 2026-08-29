import 'package:flutter_test/flutter_test.dart';
import 'package:foodrescue_sync/providers/block_provider.dart';
import 'package:foodrescue_sync/providers/auth_provider.dart';
import 'package:foodrescue_sync/providers/consumer_provider.dart';
import 'package:foodrescue_sync/providers/theme_provider.dart';
import 'package:foodrescue_sync/providers/locale_provider.dart';
void main() {
  test('construct providers', () {
    expect(BlockProvider.new, returnsNormally);
    expect(AuthProvider.new, returnsNormally);
    expect(ConsumerProvider.new, returnsNormally);
    expect(ThemeProvider.new, returnsNormally);
    expect(LocaleProvider.new, returnsNormally);
  });
}
