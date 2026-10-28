import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「长度换算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kDistanceLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '长度换算',
    '公制英制，一屏换算',
    '公制 / 英制 / 市制共 25 个单位互转，输入即算，附常见长度参照物。',
  ),
  AppLanguage.zhHant: ToolText(
    '長度換算',
    '公制英制，一螢幕換算',
    '公制 / 英制 / 市制共 25 個單位互轉，輸入即算，附常見長度參照物。',
  ),
  AppLanguage.en: ToolText(
    'Length',
    'Metric and imperial, one screen',
    '25 units across metric, imperial and Chinese customary systems; converts as you type, with everyday references.',
  ),
  AppLanguage.ja: ToolText(
    '長さ換算',
    'メートル法とヤード法を一画面で',
    'メートル法・ヤード法・中国市制の全 25 単位。入力即換算、身近な例付き。',
  ),
  AppLanguage.es: ToolText(
    'Longitud',
    'Métrico e imperial en una pantalla',
    '25 unidades métricas, imperiales y chinas; convierte al escribir, con referencias cotidianas.',
  ),
};
