/// 贷款计算：等额本息 / 等额本金的月供拆分（本金 + 利息）与还款计划，
/// 纯逻辑，不依赖 Flutter。
library;

/// 还款方式。
enum LoanMethod {
  /// 等额本息：每月还款额固定，前期利息多、本金少。
  equalInstallment('等额本息'),

  /// 等额本金：每月本金固定，还款额逐月递减，总利息更少。
  equalPrincipal('等额本金');

  const LoanMethod(this.label);

  final String label;
}

/// 一年 12 期。
const int loanPeriodsPerYear = 12;

/// 期限的输入单位。
enum LoanTermUnit {
  years('年', loanPeriodsPerYear),
  months('月', 1);

  const LoanTermUnit(this.label, this.monthsPerUnit);

  /// 单位名（年 / 月）。
  final String label;

  /// 一个单位包含多少期（月）。
  final int monthsPerUnit;

  /// 把输入数值换算成月数（四舍五入）。
  int toMonths(double value) => (value * monthsPerUnit).round();
}

/// 期限上限（月），100 年足够覆盖所有真实贷款。
const int maxLoanMonths = 1200;

/// 年利率上限（%）。
const double maxLoanRatePercent = 100;

/// 一期（一个月）的还款明细。
class LoanPeriod {
  const LoanPeriod({
    required this.index,
    required this.payment,
    required this.principal,
    required this.interest,
    required this.balance,
  });

  /// 第几期（按年汇总时是第几年），从 1 开始。
  final int index;

  /// 本期还款总额。
  final double payment;

  /// 本期偿还的本金。
  final double principal;

  /// 本期支付的利息。
  final double interest;

  /// 本期还完后的剩余本金。
  final double balance;

  /// 利息占本期还款的比例（0~1），用于双色条。
  double get interestRatio => payment == 0 ? 0 : interest / payment;

  /// 本金占本期还款的比例（0~1）。
  double get principalRatio => 1 - interestRatio;
}

/// 贷款计算结果。
class LoanResult {
  LoanResult({
    required this.amount,
    required this.annualRatePercent,
    required this.method,
    required this.periods,
  });

  /// 贷款总额。
  final double amount;

  /// 年利率，按百分比传入（4.9 表示 4.9%）。
  final double annualRatePercent;

  final LoanMethod method;

  /// 逐月还款计划，长度等于贷款月数。
  final List<LoanPeriod> periods;

  /// 贷款月数。
  int get months => periods.length;

  /// 总还款额。
  double get totalPayment =>
      periods.fold<double>(0, (sum, item) => sum + item.payment);

  /// 总利息。
  double get totalInterest =>
      periods.fold<double>(0, (sum, item) => sum + item.interest);

  /// 首期还款额。
  double get firstPayment => periods.isEmpty ? 0 : periods.first.payment;

  /// 末期还款额。
  double get lastPayment => periods.isEmpty ? 0 : periods.last.payment;

  /// 等额本息每月固定，等额本金逐月递减。
  bool get isFixedPayment => method == LoanMethod.equalInstallment;

  /// 利息占总还款的比例（0~1）。
  double get interestRatio =>
      totalPayment == 0 ? 0 : totalInterest / totalPayment;

  /// 按月汇总成「每年一行」，最后不足 12 期也算一行。
  ///
  /// 每行的 `principal`/`interest` 是该年合计，`payment` 是两者之和，
  /// `balance` 取该年最后一期还完后的剩余本金。
  List<LoanPeriod> get yearly {
    final result = <LoanPeriod>[];
    for (var start = 0; start < periods.length; start += loanPeriodsPerYear) {
      final end = (start + loanPeriodsPerYear).clamp(0, periods.length);
      final chunk = periods.sublist(start, end);
      result.add(
        LoanPeriod(
          index: result.length + 1,
          payment: chunk.fold<double>(0, (sum, item) => sum + item.payment),
          principal: chunk.fold<double>(0, (sum, item) => sum + item.principal),
          interest: chunk.fold<double>(0, (sum, item) => sum + item.interest),
          balance: chunk.last.balance,
        ),
      );
    }
    return result;
  }
}

/// 还款明细里每条金额条的相对长度（0~1），用于把明细画成倒梯形。
///
/// 规则：还款额最大的那一行（等额本金的首期）占满 100%，最小的一行
/// （末期）为 [floor]（默认 60%），中间的额度按还款金额线性插值，
/// 所以逐期递减的等额本金会自然拼成一个倒梯形；还款额恒定时（等额本息）
/// 每行都是满长。
List<double> scheduleBarRatios(List<LoanPeriod> rows, {double floor = 0.6}) {
  if (rows.isEmpty) return const <double>[];
  final safeFloor = floor.clamp(0.0, 1.0);
  final first = rows.first.payment;
  final last = rows.last.payment;
  final span = first - last;
  // 等额本息每期相等，只有末期抹平浮点误差带来的几分钱差异，
  // 相对差小于万分之一就当「没有落差」，整列满长。
  if (!span.isFinite || span.abs() <= first.abs() * 1e-4) {
    return List<double>.filled(rows.length, 1);
  }
  return <double>[
    for (final row in rows)
      (safeFloor + (1 - safeFloor) * (row.payment - last) / span).clamp(
        safeFloor,
        1.0,
      ),
  ];
}

/// 校验贷款参数是否可用。
bool _validLoanInput({
  required double amount,
  required double annualRatePercent,
  required int months,
}) {
  if (!amount.isFinite || amount <= 0) return false;
  if (!annualRatePercent.isFinite) return false;
  if (annualRatePercent.abs() > maxLoanRatePercent) return false;
  if (months < 1 || months > maxLoanMonths) return false;
  return true;
}

/// 等额本息的每月还款额。
///
/// `monthlyRate` 为月利率（小数），`months` 为总期数；月利率为 0 时退化为
/// 本金平均摊销。
double equalInstallmentPayment({
  required double amount,
  required double monthlyRate,
  required int months,
}) {
  if (months <= 0) return 0;
  if (monthlyRate == 0) return amount / months;
  final growth = _pow(1 + monthlyRate, months);
  return amount * monthlyRate * growth / (growth - 1);
}

/// 计算贷款还款计划；参数非法返回 null。
///
/// ```dart
/// calculateLoan(
///   amount: 1000000,
///   annualRatePercent: 4.9,
///   months: 360,
/// ); // 等额本息：月供 5307.27，总利息 910616.19
/// ```
LoanResult? calculateLoan({
  required double amount,
  required double annualRatePercent,
  required int months,
  LoanMethod method = LoanMethod.equalInstallment,
}) {
  if (!_validLoanInput(
    amount: amount,
    annualRatePercent: annualRatePercent,
    months: months,
  )) {
    return null;
  }

  final monthlyRate = annualRatePercent / 100 / loanPeriodsPerYear;
  final periods = <LoanPeriod>[];
  var balance = amount;

  switch (method) {
    case LoanMethod.equalInstallment:
      final payment = equalInstallmentPayment(
        amount: amount,
        monthlyRate: monthlyRate,
        months: months,
      );
      for (var i = 1; i <= months; i++) {
        final interest = balance * monthlyRate;
        // 最后一期把浮点误差抹平，保证本金正好还完
        final principal = i == months ? balance : payment - interest;
        balance -= principal;
        periods.add(
          LoanPeriod(
            index: i,
            payment: principal + interest,
            principal: principal,
            interest: interest,
            balance: balance.abs() < 1e-9 ? 0 : balance,
          ),
        );
      }
    case LoanMethod.equalPrincipal:
      final principal = amount / months;
      for (var i = 1; i <= months; i++) {
        final interest = balance * monthlyRate;
        final paid = i == months ? balance : principal;
        balance -= paid;
        periods.add(
          LoanPeriod(
            index: i,
            payment: paid + interest,
            principal: paid,
            interest: interest,
            balance: balance.abs() < 1e-9 ? 0 : balance,
          ),
        );
      }
  }

  return LoanResult(
    amount: amount,
    annualRatePercent: annualRatePercent,
    method: method,
    periods: List.unmodifiable(periods),
  );
}

/// 整数指数的快速幂，避免每月都调用 math.pow。
double _pow(double base, int exponent) {
  var result = 1.0;
  var factor = base;
  var power = exponent;
  while (power > 0) {
    if (power & 1 == 1) result *= factor;
    factor *= factor;
    power >>= 1;
  }
  return result;
}
