import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/tools/bmi.dart';
import 'package:free_clac/tools/compound.dart';

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
}
