import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'tax.dart';

/// 个人所得税页的界面文案。
///
/// 只有简繁中文两种：五险一金与累计预扣都是中国口径，`ToolInfo.availableIn`
/// 限定为中文，其他语言界面不展示。
class TaxStrings {
  const TaxStrings({
    required this.title,
    required this.sectionIncome,
    required this.gross,
    required this.yuan,
    required this.base,
    required this.baseHint,
    required this.special,
    required this.perMonth,
    required this.sectionInsurance,
    required this.total,
    required this.sectionMonths,
    required this.baseCalc,
    required this.emptyHint,
    required this.firstMonthNet,
    required this.deduction,
    required this.yearlyTax,
    required this.yearlyNet,
    required this.marginalRate,
    required this.breakdown,
    required this.noInsurance,
    required this.monthColumn,
    required this.taxColumn,
    required this.netColumn,
    required this.monthRow,
    required this.pension,
    required this.medical,
    required this.unemployment,
    required this.housingFund,
  });

  final String title;
  final String sectionIncome;
  final String gross;
  final String yuan;
  final String base;
  final String baseHint;
  final String special;

  /// 「元 / 月」。
  final String perMonth;
  final String sectionInsurance;

  /// 「合计 {0}%」。
  final String total;
  final String sectionMonths;

  /// 「按基数 ¥ {0} 计算，每月个人缴纳 ¥ {1}」。
  final String baseCalc;
  final String emptyHint;
  final String firstMonthNet;

  /// 「税前 ¥ {0} − 五险一金 ¥ {1} − 个税 ¥ {2}」。
  final String deduction;
  final String yearlyTax;
  final String yearlyNet;
  final String marginalRate;
  final String breakdown;
  final String noInsurance;
  final String monthColumn;
  final String taxColumn;
  final String netColumn;

  /// 「第 {0} 月」。
  final String monthRow;
  final String pension;
  final String medical;
  final String unemployment;
  final String housingFund;

  /// 五险一金各项名称（数据层的 `InsuranceItem.label` 只有中文）。
  String itemLabel(InsuranceItem value) => switch (value) {
    InsuranceItem.pension => pension,
    InsuranceItem.medical => medical,
    InsuranceItem.unemployment => unemployment,
    InsuranceItem.housingFund => housingFund,
  };
}

/// 各语言的个人所得税文案。
const Map<AppLanguage, TaxStrings> kTaxStrings = <AppLanguage, TaxStrings>{
  AppLanguage.zhHans: TaxStrings(
    title: '个人所得税',
    sectionIncome: '收入',
    gross: '税前月薪',
    yuan: '元',
    base: '缴费基数',
    baseHint: '默认等于月薪',
    special: '专项附加扣除',
    perMonth: '元 / 月',
    sectionInsurance: '五险一金（个人缴纳比例）',
    total: '合计 {0}%',
    sectionMonths: '月度明细',
    baseCalc: '按基数 ¥ {0} 计算，每月个人缴纳 ¥ {1}',
    emptyHint: '填写税前月薪与缴纳比例后自动计算',
    firstMonthNet: '首月到手',
    deduction: '税前 ¥ {0} − 五险一金 ¥ {1} − 个税 ¥ {2}',
    yearlyTax: '全年个税',
    yearlyNet: '全年到手',
    marginalRate: '适用税率',
    breakdown: '五险一金构成（每月）',
    noInsurance: '未缴纳五险一金',
    monthColumn: '月份',
    taxColumn: '个税',
    netColumn: '到手',
    monthRow: '第 {0} 月',
    pension: '养老',
    medical: '医疗',
    unemployment: '失业',
    housingFund: '公积金',
  ),
  AppLanguage.zhHant: TaxStrings(
    title: '個人所得稅',
    sectionIncome: '收入',
    gross: '稅前月薪',
    yuan: '元',
    base: '繳費基數',
    baseHint: '預設等於月薪',
    special: '專項附加扣除',
    perMonth: '元 / 月',
    sectionInsurance: '五險一金（個人繳納比例）',
    total: '合計 {0}%',
    sectionMonths: '月度明細',
    baseCalc: '按基數 ¥ {0} 計算，每月個人繳納 ¥ {1}',
    emptyHint: '填寫稅前月薪與繳納比例後自動計算',
    firstMonthNet: '首月到手',
    deduction: '稅前 ¥ {0} − 五險一金 ¥ {1} − 個稅 ¥ {2}',
    yearlyTax: '全年個稅',
    yearlyNet: '全年到手',
    marginalRate: '適用稅率',
    breakdown: '五險一金構成（每月）',
    noInsurance: '未繳納五險一金',
    monthColumn: '月份',
    taxColumn: '個稅',
    netColumn: '到手',
    monthRow: '第 {0} 月',
    pension: '養老',
    medical: '醫療',
    unemployment: '失業',
    housingFund: '公積金',
  ),
};

/// 当前语言的个人所得税文案。
TaxStrings get taxStrings => toolText(kTaxStrings);
