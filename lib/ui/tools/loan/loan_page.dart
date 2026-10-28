import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_i18n.dart';
import 'loan.dart';
import 'loan_strings.dart';
import '../widgets/tool_bars.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_unit_picker.dart';

/// 本金条的颜色。
Color get loanPrincipalColor => AppColors.primary;

/// 利息条的颜色。
Color get loanInterestColor => AppColors.warning;

/// 解析深链里的还款方式（Web 端 `?method=equalPrincipal`），无效值回落到等额本息。
///
/// 主要给截图脚本用：`?page=tools&tool=loan&method=equalPrincipal`
/// 打开就是等额本金，能直接看到明细的倒梯形。
LoanMethod loanMethodFromQuery(Map<String, String> query) {
  final name = query['method'];
  return LoanMethod.values.firstWhere(
    (method) => method.name == name,
    orElse: () => LoanMethod.equalInstallment,
  );
}

/// 贷款计算器：等额本息 / 等额本金，逐期拆分本金与利息并用双色条表示。
class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  LoanMethod _method = loanMethodFromQuery(Uri.base.queryParameters);
  LoanTermUnit _termUnit = LoanTermUnit.years;

  final TextEditingController _amount = TextEditingController(text: '1000000');
  final TextEditingController _rate = TextEditingController(text: '4.9');
  final TextEditingController _term = TextEditingController(text: '30');

  /// 明细表按「月」还是按「年」汇总。
  bool _groupByYear = false;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _term.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  LoanResult? get _result => calculateLoan(
    amount: _parse(_amount),
    annualRatePercent: _parse(_rate),
    months: _termUnit.toMonths(_parse(_term)),
    method: _method,
  );

  /// 切换期限单位时换算数值（30 年 ⇄ 360 月）。
  void _switchTermUnit(LoanTermUnit unit) {
    if (unit == _termUnit) return;
    // 先用旧单位换算出月数，再切单位回填，避免「30 年 → 30 月」
    final months = _termUnit.toMonths(_parse(_term));
    setState(() {
      _termUnit = unit;
      _term.text = unit == LoanTermUnit.months
          ? months.toString()
          : _trimNumber(months / loanPeriodsPerYear);
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(loanStrings.title),
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
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSection(
                  title: loanStrings.sectionInput,
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final amount = ToolNumberField(
                            label: loanStrings.amount,
                            suffix: loanStrings.currency,
                            controller: _amount,
                            onChanged: (_) => setState(() {}),
                          );
                          final rate = ToolNumberField(
                            label: loanStrings.annualRate,
                            suffix: '%',
                            controller: _rate,
                            onChanged: (_) => setState(() {}),
                          );
                          final term = ToolNumberField(
                            label: loanStrings.term,
                            controller: _term,
                            trailing: ToolUnitPicker<LoanTermUnit>(
                              value: _termUnit,
                              items: LoanTermUnit.values,
                              labelOf: loanStrings.termUnitLabel,
                              tooltip: loanStrings.termUnit,
                              onSelected: _switchTermUnit,
                            ),
                            onChanged: (_) => setState(() {}),
                          );
                          // 窄屏下一行放三个输入框会把输入区挤没，改成两行
                          if (constraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                amount,
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: rate),
                                    const SizedBox(width: 12),
                                    Expanded(child: term),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(flex: 3, child: amount),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: rate),
                              const SizedBox(width: 12),
                              Expanded(flex: 2, child: term),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        loanStrings.method,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final method in LoanMethod.values)
                            ChoiceChip(
                              label: Text(
                                loanStrings.methodLabel(method),
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _method == method,
                              onSelected: (_) =>
                                  setState(() => _method = method),
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (result == null)
                  const ToolSection(child: _EmptyHint())
                else ...[
                  ToolSection(child: _Summary(result: result)),
                  const SizedBox(height: 12),
                  ToolSection(
                    title: loanStrings.sectionSchedule,
                    icon: Icons.table_rows_outlined,
                    trailing: _GroupSwitch(
                      groupByYear: _groupByYear,
                      onChanged: (value) =>
                          setState(() => _groupByYear = value),
                    ),
                    child: _Schedule(result: result, groupByYear: _groupByYear),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 去掉多余的小数位，用于把期限回填到输入框。
String _trimNumber(double value) {
  final text = value.toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 30,
            color: AppColors.outline,
          ),
          SizedBox(height: 10),
          Text(
            loanStrings.emptyHint,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

/// 还款明细的「按月 / 按年」切换。
class _GroupSwitch extends StatelessWidget {
  const _GroupSwitch({required this.groupByYear, required this.onChanged});

  final bool groupByYear;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (label, value) in [
          (loanStrings.byMonth, false),
          (loanStrings.byYear, true),
        ])
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              label: Text(label, style: const TextStyle(fontSize: 11)),
              selected: groupByYear == value,
              onSelected: (_) => onChanged(value),
              visualDensity: VisualDensity.compact,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result});

  final LoanResult result;

  @override
  Widget build(BuildContext context) {
    final fixed = result.isFixedPayment;
    final months = result.months;
    final decrease = months >= 2
        ? result.periods[0].payment - result.periods[1].payment
        : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fixed ? loanStrings.monthlyPayment : loanStrings.firstPayment,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text(
          '¥ ${formatMoney(result.firstPayment)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          fixed
              ? fill(loanStrings.summaryFixed, [
                  loanStrings.methodLabel(result.method),
                  months,
                ])
              : fill(loanStrings.summaryDecreasing, [
                  loanStrings.methodLabel(result.method),
                  months,
                  formatMoney(decrease),
                ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 18),
        // 三行金额条：长度按金额占「总还款」的比例缩放，本金 / 利息 / 总额
        // 一眼比出差距，而不是永远等长的百分比条
        AmountBar(
          key: const ValueKey('loan-bar-贷款总额'),
          label: loanStrings.loanTotal,
          value: '¥ ${formatMoney(result.amount, decimals: 0)}',
          ratio: result.amount / result.totalPayment,
          segments: [RatioSegment(value: 1, color: loanPrincipalColor)],
        ),
        const SizedBox(height: 8),
        AmountBar(
          key: const ValueKey('loan-bar-总利息'),
          label: loanStrings.totalInterest,
          value: '¥ ${formatMoney(result.totalInterest, decimals: 0)}',
          ratio: result.interestRatio,
          segments: [RatioSegment(value: 1, color: loanInterestColor)],
        ),
        const SizedBox(height: 8),
        AmountBar(
          key: const ValueKey('loan-bar-总还款'),
          label: loanStrings.totalPayment,
          value: '¥ ${formatMoney(result.totalPayment, decimals: 0)}',
          ratio: 1,
          segments: [
            RatioSegment(
              value: 1 - result.interestRatio,
              color: loanPrincipalColor,
            ),
            RatioSegment(value: result.interestRatio, color: loanInterestColor),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              fill(loanStrings.principalShare, [
                (result.amount / result.totalPayment * 100).toStringAsFixed(1),
              ]),
              style: TextStyle(color: loanPrincipalColor, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              fill(loanStrings.interestShare, [
                (result.interestRatio * 100).toStringAsFixed(1),
              ]),
              style: TextStyle(color: loanInterestColor, fontSize: 10.5),
            ),
          ],
        ),
      ],
    );
  }
}

class _Schedule extends StatelessWidget {
  const _Schedule({required this.result, required this.groupByYear});

  final LoanResult result;
  final bool groupByYear;

  @override
  Widget build(BuildContext context) {
    final rows = groupByYear ? result.yearly : result.periods;
    // 条长按还款额缩放：等额本金首期 100%、末期 60%，整体是个倒梯形
    final ratios = scheduleBarRatios(rows);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              loanStrings.periodColumn,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              groupByYear
                  ? loanStrings.paymentThisYear
                  : loanStrings.paymentThisPeriod,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 360),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _PeriodRow(
              period: rows[index],
              byYear: groupByYear,
              barWidth: ratios[index],
            ),
          ),
        ),
        if (!result.isFixedPayment) ...[
          const SizedBox(height: 10),
          Text(
            loanStrings.barNote,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ],
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({
    required this.period,
    required this.byYear,
    this.barWidth = 1,
  });

  final LoanPeriod period;
  final bool byYear;

  /// 金额条占满宽的比例（1 = 满宽），由 [scheduleBarRatios] 按还款额算出。
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    final title = fill(byYear ? loanStrings.yearRow : loanStrings.periodRow, [
      period.index,
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '¥ ${formatMoney(period.payment)}',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // 左对齐 + 按比例收窄，逐期变短就拼出倒梯形
        Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            key: ValueKey('loan-period-bar-${period.index}'),
            widthFactor: barWidth.clamp(0.0, 1.0),
            child: SegmentedBar(
              segments: [
                RatioSegment(
                  value: period.principalRatio,
                  color: loanPrincipalColor,
                ),
                RatioSegment(
                  value: period.interestRatio,
                  color: loanInterestColor,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              fill(loanStrings.principalRow, [
                formatMoney(period.principal, decimals: 0),
              ]),
              style: TextStyle(color: loanPrincipalColor, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              fill(loanStrings.interestRow, [
                formatMoney(period.interest, decimals: 0),
              ]),
              style: TextStyle(color: loanInterestColor, fontSize: 10.5),
            ),
          ],
        ),
      ],
    );
  }
}
