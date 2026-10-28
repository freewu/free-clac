/// 延迟退休年龄测算，纯逻辑（不依赖 Flutter）。
///
/// 口径：《全国人民代表大会常务委员会关于实施渐进式延迟法定退休年龄的决定》
/// （2024-09-13 通过，2025-01-01 施行）。要点：
///
/// - 男职工原 60 岁 → 63 岁，每 4 个月出生推迟 1 个月；
/// - 原 55 岁女职工 → 58 岁，每 4 个月出生推迟 1 个月；
/// - 原 50 岁女职工 → 55 岁，每 2 个月出生推迟 1 个月；
/// - 最低缴费年限 2030 年起每年提高 6 个月，2039 年及以后为 20 年；
/// - 可自愿弹性提前（不低于原法定退休年龄）或协商延迟，前后各不超过 3 年。
library;

import 'dart:math' as math;

/// 参保人所属类别，决定原法定退休年龄与延迟节奏。
enum RetirementGroup {
  /// 男职工：原 60 岁，目标 63 岁，每 4 个月出生延迟 1 个月。
  male(baseAge: 60, targetAge: 63, stepMonths: 4),

  /// 原法定退休年龄 55 岁的女职工（干部 / 管理技术人员）：55 → 58。
  female55(baseAge: 55, targetAge: 58, stepMonths: 4),

  /// 原法定退休年龄 50 岁的女职工（工人）：50 → 55，节奏翻倍。
  female50(baseAge: 50, targetAge: 55, stepMonths: 2);

  const RetirementGroup({
    required this.baseAge,
    required this.targetAge,
    required this.stepMonths,
  });

  /// 改革前的法定退休年龄（岁）。
  final int baseAge;

  /// 改革完成后的法定退休年龄（岁）。
  final int targetAge;

  /// 每多少个月出生，延迟 1 个月。
  final int stepMonths;

  /// 改革从 2025 年 1 月开始，故该类别从「2025 - 原年龄」那一年的 1 月出生起受影响。
  int get firstAffectedYear => 2025 - baseAge;

  /// 延迟上限（月）。
  int get maxDelayMonths => (targetAge - baseAge) * 12;
}

/// 测算结果。
class RetirementResult {
  const RetirementResult({
    required this.birth,
    required this.group,
    required this.delayMonths,
    required this.earliestMonths,
    required this.latestMonths,
  });

  /// 出生年月（统一取当月 1 日）。
  final DateTime birth;

  final RetirementGroup group;

  /// 相比原法定退休年龄延迟的月数，0 表示不受影响。
  final int delayMonths;

  /// 弹性提前后最早的退休年龄（月数）。
  final int earliestMonths;

  /// 弹性延迟后最晚的退休年龄（月数）。
  final int latestMonths;

  /// 改革后的法定退休年龄（月数）= 原年龄 + 延迟月数。
  int get legalAgeMonths => group.baseAge * 12 + delayMonths;

  /// 法定退休年龄的整岁部分。
  int get legalAgeYears => legalAgeMonths ~/ 12;

  /// 法定退休年龄不满一年的月份部分。
  int get legalAgeExtraMonths => legalAgeMonths % 12;

  /// 法定退休年月。
  DateTime get retireMonth => addMonths(birth, legalAgeMonths);

  /// 弹性提前后最早的退休年月。
  DateTime get earliestMonth => addMonths(birth, earliestMonths);

  /// 弹性延迟后最晚的退休年月。
  DateTime get latestMonth => addMonths(birth, latestMonths);

  /// 弹性提前后的年龄（岁）。
  int get earliestAgeYears => earliestMonths ~/ 12;

  /// 弹性延迟后的年龄（岁）。
  int get latestAgeYears => latestMonths ~/ 12;

  /// 法定退休当年对应的最低缴费年限（年）。
  double get minimumContributionYears =>
      minimumContributionYearsAt(retireMonth.year);

  /// 改革完成后的目标年龄是否已到手（延迟拉满）。
  bool get isCapped => delayMonths >= group.maxDelayMonths;
}

/// 在 [month]（当月 1 日）上加 [months] 个月，返回当月 1 日。
DateTime addMonths(DateTime month, int months) {
  final total = month.year * 12 + (month.month - 1) + months;
  return DateTime(total ~/ 12, total % 12 + 1);
}

/// 按 [group] 与出生年月 [birth] 测算法定退休年龄。
///
/// 出生早于受影响区间的（如 1964 年出生的男性）延迟 0 个月。
RetirementResult calculateRetirement({
  required DateTime birth,
  required RetirementGroup group,
}) {
  final monthsSince =
      (birth.year - group.firstAffectedYear) * 12 + (birth.month - 1);
  final delayMonths = monthsSince < 0
      ? 0
      : math.min(group.maxDelayMonths, monthsSince ~/ group.stepMonths + 1);
  // 弹性提前不超过 3 年，且不得低于原法定退休年龄；延迟同样不超过 3 年。
  final earliest = math.max(
    group.baseAge * 12,
    group.baseAge * 12 + delayMonths - 36,
  );
  return RetirementResult(
    birth: DateTime(birth.year, birth.month),
    group: group,
    delayMonths: delayMonths,
    earliestMonths: earliest,
    latestMonths: group.baseAge * 12 + delayMonths + 36,
  );
}

/// 某年退休对应的最低缴费年限（年）：2029 年前 15 年，2030 年起每年加 6 个月，
/// 2039 年及以后 20 年。
double minimumContributionYearsAt(int year) {
  if (year <= 2029) return 15;
  return math.min(20, 15 + (year - 2029) * 0.5);
}
