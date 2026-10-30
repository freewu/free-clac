import 'package:flutter/foundation.dart';

import '../l10n/app_language.dart';
import '../l10n/currency.dart';
import '../services/settings_store.dart';
import '../theme/app_theme.dart';
import '../ui/tools/bmi/bmi.dart';
import '../ui/tools/bmr/bmr.dart';
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
    this.bmrGender = BmrGender.male,
    this.bmrActivity = BmrActivity.light,
    this.currencyCode = kFollowLanguageCurrency,
  }) : _store = store ?? const SettingsStore();

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _bmiUnitKey = 'bmi_unit';
  static const String _bmrGenderKey = 'bmr_gender';
  static const String _bmrActivityKey = 'bmr_activity';
  static const String _currencyKey = 'currency_style';

  /// 换算工具设置键的前缀，完整键如 `convert.distance.system`。
  static const String _convertPrefix = 'convert.';

  final SettingsStore _store;

  AppThemeMode themeMode;
  AppLanguage language;

  /// BMI 工具默认使用的计量单位。
  BmiUnitSystem bmiUnit;

  /// 基础代谢工具默认的性别。
  BmrGender bmrGender;

  /// 基础代谢工具默认的活动水平。
  BmrActivity bmrActivity;

  /// 金额符号偏好：`auto` 跟随语言（默认），否则是货币的 ISO 代码。
  String currencyCode;

  /// 各换算工具默认的计量体系（换算工具 id → 体系），没存过时为公制。
  final Map<String, MeasureSystem> convertSystems = <String, MeasureSystem>{};

  /// 各换算工具结果默认选中的 tab（换算工具 id → 体系）。
  final Map<String, MeasureSystem> convertTabs = <String, MeasureSystem>{};

  /// 不分体系的换算工具（温度）默认选中的单位 id。
  final Map<String, String> convertUnits = <String, String>{};

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
    final storedBmrGender = BmrGender.fromCode(values[_bmrGenderKey]);
    if (storedBmrGender != null && storedBmrGender != bmrGender) {
      bmrGender = storedBmrGender;
      changed = true;
    }
    final storedBmrActivity = BmrActivity.fromCode(values[_bmrActivityKey]);
    if (storedBmrActivity != null && storedBmrActivity != bmrActivity) {
      bmrActivity = storedBmrActivity;
      changed = true;
    }
    final storedCurrency = values[_currencyKey];
    if (storedCurrency != null && storedCurrency != currencyCode) {
      currencyCode = storedCurrency;
      changed = true;
    }
    for (final entry in values.entries) {
      // convert.<工具 id>.(system|tab)
      if (!entry.key.startsWith(_convertPrefix)) continue;
      final rest = entry.key.substring(_convertPrefix.length);
      final dot = rest.lastIndexOf('.');
      if (dot <= 0) continue;
      final id = rest.substring(0, dot);
      final field = rest.substring(dot + 1);
      if (field == 'unit') {
        if (entry.value.isEmpty || convertUnits[id] == entry.value) continue;
        convertUnits[id] = entry.value;
        changed = true;
        continue;
      }
      final system = MeasureSystem.fromCode(entry.value);
      if (system == null) continue;
      final target = switch (field) {
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

  /// 用深链 / 截图参数指定的语言临时覆盖本地设置。
  ///
  /// 只改内存不写回本地：分享出去的 `?lang=en` 链接不该改掉对方存的偏好。
  void overrideLanguage(AppLanguage value) {
    if (value == language) return;
    language = value;
    notifyListeners();
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

  /// 切换基础代谢默认性别。
  Future<void> setBmrGender(BmrGender gender) async {
    if (gender == bmrGender) return;
    bmrGender = gender;
    notifyListeners();
    await _store.write(_bmrGenderKey, gender.code);
  }

  /// 切换基础代谢默认活动水平。
  Future<void> setBmrActivity(BmrActivity activity) async {
    if (activity == bmrActivity) return;
    bmrActivity = activity;
    notifyListeners();
    await _store.write(_bmrActivityKey, activity.code);
  }

  /// 切换金额符号偏好（`auto` 或货币代码）。
  Future<void> setCurrency(String code) async {
    if (code == currencyCode) return;
    currencyCode = code;
    notifyListeners();
    await _store.write(_currencyKey, code);
  }

  /// 某个换算工具默认的计量体系。
  MeasureSystem convertSystemFor(String catalogId) =>
      convertSystems[catalogId] ?? MeasureSystem.metric;

  /// 某个换算工具结果默认选中的 tab 对应体系。
  MeasureSystem convertTabFor(String catalogId) =>
      convertTabs[catalogId] ?? MeasureSystem.metric;

  /// 某个换算工具默认选中的单位（只对不分体系的工具如温度有意义）。
  String? convertUnitFor(String catalogId) => convertUnits[catalogId];

  /// 设置换算工具的默认单位。
  Future<void> setConvertUnit(String catalogId, String unitId) async {
    if (convertUnits[catalogId] == unitId) return;
    convertUnits[catalogId] = unitId;
    notifyListeners();
    await _store.write('$_convertPrefix$catalogId.unit', unitId);
  }

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
