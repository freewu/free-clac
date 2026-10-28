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

/// 计量单位：公制（cm / kg）与英制（ft + in / lb）。
enum BmiUnitSystem {
  metric('公制', 'metric'),
  imperial('英制', 'imperial');

  const BmiUnitSystem(this.label, this.code);

  /// 界面上的短标签（公制 / 英制）。
  final String label;

  /// 持久化用的稳定标识。
  final String code;

  /// 解析持久化的单位标识，无法识别时返回 null。
  static BmiUnitSystem? fromCode(String? code) {
    if (code == null) return null;
    for (final unit in BmiUnitSystem.values) {
      if (unit.code == code) return unit;
    }
    return null;
  }
}

/// 英制身高的输入单位。
enum BmiImperialHeightUnit {
  feet('ft', '英尺'),
  inches('in', '英寸');

  const BmiImperialHeightUnit(this.symbol, this.label);

  final String symbol;
  final String label;

  /// 另一个单位（用于一键切换）。
  BmiImperialHeightUnit get other => this == feet ? inches : feet;
}

/// 1 英寸 = 2.54 cm。
const double cmPerInch = 2.54;

/// 1 磅 = 0.45359237 kg。
const double kgPerPound = 0.45359237;

/// 英尺 → 厘米。
double cmFromFeet(double feet) => feet * 12 * cmPerInch;

/// 英寸 → 厘米。
double cmFromInches(double inches) => inches * cmPerInch;

/// 英尺 + 英寸 → 厘米。
double cmFromFeetInches({double feet = 0, double inches = 0}) =>
    cmFromFeet(feet) + cmFromInches(inches);

/// 厘米 → 英尺。
double feetFromCm(double cm) => cm / cmPerInch / 12;

/// 厘米 → 英寸。
double inchesFromCm(double cm) => cm / cmPerInch;

/// 磅 → 千克。
double kgFromPounds(double pounds) => pounds * kgPerPound;

/// 千克 → 磅。
double poundsFromKg(double kg) => kg / kgPerPound;

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

  /// 身高换算成英寸。
  double get heightInches => heightCm / cmPerInch;

  /// 英制身高的整英尺部分。
  int get heightFeet => (heightInches / 12).floor();

  /// 英制身高去掉整英尺后的英寸部分。
  double get heightRemainderInches => heightInches - heightFeet * 12;

  /// 体重换算成磅。
  double get weightPounds => poundsFromKg(weightKg);

  /// 正常体重下限（磅）。
  double get healthyMinPounds => poundsFromKg(healthyMinKg);

  /// 正常体重上限（磅）。
  double get healthyMaxPounds => poundsFromKg(healthyMaxKg);

  /// 距理想体重的差距（磅，负数表示偏轻）。
  double get weightToHealthyCenterPounds => poundsFromKg(weightToHealthyCenter);

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
