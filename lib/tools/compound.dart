/// 复利计算，纯逻辑，不依赖 Flutter。
library;

import 'dart:math' as math;

/// 复利频率（每年计息次数）。
enum CompoundFrequency {
  yearly('每年', 1),
  semiannual('每半年', 2),
  quarterly('每季度', 4),
  monthly('每月', 12),
  daily('每日', 365);

  const CompoundFrequency(this.label, this.periodsPerYear);

  final String label;
  final int periodsPerYear;
}

/// 复利输入参数。
class CompoundInput {
  const CompoundInput({
    required this.principal,
    required this.annualRatePercent,
    required this.years,
    this.frequency = CompoundFrequency.yearly,
    this.contributionPerPeriod = 0,
  });

  /// 期初本金。
  final double principal;

  /// 年利率，按百分比传入（5 表示 5%）。
  final double annualRatePercent;

  /// 投资年限，可以是小数。
  final double years;

  final CompoundFrequency frequency;

  /// 每个计息周期追加的金额（默认 0）。
  final double contributionPerPeriod;
}

/// 某一年年末的账户情况。
class CompoundYearPoint {
  const CompoundYearPoint({
    required this.year,
    required this.balance,
    required this.contributions,
  });

  final int year;

  /// 年末余额。
  final double balance;

  /// 累计投入（本金 + 追加）。
  final double contributions;

  /// 累计收益。
  double get gain => balance - contributions;
}

/// 复利计算结果。
class CompoundResult {
  const CompoundResult({
    required this.futureValue,
    required this.principal,
    required this.contributions,
    required this.frequency,
    required this.periods,
    required this.effectiveAnnualRatePercent,
    required this.yearly,
  });

  /// 到期本息合计。
  final double futureValue;

  /// 期初本金。
  final double principal;

  /// 追加投入总额（不含本金）。
  final double contributions;

  final CompoundFrequency frequency;

  /// 总计息周期数（可能为小数）。
  final double periods;

  /// 有效年利率（百分比）。
  final double effectiveAnnualRatePercent;

  /// 逐年数据（最多 50 年）。
  final List<CompoundYearPoint> yearly;

  /// 总投入 = 本金 + 追加。
  double get totalInvested => principal + contributions;

  /// 总收益。
  double get totalGain => futureValue - totalInvested;

  /// 收益率（收益 / 总投入），总投入为 0 时返回 0。
  double get gainRate => totalInvested == 0 ? 0 : totalGain / totalInvested;
}

/// 按复利公式计算结果；参数不合法时返回 null。
///
/// * 本金、追加金额、年限不可为负，年限必须大于 0；
/// * 年利率需大于 -100%（-100% 会让本金直接归零，后续周期无意义）。
CompoundResult? compoundInterest(CompoundInput input) {
  final ratePercent = input.annualRatePercent;
  if (input.principal < 0 ||
      input.contributionPerPeriod < 0 ||
      input.years <= 0 ||
      ratePercent <= -100 ||
      !ratePercent.isFinite) {
    return null;
  }

  final m = input.frequency.periodsPerYear;
  final rate = ratePercent / 100;
  final periodRate = rate / m;
  final periods = input.years * m;

  double balanceAt(double t) {
    final n = t * m;
    if (periodRate == 0) {
      return input.principal + input.contributionPerPeriod * n;
    }
    final growth = _pow(1 + periodRate, n);
    final annuity = (growth - 1) / periodRate;
    return input.principal * growth + input.contributionPerPeriod * annuity;
  }

  final futureValue = balanceAt(input.years);
  final contributions = input.contributionPerPeriod * periods;
  final effectiveAnnualRate = (_pow(1 + periodRate, m.toDouble()) - 1) * 100;

  final yearly = <CompoundYearPoint>[];
  final wholeYears = input.years.floor().clamp(0, 50);
  for (var year = 1; year <= wholeYears; year++) {
    yearly.add(
      CompoundYearPoint(
        year: year,
        balance: balanceAt(year.toDouble()),
        contributions:
            input.principal + input.contributionPerPeriod * (year * m),
      ),
    );
  }

  return CompoundResult(
    futureValue: futureValue,
    principal: input.principal,
    contributions: contributions,
    frequency: input.frequency,
    periods: periods,
    effectiveAnnualRatePercent: effectiveAnnualRate,
    yearly: List.unmodifiable(yearly),
  );
}

/// 幂运算：`1.05^10` 之类的复利增长。
double _pow(double base, double exponent) =>
    math.pow(base, exponent).toDouble();
