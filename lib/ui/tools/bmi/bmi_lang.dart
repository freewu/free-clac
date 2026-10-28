import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「BMI 计算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kBmiLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    'BMI 计算',
    '身高体重，一眼看体型',
    '按中国成人标准给出分级、标准体重区间与建议，支持米制与厘米输入。',
  ),
  AppLanguage.zhHant: ToolText(
    'BMI 計算',
    '身高體重，一眼看體型',
    '依中國成人標準給出分級、標準體重區間與建議，支援公尺與公分輸入。',
  ),
  AppLanguage.en: ToolText(
    'BMI',
    'Body shape at a glance',
    'Grades by Chinese adult standards, ideal weight range and advice; accepts metres or centimetres.',
  ),
  AppLanguage.ja: ToolText(
    'BMI',
    '身長と体重で体型が一目',
    '中国成人基準で区分・標準体重の範囲・アドバイスを表示。メートル/センチ入力対応。',
  ),
  AppLanguage.es: ToolText(
    'IMC',
    'Tu forma de un vistazo',
    'Clasificación según el estándar adulto chino, rango de peso ideal y consejos; acepta metros o centímetros.',
  ),
};
