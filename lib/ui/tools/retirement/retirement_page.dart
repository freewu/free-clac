import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/app_appearance.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_select.dart';
import 'retirement.dart';
import 'retirement_strings.dart';

/// 退休年龄计算器页：选出生年月与人员类别，测算退休时间与退休年龄。
class RetirementPage extends StatefulWidget {
  const RetirementPage({super.key, this.now});

  /// 计算「还需奋斗」用的当前时间，默认取系统时间（测试里可注入固定值）。
  final DateTime? now;

  @override
  State<RetirementPage> createState() => _RetirementPageState();
}

class _RetirementPageState extends State<RetirementPage>
    with AppAppearanceAware {
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

  /// 上次选的出生年月与人员类别。
  final ToolDraft _draft = ToolDraft('retirement');

  late int _birthYear = _draft.integer('birthYear') ?? 1985;
  late int _birthMonth = _draft.integer('birthMonth') ?? 6;
  late RetirementGroup _group =
      _draft.enumOf('group', RetirementGroup.values) ?? RetirementGroup.male;

  /// 「还需奋斗」的基准时间，测试可注入固定值。
  late final DateTime _now = widget.now ?? DateTime.now();

  RetirementResult get _result => calculateRetirement(
    birth: DateTime(_birthYear, _birthMonth),
    group: _group,
  );

  RetirementStrings get _s => retirementStrings;

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final s = _s;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
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
                  title: s.sectionPerson,
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
                              label: s.birthYear,
                              value: _birthYear,
                              items: _years,
                              labelOf: (year) => fill(s.yearOption, [year]),
                              onChanged: (year) {
                                _draft.set('birthYear', year);
                                setState(() => _birthYear = year);
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ToolSelect<int>(
                              key: const Key('retirement-birth-month'),
                              label: s.birthMonth,
                              value: _birthMonth,
                              items: _months,
                              labelOf: (month) => fill(s.monthOption, [month]),
                              onChanged: (month) {
                                _draft.set('birthMonth', month);
                                setState(() => _birthMonth = month);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ToolSelect<RetirementGroup>(
                        key: const Key('retirement-group'),
                        label: s.group,
                        value: _group,
                        items: RetirementGroup.values,
                        labelOf: s.groupLabel,
                        onChanged: (group) {
                          _draft.setEnum('group', group);
                          setState(() => _group = group);
                        },
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
                        s.retireTime,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fill(s.yearMonth, [
                          result.retireMonth.year,
                          result.retireMonth.month,
                        ]),
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
                        label: s.legalAge,
                        value: _ageLabel(result.legalAgeMonths),
                        key: const Key('retirement-age'),
                      ),
                      _InfoRow(
                        label: s.minContribution,
                        value: fill(s.contributionValue, [
                          _yearsLabel(result.minimumContributionYears),
                          result.retireMonth.year,
                        ]),
                        key: const Key('retirement-contribution'),
                      ),
                      _InfoRow(
                        label: s.earliest,
                        value: _flexLabel(
                          result.earliestMonth,
                          result.earliestAgeYears,
                        ),
                        key: const Key('retirement-earliest'),
                      ),
                      _InfoRow(
                        label: s.latest,
                        value: _flexLabel(
                          result.latestMonth,
                          result.latestAgeYears,
                        ),
                        key: const Key('retirement-latest'),
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  s.policyNote,
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
    if (months == 0) return _s.countdownDone;
    return fill(_s.countdown, [_spanLabel(months)]);
  }

  /// 把月数写成「X 年 Y 个月」/「X 年」/「Y 个月」。
  String _spanLabel(int months) {
    final years = months ~/ 12;
    final rest = months % 12;
    if (years == 0) return fill(_s.spanMonths, [rest]);
    if (rest == 0) return fill(_s.spanYears, [years]);
    return fill(_s.spanYearsMonths, [years, rest]);
  }

  /// 「较原法定年龄延迟 N 个月」的说明。
  String _summary(RetirementResult result) {
    final base = result.group.baseAge;
    if (result.delayMonths == 0) {
      return fill(_s.summaryNoDelay, [base]);
    }
    final capped = result.isCapped
        ? fill(_s.capped, [result.group.targetAge])
        : '';
    return fill(_s.summaryDelay, [base, result.delayMonths, capped]);
  }

  /// 「2045 年 6 月 · 60 岁」。
  String _flexLabel(DateTime month, int age) => fill(_s.flexValue, [
    fill(_s.yearMonth, [month.year, month.month]),
    age,
  ]);

  String _ageLabel(int months) {
    final years = months ~/ 12;
    final rest = months % 12;
    return rest == 0
        ? fill(_s.ageYears, [years])
        : fill(_s.ageYearsMonths, [years, rest]);
  }

  String _yearsLabel(double years) {
    final text = years == years.roundToDouble()
        ? years.toStringAsFixed(0)
        : years.toStringAsFixed(1);
    return fill(_s.yearsValue, [text]);
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
