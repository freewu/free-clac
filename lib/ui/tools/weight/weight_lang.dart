import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「重量换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kWeightLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '重量换算',
    '斤两磅，随手换',
    '公制 / 英制 / 市制共 17 个单位互转，含千克、磅与斤两钱，附常见重量参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '重量換算',
    '斤兩磅，隨手換',
    '公制 / 英制 / 市制共 17 個單位互轉，含公斤、磅與斤兩錢，附常見重量參照物。',
  ),
  AppLanguage.en: ToolText(
    'Weight',
    'Jin, liang and pounds on the fly',
    '17 units across metric, imperial and Chinese systems, with kilograms, pounds and jin/liang/qian.',
  ),
  AppLanguage.ja: ToolText(
    '重さ換算',
    '斤・両・ポンドをさっと換算',
    'メートル法・ヤード法・中国市制の 17 単位。キロ・ポンド・斤両銭を含む。',
  ),
  AppLanguage.es: ToolText(
    'Peso',
    'Jin, liang y libras al instante',
    '17 unidades métricas, imperiales y chinas con kilogramos, libras y jin/liang/qian.',
  ),
};
