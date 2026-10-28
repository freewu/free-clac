import '../core/number_format.dart';
import '../state/settings_controller.dart';
import 'app_i18n.dart';
import 'currency.dart';

export 'currency.dart';

/// 当前生效的金额符号。
///
/// 设置里选了具体货币就用它的符号，否则跟界面语言走（简中 ¥、繁中与英语 $、
/// 日语 ￥、西语 €）。和 `t` / `AppColors` 一样是全局入口，工具页不必
/// 层层传设置。
String get currencySymbol => currencySymbolFor(
  currentSettings?.currencyCode ?? kFollowLanguageCurrency,
  appLanguage,
);

/// 金额展示：符号 + 千分位数字，如 `¥ 12,345.67`。
String money(double value, {int decimals = 2}) =>
    '$currencySymbol ${formatMoney(value, decimals: decimals)}';
