import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../tools/loan.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_unit_picker.dart';

/// 本金条的颜色。
const Color loanPrincipalColor = AppColors.primary;

/// 利息条的颜色。
const Color loanInterestColor = AppColors.warning;

/// 贷款计算器：等额本息 / 等额本金，逐期拆分本金与利息并用双色条表示。
class LoanPage extends StatefulWidget {
  const LoanPage({super.key});

  @override
  State<LoanPage> createState() => _LoanPageState();
}

class _LoanPageState extends State<LoanPage> {
  LoanMethod _method = LoanMethod.equalInstallment;
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
        title: const Text('贷款计算器'),
        titleTextStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
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
                  title: '输入',
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final amount = ToolNumberField(
                            label: '贷款金额',
                            suffix: '元',
                            controller: _amount,
                            onChanged: (_) => setState(() {}),
                          );
                          final rate = ToolNumberField(
                            label: '年利率',
                            suffix: '%',
                            controller: _rate,
                            onChanged: (_) => setState(() {}),
                          );
                          final term = ToolNumberField(
                            label: '期限',
                            controller: _term,
                            trailing: ToolUnitPicker<LoanTermUnit>(
                              value: _termUnit,
                              items: LoanTermUnit.values,
                              labelOf: (unit) => unit.label,
                              tooltip: '期限单位',
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
                      const Text(
                        '还款方式',
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
                                method.label,
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
                    title: '还款明细',
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
    return const Padding(
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
            '填写金额、利率与期限后自动计算',
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
        for (final (label, value) in const [('按月', false), ('按年', true)])
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
          fixed ? '每月还款' : '首月还款',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
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
              ? '${result.method.label} · 共 $months 期 · 每期还款额固定'
              : '${result.method.label} · 共 $months 期 · '
                    '月供逐月递减 ¥ ${formatMoney(decrease)}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: '贷款总额',
                value: '¥ ${formatMoney(result.amount, decimals: 0)}',
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: '总利息',
                value: '¥ ${formatMoney(result.totalInterest, decimals: 0)}',
                color: loanInterestColor,
              ),
            ),
            Expanded(
              child: _Stat(
                label: '总还款',
                value: '¥ ${formatMoney(result.totalPayment, decimals: 0)}',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        StackedRatioBar(principalRatio: 1 - result.interestRatio, height: 10),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '本金 ${(result.amount / result.totalPayment * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: loanPrincipalColor, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              '利息 ${(result.interestRatio * 100).toStringAsFixed(1)}%',
              style: const TextStyle(color: loanInterestColor, fontSize: 10.5),
            ),
          ],
        ),
      ],
    );
  }
}

/// 双色比例条：蓝色是本金，黄色是利息。
class StackedRatioBar extends StatelessWidget {
  const StackedRatioBar({
    super.key,
    required this.principalRatio,
    this.height = 6,
    this.radius = 3,
  });

  /// 本金占比（0~1），其余部分显示为利息。
  final double principalRatio;

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final ratio = principalRatio.clamp(0.0, 1.0);
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Positioned.fill(child: ColoredBox(color: loanInterestColor)),
              SizedBox(
                width: constraints.maxWidth * ratio,
                height: height,
                child: const ColoredBox(color: loanPrincipalColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              '期数',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              groupByYear ? '当年还款' : '本期还款',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
              ),
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
            itemBuilder: (context, index) =>
                _PeriodRow(period: rows[index], byYear: groupByYear),
          ),
        ),
      ],
    );
  }
}

class _PeriodRow extends StatelessWidget {
  const _PeriodRow({required this.period, required this.byYear});

  final LoanPeriod period;
  final bool byYear;

  @override
  Widget build(BuildContext context) {
    final title = byYear ? '第 ${period.index} 年' : '第 ${period.index} 期';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '¥ ${formatMoney(period.payment)}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        StackedRatioBar(principalRatio: period.principalRatio),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              '本金 ¥ ${formatMoney(period.principal, decimals: 0)}',
              style: const TextStyle(color: loanPrincipalColor, fontSize: 10.5),
            ),
            const Spacer(),
            Text(
              '利息 ¥ ${formatMoney(period.interest, decimals: 0)}',
              style: const TextStyle(color: loanInterestColor, fontSize: 10.5),
            ),
          ],
        ),
      ],
    );
  }
}
