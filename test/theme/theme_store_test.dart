import 'package:flutter_test/flutter_test.dart';
import 'package:game_app/theme/game_color_theme.dart';
import 'package:game_app/theme/theme_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeStore', () {
    test('load returns null when nothing has been saved', () async {
      expect(await ThemeStore.load(), isNull);
    });

    test('save then load round-trips the chosen theme', () async {
      await ThemeStore.save(GameColorTheme.sakura);
      expect(await ThemeStore.load(), GameColorTheme.sakura);
    });

    test('a later save overwrites the earlier one', () async {
      await ThemeStore.save(GameColorTheme.sakura);
      await ThemeStore.save(GameColorTheme.sky);
      expect(await ThemeStore.load(), GameColorTheme.sky);
    });
  });
}
