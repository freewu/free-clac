import 'dart:async';
import 'dart:convert';

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
  }) : _store = store ?? defaultStore ?? const SettingsStore();

  /// 测试用：不显式传 `store` 时改用这个存储，免得读写开发机上的真实配置。
  @visibleForTesting
  static SettingsStore? defaultStore;

  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _bmiUnitKey = 'bmi_unit';
  static const String _bmrGenderKey = 'bmr_gender';
  static const String _bmrActivityKey = 'bmr_activity';
  static const String _currencyKey = 'currency_style';
  static const String _pinnedToolsKey = 'pinned_tools';
  static const String _pinnedLimitKey = 'pinned_limit';

  /// 置顶工具数量下限。
  static const int minPinnedTools = 2;

  /// 置顶工具数量上限。
  static const int maxPinnedTools = 5;

  /// 默认最多置顶几个工具。
  static const int defaultPinnedTools = 3;

  /// 置顶数量可选的值（设置页下拉框用）。
  static const List<int> pinnedLimitOptions = <int>[2, 3, 4, 5];

  /// 换算工具设置键的前缀，完整键如 `convert.distance.system`。
  static const String _convertPrefix = 'convert.';

  /// 工具历史记录的键前缀，完整键如 `history.hourly`（值是一个 JSON 数组）。
  static const String _historyPrefix = 'history.';

  /// 工具页输入草稿的键前缀，完整键如 `tool.loan`（值是一段 JSON）。
  static const String _draftPrefix = 'tool.';

  /// 输入停止后隔多久写盘：打字时每个字符都读改写配置文件太浪费。
  static const Duration _draftDelay = Duration(milliseconds: 400);

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

  /// 置顶的工具 id，显示在工具页最前面；顺序不影响展示（按工具表顺序）。
  final List<String> pinnedTools = <String>[];

  /// 最多能置顶几个工具，取值 2 ~ 5，默认 3，可在设置页调整。
  int pinnedLimit = defaultPinnedTools;

  /// 各工具页上次填的输入（工具 id → 字段 → 值），重新进入时填回。
  final Map<String, Map<String, String>> toolDrafts =
      <String, Map<String, String>>{};

  /// 各工具的历史记录（工具 id → 记录，最近的在前，每条是一段 JSON）。
  ///
  /// 目前只有「时薪计算器」用，存法保持通用：工具自己负责编解码。
  final Map<String, List<String>> toolHistory = <String, List<String>>{};

  /// 待写盘的草稿（工具 id → 定时器）。
  final Map<String, Timer> _draftTimers = <String, Timer>{};

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
    final storedPinned = values[_pinnedToolsKey];
    if (storedPinned != null) {
      final ids = <String>[
        for (final id in storedPinned.split(','))
          if (id.trim().isNotEmpty) id.trim(),
      ];
      if (!listEquals(ids, pinnedTools)) {
        pinnedTools
          ..clear()
          ..addAll(ids);
        changed = true;
      }
    }
    final storedLimit = int.tryParse(values[_pinnedLimitKey] ?? '');
    if (storedLimit != null && storedLimit != pinnedLimit) {
      final limit = storedLimit.clamp(minPinnedTools, maxPinnedTools);
      if (limit != pinnedLimit) {
        pinnedLimit = limit;
        changed = true;
      }
    }
    // 数量上限调小后，多出来的置顶项直接丢掉，避免界面上看不到也取消不掉
    if (pinnedTools.length > pinnedLimit) {
      pinnedTools.removeRange(pinnedLimit, pinnedTools.length);
    }
    for (final entry in values.entries) {
      if (!entry.key.startsWith(_draftPrefix)) continue;
      final id = entry.key.substring(_draftPrefix.length);
      final parsed = _decodeDraft(entry.value);
      if (parsed == null || parsed.isEmpty) continue;
      toolDrafts[id] = parsed;
    }
    for (final entry in values.entries) {
      if (!entry.key.startsWith(_historyPrefix)) continue;
      final id = entry.key.substring(_historyPrefix.length);
      final parsed = _decodeHistory(entry.value);
      if (parsed == null || parsed.isEmpty) continue;
      toolHistory[id] = parsed;
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
    // 单位变了，BMI 页里上次填的身高体重含义也跟着变（cm 不是 ft），整条作废
    await clearToolDraft('bmi');
    await _store.write(_bmiUnitKey, unit.code);
  }

  /// 切换基础代谢默认性别。
  Future<void> setBmrGender(BmrGender gender) async {
    if (gender == bmrGender) return;
    bmrGender = gender;
    notifyListeners();
    await clearToolDraft('bmr', field: 'gender');
    await _store.write(_bmrGenderKey, gender.code);
  }

  /// 切换基础代谢默认活动水平。
  Future<void> setBmrActivity(BmrActivity activity) async {
    if (activity == bmrActivity) return;
    bmrActivity = activity;
    notifyListeners();
    await clearToolDraft('bmr', field: 'activity');
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
    await clearToolDraft(catalogId, field: 'from');
    await _store.write('$_convertPrefix$catalogId.unit', unitId);
  }

  /// 设置换算工具默认的计量体系。
  Future<void> setConvertSystem(String catalogId, MeasureSystem system) async {
    if (convertSystems[catalogId] == system) return;
    convertSystems[catalogId] = system;
    notifyListeners();
    await clearToolDraft(catalogId, field: 'from');
    await _store.write('$_convertPrefix$catalogId.system', system.code);
  }

  /// 设置换算工具结果默认选中的 tab。
  Future<void> setConvertTab(String catalogId, MeasureSystem system) async {
    if (convertTabs[catalogId] == system) return;
    convertTabs[catalogId] = system;
    notifyListeners();
    await clearToolDraft(catalogId, field: 'from');
    await _store.write('$_convertPrefix$catalogId.tab', system.code);
  }

  /// 某个工具是否已置顶。
  bool isPinned(String toolId) => pinnedTools.contains(toolId);

  /// 置顶还能再加几个。
  int get pinnedSlotsLeft => pinnedLimit - pinnedTools.length;

  /// 是否已经顶满（再加就得先取消一个）。
  bool get pinnedFull => pinnedTools.length >= pinnedLimit;

  /// 置顶 / 取消置顶某个工具。
  ///
  /// 置顶数已达上限时不再添加，返回 false 让调用方提示用户；
  /// 取消置顶总是成功。
  Future<bool> togglePinned(String toolId) async {
    if (pinnedTools.remove(toolId)) {
      notifyListeners();
      await _store.write(_pinnedToolsKey, pinnedTools.join(','));
      return true;
    }
    if (pinnedFull) return false;
    pinnedTools.add(toolId);
    notifyListeners();
    await _store.write(_pinnedToolsKey, pinnedTools.join(','));
    return true;
  }

  /// 调整最多能置顶几个工具（超出 2 ~ 5 的值会被夹回范围内）。
  Future<void> setPinnedLimit(int limit) async {
    final next = limit.clamp(minPinnedTools, maxPinnedTools);
    if (next == pinnedLimit) return;
    pinnedLimit = next;
    // 上限调小：从末尾丢掉多出来的置顶项
    final trimmed = pinnedTools.length > next;
    if (trimmed) pinnedTools.removeRange(next, pinnedTools.length);
    notifyListeners();
    await _store.write(_pinnedLimitKey, '$next');
    if (trimmed) await _store.write(_pinnedToolsKey, pinnedTools.join(','));
  }

  /// 某个工具上次填的输入（字段 → 值），没存过时为空表。
  Map<String, String> toolDraftOf(String toolId) =>
      toolDrafts[toolId] ?? const <String, String>{};

  /// 记下工具页的一个输入字段；`value` 为 null / 空串表示删掉该字段。
  ///
  /// 草稿不通知监听者：输入框自己会重建，没必要让全应用跟着刷新。写盘有
  /// 400 ms 的合并，打字时最多每 400 ms 落一次盘。
  void setToolDraftValue(String toolId, String field, String? value) {
    final draft = toolDrafts.putIfAbsent(toolId, () => <String, String>{});
    final next = (value == null || value.isEmpty) ? null : value;
    if (draft[field] == next) return;
    if (next == null) {
      draft.remove(field);
    } else {
      draft[field] = next;
    }
    if (draft.isEmpty) toolDrafts.remove(toolId);
    _draftTimers.putIfAbsent(
      toolId,
      () => Timer(_draftDelay, () => unawaited(_flushDraft(toolId))),
    );
  }

  /// 清掉某个工具（或其中某个字段）的草稿。
  ///
  /// 设置页改了某项默认值后顺手清掉对应草稿，让新默认值真的生效；
  /// 传 [field] 只清一个字段，不传清整个工具。
  Future<void> clearToolDraft(String toolId, {String? field}) async {
    final draft = toolDrafts[toolId];
    if (draft == null) return;
    if (field == null) {
      toolDrafts.remove(toolId);
    } else {
      draft.remove(field);
      if (draft.isEmpty) toolDrafts.remove(toolId);
    }
    _draftTimers.remove(toolId)?.cancel();
    await _writeDraft(toolId);
  }

  /// 把还没写盘的草稿立即写掉（离开页面、关闭应用时用）。
  Future<void> flushDrafts() async {
    final pending = _draftTimers.keys.toList();
    for (final id in pending) {
      _draftTimers.remove(id)?.cancel();
    }
    for (final id in pending) {
      await _writeDraft(id);
    }
  }

  Future<void> _flushDraft(String toolId) async {
    _draftTimers.remove(toolId)?.cancel();
    await _writeDraft(toolId);
  }

  Future<void> _writeDraft(String toolId) async {
    final draft = toolDrafts[toolId];
    await _store.write(
      '$_draftPrefix$toolId',
      draft == null || draft.isEmpty ? '' : jsonEncode(draft),
    );
  }

  /// 某个工具的历史记录（最近的在前），没存过时为空表。
  List<String> toolHistoryOf(String toolId) =>
      List<String>.unmodifiable(toolHistory[toolId] ?? const <String>[]);

  /// 记一条历史记录（最新的排在最前），超过 [limit] 条时丢掉最旧的。
  Future<void> addToolHistory(
    String toolId,
    String entry, {
    int limit = 20,
  }) async {
    final list = toolHistory.putIfAbsent(toolId, () => <String>[]);
    list.insert(0, entry);
    if (list.length > limit) list.removeRange(limit, list.length);
    notifyListeners();
    await _writeHistory(toolId);
  }

  /// 删掉某个工具的第 [index] 条历史记录。
  Future<void> removeToolHistory(String toolId, int index) async {
    final list = toolHistory[toolId];
    if (list == null || index < 0 || index >= list.length) return;
    list.removeAt(index);
    if (list.isEmpty) toolHistory.remove(toolId);
    notifyListeners();
    await _writeHistory(toolId);
  }

  /// 清空某个工具的历史记录。
  Future<void> clearToolHistory(String toolId) async {
    if (toolHistory.remove(toolId) == null) return;
    notifyListeners();
    await _writeHistory(toolId);
  }

  Future<void> _writeHistory(String toolId) async {
    final list = toolHistory[toolId];
    await _store.write(
      '$_historyPrefix$toolId',
      list == null || list.isEmpty ? '' : jsonEncode(list),
    );
  }

  static List<String>? _decodeHistory(String raw) {
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;
      return <String>[
        for (final entry in decoded)
          if (entry is String) entry,
      ];
    } on Object {
      return null;
    }
  }

  static Map<String, String>? _decodeDraft(String raw) {
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return <String, String>{
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } on Object {
      return null;
    }
  }

  @override
  void dispose() {
    unawaited(flushDrafts());
    super.dispose();
  }

  /// 结合系统明暗，得出当前应该使用的配色。
  AppPalette paletteFor(Brightness platformBrightness) => switch (themeMode) {
    AppThemeMode.dark => kDarkPalette,
    AppThemeMode.light => kLightPalette,
    AppThemeMode.system =>
      platformBrightness == Brightness.dark ? kDarkPalette : kLightPalette,
  };
}
