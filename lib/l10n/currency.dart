import 'app_language.dart';

/// 金额符号偏好：跟随语言，或固定用某一种货币符号。
enum CurrencyStyle {
  followLanguage('auto'),
  yuan('cny'),
  dollar('usd'),
  yen('jpy'),
  euro('eur');

  const CurrencyStyle(this.code);

  /// 持久化用的稳定标识。
  final String code;

  /// 固定符号；[followLanguage] 没有自己的符号，返回空串。
  String get symbol => switch (this) {
    CurrencyStyle.followLanguage => '',
    CurrencyStyle.yuan => '¥',
    CurrencyStyle.dollar => r'$',
    CurrencyStyle.yen => '￥',
    CurrencyStyle.euro => '€',
  };

  static CurrencyStyle? fromCode(String? code) {
    if (code == null) return null;
    for (final style in CurrencyStyle.values) {
      if (style.code == code) return style;
    }
    return null;
  }
}

/// 「跟随语言」时各语言的默认金额符号。
///
/// 简中用人民币符号、繁中与英语用美元、日语用全角日元、西语用欧元。
const Map<AppLanguage, String> kLanguageCurrencySymbols = <AppLanguage, String>{
  AppLanguage.zhHans: '¥',
  AppLanguage.zhHant: r'$',
  AppLanguage.en: r'$',
  AppLanguage.ja: '￥',
  AppLanguage.es: '€',
};

/// 按偏好与语言得出要显示的金额符号。
String currencySymbolFor(CurrencyStyle style, AppLanguage language) =>
    style == CurrencyStyle.followLanguage
    ? (kLanguageCurrencySymbols[language] ?? '¥')
    : style.symbol;
