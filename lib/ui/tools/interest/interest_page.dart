import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import 'interest.dart';
import '../widgets/tool_field.dart';

/// 利率计算页：本金配日付 / 月付 / 年付，双向换算年化率。
///
/// * 输入每期收益 → 反推年化率
/// * 输入年化率 → 算出日付 / 月付 / 年付
class InterestPage extends StatefulWidget {
  const InterestPage({super.key});

  @override
  State<InterestPage> createState() => _InterestPageState();
}

/// 换算方向。
enum _Mode {
  fromPayment('由期付算年化'),
  fromRate('由年化算期付');

  const _Mode(this.label);

  final String label;
}

class _InterestPageState extends State<InterestPage> {
  _Mode _mode = _Mode.fromPayment;

  /// 当前关注的付息周期：模式一时是「输入哪一种期付」，
  /// 模式二时是「重点显示哪一种期付」。
  InterestPeriod _period = InterestPeriod.daily;

  final TextEditingController _principal = TextEditingController(text: '10000');
  final TextEditingController _payment = TextEditingController(text: '1');
  final TextEditingController _rate = TextEditingController(text: '3.65');

  @override
  void dispose() {
    _principal.dispose();
    _payment.dispose();
    _rate.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  /// 当前方向下算出的年化率（百分比），输入非法时为 null。
  double? get _annualRatePercent => switch (_mode) {
    _Mode.fromPayment => annualRatePercentFromPayment(
      principal: _parse(_principal),
      payment: _parse(_payment),
      period: _period,
    ),
    _Mode.fromRate => _parse(_rate),
  };

  /// 当前年化率对应的完整报价。
  InterestQuote? get _quote {
    final rate = _annualRatePercent;
    if (rate == null) return null;
    return interestQuote(
      principal: _parse(_principal),
      annualRatePercent: rate,
    );
  }

  /// 切换方向时把当前结果带过去，避免数值突变。
  void _switchMode(_Mode mode) {
    if (mode == _mode) return;
    final quote = _quote;
    setState(() {
      _mode = mode;
      if (quote == null) return;
      if (mode == _Mode.fromRate) {
        _rate.text = _trimRate(quote.annualRatePercent);
      } else {
        _payment.text = quote.paymentFor(_period).toStringAsFixed(2);
      }
    });
  }

  void _switchPeriod(InterestPeriod period) {
    if (period == _period) return;
    final quote = _quote;
    setState(() {
      _period = period;
      // 模式一时换周期要同步换算期付金额，年化率保持不变
      if (_mode == _Mode.fromPayment && quote != null) {
        _payment.text = quote.paymentFor(period).toStringAsFixed(2);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    final rate = _annualRatePercent;
    return Scaffold(
      appBar: AppBar(
        title: const Text('利率计算'),
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
                  title: '输入',
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolNumberField(
                        label: '本金',
                        suffix: '元',
                        controller: _principal,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '换算方向',
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
                          for (final mode in _Mode.values)
                            ChoiceChip(
                              label: Text(
                                mode.label,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _mode == mode,
                              onSelected: (_) => _switchMode(mode),
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '付息周期',
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
                          for (final period in InterestPeriod.values)
                            ChoiceChip(
                              label: Text(
                                period.label,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _period == period,
                              onSelected: (_) => _switchPeriod(period),
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_mode == _Mode.fromPayment)
                        ToolNumberField(
                          // everyLabel 本身已带「每」（每天 / 每月 / 每年）
                          label: '${_period.everyLabel}收益',
                          suffix: '元 / ${_period.everyLabel}',
                          controller: _payment,
                          allowNegative: true,
                          onChanged: (_) => setState(() {}),
                        )
                      else
                        ToolNumberField(
                          label: '年化率',
                          suffix: '%',
                          controller: _rate,
                          allowNegative: true,
                          onChanged: (_) => setState(() {}),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (quote == null || rate == null)
                  const ToolSection(child: _EmptyHint())
                else
                  ToolSection(
                    child: _QuoteResult(
                      quote: quote,
                      mode: _mode,
                      period: _period,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 去掉多余的小数位，用于把年化率回填到输入框。
String _trimRate(double percent) {
  final text = percent.toStringAsFixed(4);
  if (!text.contains('.')) return text;
  return text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
}

/// 年化率显示：小于 1% 时多留两位小数，避免显示成 0.01%。
String formatRatePercent(double percent) {
  final text = percent.abs() >= 1
      ? percent.toStringAsFixed(2)
      : percent.toStringAsFixed(4);
  return '$text%';
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(Icons.percent_rounded, size: 30, color: AppColors.outline),
          SizedBox(height: 10),
          Text(
            '填写本金与期付 / 年化率后自动换算',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _QuoteResult extends StatelessWidget {
  const _QuoteResult({
    required this.quote,
    required this.mode,
    required this.period,
  });

  final InterestQuote quote;
  final _Mode mode;
  final InterestPeriod period;

  @override
  Widget build(BuildContext context) {
    final fromPayment = mode == _Mode.fromPayment;
    final headline = fromPayment
        ? formatRatePercent(quote.annualRatePercent)
        : '¥ ${formatMoney(quote.paymentFor(period))}';
    final caption = fromPayment
        ? '年化率 · 本金 ¥ ${formatMoney(quote.principal, decimals: 0)} · '
              '${period.label} ¥ ${formatMoney(quote.paymentFor(period))}'
        : '${period.everyLabel}收益 · 年化率 '
              '${formatRatePercent(quote.annualRatePercent)} · '
              '本金 ¥ ${formatMoney(quote.principal, decimals: 0)}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          fromPayment ? '年化率' : '${period.everyLabel}收益',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 4),
        Text(
          headline,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 30,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caption,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final item in InterestPeriod.values)
              Expanded(
                child: _Stat(
                  label: item.label,
                  value: '¥ ${formatMoney(quote.paymentFor(item))}',
                  color: item == period
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                  bold: item == period,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        const SizedBox(height: 10),
        Wrap(
          spacing: 14,
          runSpacing: 4,
          children: [
            _FootNote(
              '${period.everyLabel}利率 '
              '${formatRatePercent(quote.rateFor(period) * 100)}',
            ),
            _FootNote(
              '每万元${period.label} '
              '¥ ${formatMoney(quote.paymentPerTenThousand(period))}',
            ),
            _FootNote('年化 ${formatRatePercent(quote.annualRatePercent)}'),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;

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
            fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _FootNote extends StatelessWidget {
  const _FootNote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
    );
  }
}
