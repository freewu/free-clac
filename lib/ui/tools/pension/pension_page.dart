import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../l10n/money.dart';
import '../../../theme/app_theme.dart';
import 'pension.dart';
import 'pension_strings.dart';
import '../tool_draft.dart';
import '../widgets/tool_bars.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_select.dart';

/// 养老金计算器页：输入年龄、缴费年限、缴费工资与账户余额，测算退休时的月养老金。
class PensionPage extends StatefulWidget {
  const PensionPage({super.key});

  @override
  State<PensionPage> createState() => _PensionPageState();
}

class _PensionPageState extends State<PensionPage> {
  /// 上次填的各项参数与选的退休年龄。
  final ToolDraft _draft = ToolDraft('pension');

  late final TextEditingController _age = _draft.controller('age', '30');
  late final TextEditingController _paidYears = _draft.controller(
    'paidYears',
    '5',
  );
  late final TextEditingController _balance = _draft.controller(
    'balance',
    '50000',
  );
  late final TextEditingController _wage = _draft.controller('wage', '10000');
  late final TextEditingController _socialWage = _draft.controller(
    'socialWage',
    '8000',
  );
  late final TextEditingController _growth = _draft.controller('growth', '5');
  late final TextEditingController _accountRate = _draft.controller(
    'accountRate',
    '3',
  );

  /// 预计退休年龄，决定计发月数。
  late int _retireAge = _draft.integer('retireAge') ?? 60;

  /// 增长假设默认收起，绝大多数人只需要改前两栏。
  bool _advancedExpanded = false;

  @override
  void dispose() {
    _age.dispose();
    _paidYears.dispose();
    _balance.dispose();
    _wage.dispose();
    _socialWage.dispose();
    _growth.dispose();
    _accountRate.dispose();
    super.dispose();
  }

  double _valueOf(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  PensionResult? get _result => calculatePension(
    PensionInput(
      age: _valueOf(_age).round(),
      retireAge: _retireAge,
      paidYears: _valueOf(_paidYears),
      balance: _valueOf(_balance),
      monthlyWage: _valueOf(_wage),
      socialAverageWage: _valueOf(_socialWage),
      socialGrowthPercent: _valueOf(_growth),
      accountRatePercent: _valueOf(_accountRate),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final s = pensionStrings;
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final age = ToolNumberField(
                        label: s.age,
                        suffix: s.ageSuffix,
                        controller: _age,
                        onChanged: (_) => setState(() {}),
                      );
                      final retire = ToolSelect<int>(
                        key: const Key('pension-retire-age'),
                        label: s.retireAge,
                        value: _retireAge,
                        items: kPensionRetireAges,
                        labelOf: (age) => fill(s.retireAgeOption, [
                          age,
                          pensionPayoutMonthsOf(age),
                        ]),
                        onChanged: (age) {
                          _draft.set('retireAge', age);
                          setState(() => _retireAge = age);
                        },
                      );
                      final paid = ToolNumberField(
                        label: s.paidYears,
                        suffix: s.yearsSuffix,
                        controller: _paidYears,
                        onChanged: (_) => setState(() {}),
                      );
                      // 窄屏排不下三栏：年龄与缴费年限并排，退休年龄独占一行
                      if (constraints.maxWidth < 520) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: age),
                                const SizedBox(width: 10),
                                Expanded(child: paid),
                              ],
                            ),
                            const SizedBox(height: 12),
                            retire,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: age),
                          const SizedBox(width: 10),
                          Expanded(flex: 2, child: retire),
                          const SizedBox(width: 10),
                          Expanded(child: paid),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  title: s.sectionMoney,
                  icon: Icons.account_balance_wallet_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wage = ToolNumberField(
                        label: s.wage,
                        suffix: currencySymbol,
                        controller: _wage,
                        onChanged: (_) => setState(() {}),
                      );
                      final social = ToolNumberField(
                        label: s.socialWage,
                        suffix: s.socialWageSuffix,
                        controller: _socialWage,
                        onChanged: (_) => setState(() {}),
                      );
                      final balance = ToolNumberField(
                        label: s.balance,
                        suffix: currencySymbol,
                        controller: _balance,
                        onChanged: (_) => setState(() {}),
                      );
                      final fields = <Widget>[wage, social, balance];
                      if (constraints.maxWidth < 520) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < fields.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              fields[i],
                            ],
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var i = 0; i < fields.length; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Expanded(child: fields[i]),
                          ],
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  key: const Key('pension-advanced'),
                  title: s.sectionAdvanced,
                  icon: Icons.trending_up_rounded,
                  onHeaderTap: () =>
                      setState(() => _advancedExpanded = !_advancedExpanded),
                  padding: EdgeInsets.fromLTRB(
                    14,
                    12,
                    14,
                    _advancedExpanded ? 14 : 12,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _advancedExpanded ? s.collapse : s.expand,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                        ),
                      ),
                      Icon(
                        _advancedExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                  child: _advancedExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ToolNumberField(
                                    label: s.growth,
                                    suffix: '%',
                                    controller: _growth,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ToolNumberField(
                                    label: s.accountRate,
                                    suffix: '%',
                                    allowNegative: true,
                                    controller: _accountRate,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              fill(s.accountNote, [
                                kPensionPersonalRate.toStringAsFixed(0),
                              ]),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  child: result == null
                      ? _EmptyHint(text: s.emptyHint)
                      : _ResultBody(result: result),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(Icons.savings_outlined, size: 30, color: AppColors.outline),
          SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});

  final PensionResult result;

  @override
  Widget build(BuildContext context) {
    final s = pensionStrings;
    final total = result.totalMonthly;
    final baseRatio = total <= 0 ? 0.0 : result.basePension / total;
    final accountRatio = total <= 0 ? 0.0 : result.accountPension / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.expectedMonthly,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text(
          money(total),
          style: TextStyle(
            fontSize: 26,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          fill(s.replacement, [
            (result.replacementRate * 100).toStringAsFixed(1),
            money(result.socialWageAtRetire, decimals: 0),
          ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 12),
        AmountBar(
          key: const Key('pension-base'),
          label: s.basePension,
          value: money(result.basePension),
          ratio: baseRatio,
          labelWidth: 64,
          valueWidth: 96,
          segments: [RatioSegment(value: 1, color: AppColors.primary)],
        ),
        const SizedBox(height: 6),
        AmountBar(
          key: const Key('pension-account'),
          label: s.accountPension,
          value: money(result.accountPension),
          ratio: accountRatio,
          labelWidth: 64,
          valueWidth: 96,
          segments: [RatioSegment(value: 1, color: AppColors.tertiary)],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: AppColors.outline),
        const SizedBox(height: 8),
        _DetailRow(
          label: s.paidYearsRow,
          value: fill(s.paidYearsValue, [
            formatNumber(result.paidYears),
            result.remainingYears,
            formatNumber(result.totalYears),
          ]),
        ),
        _DetailRow(
          label: s.avgIndex,
          value: result.contributionIndex.toStringAsFixed(2),
        ),
        _DetailRow(
          label: s.accountAtRetire,
          value: fill(s.accountAtRetireValue, [
            money(result.accountAtRetire, decimals: 0),
            money(result.accountInterest, decimals: 0),
          ]),
        ),
        _DetailRow(
          label: s.payoutMonths,
          value: fill(s.payoutMonthsValue, [result.payoutMonths]),
        ),
        _DetailRow(
          label: s.wageAtRetire,
          value: money(result.wageAtRetire, decimals: 0),
        ),
        const SizedBox(height: 8),
        Text(
          s.policyNote,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
