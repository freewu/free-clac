import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「速度换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kSpeedLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '速度换算',
    '车速航速，一节就懂',
    '公制 / 英制 / 市制共 11 个单位互转，含千米每小时、英里每小时、节与马赫。',
  ),
  AppLanguage.zhHant: ToolText(
    '速度換算',
    '車速航速，一節就懂',
    '公制 / 英制 / 市制共 11 個單位互轉，含公里每小時、英里每小時、節與馬赫。',
  ),
  AppLanguage.en: ToolText(
    'Speed',
    'Road speed, knots and Mach',
    '11 units across metric, imperial and Chinese systems, including km/h, mph, knots and Mach.',
  ),
  AppLanguage.ja: ToolText(
    '速さ換算',
    '車の速度もノットも一発',
    'メートル法・ヤード法・中国市制の 11 単位。km/h・mph・ノット・マッハを含む。',
  ),
  AppLanguage.es: ToolText(
    'Velocidad',
    'Velocidad terrestre, nudos y Mach',
    '11 unidades métricas, imperiales y chinas, con km/h, mph, nudos y Mach.',
  ),
};
