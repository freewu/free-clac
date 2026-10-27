/// BMI（身体质量指数）计算，纯逻辑，不依赖 Flutter。
library;

/// BMI 分级，采用中国成人标准（WS/T 428—2013）。
enum BmiCategory {
  underweight('偏瘦'),
  normal('正常'),
  overweight('超重'),
  obese('肥胖');

  const BmiCategory(this.label);

  final String label;
}

/// 分级边界（不含上界）：18.5 / 24 / 28。
const double bmiUnderweightMax = 18.5;
const double bmiNormalMax = 24.0;
const double bmiOverweightMax = 28.0;

/// 正常区间的参考上下界（用于反推标准体重）。
const double bmiHealthyMin = 18.5;
const double bmiHealthyMax = 23.9;

/// 一次 BMI 计算的结果。
class BmiResult {
  const BmiResult({
    required this.bmi,
    required this.heightCm,
    required this.weightKg,
  });

  final double bmi;
  final double heightCm;
  final double weightKg;

  BmiCategory get category {
    if (bmi < bmiUnderweightMax) return BmiCategory.underweight;
    if (bmi < bmiNormalMax) return BmiCategory.normal;
    if (bmi < bmiOverweightMax) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  /// 该身高对应的正常体重下限（kg）。
  double get healthyMinKg => bmiHealthyMin * _heightM2;

  /// 该身高对应的正常体重上限（kg）。
  double get healthyMaxKg => bmiHealthyMax * _heightM2;

  /// 距离正常区间中心（BMI 21）还差多少公斤，负数表示偏轻。
  double get weightToHealthyCenter => 21 * _heightM2 - weightKg;

  String get advice => switch (category) {
    BmiCategory.underweight => '体重偏低，注意均衡饮食并适当增加力量训练。',
    BmiCategory.normal => '体重处于正常范围，保持现有作息与运动习惯即可。',
    BmiCategory.overweight => '体重偏高，建议控制精制碳水摄入并增加有氧运动。',
    BmiCategory.obese => '已进入肥胖区间，建议咨询医生或营养师制定减重方案。',
  };

  double get _heightM2 {
    final m = heightCm / 100;
    return m * m;
  }
}

/// 计算 BMI；输入不合法（身高或体重非正数）时返回 null。
///
/// [heightCm] 小于 3 时按「米」理解（如 1.75），方便直接输入。
BmiResult? calculateBmi({required double heightCm, required double weightKg}) {
  if (heightCm <= 0 || weightKg <= 0) return null;
  final cm = heightCm < 3 ? heightCm * 100 : heightCm;
  if (cm < 30 || cm > 300) return null;
  final m = cm / 100;
  return BmiResult(bmi: weightKg / (m * m), heightCm: cm, weightKg: weightKg);
}
