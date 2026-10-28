import 'package:flutter/foundation.dart';

import '../l10n/app_language.dart';
import '../services/settings_store.dart';
import '../theme/app_theme.dart';

/// 主题模式：跟随系统、浅色、深色。
enum AppThemeMode {
  system('system'),
  light('light'),
  dark('dark');

  const AppThemeMode(this.code);

  /// 持久化用的稳定标识。
  final String code;

  static AppThemeMode? fromCode(String? code) {
    if (code == null) return null;
    for (final mode in AppThemeMode.values) {
      if (mode.code == code) return mode;
    }
    return null;
  }
}

/// 应用设置：主题模式与界面语言，改动后立即生效并写回本地。
class SettingsController extends ChangeNotifier {
  SettingsController({
    SettingsStore? store,
    this.themeMode = AppThemeMode.system,
    this.language = AppLanguage.zhHans,
  }) : _store = store ?? const SettingsStore();

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';

  final SettingsStore _store;

  AppThemeMode themeMode;
  AppLanguage language;

  /// 读取本地设置；没有存过或读取失败时保持构造时的默认值。
  Future<void> load() async {
    final values = await _store.readAll();
    var changed = false;
    final storedMode = AppThemeMode.fromCode(values[_themeKey]);
    if (storedMode != null && storedMode != themeMode) {
      themeMode = storedMode;
      changed = true;
    }
    final storedLanguage = AppLanguage.fromCode(values[_languageKey]);
    if (storedLanguage != null && storedLanguage != language) {
      language = storedLanguage;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// 切换主题模式。
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (mode == themeMode) return;
    themeMode = mode;
    notifyListeners();
    await _store.write(_themeKey, mode.code);
  }

  /// 切换界面语言。
  Future<void> setLanguage(AppLanguage value) async {
    if (value == language) return;
    language = value;
    notifyListeners();
    await _store.write(_languageKey, value.code);
  }

  /// 结合系统明暗，得出当前应该使用的配色。
  AppPalette paletteFor(Brightness platformBrightness) => switch (themeMode) {
    AppThemeMode.dark => kDarkPalette,
    AppThemeMode.light => kLightPalette,
    AppThemeMode.system =>
      platformBrightness == Brightness.dark ? kDarkPalette : kLightPalette,
  };
}
