import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「容量换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kVolumeLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '容量换算',
    '升与加仑，厨房能用',
    '公制 / 英制 / 市制共 17 个单位互转，含毫升、英制加仑与石斗升，附常见容量参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '容量換算',
    '公升與加侖，廚房能用',
    '公制 / 英制 / 市制共 17 個單位互轉，含毫升、英制加侖與石斗升，附常見容量參照物。',
  ),
  AppLanguage.en: ToolText(
    'Volume',
    'Litres and gallons, kitchen ready',
    '17 units across metric, imperial and Chinese systems, with millilitres, imperial gallons and dan/dou/sheng.',
  ),
  AppLanguage.ja: ToolText(
    '体積換算',
    'リットルとガロン、台所でも',
    'メートル法・ヤード法・中国市制の 17 単位。ミリリットル・英ガロン・石斗升を含む。',
  ),
  AppLanguage.es: ToolText(
    'Volumen',
    'Litros y galones, útil en la cocina',
    '17 unidades métricas, imperiales y chinas con mililitros, galones imperiales y dan/dou/sheng.',
  ),
};
