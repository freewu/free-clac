import 'dart:ui' show Locale;

/// 应用支持的语言：简体中文、繁体中文、英语、日语、西班牙语。
///
/// 新增语言时只需在枚举里加一项、补一份 `AppStrings` 实现，
/// 以及各工具 `lang/` 目录下语言包里的一条记录。
enum AppLanguage {
  zhHans('zh-Hans', '简体中文', 'Chinese (Simplified)', 'zh', 'CN'),
  zhHant('zh-Hant', '繁體中文', 'Chinese (Traditional)', 'zh', 'TW'),
  en('en', 'English', 'English', 'en', 'US'),
  ja('ja', '日本語', 'Japanese', 'ja', 'JP'),
  es('es', 'Español', 'Spanish', 'es', 'ES');

  const AppLanguage(
    this.code,
    this.nativeLabel,
    this.englishLabel,
    this.languageCode,
    this.countryCode,
  );

  /// 语言包 / 持久化用的稳定标识（`zh-Hans`）。
  final String code;

  /// 用本语言书写的名称，语言选择列表里显示这个。
  final String nativeLabel;

  /// 英文名，给未翻译场景兜底。
  final String englishLabel;

  final String languageCode;
  final String countryCode;

  Locale get locale => Locale(languageCode, countryCode);

  /// 按系统语言挑一个最接近的；认不出时用简体中文。
  static AppLanguage fromLocale(Locale? locale) {
    if (locale == null) return AppLanguage.zhHans;
    final code = locale.toLanguageTag().toLowerCase();
    if (code.startsWith('zh')) {
      return code.contains('tw') ||
              code.contains('hk') ||
              code.contains('mo') ||
              code.contains('hant')
          ? AppLanguage.zhHant
          : AppLanguage.zhHans;
    }
    if (code.startsWith('ja')) return AppLanguage.ja;
    if (code.startsWith('es')) return AppLanguage.es;
    if (code.startsWith('en')) return AppLanguage.en;
    return AppLanguage.zhHans;
  }

  /// 解析持久化的语言标识，无法识别时返回 null。
  static AppLanguage? fromCode(String? code) {
    if (code == null) return null;
    for (final language in AppLanguage.values) {
      if (language.code == code) return language;
    }
    return null;
  }
}
