import 'package:shared_preferences/shared_preferences.dart';

import 'game_color_theme.dart';

/// Persists the player's chosen color theme locally — no accounts, applies
/// across every game in the app.
class ThemeStore {
  const ThemeStore._();

  static const _key = 'app_color_theme';

  static Future<void> save(GameColorTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, theme.name);
  }

  static Future<GameColorTheme?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    for (final theme in GameColorTheme.values) {
      if (theme.name == raw) return theme;
    }
    return null;
  }
}
