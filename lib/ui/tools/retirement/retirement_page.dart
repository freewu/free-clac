import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_select.dart';
import 'retirement.dart';

/// 退休年龄计算器页：选出生年月与人员类别，测算退休时间与退休年龄。
class RetirementPage extends StatefulWidget {
  const RetirementPage({super.key, this.now});

  /// 计算「还需奋斗」用的当前时间，默认取系统时间（测试里可注入固定值）。
  final DateTime? now;

  @override
  State<RetirementPage> createState() => _RetirementPageState();
}

class _RetirementPageState extends State<RetirementPage> {
  /// 可选出生年份：覆盖「改革前出生」到刚参加工作的人群。
  static const List<int> _years = <int>[
    1950, 1951, 1952, 1953, 1954, 1955, 1956, 1957, 1958, 1959, //
    1960, 1961, 1962, 1963, 1964, 1965, 1966, 1967, 1968, 1969, //
    1970, 1971, 1972, 1973, 1974, 1975, 1976, 1977, 1978, 1979, //
    1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988, 1989, //
    1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998, 1999, //
    2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, //
    2010,
  ];

  static final List<int> _months = List<int>.generate(12, (index) => index + 1);

  int _birthYear = 1985;
  int _birthMonth = 6;
  RetirementGroup _group = RetirementGroup.male;

  /// 「还需奋斗」的基准时间，测试可注入固定值。
  late final DateTime _now = widget.now ?? DateTime.now();

  RetirementResult get _result => calculateRetirement(
    birth: DateTime(_birthYear, _birthMonth),
    group: _group,
  );

  static String _groupLabel(RetirementGroup group) => switch (group) {
    RetirementGroup.male => '男职工 · 原 ${group.baseAge} 岁',
    RetirementGroup.female55 => '女职工（管理技术）· 原 ${group.baseAge} 岁',
    RetirementGroup.female50 => '女职工（工人）· 原 ${group.baseAge} 岁',
  };

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('退休年龄计算器'),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSection(
                  title: '参保人',
                  icon: Icons.person_outline_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: 2,
                            child: ToolSelect<int>(
                              key: const Key('retirement-birth-year'),
                              label: '出生年份',
                              value: _birthYear,
                              items: _years,
                              labelOf: (year) => '$year 年',
                              onChanged: (year) =>
                                  setState(() => _birthYear = year),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ToolSelect<int>(
                              key: const Key('retirement-birth-month'),
                              label: '出生月份',
                              value: _birthMonth,
                              items: _months,
                              labelOf: (month) => '$month 月',
                              onChanged: (month) =>
                                  setState(() => _birthMonth = month),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ToolSelect<RetirementGroup>(
                        key: const Key('retirement-group'),
                        label: '人员类别',
                        value: _group,
                        items: RetirementGroup.values,
                        labelOf: _groupLabel,
                        onChanged: (group) => setState(() => _group = group),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  key: const Key('retirement-result'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '法定退休时间',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${result.retireMonth.year} 年 '
                        '${result.retireMonth.month} 月',
                        style: TextStyle(
                          fontSize: 26,
                          height: 1.15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _countdownLabel(result),
                        key: const Key('retirement-countdown'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _summary(result),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: '法定退休年龄',
                        value: _ageLabel(result.legalAgeMonths),
                        key: const Key('retirement-age'),
                      ),
                      _InfoRow(
                        label: '最低缴费年限',
                        value:
                            '${_yearsLabel(result.minimumContributionYears)}'
                            '（${result.retireMonth.year} 年退休）',
                        key: const Key('retirement-contribution'),
                      ),
                      _InfoRow(
                        label: '弹性提前最早',
                        value:
                            '${result.earliestMonth.year} 年 '
                            '${result.earliestMonth.month} 月 · '
                            '${result.earliestAgeYears} 岁',
                        key: const Key('retirement-earliest'),
                      ),
                      _InfoRow(
                        label: '弹性延迟最晚',
                        value:
                            '${result.latestMonth.year} 年 '
                            '${result.latestMonth.month} 月 · '
                            '${result.latestAgeYears} 岁',
                        key: const Key('retirement-latest'),
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '口径：《全国人民代表大会常务委员会关于实施渐进式延迟法定退休年龄的'
                  '决定》，2025 年 1 月 1 日起施行。男职工 60 → 63 岁、原 55 岁女职工 '
                  '55 → 58 岁（每 4 个月出生延迟 1 个月），原 50 岁女职工 50 → 55 岁'
                  '（每 2 个月出生延迟 1 个月）；最低缴费年限自 2030 年起每年提高 6 '
                  '个月，2039 年及以后为 20 年。可自愿提前（不低于原法定退休年龄）或'
                  '协商延迟，前后各不超过 3 年。不含特殊工种提前退休、病退与军龄折算。',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 「还需奋斗 X 年 Y 个月」，已到退休年龄时给出提示。
  String _countdownLabel(RetirementResult result) {
    final months = monthsUntilRetirement(result, _now);
    if (months == 0) return '已达到法定退休年龄';
    return '还需奋斗 ${_spanLabel(months)}';
  }

  /// 把月数写成「X 年 Y 个月」/「X 年」/「Y 个月」。
  String _spanLabel(int months) {
    final years = months ~/ 12;
    final rest = months % 12;
    if (years == 0) return '$rest 个月';
    if (rest == 0) return '$years 年';
    return '$years 年 $rest 个月';
  }

  /// 「较原法定年龄延迟 N 个月」的说明。
  String _summary(RetirementResult result) {
    final base = result.group.baseAge;
    if (result.delayMonths == 0) {
      return '原法定退休年龄 $base 岁，不受延迟退休影响。';
    }
    final capped = result.isCapped
        ? '，已到 ${result.group.targetAge} 岁的改革目标'
        : '';
    return '原法定退休年龄 $base 岁，延迟 ${result.delayMonths} 个月$capped。'
        '可在法定退休年龄前后各 3 年内弹性选择。';
  }

  String _ageLabel(int months) {
    final years = months ~/ 12;
    final rest = months % 12;
    return rest == 0 ? '$years 岁' : '$years 岁 $rest 个月';
  }

  String _yearsLabel(double years) {
    final text = years == years.roundToDouble()
        ? years.toStringAsFixed(0)
        : years.toStringAsFixed(1);
    return '$text 年';
  }
}

/// 结果卡片里的一行「标题 + 值」。
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: last
            ? null
            : Border(bottom: BorderSide(color: AppColors.outline, width: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
