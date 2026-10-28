import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../tools/pension.dart';
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
  final TextEditingController _age = TextEditingController(text: '30');
  final TextEditingController _paidYears = TextEditingController(text: '5');
  final TextEditingController _balance = TextEditingController(text: '50000');
  final TextEditingController _wage = TextEditingController(text: '10000');
  final TextEditingController _socialWage = TextEditingController(text: '8000');
  final TextEditingController _growth = TextEditingController(text: '5');
  final TextEditingController _accountRate = TextEditingController(text: '3');

  /// 预计退休年龄，决定计发月数。
  int _retireAge = 60;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('养老金计算器'),
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
                  title: '参保情况',
                  icon: Icons.person_outline_rounded,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final age = ToolNumberField(
                        label: '当前年龄',
                        suffix: '岁',
                        controller: _age,
                        onChanged: (_) => setState(() {}),
                      );
                      final retire = ToolSelect<int>(
                        key: const Key('pension-retire-age'),
                        label: '预计退休年龄',
                        value: _retireAge,
                        items: kPensionRetireAges,
                        labelOf: (age) =>
                            '$age 岁 · 计发 ${pensionPayoutMonthsOf(age)} 个月',
                        onChanged: (age) => setState(() => _retireAge = age),
                      );
                      final paid = ToolNumberField(
                        label: '已缴费年限',
                        suffix: '年',
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
                  title: '缴费与账户',
                  icon: Icons.account_balance_wallet_outlined,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wage = ToolNumberField(
                        label: '月缴费工资',
                        suffix: '元',
                        controller: _wage,
                        onChanged: (_) => setState(() {}),
                      );
                      final social = ToolNumberField(
                        label: '当地社平工资',
                        suffix: '元/月',
                        controller: _socialWage,
                        onChanged: (_) => setState(() {}),
                      );
                      final balance = ToolNumberField(
                        label: '个人账户余额',
                        suffix: '元',
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
                  title: '增长假设',
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
                        _advancedExpanded ? '收起' : '展开',
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
                                    label: '社平工资年增长',
                                    suffix: '%',
                                    controller: _growth,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ToolNumberField(
                                    label: '个人账户记账利率',
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
                              '个人账户按本人缴费基数的 '
                              '${kPensionPersonalRate.toStringAsFixed(0)}% 记入，'
                              '缴费基数随社平工资同步增长。',
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
                      ? const _EmptyHint()
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
            '填入年龄、缴费工资与账户余额后自动测算',
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
    final total = result.totalMonthly;
    final baseRatio = total <= 0 ? 0.0 : result.basePension / total;
    final accountRatio = total <= 0 ? 0.0 : result.accountPension / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '预计每月养老金',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text(
          '¥ ${formatMoney(total)}',
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
          '替代率 ${(result.replacementRate * 100).toStringAsFixed(1)}%'
          ' · 退休时社平工资 ¥ ${formatMoney(result.socialWageAtRetire, decimals: 0)}/月',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 12),
        AmountBar(
          key: const Key('pension-base'),
          label: '基础养老金',
          value: '¥ ${formatMoney(result.basePension)}',
          ratio: baseRatio,
          labelWidth: 64,
          valueWidth: 96,
          segments: [RatioSegment(value: 1, color: AppColors.primary)],
        ),
        const SizedBox(height: 6),
        AmountBar(
          key: const Key('pension-account'),
          label: '个人账户',
          value: '¥ ${formatMoney(result.accountPension)}',
          ratio: accountRatio,
          labelWidth: 64,
          valueWidth: 96,
          segments: [RatioSegment(value: 1, color: AppColors.tertiary)],
        ),
        const SizedBox(height: 10),
        Divider(height: 1, color: AppColors.outline),
        const SizedBox(height: 8),
        _DetailRow(
          label: '缴费年限',
          value:
              '已缴 ${formatNumber(result.paidYears)} 年'
              ' + 续缴 ${result.remainingYears} 年'
              ' = ${formatNumber(result.totalYears)} 年',
        ),
        _DetailRow(
          label: '平均缴费指数',
          value: result.contributionIndex.toStringAsFixed(2),
        ),
        _DetailRow(
          label: '退休时个人账户',
          value:
              '¥ ${formatMoney(result.accountAtRetire, decimals: 0)}'
              '（其中利息 ¥ ${formatMoney(result.accountInterest, decimals: 0)}）',
        ),
        _DetailRow(label: '计发月数', value: '${result.payoutMonths} 个月'),
        _DetailRow(
          label: '退休前月工资',
          value: '¥ ${formatMoney(result.wageAtRetire, decimals: 0)}',
        ),
        const SizedBox(height: 8),
        Text(
          '按国发〔2005〕38 号口径测算：基础养老金 =（社平工资 + 本人指数化月平均缴费工资）'
          '÷ 2 × 缴费年限 × 1%，个人账户养老金 = 账户储存额 ÷ 计发月数。'
          '不含过渡性养老金、企业年金与地方补贴，结果仅供参考。',
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
