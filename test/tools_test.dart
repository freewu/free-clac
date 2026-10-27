import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/tools/area.dart';
import 'package:free_clac/tools/bmi.dart';
import 'package:free_clac/tools/compound.dart';
import 'package:free_clac/tools/distance.dart';
import 'package:free_clac/tools/interest.dart';
import 'package:free_clac/tools/loan.dart';
import 'package:free_clac/tools/speed.dart';
import 'package:free_clac/tools/tax.dart';
import 'package:free_clac/tools/temperature.dart';
import 'package:free_clac/tools/unit_catalog.dart';
import 'package:free_clac/tools/volume.dart';
import 'package:free_clac/tools/weight.dart';

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

    test('明细条长：等额本金首期 100%、末期 60%，中间按金额缩放', () {
      final result = calculate(method: LoanMethod.equalPrincipal);
      final rows = result.periods;
      final ratios = scheduleBarRatios(rows);

      expect(ratios.length, rows.length);
      expect(ratios.first, closeTo(1, 1e-9));
      expect(ratios.last, closeTo(0.6, 1e-9));
      // 逐期变短 → 倒梯形
      for (var i = 1; i < ratios.length; i++) {
        expect(ratios[i], lessThan(ratios[i - 1]));
      }

      // 中间各期按还款额线性插值，而不是等步长
      const mid = 180;
      final expected =
          0.6 +
          0.4 *
              (rows[mid].payment - rows.last.payment) /
              (rows.first.payment - rows.last.payment);
      expect(ratios[mid], closeTo(expected, 1e-9));
      expect(ratios[mid], inExclusiveRange(0.6, 1));

      // 按年汇总同样是倒梯形
      final yearly = scheduleBarRatios(result.yearly);
      expect(yearly.first, closeTo(1, 1e-9));
      expect(yearly.last, closeTo(0.6, 1e-9));
    });

    test('明细条长：等额本息每期满长，空列表安全', () {
      final result = calculate();
      expect(scheduleBarRatios(result.periods), everyElement(closeTo(1, 1e-9)));
      expect(scheduleBarRatios(<LoanPeriod>[]), isEmpty);
      // 自定义下限
      final tapered = scheduleBarRatios(
        calculate(method: LoanMethod.equalPrincipal).periods,
        floor: 0.4,
      );
      expect(tapered.first, closeTo(1, 1e-9));
      expect(tapered.last, closeTo(0.4, 1e-9));
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

  group('个税：五险一金与累计预扣', () {
    PayrollResult calculate({
      double gross = 20000,
      double? base,
      InsuranceRates? rates,
      double special = 0,
    }) {
      final result = calculatePayroll(
        PayrollPlan(
          grossMonthly: gross,
          contributionBase: base ?? gross,
          rates: rates ?? InsuranceRates.defaults(),
          specialDeductionMonthly: special,
        ),
      );
      expect(result, isNotNull, reason: '参数应合法');
      return result!;
    }

    test('默认比例：养老 8 / 医疗 2 / 失业 0.5 / 公积金 12', () {
      final rates = InsuranceRates.defaults();
      expect(rates.of(InsuranceItem.pension), 8);
      expect(rates.of(InsuranceItem.medical), 2);
      expect(rates.of(InsuranceItem.unemployment), 0.5);
      expect(rates.of(InsuranceItem.housingFund), 12);
      expect(rates.totalPercent, 22.5);
      expect(rates.socialSecurityPercent, 10.5);
      expect(InsuranceItem.housingFund.isSocialSecurity, isFalse);
      expect(InsuranceItem.pension.label, '养老');
      // 改一项不影响其它项
      expect(rates.withRate(InsuranceItem.housingFund, 5).totalPercent, 15.5);
    });

    test('2 万月薪：五险一金、首月个税与全年到手', () {
      final result = calculate();
      expect(result.contributionMonthly, closeTo(4500, 1e-9));
      expect(result.socialSecurityMonthly, closeTo(2100, 1e-9));
      expect(result.housingFundMonthly, closeTo(2400, 1e-9));
      expect(result.firstMonthTax, closeTo(315, 1e-9));
      expect(result.firstMonthNet, closeTo(15185, 1e-9));
      expect(result.yearlyTax, closeTo(10080, 1e-9));
      expect(result.yearlyNet, closeTo(175920, 1e-9));
      expect(result.yearlyGross, closeTo(240000, 1e-9));
      expect(result.marginalRatePercent, 10);
    });

    test('累计预扣法：跨档月份个税跳升', () {
      final months = calculate().months;
      expect(months.length, 12);
      // 1~3 月还在 3% 档，4 月补差额，5 月起稳定在 10%
      expect(months[0].tax, closeTo(315, 1e-9));
      expect(months[2].tax, closeTo(315, 1e-9));
      expect(months[3].tax, closeTo(735, 1e-9));
      expect(months[4].tax, closeTo(1050, 1e-9));
      expect(months[11].tax, closeTo(1050, 1e-9));
      // 每月个税之和等于全年个税，累计值单调不减
      expect(
        months.fold<double>(0, (sum, month) => sum + month.tax),
        closeTo(10080, 1e-9),
      );
      for (var i = 1; i < months.length; i++) {
        expect(
          months[i].cumulativeTax,
          greaterThanOrEqualTo(months[i - 1].cumulativeTax),
        );
        expect(
          months[i].net,
          closeTo(
            months[i].gross - months[i].contribution - months[i].tax,
            1e-9,
          ),
        );
      }
      expect(months.last.cumulativeTax, closeTo(10080, 1e-9));
      expect(maxMonthlyTaxOf(months), closeTo(1050, 1e-9));
    });

    test('5 万月薪进入 20% 档', () {
      final result = calculate(gross: 50000);
      expect(result.contributionMonthly, closeTo(11250, 1e-9));
      expect(result.firstMonthTax, closeTo(1012.5, 1e-9));
      expect(result.yearlyTax, closeTo(69330, 1e-9));
      // 年应纳税所得额 405000 落在 25% 档
      expect(result.marginalRatePercent, 25);
    });

    test('低薪不缴个税', () {
      final result = calculate(gross: 6000);
      expect(result.yearlyTax, 0);
      expect(result.firstMonthTax, 0);
      expect(result.firstMonthNet, closeTo(4650, 1e-9));
      expect(result.marginalRatePercent, 3);
    });

    test('专项附加扣除与缴费基数都会影响个税', () {
      final plain = calculate();
      final withSpecial = calculate(special: 3000);
      expect(withSpecial.yearlyTax, lessThan(plain.yearlyTax));
      expect(withSpecial.firstMonthTax, closeTo(225, 1e-9));

      final lowBase = calculate(base: 10000);
      expect(lowBase.contributionMonthly, closeTo(2250, 1e-9));
      expect(lowBase.yearlyTax, greaterThan(plain.yearlyTax));

      // 不缴公积金 → 五险一金少 2400，个税多，到手反而更多（公积金也是自己的钱）
      final noFund = calculate(
        rates: InsuranceRates.defaults().withRate(InsuranceItem.housingFund, 0),
      );
      expect(noFund.contributionMonthly, closeTo(2100, 1e-9));
      expect(noFund.firstMonthTax, closeTo(387, 1e-9));
      expect(noFund.firstMonthNet, greaterThan(plain.firstMonthNet));
    });

    test('税率表边界与档位', () {
      expect(yearlyIncomeTax(0), 0);
      expect(yearlyIncomeTax(-100), 0);
      expect(yearlyIncomeTax(36000), closeTo(1080, 1e-9));
      expect(yearlyIncomeTax(36001), closeTo(1080.1, 1e-9));
      expect(yearlyIncomeTax(144000), closeTo(11880, 1e-9));
      expect(yearlyIncomeTax(960000), closeTo(250080, 1e-9));
      expect(yearlyIncomeTax(1000000), closeTo(268080, 1e-9));
      expect(bracketOf(36000).ratePercent, 3);
      expect(bracketOf(40000).ratePercent, 10);
      expect(bracketOf(200000).ratePercent, 20);
      expect(bracketOf(500000).ratePercent, 30);
      expect(bracketOf(double.infinity).ratePercent, 45);
      expect(kTaxBrackets.length, 7);
    });

    test('非法参数返回 null', () {
      PayrollResult? run({
        double gross = 20000,
        double base = 20000,
        InsuranceRates? rates,
        double special = 0,
      }) => calculatePayroll(
        PayrollPlan(
          grossMonthly: gross,
          contributionBase: base,
          rates: rates ?? InsuranceRates.defaults(),
          specialDeductionMonthly: special,
        ),
      );

      expect(run(gross: 0), isNull);
      expect(run(gross: -1000), isNull);
      expect(run(base: -1), isNull);
      expect(run(special: -1), isNull);
      expect(run(gross: double.nan), isNull);
      expect(run(gross: double.infinity), isNull);
      // 比例超过 100% 或合计超过 100%
      expect(
        run(
          rates: InsuranceRates.defaults().withRate(InsuranceItem.pension, 120),
        ),
        isNull,
      );
      final overTotal = InsuranceRates({
        for (final item in InsuranceItem.values) item: 40,
      });
      expect(run(rates: overTotal), isNull);
      // 五险一金比月薪还多
      expect(run(gross: 1000, base: 10000), isNull);
    });
  });

  group('长度：公制 / 英制 / 市制换算', () {
    DistanceUnit unit(String id) => distanceUnitById(id)!;

    double? convert(double value, String from, String to) =>
        convertDistance(value, from: unit(from), to: unit(to));

    test('单位表：三个体系共 25 个单位，id 唯一', () {
      expect(kDistanceUnits.length, 25);
      expect(distanceUnitsOf(DistanceSystem.metric).length, 9);
      expect(distanceUnitsOf(DistanceSystem.imperial).length, 7);
      expect(distanceUnitsOf(DistanceSystem.chinese).length, 9);
      expect(
        kDistanceUnits.map((item) => item.id).toSet().length,
        kDistanceUnits.length,
      );
      expect(distanceUnitById('nope'), isNull);
      for (final item in kDistanceUnits) {
        expect(item.meters.isFinite && item.meters > 0, isTrue);
      }
    });

    test('公制内部换算', () {
      expect(convert(1, 'km', 'm'), closeTo(1000, 1e-12));
      expect(convert(1, 'm', 'cm'), closeTo(100, 1e-12));
      expect(convert(1, 'm', 'mm'), closeTo(1000, 1e-12));
      expect(convert(1, 'mm', 'um'), closeTo(1000, 1e-12));
      expect(convert(1, 'um', 'nm'), closeTo(1000, 1e-12));
      expect(convert(1, 'nm', 'pm'), closeTo(1000, 1e-12));
      expect(convert(1, 'm', 'dm'), closeTo(10, 1e-12));
      // 海里归在公制里（1852 米）
      expect(convert(1, 'nmile', 'm'), closeTo(1852, 1e-12));
    });

    test('英制内部与跨体系换算', () {
      expect(convert(1, 'foot', 'inch'), closeTo(12, 1e-12));
      expect(convert(1, 'yard', 'foot'), closeTo(3, 1e-12));
      expect(convert(1, 'mile', 'yard'), closeTo(1760, 1e-12));
      expect(convert(1, 'chain', 'foot'), closeTo(66, 1e-12));
      expect(convert(1, 'furlong', 'chain'), closeTo(10, 1e-12));
      expect(convert(1, 'mile', 'm'), closeTo(1609.344, 1e-9));
      expect(convert(1, 'inch', 'cm'), closeTo(2.54, 1e-12));
      expect(convert(1, 'foot', 'm'), closeTo(0.3048, 1e-12));
    });

    test('市制：1 尺 = 1/3 米', () {
      expect(convert(1, 'li', 'm'), closeTo(500, 1e-12));
      expect(convert(1, 'li', 'chi'), closeTo(1500, 1e-9));
      expect(convert(1, 'yin', 'm'), closeTo(500 / 15, 1e-12));
      expect(convert(1, 'zhang', 'chi'), closeTo(10, 1e-12));
      expect(convert(1, 'chi', 'm'), closeTo(1 / 3, 1e-12));
      expect(convert(1, 'cun', 'chi'), closeTo(0.1, 1e-12));
      expect(convert(1, 'fen', 'cun'), closeTo(0.1, 1e-12));
      expect(convert(1, 'li2', 'fen'), closeTo(0.1, 1e-12));
      expect(convert(1, 'hao', 'li2'), closeTo(0.1, 1e-12));
      expect(convert(1, 'si', 'hao'), closeTo(0.1, 1e-12));
      // 市制 ↔ 公制：3 尺 = 1 米
      expect(convert(3, 'chi', 'm'), closeTo(1, 1e-12));
      expect(convert(1, 'm', 'cun'), closeTo(30, 1e-9));
    });

    test('任意两个单位互为反函数', () {
      for (final from in kDistanceUnits) {
        for (final to in kDistanceUnits) {
          final forward = convertDistance(2.5, from: from, to: to)!;
          final back = convertDistance(forward, from: to, to: from)!;
          expect(back, closeTo(2.5, 1e-9), reason: '$from -> $to');
        }
      }
    });

    test('非法输入', () {
      expect(convert(double.nan, 'm', 'cm'), isNull);
      expect(convert(double.infinity, 'm', 'cm'), isNull);
      expect(convert(double.negativeInfinity, 'm', 'cm'), isNull);
    });

    test('参照物都指向真实单位', () {
      expect(kDistanceSamples, isNotEmpty);
      for (final sample in kDistanceSamples) {
        expect(
          kLengthCatalog.unitOfSample(sample),
          isNotNull,
          reason: sample.label,
        );
        expect(sample.value > 0, isTrue);
      }
      // 1 光年按 9.46 万亿千米
      final lightYear = kDistanceSamples.firstWhere(
        (sample) => sample.label == '1 光年',
      );
      expect(
        convertDistance(
          lightYear.value,
          from: kLengthCatalog.unitOfSample(lightYear)!,
          to: unit('m'),
        ),
        closeTo(9.4607304725808e15, 1e9),
      );
    });
  });
  group('单位换算：面积 / 容量 / 重量 / 温度 / 速度', () {
    /// 用单位 id 换算，测试里少写样板。
    double? swap(
      MeasureCatalog catalog,
      double value,
      String from,
      String to,
    ) => catalog.convert(
      value,
      from: catalog.unitById(from)!,
      to: catalog.unitById(to)!,
    );

    test('面积：1 公顷 = 15 亩，1 英亩 ≈ 4046.86 平方米', () {
      expect(swap(kAreaCatalog, 1, 'ha', 'sqm'), closeTo(10000, 1e-9));
      expect(swap(kAreaCatalog, 1, 'ha', 'mu'), closeTo(15, 1e-9));
      expect(swap(kAreaCatalog, 1, 'mu', 'sqm'), closeTo(2000 / 3, 1e-9));
      expect(swap(kAreaCatalog, 1, 'qing', 'mu'), closeTo(100, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqzhang', 'sqchi'), closeTo(100, 1e-9));
      expect(swap(kAreaCatalog, 1, 'acre', 'sqm'), closeTo(4046.8564224, 1e-6));
      expect(swap(kAreaCatalog, 1, 'sqmi', 'acre'), closeTo(640, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqft', 'sqin'), closeTo(144, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqm', 'sqcm'), closeTo(10000, 1e-9));
      expect(swap(kAreaCatalog, 1, 'sqkm', 'ha'), closeTo(100, 1e-9));
      // A4 纸 0.06237 平方米 = 623.7 平方厘米
      expect(swap(kAreaCatalog, 0.06237, 'sqm', 'sqcm'), closeTo(623.7, 1e-9));
    });

    test('容量：1 英制加仑 = 4.54609 升，1 石 = 100 升', () {
      expect(swap(kVolumeCatalog, 1, 'm3', 'l'), closeTo(1000, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'm3', 'ml'), closeTo(1e6, 1e-6));
      expect(swap(kVolumeCatalog, 1, 'l', 'ml'), closeTo(1000, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'gal', 'l'), closeTo(4.54609, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'gal', 'pt'), closeTo(8, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'gal', 'floz'), closeTo(160, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'pt', 'floz'), closeTo(20, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'bu', 'gal'), closeTo(8, 1e-9));
      expect(swap(kVolumeCatalog, 1, 'dan', 'dou'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'dou', 'sheng'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'ge', 'shao'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 1, 'shao', 'ml'), closeTo(10, 1e-12));
      expect(swap(kVolumeCatalog, 550, 'ml', 'l'), closeTo(0.55, 1e-12));
    });

    test('重量：1 磅 = 0.45359237 千克，1 斤 = 500 克', () {
      expect(swap(kWeightCatalog, 1, 't', 'kg'), closeTo(1000, 1e-9));
      expect(swap(kWeightCatalog, 1, 'kg', 'mg'), closeTo(1e6, 1e-6));
      expect(swap(kWeightCatalog, 1, 'lb', 'kg'), closeTo(0.45359237, 1e-12));
      expect(swap(kWeightCatalog, 1, 'lb', 'oz'), closeTo(16, 1e-9));
      expect(swap(kWeightCatalog, 1, 'st', 'lb'), closeTo(14, 1e-9));
      expect(swap(kWeightCatalog, 1, 'longton', 'lb'), closeTo(2240, 1e-6));
      expect(swap(kWeightCatalog, 1, 'shortton', 'lb'), closeTo(2000, 1e-6));
      expect(swap(kWeightCatalog, 1, 'jin', 'g'), closeTo(500, 1e-9));
      expect(swap(kWeightCatalog, 1, 'jin', 'lb'), closeTo(1.1023113109, 1e-9));
      expect(swap(kWeightCatalog, 1, 'dan', 'jin'), closeTo(100, 1e-9));
      expect(swap(kWeightCatalog, 1, 'liang', 'qian'), closeTo(10, 1e-9));
      expect(swap(kWeightCatalog, 65, 'kg', 'jin'), closeTo(130, 1e-9));
    });

    test('温度：仿射换算（含零点偏移）', () {
      expect(swap(kTemperatureCatalog, 0, 'c', 'f'), closeTo(32, 1e-9));
      expect(swap(kTemperatureCatalog, 100, 'c', 'f'), closeTo(212, 1e-9));
      expect(swap(kTemperatureCatalog, 32, 'f', 'c'), closeTo(0, 1e-9));
      expect(swap(kTemperatureCatalog, -40, 'c', 'f'), closeTo(-40, 1e-9));
      expect(swap(kTemperatureCatalog, 37, 'c', 'f'), closeTo(98.6, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'c', 'k'), closeTo(273.15, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'k', 'c'), closeTo(-273.15, 1e-9));
      expect(swap(kTemperatureCatalog, 273.15, 'k', 'f'), closeTo(32, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'r', 'k'), closeTo(0, 1e-9));
      expect(swap(kTemperatureCatalog, 0, 'r', 'c'), closeTo(-273.15, 1e-9));
      // 摄氏与开尔文同刻度，华氏与兰氏同刻度
      expect(swap(kTemperatureCatalog, 10, 'c', 'k'), closeTo(283.15, 1e-9));
      expect(swap(kTemperatureCatalog, 9, 'f', 'r'), closeTo(468.67, 1e-9));
      // 温度只有公制 / 英制两套体系
      expect(kTemperatureCatalog.systems, <MeasureSystem>[
        MeasureSystem.metric,
        MeasureSystem.imperial,
      ]);
      expect(kTemperatureCatalog.unitsOf(MeasureSystem.chinese), isEmpty);
    });

    test('速度：1 节 = 1.852 千米/小时，1 马赫 = 340.3 米/秒', () {
      expect(swap(kSpeedCatalog, 1, 'kmh', 'ms'), closeTo(1 / 3.6, 1e-12));
      expect(swap(kSpeedCatalog, 36, 'kmh', 'ms'), closeTo(10, 1e-12));
      expect(swap(kSpeedCatalog, 1, 'mph', 'kmh'), closeTo(1.609344, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'kn', 'kmh'), closeTo(1.852, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'mach', 'ms'), closeTo(340.3, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'kms', 'kmh'), closeTo(3600, 1e-9));
      expect(swap(kSpeedCatalog, 1, 'fts', 'ms'), closeTo(0.3048, 1e-12));
      expect(swap(kSpeedCatalog, 3600, 'lishi', 'ms'), closeTo(500, 1e-9));
      expect(swap(kSpeedCatalog, 100, 'kmh', 'mach'), closeTo(0.081627, 1e-6));
    });

    test('五张单位表：id 唯一、体系自洽、参照物都落到真实单位', () {
      for (final catalog in <MeasureCatalog>[
        kAreaCatalog,
        kVolumeCatalog,
        kWeightCatalog,
        kTemperatureCatalog,
        kSpeedCatalog,
      ]) {
        final ids = catalog.units.map((unit) => unit.id).toList();
        expect(ids.toSet().length, ids.length, reason: catalog.name);
        expect(
          catalog.unitById(catalog.defaultUnitId),
          isNotNull,
          reason: catalog.name,
        );
        for (final unit in catalog.units) {
          expect(
            unit.baseValue.isFinite && unit.baseValue > 0,
            isTrue,
            reason: '${catalog.name} ${unit.id}',
          );
          expect(
            catalog.systems.contains(unit.system),
            isTrue,
            reason: '${catalog.name} ${unit.id}',
          );
        }
        expect(catalog.samples, isNotEmpty, reason: catalog.name);
        for (final sample in catalog.samples) {
          expect(
            catalog.unitOfSample(sample),
            isNotNull,
            reason: '${catalog.name} ${sample.label}',
          );
        }
        // 任意两个单位互为反函数
        for (final from in catalog.units) {
          for (final to in catalog.units) {
            final forward = catalog.convert(7.5, from: from, to: to)!;
            final back = catalog.convert(forward, from: to, to: from)!;
            expect(
              back,
              closeTo(7.5, 1e-6),
              reason: '${catalog.name} ${from.id} → ${to.id}',
            );
          }
        }
      }
    });
  });
}

/// 测试辅助：明细里最大的一个月个税。
double maxMonthlyTaxOf(List<PayrollMonth> months) =>
    months.map((month) => month.tax).reduce((a, b) => a > b ? a : b);
