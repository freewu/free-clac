import 'package:flutter/foundation.dart';

import '../l10n/app_language.dart';
import '../services/settings_store.dart';
import '../theme/app_theme.dart';
import '../ui/tools/bmi/bmi.dart';
import '../ui/tools/unit_catalog.dart';

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

  /// 换算工具设置键的前缀，完整键如 `convert.distance.system`。
  static const String _convertPrefix = 'convert.';

  final SettingsStore _store;

  AppThemeMode themeMode;
  AppLanguage language;

  /// BMI 工具默认使用的计量单位。
  BmiUnitSystem bmiUnit;

  /// 各换算工具默认的计量体系（换算工具 id → 体系），没存过时为公制。
  final Map<String, MeasureSystem> convertSystems = <String, MeasureSystem>{};

  /// 各换算工具结果默认选中的 tab（换算工具 id → 体系）。
  final Map<String, MeasureSystem> convertTabs = <String, MeasureSystem>{};

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
    for (final entry in values.entries) {
      // convert.<工具 id>.(system|tab)
      if (!entry.key.startsWith(_convertPrefix)) continue;
      final rest = entry.key.substring(_convertPrefix.length);
      final dot = rest.lastIndexOf('.');
      if (dot <= 0) continue;
      final id = rest.substring(0, dot);
      final system = MeasureSystem.fromCode(entry.value);
      if (system == null) continue;
      final target = switch (rest.substring(dot + 1)) {
        'system' => convertSystems,
        'tab' => convertTabs,
        _ => null,
      };
      if (target == null || target[id] == system) continue;
      target[id] = system;
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

  /// 某个换算工具默认的计量体系。
  MeasureSystem convertSystemFor(String catalogId) =>
      convertSystems[catalogId] ?? MeasureSystem.metric;

  /// 某个换算工具结果默认选中的 tab 对应体系。
  MeasureSystem convertTabFor(String catalogId) =>
      convertTabs[catalogId] ?? MeasureSystem.metric;

  /// 设置换算工具默认的计量体系。
  Future<void> setConvertSystem(String catalogId, MeasureSystem system) async {
    if (convertSystems[catalogId] == system) return;
    convertSystems[catalogId] = system;
    notifyListeners();
    await _store.write('$_convertPrefix$catalogId.system', system.code);
  }

  /// 设置换算工具结果默认选中的 tab。
  Future<void> setConvertTab(String catalogId, MeasureSystem system) async {
    if (convertTabs[catalogId] == system) return;
    convertTabs[catalogId] = system;
    notifyListeners();
    await _store.write('$_convertPrefix$catalogId.tab', system.code);
  }

  /// 结合系统明暗，得出当前应该使用的配色。
  AppPalette paletteFor(Brightness platformBrightness) => switch (themeMode) {
    AppThemeMode.dark => kDarkPalette,
    AppThemeMode.light => kLightPalette,
    AppThemeMode.system =>
      platformBrightness == Brightness.dark ? kDarkPalette : kLightPalette,
  };
}
