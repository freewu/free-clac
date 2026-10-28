import 'app_language.dart';
import 'app_strings.dart';

/// 当前生效的语言与文案。
///
/// 与 [AppColors] 的思路一致：由 `FreeCalcApp` 在构建 `MaterialApp` 之前
/// 调用 [applyAppLanguage]，随后整棵树重建，任何位置的代码都能直接读到
/// 当前语言的文案，不必层层传 `BuildContext`。
AppLanguage _language = AppLanguage.zhHans;

/// 当前语言。
AppLanguage get appLanguage => _language;

/// 切换当前语言（只改数据，重建由调用方负责）。
void applyAppLanguage(AppLanguage language) => _language = language;

/// 当前语言的界面文案。
AppStrings get t => AppStrings.of(_language);

/// 取某个工具语言包里指定语言的文案；缺翻译时回落简体中文。
V toolTextFor<V>(Map<AppLanguage, V> pack, AppLanguage language) =>
    pack[language] ?? pack[AppLanguage.zhHans] ?? pack.values.first;

/// 取某个工具语言包里当前语言的文案。
V toolText<V>(Map<AppLanguage, V> pack) => toolTextFor(pack, _language);

/// 用位置占位符填充模板：`fill('{0} 年 {1} 个月', [y, m])`。
///
/// 多语言的语序不同（如日语把数量放在名词前），所以工具页文案一律用模板
/// 而不是在代码里拼字符串。
String fill(String template, [List<Object?> args = const <Object?>[]]) {
  if (args.isEmpty) return template;
  var text = template;
  for (var i = 0; i < args.length; i++) {
    text = text.replaceAll('{$i}', '${args[i]}');
  }
  return text;
}
