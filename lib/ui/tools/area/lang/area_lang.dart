import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「面积换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kAreaLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '面积换算',
    '平方米到亩，一键换算',
    '公制 / 英制 / 市制共 19 个单位互转，含公顷、英亩与市亩，附常见面积参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '面積換算',
    '平方公尺到畝，一鍵換算',
    '公制 / 英制 / 市制共 19 個單位互轉，含公頃、英畝與市畝，附常見面積參照物。',
  ),
  AppLanguage.en: ToolText(
    'Area',
    'Square metres to mu, one tap',
    '19 units across metric, imperial and Chinese systems, including hectares, acres and mu.',
  ),
  AppLanguage.ja: ToolText(
    '面積換算',
    '平方メートルから畝まで一発換算',
    'メートル法・ヤード法・中国市制の 19 単位。ヘクタール・エーカー・畝を含む。',
  ),
  AppLanguage.es: ToolText(
    'Superficie',
    'De metros cuadrados a mu con un toque',
    '19 unidades métricas, imperiales y chinas, con hectáreas, acres y mu.',
  ),
};
