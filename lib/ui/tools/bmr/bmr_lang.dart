import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「基础代谢 BMR」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kBmrLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '基础代谢 BMR',
    '算出每天该吃多少',
    'Mifflin-St Jeor 公式算基础代谢，并给出五种活动水平下的每日总消耗（TDEE）。',
  ),
  AppLanguage.zhHant: ToolText(
    '基礎代謝 BMR',
    '算出每天該吃多少',
    '以 Mifflin-St Jeor 公式計算基礎代謝，並給出五種活動水平的每日總消耗（TDEE）。',
  ),
  AppLanguage.en: ToolText(
    'BMR & TDEE',
    'How much to eat daily',
    'Mifflin-St Jeor BMR plus the total daily energy burn for five activity '
        'levels.',
  ),
  AppLanguage.ja: ToolText(
    '基礎代謝 BMR',
    '1 日に必要な量がわかる',
    'Mifflin-St Jeor 式で基礎代謝と、5 段階の活動レベル別の 1 日消費量（TDEE）を計算。',
  ),
  AppLanguage.es: ToolText(
    'Metabolismo basal',
    'Cuánto comer al día',
    'BMR con la fórmula Mifflin-St Jeor y el gasto diario total (TDEE) en cinco '
        'niveles de actividad.',
  ),
};
