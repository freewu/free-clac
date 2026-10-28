import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/app_i18n.dart';
import 'compound.dart';
import 'compound_strings.dart';
import '../widgets/tool_field.dart';

/// 复利计算页：本金、利率、期限、复利频率与定期追加，输出本息与逐年增长表。
class CompoundPage extends StatefulWidget {
  const CompoundPage({super.key});

  @override
  State<CompoundPage> createState() => _CompoundPageState();
}

class _CompoundPageState extends State<CompoundPage> {
  final TextEditingController _principal = TextEditingController(
    text: '100000',
  );
  final TextEditingController _rate = TextEditingController(text: '5');
  final TextEditingController _years = TextEditingController(text: '10');
  final TextEditingController _contribution = TextEditingController(text: '0');

  CompoundFrequency _frequency = CompoundFrequency.yearly;

  @override
  void dispose() {
    _principal.dispose();
    _rate.dispose();
    _years.dispose();
    _contribution.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  CompoundResult? get _result => compoundInterest(
    CompoundInput(
      principal: _parse(_principal),
      annualRatePercent: _parse(_rate),
      years: _parse(_years),
      frequency: _frequency,
      contributionPerPeriod: _parse(_contribution),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(compoundStrings.title),
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
                  title: compoundStrings.sectionInput,
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final principal = ToolNumberField(
                            label: compoundStrings.principal,
                            suffix: compoundStrings.currency,
                            controller: _principal,
                            onChanged: (_) => setState(() {}),
                          );
                          final rate = ToolNumberField(
                            label: compoundStrings.annualRate,
                            suffix: '%',
                            controller: _rate,
                            allowNegative: true,
                            onChanged: (_) => setState(() {}),
                          );
                          final years = ToolNumberField(
                            label: compoundStrings.years,
                            suffix: compoundStrings.yearsSuffix,
                            controller: _years,
                            onChanged: (_) => setState(() {}),
                          );
                          // 三项按 2 : 1 : 1 排一行；窄屏会把利率挤得只剩两位数，
                          // 改成「本金一行 + 利率 / 年限一行」
                          if (constraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                principal,
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(child: rate),
                                    const SizedBox(width: 12),
                                    Expanded(child: years),
                                  ],
                                ),
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(flex: 2, child: principal),
                              const SizedBox(width: 12),
                              Expanded(child: rate),
                              const SizedBox(width: 12),
                              Expanded(child: years),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ToolNumberField(
                        label: compoundStrings.contribution,
                        suffix: fill(compoundStrings.contributionSuffix, [
                          compoundStrings.frequencyLabel(_frequency),
                        ]),
                        controller: _contribution,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        compoundStrings.frequency,
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
                          for (final frequency in CompoundFrequency.values)
                            ChoiceChip(
                              label: Text(
                                frequency.label,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _frequency == frequency,
                              onSelected: (_) =>
                                  setState(() => _frequency = frequency),
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
                    title: compoundStrings.sectionTable,
                    icon: Icons.table_chart_outlined,
                    trailing: Text(
                      fill(compoundStrings.frequencyNote, [
                        compoundStrings.frequencyLabel(result.frequency),
                      ]),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    child: _YearTable(result: result),
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

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, size: 30, color: AppColors.outline),
          SizedBox(height: 10),
          Text(
            compoundStrings.emptyHint,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.result});

  final CompoundResult result;

  @override
  Widget build(BuildContext context) {
    final gainPositive = result.totalGain >= 0;
    final gainColor = gainPositive ? AppColors.tertiary : AppColors.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          compoundStrings.futureValue,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                '¥ ${formatMoney(result.futureValue)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          fill(compoundStrings.periodsNote, [
            compoundStrings.frequencyLabel(result.frequency),
            formatNumber(result.periods, significantDigits: 6),
            result.effectiveAnnualRatePercent.toStringAsFixed(2),
          ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: compoundStrings.totalInvested,
                value: '¥ ${formatMoney(result.totalInvested)}',
                color: AppColors.textPrimary,
              ),
            ),
            Expanded(
              child: _Stat(
                label: compoundStrings.totalGain,
                value: '¥ ${formatMoney(result.totalGain)}',
                color: gainColor,
              ),
            ),
            Expanded(
              child: _Stat(
                label: compoundStrings.gainRate,
                value: '${(result.gainRate * 100).toStringAsFixed(1)}%',
                color: gainColor,
              ),
            ),
          ],
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

class _YearTable extends StatelessWidget {
  const _YearTable({required this.result});

  final CompoundResult result;

  @override
  Widget build(BuildContext context) {
    if (result.yearly.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Text(
          compoundStrings.noYearly,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TableRow(
          year: compoundStrings.colYear,
          invested: compoundStrings.colInvested,
          balance: compoundStrings.colBalance,
          gain: compoundStrings.colGain,
          header: true,
        ),
        const Divider(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 240),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: result.yearly.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final point = result.yearly[index];
              return _TableRow(
                year: fill(compoundStrings.yearRow, [point.year]),
                invested: '¥ ${formatMoney(point.contributions, decimals: 0)}',
                balance: '¥ ${formatMoney(point.balance, decimals: 0)}',
                gain: '¥ ${formatMoney(point.gain, decimals: 0)}',
                highlight: index == result.yearly.length - 1,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.year,
    required this.invested,
    required this.balance,
    required this.gain,
    this.highlight = false,
    this.header = false,
  });

  final String year;
  final String invested;
  final String balance;
  final String gain;
  final bool highlight;
  final bool header;

  @override
  Widget build(BuildContext context) {
    final cellStyle = TextStyle(
      color: header
          ? AppColors.textSecondary
          : (highlight ? AppColors.textPrimary : AppColors.textSecondary),
      fontSize: header ? 10.5 : 11.5,
      fontWeight: (header || highlight) ? FontWeight.w600 : FontWeight.w400,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 62, child: Text(year, style: cellStyle)),
          Expanded(child: _cell(invested, TextAlign.right, cellStyle)),
          Expanded(
            child: _cell(
              balance,
              TextAlign.right,
              cellStyle.copyWith(
                color: header
                    ? AppColors.textSecondary
                    : (highlight ? AppColors.primary : AppColors.textPrimary),
              ),
            ),
          ),
          Expanded(
            child: _cell(
              gain,
              TextAlign.right,
              cellStyle.copyWith(
                color: header ? AppColors.textSecondary : AppColors.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, TextAlign align, TextStyle style) => Text(
    text,
    textAlign: align,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: style,
  );
}
