import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/tools/bmi.dart';
import 'package:free_clac/tools/compound.dart';
import 'package:free_clac/tools/interest.dart';
import 'package:free_clac/tools/loan.dart';

void main() {
  group('BMI：计算与分级', () {
    test('基本计算', () {
      final result = calculateBmi(heightCm: 170, weightKg: 65)!;
      expect(result.bmi, closeTo(22.49, 0.01));
      expect(result.category, BmiCategory.normal);
      expect(result.heightCm, 170);
    });

    test('身高支持米制输入', () {
      final result = calculateBmi(heightCm: 1.7, weightKg: 65)!;
      expect(result.heightCm, 170);
      expect(result.bmi, closeTo(22.49, 0.01));
    });

    test('分级边界（中国成人标准）', () {
      BmiCategory categoryOf(double bmi) =>
          calculateBmi(heightCm: 100, weightKg: bmi)!.category;

      expect(categoryOf(17), BmiCategory.underweight);
      expect(categoryOf(18.4), BmiCategory.underweight);
      expect(categoryOf(18.5), BmiCategory.normal);
      expect(categoryOf(23.9), BmiCategory.normal);
      expect(categoryOf(24), BmiCategory.overweight);
      expect(categoryOf(27.9), BmiCategory.overweight);
      expect(categoryOf(28), BmiCategory.obese);
      expect(categoryOf(40), BmiCategory.obese);
    });

    test('正常体重区间与建议', () {
      final result = calculateBmi(heightCm: 170, weightKg: 65)!;
      expect(result.healthyMinKg, closeTo(53.5, 0.1));
      expect(result.healthyMaxKg, closeTo(69.1, 0.1));
      expect(result.weightToHealthyCenter, closeTo(-4.3, 0.1));
      expect(result.advice, contains('正常范围'));

      final thin = calculateBmi(heightCm: 170, weightKg: 45)!;
      expect(thin.weightToHealthyCenter, greaterThan(0));
      expect(thin.advice, contains('偏低'));
    });

    test('非法输入返回 null', () {
      expect(calculateBmi(heightCm: 0, weightKg: 65), isNull);
      expect(calculateBmi(heightCm: 170, weightKg: 0), isNull);
      expect(calculateBmi(heightCm: -170, weightKg: 65), isNull);
      expect(calculateBmi(heightCm: 500, weightKg: 65), isNull);
    });
  });

  group('BMI：单位换算', () {
    test('英尺英寸与磅换算', () {
      expect(cmFromFeetInches(feet: 5, inches: 7), closeTo(170.18, 1e-9));
      expect(cmFromFeetInches(inches: 66.93), closeTo(170.0, 0.01));
      expect(kgFromPounds(143.3), closeTo(65.0, 0.01));
      expect(poundsFromKg(65), closeTo(143.3, 0.01));
      expect(poundsFromKg(kgFromPounds(180)), closeTo(180, 1e-9));
    });

    test('英制输入与公制结果等价', () {
      final imperial = calculateBmi(
        heightCm: cmFromFeetInches(feet: 5, inches: 7),
        weightKg: kgFromPounds(143.3),
      )!;
      // 5 ft 7 in ≈ 170.18 cm、143.3 lb ≈ 65 kg，BMI 应落在 22.44 附近
      final metric = calculateBmi(heightCm: 170.18, weightKg: 65)!;
      expect(imperial.bmi, closeTo(metric.bmi, 1e-3));
      expect(imperial.bmi, closeTo(22.44, 0.01));
      expect(imperial.category, BmiCategory.normal);
    });

    test('结果提供英制取值', () {
      final result = calculateBmi(heightCm: 170, weightKg: 65)!;
      expect(result.heightInches, closeTo(66.93, 0.01));
      expect(result.heightFeet, 5);
      expect(result.heightRemainderInches, closeTo(6.93, 0.01));
      expect(result.weightPounds, closeTo(143.3, 0.05));
      expect(
        result.healthyMinPounds,
        closeTo(result.healthyMinKg * 2.20462, 0.01),
      );
      expect(
        result.weightToHealthyCenterPounds,
        closeTo(result.weightToHealthyCenter * 2.20462, 0.01),
      );
    });

    test('英尺 / 英寸单值换算与双向转换', () {
      expect(cmFromFeet(5.5), closeTo(167.64, 1e-9));
      expect(cmFromInches(67), closeTo(170.18, 1e-9));
      expect(feetFromCm(170.18), closeTo(5.5833, 0.0001));
      expect(inchesFromCm(170.18), closeTo(67.0, 1e-9));
      // 往返回原值（输入框保留两位小数）
      expect(inchesFromCm(cmFromFeet(5.58)), closeTo(66.96, 1e-9));
      expect(feetFromCm(cmFromInches(66.96)), closeTo(5.58, 1e-9));
    });

    test('英制身高单位可切换', () {
      expect(BmiImperialHeightUnit.feet.symbol, 'ft');
      expect(BmiImperialHeightUnit.inches.symbol, 'in');
      expect(BmiImperialHeightUnit.feet.other, BmiImperialHeightUnit.inches);
      expect(BmiImperialHeightUnit.inches.other, BmiImperialHeightUnit.feet);
      expect(BmiImperialHeightUnit.feet.label, '英尺');
    });

    test('单位枚举带中文标签', () {
      expect(BmiUnitSystem.metric.label, '公制');
      expect(BmiUnitSystem.imperial.label, '英制');
    });
  });

  group('复利：按年计息', () {
    CompoundResult calculate({
      double principal = 100000,
      double rate = 5,
      double years = 10,
      CompoundFrequency frequency = CompoundFrequency.yearly,
      double contribution = 0,
    }) {
      final result = compoundInterest(
        CompoundInput(
          principal: principal,
          annualRatePercent: rate,
          years: years,
          frequency: frequency,
          contributionPerPeriod: contribution,
        ),
      );
      expect(result, isNotNull, reason: '参数应合法');
      return result!;
    }

    test('整存整取 10 年 5%', () {
      final result = calculate();
      expect(result.futureValue, closeTo(162889.46, 0.01));
      expect(result.totalInvested, 100000);
      expect(result.totalGain, closeTo(62889.46, 0.01));
      expect(result.gainRate, closeTo(0.6289, 0.001));
      expect(result.effectiveAnnualRatePercent, closeTo(5, 1e-9));
    });

    test('按月计息收益更高', () {
      final monthly = calculate(frequency: CompoundFrequency.monthly);
      expect(monthly.futureValue, closeTo(164700.95, 0.01));
      expect(monthly.periods, 120);
      expect(monthly.effectiveAnnualRatePercent, closeTo(5.1162, 0.001));
      expect(
        monthly.futureValue,
        greaterThan(calculate().futureValue),
        reason: '复利频率越高收益越高',
      );
    });

    test('定期追加投入（年金）', () {
      final result = calculate(contribution: 1000);
      // 100000×1.05^10 + 1000×((1.05^10−1)/0.05)
      expect(result.futureValue, closeTo(175467.35, 0.01));
      expect(result.contributions, 10000);
      expect(result.totalInvested, 110000);
      expect(result.totalGain, closeTo(65467.35, 0.01));
    });

    test('零利率只累计本金', () {
      final result = calculate(rate: 0, contribution: 1000);
      expect(result.futureValue, 110000);
      expect(result.effectiveAnnualRatePercent, 0);
    });

    test('负利率会亏损', () {
      final result = calculate(rate: -10, years: 5);
      expect(result.futureValue, closeTo(59049, 0.01));
      expect(result.totalGain, lessThan(0));
      expect(result.gainRate, lessThan(0));
    });

    test('逐年表格与到期金额一致', () {
      final result = calculate(years: 10);
      expect(result.yearly.length, 10);
      expect(result.yearly.first.year, 1);
      expect(result.yearly.first.balance, closeTo(105000, 0.01));
      expect(result.yearly.last.balance, closeTo(result.futureValue, 0.01));
      expect(result.yearly.last.gain, closeTo(62889.46, 0.01));
    });

    test('小数年限可用，逐年表格截断到整数年', () {
      final result = calculate(years: 2.5);
      expect(result.futureValue, closeTo(112972.63, 0.01));
      expect(result.yearly.length, 2);
    });

    test('非法参数返回 null', () {
      CompoundResult? run({double years = 10, double principal = 100}) =>
          compoundInterest(
            CompoundInput(
              principal: principal,
              annualRatePercent: 5,
              years: years,
            ),
          );

      expect(run(years: 0), isNull);
      expect(run(years: -1), isNull);
      expect(run(principal: -1), isNull);
      expect(
        compoundInterest(
          const CompoundInput(
            principal: 100,
            annualRatePercent: -100,
            years: 5,
          ),
        ),
        isNull,
      );
      expect(
        compoundInterest(
          const CompoundInput(
            principal: 100,
            annualRatePercent: 5,
            years: 5,
            contributionPerPeriod: -10,
          ),
        ),
        isNull,
      );
    });
  });

  group('利率：期付 ⇄ 年化', () {
    test('周期定义', () {
      expect(InterestPeriod.daily.periodsPerYear, 365);
      expect(InterestPeriod.monthly.periodsPerYear, 12);
      expect(InterestPeriod.yearly.periodsPerYear, 1);
      expect(InterestPeriod.daily.label, '日付');
      expect(InterestPeriod.monthly.everyLabel, '每月');
      expect(InterestPeriod.yearly.everyLabel, '每年');
    });

    test('本金 + 期付反推年化率', () {
      double? rate(double payment, InterestPeriod period) =>
          annualRatePercentFromPayment(
            principal: 10000,
            payment: payment,
            period: period,
          );

      expect(rate(1, InterestPeriod.daily), closeTo(3.65, 1e-9));
      expect(rate(50, InterestPeriod.monthly), closeTo(6, 1e-9));
      expect(rate(500, InterestPeriod.yearly), closeTo(5, 1e-9));
      // 同一笔钱：1 元 / 天 = 30 元 / 月 ≈ 365 元 / 年
      expect(rate(30.4166666, InterestPeriod.monthly), closeTo(3.65, 1e-6));
      expect(rate(365, InterestPeriod.yearly), closeTo(3.65, 1e-9));
    });

    test('年化率算各周期收益', () {
      double? pay(double rate, InterestPeriod period) => paymentFromAnnualRate(
        principal: 10000,
        annualRatePercent: rate,
        period: period,
      );

      expect(pay(3.65, InterestPeriod.daily), closeTo(1, 1e-12));
      expect(pay(3.65, InterestPeriod.monthly), closeTo(30.4166667, 1e-6));
      expect(pay(3.65, InterestPeriod.yearly), closeTo(365, 1e-12));
    });

    test('双向换算互为反函数', () {
      for (final period in InterestPeriod.values) {
        for (final payment in [0.5, 1.0, 12.5, 100.0]) {
          final rate = annualRatePercentFromPayment(
            principal: 20000,
            payment: payment,
            period: period,
          )!;
          final back = paymentFromAnnualRate(
            principal: 20000,
            annualRatePercent: rate,
            period: period,
          )!;
          expect(back, closeTo(payment, 1e-9));
        }
      }
    });

    test('报价：三档收益与万份收益', () {
      final quote = interestQuote(principal: 10000, annualRatePercent: 3.65)!;
      expect(quote.annualRate, closeTo(0.0365, 1e-12));
      expect(quote.dailyPayment, closeTo(1, 1e-12));
      expect(quote.monthlyPayment, closeTo(30.4166667, 1e-6));
      expect(quote.yearlyPayment, closeTo(365, 1e-12));
      expect(quote.rateFor(InterestPeriod.daily), closeTo(0.0001, 1e-12));
      expect(
        quote.paymentPerTenThousand(InterestPeriod.daily),
        closeTo(1, 1e-12),
      );
      // 本金 5 万时万份收益与本金无关
      final bigger = interestQuote(principal: 50000, annualRatePercent: 3.65)!;
      expect(
        bigger.paymentPerTenThousand(InterestPeriod.monthly),
        closeTo(quote.paymentPerTenThousand(InterestPeriod.monthly), 1e-9),
      );
      expect(bigger.monthlyPayment, closeTo(quote.monthlyPayment * 5, 1e-9));
    });

    test('零利率与负利率', () {
      final zero = interestQuote(principal: 1000, annualRatePercent: 0)!;
      expect(zero.dailyPayment, 0);
      expect(zero.yearlyPayment, 0);

      final negative = interestQuote(principal: 1000, annualRatePercent: -5)!;
      expect(negative.yearlyPayment, closeTo(-50, 1e-12));
      expect(
        annualRatePercentFromPayment(
          principal: 1000,
          payment: -0.1,
          period: InterestPeriod.daily,
        ),
        closeTo(-3.65, 1e-9),
      );
    });

    test('非法参数返回 null', () {
      expect(
        annualRatePercentFromPayment(
          principal: 0,
          payment: 1,
          period: InterestPeriod.daily,
        ),
        isNull,
      );
      expect(
        annualRatePercentFromPayment(
          principal: 10000,
          payment: 1,
          period: InterestPeriod.daily,
        ),
        isNotNull,
      );
      expect(
        paymentFromAnnualRate(
          principal: -100,
          annualRatePercent: 5,
          period: InterestPeriod.daily,
        ),
        isNull,
      );
      // 年化率超过 1000% 视为输入错误
      expect(
        paymentFromAnnualRate(
          principal: 100,
          annualRatePercent: 1001,
          period: InterestPeriod.daily,
        ),
        isNull,
      );
      expect(
        annualRatePercentFromPayment(
          principal: 1,
          payment: 1000,
          period: InterestPeriod.yearly,
        ),
        isNull,
      );
      expect(
        interestQuote(principal: double.infinity, annualRatePercent: 5),
        isNull,
      );
      expect(
        annualRatePercentFromPayment(
          principal: 100,
          payment: double.nan,
          period: InterestPeriod.daily,
        ),
        isNull,
      );
    });
  });

  group('贷款：等额本息 / 等额本金', () {
    LoanResult calculate({
      double amount = 1000000,
      double rate = 4.9,
      int months = 360,
      LoanMethod method = LoanMethod.equalInstallment,
    }) {
      final result = calculateLoan(
        amount: amount,
        annualRatePercent: rate,
        months: months,
        method: method,
      );
      expect(result, isNotNull, reason: '参数应合法');
      return result!;
    }

    test('等额本息：月供、总利息与总还款', () {
      final result = calculate();
      expect(result.months, 360);
      expect(result.isFixedPayment, isTrue);
      expect(result.firstPayment, closeTo(5307.27, 0.01));
      expect(result.lastPayment, closeTo(5307.27, 0.05));
      expect(result.totalInterest, closeTo(910616.19, 0.5));
      expect(result.totalPayment, closeTo(1910616.19, 0.5));
      expect(result.interestRatio, closeTo(0.4766, 0.001));
    });

    test('等额本息：每期本金递增、利息递减', () {
      final periods = calculate().periods;
      expect(periods.first.interest, greaterThan(periods.first.principal));
      expect(periods.last.principal, greaterThan(periods.last.interest));
      for (var i = 1; i < periods.length; i++) {
        expect(
          periods[i].principal,
          greaterThan(periods[i - 1].principal),
          reason: '等额本息前期本金少、逐期递增',
        );
        expect(periods[i].interest, lessThan(periods[i - 1].interest));
        expect(
          periods[i].payment,
          closeTo(periods.first.payment, 1e-6),
          reason: '每期还款额固定',
        );
      }
    });

    test('每期本金之和等于贷款总额，余额归零', () {
      for (final method in LoanMethod.values) {
        final result = calculate(method: method);
        final principal = result.periods.fold<double>(
          0,
          (sum, item) => sum + item.principal,
        );
        expect(principal, closeTo(1000000, 0.01));
        expect(result.periods.last.balance, 0);
        final payment = result.periods.fold<double>(
          0,
          (sum, item) => sum + item.payment,
        );
        expect(payment, closeTo(result.totalPayment, 1e-6));
      }
    });

    test('等额本金：首末期还款与总利息', () {
      final result = calculate(method: LoanMethod.equalPrincipal);
      expect(result.isFixedPayment, isFalse);
      expect(result.firstPayment, closeTo(6861.11, 0.01));
      expect(result.lastPayment, closeTo(2789.12, 0.01));
      expect(result.totalInterest, closeTo(737041.67, 0.5));
      // 等额本金总利息一定比等额本息少
      expect(result.totalInterest, lessThan(calculate().totalInterest));
      // 本金平均摊销，每期固定
      expect(result.periods.first.principal, closeTo(2777.78, 0.01));
      expect(result.periods.last.principal, closeTo(2777.78, 0.01));
    });

    test('期数随期限变化', () {
      expect(calculate(months: 120).firstPayment, closeTo(10557.74, 0.01));
      expect(calculate(months: 240).firstPayment, closeTo(6544.44, 0.01));
      expect(calculate(months: 12).months, 12);
    });

    test('零利率时只有本金', () {
      final result = calculate(rate: 0, months: 12);
      expect(result.totalInterest, 0);
      expect(result.firstPayment, closeTo(1000000 / 12, 1e-9));
      expect(result.periods.first.interest, 0);
      expect(result.interestRatio, 0);
    });

    test('按年汇总', () {
      final result = calculate(months: 360);
      final yearly = result.yearly;
      expect(yearly.length, 30);
      expect(yearly.first.index, 1);
      expect(
        yearly.first.payment,
        closeTo(
          result.periods.take(12).fold(0.0, (s, p) => s + p.payment),
          1e-6,
        ),
      );
      expect(
        yearly.fold<double>(0, (sum, item) => sum + item.principal),
        closeTo(1000000, 0.01),
      );
      expect(yearly.last.balance, 0);
      // 最后不足 12 期的按一行算
      expect(calculate(months: 25).yearly.length, 3);
    });

    test('期限单位换算', () {
      expect(LoanTermUnit.years.toMonths(30), 360);
      expect(LoanTermUnit.months.toMonths(360), 360);
      expect(LoanTermUnit.years.toMonths(1.5), 18);
      expect(LoanTermUnit.years.label, '年');
      expect(LoanMethod.equalInstallment.label, '等额本息');
      expect(LoanMethod.equalPrincipal.label, '等额本金');
    });

    test('双色条比例之和为 1', () {
      final period = calculate(method: LoanMethod.equalPrincipal).periods.first;
      expect(period.principalRatio, closeTo(1 - period.interestRatio, 1e-12));
      expect(period.principalRatio, inInclusiveRange(0, 1));
      expect(period.interestRatio, inInclusiveRange(0, 1));
    });

    test('非法参数返回 null', () {
      LoanResult? run({
        double amount = 1000000,
        double rate = 4.9,
        int months = 360,
      }) => calculateLoan(
        amount: amount,
        annualRatePercent: rate,
        months: months,
      );

      expect(run(amount: 0), isNull);
      expect(run(amount: -100), isNull);
      expect(run(months: 0), isNull);
      expect(run(months: -12), isNull);
      expect(run(months: maxLoanMonths + 1), isNull);
      expect(run(rate: maxLoanRatePercent + 1), isNull);
      expect(run(rate: double.nan), isNull);
      expect(run(amount: double.infinity), isNull);
    });
  });
}
