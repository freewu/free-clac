/// 时薪计算：月薪 ÷ (月工作天数 × 每日工作时长)。纯逻辑，不依赖 Flutter。
library;

import 'dart:convert';

/// 月计薪天数（双休）：人社部口径 21.75 天。
const double baseWorkDays = 21.75;

/// 工作日制度：月工作天数在 21.75 天基础上叠加。
///
/// * 双休：21.75 天
/// * 大小周：每月多上 2 天 → 23.75 天
/// * 996：每月多上 4 天 → 25.75 天
enum WorkSchedule {
  standard('双休', baseWorkDays, 'standard'),
  alternate('大小周', baseWorkDays + 2, 'alternate'),
  overtime('996', baseWorkDays + 4, 'overtime');

  const WorkSchedule(this.label, this.daysPerMonth, this.code);

  /// 数据层的中文名（界面文案走 `HourlyStrings.scheduleLabel()`）。
  final String label;

  /// 每月的工作天数。
  final double daysPerMonth;

  /// 持久化用的稳定标识。
  final String code;

  /// 解析持久化的制度标识，无法识别时返回 null。
  static WorkSchedule? fromCode(String? code) {
    if (code == null) return null;
    for (final schedule in WorkSchedule.values) {
      if (schedule.code == code) return schedule;
    }
    return null;
  }
}

/// 一次时薪计算的结果。
class HourlyResult {
  const HourlyResult({
    required this.monthlySalary,
    required this.schedule,
    required this.hoursPerDay,
  });

  final double monthlySalary;
  final WorkSchedule schedule;

  /// 每天工作几小时。
  final double hoursPerDay;

  /// 每月工作天数。
  double get workDays => schedule.daysPerMonth;

  /// 每月工作小时数：`工作天数 × 每日工作时长`。
  double get monthlyHours => workDays * hoursPerDay;

  /// 时薪：`月薪 ÷ 月工时`。
  double get hourly => monthlySalary / monthlyHours;

  /// 日薪：`月薪 ÷ 工作天数`。
  double get dailyWage => monthlySalary / workDays;
}

/// 计算时薪；月薪不在 0–10 亿、每日工作时长不在 0–24 小时时返回 null。
HourlyResult? calculateHourly({
  required double monthlySalary,
  required WorkSchedule schedule,
  required double hoursPerDay,
}) {
  if (!monthlySalary.isFinite || monthlySalary <= 0 || monthlySalary > 1e9) {
    return null;
  }
  if (!hoursPerDay.isFinite || hoursPerDay <= 0 || hoursPerDay > 24) {
    return null;
  }
  return HourlyResult(
    monthlySalary: monthlySalary,
    schedule: schedule,
    hoursPerDay: hoursPerDay,
  );
}

/// 历史记录最多保留多少条。
const int hourlyHistoryLimit = 20;

/// 一条历史记录：算出的时薪 + 当时的输入，支持与当前结果对比。
class HourlyRecord {
  const HourlyRecord({
    required this.hourly,
    required this.monthlySalary,
    required this.schedule,
    required this.hoursPerDay,
    required this.savedAt,
  });

  /// 从计算结果生成一条记录，时间默认取当前时刻。
  factory HourlyRecord.fromResult(HourlyResult result, {DateTime? savedAt}) =>
      HourlyRecord(
        hourly: result.hourly,
        monthlySalary: result.monthlySalary,
        schedule: result.schedule,
        hoursPerDay: result.hoursPerDay,
        savedAt: savedAt ?? DateTime.now(),
      );

  final double hourly;
  final double monthlySalary;
  final WorkSchedule schedule;
  final double hoursPerDay;
  final DateTime savedAt;

  /// 月工时（记录里没存，按制度天数重新算）。
  double get monthlyHours => schedule.daysPerMonth * hoursPerDay;

  /// 与另一条记录是不是同一组输入（用于避免重复记录）。
  bool sameInputAs(HourlyRecord other) =>
      monthlySalary == other.monthlySalary &&
      schedule == other.schedule &&
      hoursPerDay == other.hoursPerDay;

  Map<String, Object?> toJson() => <String, Object?>{
    'hourly': hourly,
    'salary': monthlySalary,
    'schedule': schedule.code,
    'hours': hoursPerDay,
    'at': savedAt.millisecondsSinceEpoch,
  };

  /// 序列化成一行 JSON，存进设置里的历史记录列表。
  String encode() => jsonEncode(toJson());

  /// 解析一行 JSON；字段缺失 / 越界 / 制度认不出来时返回 null。
  static HourlyRecord? decode(String raw) {
    if (raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final hourly = _positiveNumber(decoded['hourly']);
      final salary = _positiveNumber(decoded['salary']);
      final hours = _positiveNumber(decoded['hours']);
      final schedule = WorkSchedule.fromCode(decoded['schedule'] as String?);
      final at = decoded['at'];
      if (hourly == null ||
          salary == null ||
          hours == null ||
          schedule == null) {
        return null;
      }
      if (hours > 24) return null;
      final stamp = at is int ? at : int.tryParse('$at');
      return HourlyRecord(
        hourly: hourly,
        monthlySalary: salary,
        schedule: schedule,
        hoursPerDay: hours,
        savedAt: DateTime.fromMillisecondsSinceEpoch(
          stamp ?? 0,
          isUtc: true,
        ).toLocal(),
      );
    } on Object {
      return null;
    }
  }

  static double? _positiveNumber(Object? value) {
    final number = value is num ? value.toDouble() : double.tryParse('$value');
    if (number == null || !number.isFinite || number <= 0) return null;
    return number;
  }
}
