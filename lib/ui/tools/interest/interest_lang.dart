import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「利率计算」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kInterestLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '利率计算',
    '日付月付，一眼换年化',
    '本金配日付 / 月付 / 年付反推年化率，也能由年化率算出三种周期收益。',
  ),
  AppLanguage.zhHant: ToolText(
    '利率計算',
    '日付月付，一眼換年化',
    '本金配日付 / 月付 / 年付反推年化率，也能由年化率算出三種週期收益。',
  ),
  AppLanguage.en: ToolText(
    'Interest rate',
    'Daily or monthly, straight to annual',
    'Turn a principal with daily, monthly or yearly payout into an annual rate, or the other way round.',
  ),
  AppLanguage.ja: ToolText(
    '金利計算',
    '日払い・月払いを年利に',
    '元本と日払い・月払い・年払いから年利を逆算、逆方向の計算も可能。',
  ),
  AppLanguage.es: ToolText(
    'Tasa de interés',
    'Diario o mensual a tasa anual',
    'Convierte un capital con pago diario, mensual o anual en tasa anual, o al revés.',
  ),
};
