/// 基础代谢（BMR）与每日总消耗（TDEE）计算，纯逻辑，不依赖 Flutter。
library;

/// 性别：Mifflin-St Jeor 公式男女只在常数项上不同（+5 / −161）。
enum BmrGender {
  male('男', 'male'),
  female('女', 'female');

  const BmrGender(this.label, this.code);

  /// 数据层的中文名（界面文案走 `BmrStrings.genderLabel()`）。
  final String label;

  /// 持久化用的稳定标识。
  final String code;

  /// 解析持久化的性别标识，无法识别时返回 null。
  static BmrGender? fromCode(String? code) {
    if (code == null) return null;
    for (final gender in BmrGender.values) {
      if (gender.code == code) return gender;
    }
    return null;
  }
}

/// 活动水平与对应的活动系数：`TDEE = BMR × factor`。
enum BmrActivity {
  sedentary('久坐（几乎不动）', 1.2, 'sedentary'),
  light('轻度活动（每周运动 1–3 次）', 1.375, 'light'),
  moderate('中度活动（每周运动 3–5 次）', 1.55, 'moderate'),
  active('高强度（每周运动 6–7 次）', 1.725, 'active'),
  veryActive('极高强度（体力工作 + 训练）', 1.9, 'very_active');

  const BmrActivity(this.label, this.factor, this.code);

  /// 数据层的中文名（界面文案走 `BmrStrings.activityLabel()`）。
  final String label;

  /// 乘在 BMR 上的活动系数。
  final double factor;

  /// 持久化用的稳定标识。
  final String code;

  /// 解析持久化的活动标识，无法识别时返回 null。
  static BmrActivity? fromCode(String? code) {
    if (code == null) return null;
    for (final activity in BmrActivity.values) {
      if (activity.code == code) return activity;
    }
    return null;
  }
}

/// Mifflin-St Jeor 公式里男性的常数项。
const double bmrMaleOffset = 5;

/// Mifflin-St Jeor 公式里女性的常数项。
const double bmrFemaleOffset = -161;

/// 一次基础代谢计算的结果。
class BmrResult {
  const BmrResult({
    required this.bmr,
    required this.gender,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
  });

  /// 基础代谢（千卡 / 天）。
  final double bmr;

  final BmrGender gender;

  /// 年龄（整岁）。
  final int age;

  final double heightCm;
  final double weightKg;

  /// 当前选中的活动水平。
  final BmrActivity activity;

  /// 每日总消耗（千卡 / 天）：`BMR × 活动系数`。
  double get tdee => tdeeOf(activity);

  /// 某个活动水平下的每日总消耗。
  double tdeeOf(BmrActivity value) => bmr * value.factor;

  /// 日常活动带来的额外消耗（TDEE − BMR）。
  double get activityCalories => tdee - bmr;

  /// 五种活动水平下的每日总消耗，顺序同 [BmrActivity.values]。
  List<double> get tdeeByActivity => [
    for (final value in BmrActivity.values) tdeeOf(value),
  ];
}

/// 用 Mifflin-St Jeor 公式计算基础代谢。
///
/// * 男性：`10 × 体重(kg) + 6.25 × 身高(cm) − 5 × 年龄 + 5`
/// * 女性：`10 × 体重(kg) + 6.25 × 身高(cm) − 5 × 年龄 − 161`
///
/// 输入不合法（体重 0–500 kg 之外、年龄不在 1–120 岁、身高 30–300 cm 之外）
/// 时返回 null。[heightCm] 小于 3 时按「米」理解（如 1.75），与 BMI 工具一致。
BmrResult? calculateBmr({
  required BmrGender gender,
  required double age,
  required double heightCm,
  required double weightKg,
  BmrActivity activity = BmrActivity.light,
}) {
  if (weightKg <= 0 || weightKg > 500) return null;
  // 年龄按整岁计算，和结果里展示的一致
  final years = age.roundToDouble();
  if (years < 1 || years > 120) return null;
  final cm = heightCm < 3 ? heightCm * 100 : heightCm;
  if (cm < 30 || cm > 300) return null;
  final offset = gender == BmrGender.male ? bmrMaleOffset : bmrFemaleOffset;
  final bmr = 10 * weightKg + 6.25 * cm - 5 * years + offset;
  if (bmr <= 0) return null;
  return BmrResult(
    bmr: bmr,
    gender: gender,
    age: years.round(),
    heightCm: cm,
    weightKg: weightKg,
    activity: activity,
  );
}
