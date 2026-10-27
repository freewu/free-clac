/// 利率换算：本金 + 日付 / 月付 / 年付 ⇄ 年化率，纯逻辑，不依赖 Flutter。
///
/// 采用单利年化：年化率 = 每期收益 × 每年期数 ÷ 本金，
/// 日付按 365 天、月付按 12 个月折算（和「万份收益」的口径一致）。
library;

/// 付息周期。
enum InterestPeriod {
  daily('日付', '每天', 365),
  monthly('月付', '每月', 12),
  yearly('年付', '每年', 1);

  const InterestPeriod(this.label, this.everyLabel, this.periodsPerYear);

  /// 周期名称，用于选项按钮（日付 / 月付 / 年付）。
  final String label;

  /// 「每 X」的说法，用于单位文案（每天 / 每月 / 每年）。
  final String everyLabel;

  /// 每年的周期数：日付 365、月付 12、年付 1。
  final int periodsPerYear;
}

/// 一年按 365 天折算日付。
const int daysPerYear = 365;

/// 一年按 12 个月折算月付。
const int monthsPerYear = 12;

/// 年化率的合理上限（1000%），超过视为输入错误。
const double maxAnnualRatePercent = 1000;

/// 本金 + 年化率的完整报价：各周期收益、利率与万份收益。
class InterestQuote {
  const InterestQuote({
    required this.principal,
    required this.annualRatePercent,
  });

  /// 本金。
  final double principal;

  /// 年化率，按百分比传入（5 表示 5%）。
  final double annualRatePercent;

  /// 年化率的小数形式。
  double get annualRate => annualRatePercent / 100;

  /// 某周期的收益率（小数），如日利率 = 年化率 / 365。
  double rateFor(InterestPeriod period) => annualRate / period.periodsPerYear;

  /// 某周期（每天 / 每月 / 每年）的收益。
  double paymentFor(InterestPeriod period) =>
      principal * annualRate / period.periodsPerYear;

  /// 每天收益。
  double get dailyPayment => paymentFor(InterestPeriod.daily);

  /// 每月收益。
  double get monthlyPayment => paymentFor(InterestPeriod.monthly);

  /// 每年收益。
  double get yearlyPayment => paymentFor(InterestPeriod.yearly);

  /// 万份收益：每 1 万元本金在一个周期里的收益。
  double paymentPerTenThousand(InterestPeriod period) =>
      paymentFor(period) * 10000 / principal;
}

/// 本金是否可用于计算。
bool _validPrincipal(double principal) => principal.isFinite && principal > 0;

/// 年化率是否在合理范围内。
bool _validRatePercent(double percent) =>
    percent.isFinite && percent.abs() <= maxAnnualRatePercent;

/// 由「本金 + 某周期收益」反推年化率（百分比）。
///
/// `principal` 必须为正、`payment` 需为有限数，算出的年化率超过
/// [maxAnnualRatePercent] 时返回 null。
///
/// ```dart
/// annualRatePercentFromPayment(
///   principal: 10000,
///   payment: 1,
///   period: InterestPeriod.daily,
/// ); // 3.65
/// ```
double? annualRatePercentFromPayment({
  required double principal,
  required double payment,
  required InterestPeriod period,
}) {
  if (!_validPrincipal(principal) || !payment.isFinite) return null;
  final percent = payment * period.periodsPerYear / principal * 100;
  if (!_validRatePercent(percent)) return null;
  return percent;
}

/// 由「本金 + 年化率」算出某周期的收益。
///
/// ```dart
/// paymentFromAnnualRate(
///   principal: 10000,
///   annualRatePercent: 3.65,
///   period: InterestPeriod.monthly,
/// ); // 30.4166…
/// ```
double? paymentFromAnnualRate({
  required double principal,
  required double annualRatePercent,
  required InterestPeriod period,
}) {
  if (!_validPrincipal(principal) || !_validRatePercent(annualRatePercent)) {
    return null;
  }
  return principal * (annualRatePercent / 100) / period.periodsPerYear;
}

/// 生成完整报价；本金或年化率非法时返回 null。
InterestQuote? interestQuote({
  required double principal,
  required double annualRatePercent,
}) {
  if (!_validPrincipal(principal) || !_validRatePercent(annualRatePercent)) {
    return null;
  }
  return InterestQuote(
    principal: principal,
    annualRatePercent: annualRatePercent,
  );
}
