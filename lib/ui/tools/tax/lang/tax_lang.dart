import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「个人所得税」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kTaxLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '个人所得税',
    '月薪扣完还剩多少',
    '按累计预扣法算个税，五险一金比例与缴费基数都能改，逐月列出个税与到手工资。',
  ),
  AppLanguage.zhHant: ToolText(
    '個人所得稅',
    '月薪扣完還剩多少',
    '依累計預扣法算所得稅，五險一金比例與繳費基數都能改，逐月列出稅額與實領薪資。',
  ),
  AppLanguage.en: ToolText(
    'Income tax',
    'What is left after deductions',
    'Withholding computed the Chinese cumulative way; edit social insurance rates and bases, see monthly tax and take-home pay.',
  ),
  AppLanguage.ja: ToolText(
    '所得税',
    '手取りはいくら',
    '中国の累計源泉方式で所得税を計算。社会保険の料率と基数を変更でき、月ごとの税額と手取りを表示。',
  ),
  AppLanguage.es: ToolText(
    'Impuesto sobre la renta',
    'Cuánto queda tras las deducciones',
    'Retención según el método acumulado chino; ajusta cotizaciones y bases, y ve el impuesto y el neto mensual.',
  ),
};
