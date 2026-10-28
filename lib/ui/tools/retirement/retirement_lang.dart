import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「退休年龄计算器」卡片的多语言文案：名称、卖点、说明。
///
/// 口径是中国大陆的延迟退休政策，界面只对简体 / 繁体中文开放，
/// 其余语言仍给出译文，避免缺语言时回落成空卡片。
const Map<AppLanguage, ToolText> kRetirementLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '退休年龄计算器',
    '算一算你哪年退休',
    '按 2024 年渐进式延迟法定退休年龄的决定，由出生年月测算退休时间、退休年龄与最低缴费年限。',
  ),
  AppLanguage.zhHant: ToolText(
    '退休年齡計算機',
    '算一算你哪年退休',
    '依 2024 年漸進式延遲法定退休年齡的決定，由出生年月試算退休時間、退休年齡與最低繳費年限。',
  ),
  AppLanguage.en: ToolText(
    'Retirement age',
    'Find out when you can retire',
    'Uses the 2024 statutory retirement age reform to derive your retirement date, age and minimum contribution years from your birth month.',
  ),
  AppLanguage.ja: ToolText(
    '定年退職の年齢',
    '自分がいつ退職できるか',
    '2024 年の法定退職年齢の漸進的引き上げに基づき、生年月から退職時期・年齢・最低納付年数を算出します。',
  ),
  AppLanguage.es: ToolText(
    'Edad de jubilación',
    'Calcula cuándo te jubilas',
    'Aplica la reforma de 2024 de la edad legal de jubilación para obtener fecha, edad y años mínimos de cotización.',
  ),
};
