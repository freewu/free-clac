import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「复利计算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kCompoundLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '复利计算',
    '让时间替你赚钱',
    '支持任意复利频率与定期追加投入，输出本息、有效年利率与逐年增长表。',
  ),
  AppLanguage.zhHant: ToolText(
    '複利計算',
    '讓時間替你賺錢',
    '支援任意複利頻率與定期追加投入，輸出本息、有效年利率與逐年成長表。',
  ),
  AppLanguage.en: ToolText(
    'Compound interest',
    'Let time earn for you',
    'Any compounding frequency plus regular contributions; shows balance, effective annual rate and yearly growth.',
  ),
  AppLanguage.ja: ToolText(
    '複利計算',
    '時間に稼いでもらう',
    '任意の複利頻度と積立に対応。残高・実効年利・年次推移を表示。',
  ),
  AppLanguage.es: ToolText(
    'Interés compuesto',
    'Deja que el tiempo trabaje',
    'Cualquier frecuencia de capitalización y aportes periódicos; saldo, tasa anual efectiva y evolución anual.',
  ),
};
