/// 个人所得税（工资薪金）与五险一金的计算，纯逻辑，不依赖 Flutter。
///
/// 口径：
/// * 个税起征点每月 5000 元；
/// * 采用「累计预扣预缴法」：每月按截至当月的累计应纳税所得额查**年度**税率表，
///   减去已预缴税额得到当月应缴，因此月薪固定时，跨档月份的个税会变；
/// * 应纳税所得额 = 月薪 − 五险一金个人部分 − 5000 − 专项附加扣除；
/// * 五险一金按个人缴纳比例乘缴费基数，比例默认养老 8%、医疗 2%、
///   失业 0.5%、公积金 12%（可改）。
library;

/// 个税起征点（每月）。
const double taxThresholdMonthly = 5000;

/// 一年 12 个月。
const int taxMonthsPerYear = 12;

/// 综合所得（工资薪金）年度税率表。
class TaxBracket {
  const TaxBracket({
    required this.upperLimit,
    required this.ratePercent,
    required this.quickDeduction,
  });

  /// 全年应纳税所得额上限（最后一档为 `double.infinity`）。
  final double upperLimit;

  /// 税率（%）。
  final double ratePercent;

  /// 速算扣除数。
  final double quickDeduction;
}

/// 年度税率表：3% / 10% / 20% / 25% / 30% / 35% / 45% 七级。
const List<TaxBracket> kTaxBrackets = <TaxBracket>[
  TaxBracket(upperLimit: 36000, ratePercent: 3, quickDeduction: 0),
  TaxBracket(upperLimit: 144000, ratePercent: 10, quickDeduction: 2520),
  TaxBracket(upperLimit: 300000, ratePercent: 20, quickDeduction: 16920),
  TaxBracket(upperLimit: 420000, ratePercent: 25, quickDeduction: 31920),
  TaxBracket(upperLimit: 660000, ratePercent: 30, quickDeduction: 52920),
  TaxBracket(upperLimit: 960000, ratePercent: 35, quickDeduction: 85920),
  TaxBracket(
    upperLimit: double.infinity,
    ratePercent: 45,
    quickDeduction: 181920,
  ),
];

/// 按全年应纳税所得额算全年个税。
double yearlyIncomeTax(double yearlyTaxable) {
  if (!yearlyTaxable.isFinite || yearlyTaxable <= 0) {
    return 0;
  }
  final bracket = bracketOf(yearlyTaxable);
  return yearlyTaxable * bracket.ratePercent / 100 - bracket.quickDeduction;
}

/// 全年应纳税所得额落在哪一档。
TaxBracket bracketOf(double yearlyTaxable) {
  for (final bracket in kTaxBrackets) {
    if (yearlyTaxable <= bracket.upperLimit) {
      return bracket;
    }
  }
  return kTaxBrackets.last;
}

/// 五险一金里个人缴纳的项目。
enum InsuranceItem {
  pension('养老', 8),
  medical('医疗', 2),
  unemployment('失业', 0.5),
  housingFund('公积金', 12);

  const InsuranceItem(this.label, this.defaultRatePercent);

  /// 项目名（养老 / 医疗 / 失业 / 公积金）。
  final String label;

  /// 默认比例（%）。
  final double defaultRatePercent;

  /// 是否属于社保（公积金单独算）。
  bool get isSocialSecurity => this != InsuranceItem.housingFund;
}

/// 个人缴纳比例（%），按项目保存。
class InsuranceRates {
  const InsuranceRates(this._rates);

  /// 默认比例：养老 8%、医疗 2%、失业 0.5%、公积金 12%。
  factory InsuranceRates.defaults() => InsuranceRates(<InsuranceItem, double>{
    for (final item in InsuranceItem.values) item: item.defaultRatePercent,
  });

  final Map<InsuranceItem, double> _rates;

  /// 某项的比例（%），未设置时按 0 处理。
  double of(InsuranceItem item) => _rates[item] ?? 0;

  /// 改一项比例，返回新的对象（不可变）。
  InsuranceRates withRate(InsuranceItem item, double ratePercent) =>
      InsuranceRates(<InsuranceItem, double>{..._rates, item: ratePercent});

  /// 各项比例之和（%）。
  double get totalPercent =>
      InsuranceItem.values.fold(0, (sum, item) => sum + of(item));

  /// 社保部分（不含公积金）的比例之和（%）。
  double get socialSecurityPercent => InsuranceItem.values
      .where((item) => item.isSocialSecurity)
      .fold(0, (sum, item) => sum + of(item));
}

/// 计算所需的输入。
class PayrollPlan {
  const PayrollPlan({
    required this.grossMonthly,
    required this.contributionBase,
    this.rates = const InsuranceRates(<InsuranceItem, double>{
      InsuranceItem.pension: 8,
      InsuranceItem.medical: 2,
      InsuranceItem.unemployment: 0.5,
      InsuranceItem.housingFund: 12,
    }),
    this.specialDeductionMonthly = 0,
  });

  /// 税前月薪。
  final double grossMonthly;

  /// 五险一金缴费基数（一般等于月薪，也可按当地上下限单独填）。
  final double contributionBase;

  /// 个人缴纳比例。
  final InsuranceRates rates;

  /// 专项附加扣除（每月），如子女教育 2000 + 房贷利息 1000。
  final double specialDeductionMonthly;

  /// 某项每月缴纳的金额。
  double contributionOf(InsuranceItem item) =>
      contributionBase * rates.of(item) / 100;

  /// 每月五险一金合计（个人部分）。
  double get contributionMonthly => contributionBase * rates.totalPercent / 100;

  /// 每月专项附加扣除（不超过月薪）。
  double get deductionMonthly => specialDeductionMonthly > grossMonthly
      ? grossMonthly
      : specialDeductionMonthly;
}

/// 一个月的明细。
class PayrollMonth {
  const PayrollMonth({
    required this.index,
    required this.gross,
    required this.contribution,
    required this.deduction,
    required this.taxable,
    required this.tax,
    required this.cumulativeTax,
    required this.net,
  });

  /// 第几个月（1~12）。
  final int index;

  /// 税前工资。
  final double gross;

  /// 五险一金（个人部分）。
  final double contribution;

  /// 专项附加扣除。
  final double deduction;

  /// 当月应纳税所得额（已扣 5000 起征点）。
  final double taxable;

  /// 当月个税。
  final double tax;

  /// 截至当月的累计个税。
  final double cumulativeTax;

  /// 到手工资。
  final double net;
}

/// 计算结果。
class PayrollResult {
  const PayrollResult({
    required this.plan,
    required this.months,
    required this.byItem,
    required this.socialSecurityMonthly,
    required this.housingFundMonthly,
    required this.yearlyGross,
    required this.yearlyTax,
    required this.yearlyNet,
  });

  final PayrollPlan plan;

  /// 12 个月的明细。
  final List<PayrollMonth> months;

  /// 每月各项缴纳金额。
  final Map<InsuranceItem, double> byItem;

  /// 每月社保（养老 + 医疗 + 失业）。
  final double socialSecurityMonthly;

  /// 每月公积金。
  final double housingFundMonthly;

  /// 全年税前收入。
  final double yearlyGross;

  /// 全年个税。
  final double yearlyTax;

  /// 全年到手。
  final double yearlyNet;

  /// 税前月薪。
  double get grossMonthly => plan.grossMonthly;

  /// 每月五险一金合计。
  double get contributionMonthly => socialSecurityMonthly + housingFundMonthly;

  /// 首月个税。
  double get firstMonthTax => months.first.tax;

  /// 首月到手。
  double get firstMonthNet => months.first.net;

  /// 最高的一个月个税（用于明细条的相对长度）。
  double get maxMonthlyTax =>
      months.map((month) => month.tax).reduce((a, b) => a > b ? a : b);

  /// 全年应纳税所得额。
  double get yearlyTaxable =>
      months.fold(0, (sum, month) => sum + month.taxable);

  /// 边际税率（%）：全年应纳税所得额所在档位的税率。
  double get marginalRatePercent => bracketOf(yearlyTaxable).ratePercent;
}

/// 计算 12 个月的个税与到手工资，参数非法时返回 null。
PayrollResult? calculatePayroll(PayrollPlan plan) {
  if (!_validPlan(plan)) {
    return null;
  }
  final rates = plan.rates;
  final contribution = plan.contributionMonthly;
  final deduction = plan.deductionMonthly;
  final monthlyTaxable =
      plan.grossMonthly - contribution - taxThresholdMonthly - deduction;

  final months = <PayrollMonth>[];
  var previousCumulativeTax = 0.0;
  for (var index = 1; index <= taxMonthsPerYear; index++) {
    // 累计预扣法：按累计应纳税所得额查年度税率表，再减去已预缴
    final cumulativeTaxable = monthlyTaxable * index;
    final cumulativeTax = yearlyIncomeTax(cumulativeTaxable);
    final tax = cumulativeTax - previousCumulativeTax;
    previousCumulativeTax = cumulativeTax;
    months.add(
      PayrollMonth(
        index: index,
        gross: plan.grossMonthly,
        contribution: contribution,
        deduction: deduction,
        taxable: monthlyTaxable < 0 ? 0 : monthlyTaxable,
        tax: tax < 0 ? 0 : tax,
        cumulativeTax: cumulativeTax,
        net: plan.grossMonthly - contribution - (tax < 0 ? 0 : tax),
      ),
    );
  }

  return PayrollResult(
    plan: plan,
    months: List.unmodifiable(months),
    byItem: Map.unmodifiable(<InsuranceItem, double>{
      for (final item in InsuranceItem.values) item: plan.contributionOf(item),
    }),
    socialSecurityMonthly:
        plan.contributionBase * rates.socialSecurityPercent / 100,
    housingFundMonthly: plan.contributionOf(InsuranceItem.housingFund),
    yearlyGross: plan.grossMonthly * taxMonthsPerYear,
    yearlyTax: months.fold(0, (sum, month) => sum + month.tax),
    yearlyNet: months.fold(0, (sum, month) => sum + month.net),
  );
}

bool _validPlan(PayrollPlan plan) {
  final gross = plan.grossMonthly;
  final base = plan.contributionBase;
  final deduction = plan.specialDeductionMonthly;
  if (!_finite(gross) || gross <= 0) return false;
  if (!_finite(base) || base < 0) return false;
  if (!_finite(deduction) || deduction < 0) return false;
  for (final item in InsuranceItem.values) {
    final rate = plan.rates.of(item);
    if (!_finite(rate) || rate < 0 || rate > 100) return false;
  }
  // 五险一金比例合计不超过 100%，且扣完不能为负
  if (plan.rates.totalPercent > 100) return false;
  return plan.contributionMonthly <= gross;
}

bool _finite(double value) => value.isFinite;
