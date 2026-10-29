import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「压力换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kPressureLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '压力换算',
    '帕巴托，还有 psi',
    '帕 / 百帕 / 千帕 / 兆帕 / 巴 / 托 / 磅力每平方英寸互转，附大气压、胎压等参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '壓力換算',
    '帕巴托，還有 psi',
    '帕 / 百帕 / 千帕 / 兆帕 / 巴 / 托 / 磅力每平方英寸互轉，附大氣壓、胎壓等參照物。',
  ),
  AppLanguage.en: ToolText(
    'Pressure',
    'Pascal, bar and psi',
    'Pascals, hectopascals, kilopascals, megapascals, bar, torr and psi, with everyday references.',
  ),
  AppLanguage.ja: ToolText(
    '圧力換算',
    'パスカル・バール・psi',
    'パスカル・ヘクトパスカル・キロパスカル・メガパスカル・バール・トル・psi の換算と身近な例。',
  ),
  AppLanguage.es: ToolText(
    'Presión',
    'Pascal, bar y psi',
    'Pascales, hectopascales, kilopascales, megapascales, bar, torr y psi con referencias cotidianas.',
  ),
};
