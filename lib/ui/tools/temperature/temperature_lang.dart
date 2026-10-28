import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「温度换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kTemperatureLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '温度换算',
    '摄氏华氏，连同体感',
    '摄氏度 / 华氏度 / 开尔文 / 兰氏度互转，按零点偏移精确换算，附常见温度参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '溫度換算',
    '攝氏華氏，連同體感',
    '攝氏 / 華氏 / 克耳文 / 蘭氏度互轉，依零點偏移精確換算，附常見溫度參照物。',
  ),
  AppLanguage.en: ToolText(
    'Temperature',
    'Celsius, Fahrenheit and how it feels',
    'Celsius, Fahrenheit, kelvin and Rankine with exact zero offsets, plus everyday references.',
  ),
  AppLanguage.ja: ToolText(
    '温度換算',
    '摂氏・華氏と体感',
    '摂氏・華氏・ケルビン・ランキン。零点オフセットを含む正確換算と身近な例。',
  ),
  AppLanguage.es: ToolText(
    'Temperatura',
    'Celsius, Fahrenheit y sensación',
    'Celsius, Fahrenheit, kelvin y Rankine con desplazamiento exacto del cero, y referencias cotidianas.',
  ),
};
