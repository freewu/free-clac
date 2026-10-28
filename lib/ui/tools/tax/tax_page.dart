import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../tools/tax.dart';
import '../widgets/tool_bars.dart';
import '../widgets/tool_field.dart';

/// 五险一金各项的颜色（构成条与明细用）。
Color insuranceColor(InsuranceItem item) => switch (item) {
  InsuranceItem.pension => AppColors.primary,
  InsuranceItem.medical => AppColors.secondary,
  InsuranceItem.unemployment => AppColors.warning,
  InsuranceItem.housingFund => AppColors.tertiary,
};

/// 个税条的颜色。
final Color taxBarColor = AppColors.error;

/// 个人所得税计算：税前月薪 → 五险一金 → 个税 → 到手，按累计预扣法逐月算。
class TaxPage extends StatefulWidget {
  const TaxPage({super.key});

  @override
  State<TaxPage> createState() => _TaxPageState();
}

class _TaxPageState extends State<TaxPage> {
  final TextEditingController _salary = TextEditingController(text: '20000');
  final TextEditingController _base = TextEditingController();
  final TextEditingController _special = TextEditingController(text: '0');

  /// 各项缴纳比例（%）的输入框。
  final Map<InsuranceItem, TextEditingController> _rateControllers = {
    for (final item in InsuranceItem.values)
      item: TextEditingController(text: _trimRate(item.defaultRatePercent)),
  };

  @override
  void dispose() {
    _salary.dispose();
    _base.dispose();
    _special.dispose();
    for (final controller in _rateControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _value(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  /// 基数留空时按税前月薪算。
  double get _gross => _value(_salary);

  double get _contributionBase =>
      _base.text.trim().isEmpty ? _gross : _value(_base);

  InsuranceRates get _rates => InsuranceRates({
    for (final entry in _rateControllers.entries)
      entry.key: _value(entry.value),
  });

  PayrollResult? get _result => calculatePayroll(
    PayrollPlan(
      grossMonthly: _gross,
      contributionBase: _contributionBase,
      rates: _rates,
      specialDeductionMonthly: _value(_special),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final rates = _rates;
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人所得税'),
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
                  title: '收入',
                  icon: Icons.payments_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final salary = ToolNumberField(
                        label: '税前月薪',
                        suffix: '元',
                        controller: _salary,
                        onChanged: (_) => setState(() {}),
                      );
                      final base = ToolNumberField(
                        label: '缴费基数',
                        suffix: '元',
                        hint: '默认等于月薪',
                        controller: _base,
                        onChanged: (_) => setState(() {}),
                      );
                      final special = ToolNumberField(
                        label: '专项附加扣除',
                        suffix: '元 / 月',
                        controller: _special,
                        onChanged: (_) => setState(() {}),
                      );
                      if (constraints.maxWidth < 420) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            salary,
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: base),
                                const SizedBox(width: 12),
                                Expanded(child: special),
                              ],
                            ),
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(flex: 3, child: salary),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: base),
                          const SizedBox(width: 12),
                          Expanded(flex: 4, child: special),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  title: '五险一金（个人缴纳比例）',
                  icon: Icons.account_balance_outlined,
                  trailing: Text(
                    '合计 ${_trimRate(rates.totalPercent)}%',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final fields = [
                        for (final item in InsuranceItem.values)
                          ToolNumberField(
                            label: item.label,
                            suffix: '%',
                            controller: _rateControllers[item]!,
                            onChanged: (_) => setState(() {}),
                          ),
                      ];
                      if (constraints.maxWidth < 420) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < fields.length; i += 2) ...[
                              if (i > 0) const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(child: fields[i]),
                                  const SizedBox(width: 12),
                                  Expanded(child: fields[i + 1]),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            _BaseHint(
                              base: _contributionBase,
                              total: result?.contributionMonthly ?? 0,
                            ),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (var i = 0; i < fields.length; i++) ...[
                                if (i > 0) const SizedBox(width: 12),
                                Expanded(child: fields[i]),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          _BaseHint(
                            base: _contributionBase,
                            total: result?.contributionMonthly ?? 0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  child: result == null
                      ? const _EmptyHint()
                      : _ResultBody(result: result),
                ),
                const SizedBox(height: 12),
                if (result != null)
                  ToolSection(
                    title: '月度明细',
                    icon: Icons.table_rows_outlined,
                    child: _MonthTable(result: result),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 去掉多余的小数位（8.0 → 8、0.5 → 0.5）。
String _trimRate(double value) {
  final text = value.toStringAsFixed(2);
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

class _BaseHint extends StatelessWidget {
  const _BaseHint({required this.base, required this.total});

  final double base;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Text(
      '按基数 ¥ ${formatMoney(base, decimals: 0)} 计算，每月个人缴纳 '
      '¥ ${formatMoney(total)}',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 30, color: AppColors.outline),
          SizedBox(height: 10),
          Text(
            '填写税前月薪与缴纳比例后自动计算',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});

  final PayrollResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '首月到手',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text(
          '¥ ${formatMoney(result.firstMonthNet)}',
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
          '税前 ¥ ${formatMoney(result.grossMonthly, decimals: 0)} − 五险一金 '
          '¥ ${formatMoney(result.contributionMonthly, decimals: 0)} − 个税 '
          '¥ ${formatMoney(result.firstMonthTax)}',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: '全年个税',
                value: '¥ ${formatMoney(result.yearlyTax, decimals: 0)}',
                color: taxBarColor,
              ),
            ),
            Expanded(
              child: _Stat(
                label: '全年到手',
                value: '¥ ${formatMoney(result.yearlyNet, decimals: 0)}',
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: '适用税率',
                value: '${_trimRate(result.marginalRatePercent)}%',
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '五险一金构成（每月）',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 6),
        if (result.contributionMonthly > 0) ...[
          SegmentedBar(
            height: 10,
            radius: 5,
            segments: [
              for (final item in InsuranceItem.values)
                if (result.byItem[item]! > 0)
                  RatioSegment(
                    value: result.byItem[item]!,
                    color: insuranceColor(item),
                  ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (final item in InsuranceItem.values)
                _Legend(
                  color: insuranceColor(item),
                  label: item.label,
                  value: '¥ ${formatMoney(result.byItem[item]!)}',
                ),
            ],
          ),
        ] else
          Text(
            '未缴纳五险一金',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
      ],
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
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
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

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text('$label $value', style: TextStyle(color: color, fontSize: 10.5)),
      ],
    );
  }
}

class _MonthTable extends StatelessWidget {
  const _MonthTable({required this.result});

  final PayrollResult result;

  /// 明细行的列宽：月份 / 个税 / 到手。
  static const double _monthWidth = 46;
  static const double _taxWidth = 86;
  static const double _netWidth = 96;

  @override
  Widget build(BuildContext context) {
    final maxTax = result.maxMonthlyTax;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: _monthWidth,
              child: Text('月份', style: _headerStyle),
            ),
            const Expanded(child: SizedBox()),
            SizedBox(
              width: _taxWidth,
              child: Text(
                '个税',
                textAlign: TextAlign.right,
                style: _headerStyle,
              ),
            ),
            SizedBox(
              width: _netWidth,
              child: Text(
                '到手',
                textAlign: TextAlign.right,
                style: _headerStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        for (final month in result.months)
          Padding(
            key: ValueKey('tax-month-${month.index}'),
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                SizedBox(
                  width: _monthWidth,
                  child: Text(
                    '第 ${month.index} 月',
                    maxLines: 1,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      // 条长按「当月个税 ÷ 最高月个税」缩放，一眼看出跳档
                      widthFactor: maxTax <= 0
                          ? 0
                          : (month.tax / maxTax).clamp(0.0, 1.0),
                      child: SegmentedBar(
                        height: 7,
                        radius: 3.5,
                        segments: [RatioSegment(value: 1, color: taxBarColor)],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: _taxWidth,
                  child: Text(
                    formatMoney(month.tax),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: taxBarColor,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                SizedBox(
                  width: _netWidth,
                  child: Text(
                    formatMoney(month.net),
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

final TextStyle _headerStyle = TextStyle(
  color: AppColors.textSecondary,
  fontSize: 10,
);
