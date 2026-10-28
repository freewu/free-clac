import 'package:flutter/foundation.dart';

import '../l10n/app_language.dart';
import '../services/settings_store.dart';
import '../theme/app_theme.dart';
import '../ui/tools/bmi/bmi.dart';

/// 当前生效的设置控制器。
///
/// 和 `AppColors` / `t` 一样是全局入口：工具页（如 BMI）拿不到设置页的
/// 构造参数，靠它读「默认单位」这类偏好。
SettingsController? currentSettings;

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
    this.bmiUnit = BmiUnitSystem.metric,
  }) : _store = store ?? const SettingsStore();

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _bmiUnitKey = 'bmi_unit';

  final SettingsStore _store;

  AppThemeMode themeMode;
  AppLanguage language;

  /// BMI 工具默认使用的计量单位。
  BmiUnitSystem bmiUnit;

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
    final storedBmiUnit = BmiUnitSystem.fromCode(values[_bmiUnitKey]);
    if (storedBmiUnit != null && storedBmiUnit != bmiUnit) {
      bmiUnit = storedBmiUnit;
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

  /// 切换 BMI 默认计量单位。
  Future<void> setBmiUnit(BmiUnitSystem unit) async {
    if (unit == bmiUnit) return;
    bmiUnit = unit;
    notifyListeners();
    await _store.write(_bmiUnitKey, unit.code);
  }

  /// 结合系统明暗，得出当前应该使用的配色。
  AppPalette paletteFor(Brightness platformBrightness) => switch (themeMode) {
    AppThemeMode.dark => kDarkPalette,
    AppThemeMode.light => kLightPalette,
    AppThemeMode.system =>
      platformBrightness == Brightness.dark ? kDarkPalette : kLightPalette,
  };
}
