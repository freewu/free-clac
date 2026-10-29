import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「热量换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kEnergyLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '热量换算',
    '瓦时焦耳卡路里',
    '瓦时 / 千瓦时 / 焦耳 / 千焦 / 卡路里互转，附电池、食物等常见热量参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '熱量換算',
    '瓦時焦耳卡路里',
    '瓦時 / 千瓦時 / 焦耳 / 千焦 / 卡路里互轉，附電池、食物等常見熱量參照物。',
  ),
  AppLanguage.en: ToolText(
    'Energy',
    'Watt-hours, joules, calories',
    'Watt-hours, kilowatt-hours, joules, kilojoules and calories, with everyday references.',
  ),
  AppLanguage.ja: ToolText(
    '熱量換算',
    'ワット時・ジュール・カロリー',
    'ワット時・キロワット時・ジュール・キロジュール・カロリーの換算と身近な例。',
  ),
  AppLanguage.es: ToolText(
    'Energía',
    'Vatios hora, julios, calorías',
    'Vatios hora, kilovatios hora, julios, kilojulios y calorías con referencias cotidianas.',
  ),
};
