import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../tools/distance.dart';
import '../widgets/tool_field.dart';

/// 长度换算页：公制 / 英制 / 市制共 25 个单位互转，输入即算。
class DistancePage extends StatefulWidget {
  const DistancePage({super.key});

  @override
  State<DistancePage> createState() => _DistancePageState();
}

class _DistancePageState extends State<DistancePage> {
  /// 输入单位，默认米。
  DistanceUnit _from = distanceUnitById('m')!;

  final TextEditingController _value = TextEditingController(text: '1');

  @override
  void dispose() {
    _value.dispose();
    super.dispose();
  }

  double? get _amount {
    final value = double.tryParse(_value.text);
    if (value == null || !value.isFinite) return null;
    return value;
  }

  /// 当前单位所在体系，决定下面显示哪一排单位按钮。
  DistanceSystem get _system => _from.system;

  void _switchSystem(DistanceSystem system) {
    if (system == _system) return;
    // 切体系时落到该体系的第一个单位，数值保持不变（1 米 → 1 千米不是用户想要的，
    // 但体系切换本身就是换基准，这里只换单位不换数值，配合参照物更快）。
    setState(() => _from = distanceUnitsOf(system).first);
  }

  /// 点击参照物：把数值与单位一起代入。
  void _applySample(DistanceSample sample) {
    final unit = sample.unit;
    if (unit == null) return;
    setState(() {
      _from = unit;
      _value.text = _trim(sample.value);
    });
  }

  Future<void> _copy(DistanceUnit unit, String text) async {
    await Clipboard.setData(ClipboardData(text: '$text ${unit.label}'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 $text ${unit.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    return Scaffold(
      appBar: AppBar(
        title: const Text('长度换算'),
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
                      ToolNumberField(
                        label: '数值',
                        suffix: _from.symbol,
                        controller: _value,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '计量体系',
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
                          for (final system in DistanceSystem.values)
                            ChoiceChip(
                              label: Text(
                                system.label,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _system == system,
                              onSelected: (_) => _switchSystem(system),
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_system.label}单位',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final unit in distanceUnitsOf(_system))
                            ChoiceChip(
                              label: Text(
                                unit.label,
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _from == unit,
                              onSelected: (_) => setState(() => _from = unit),
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                      if (_from.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _from.note,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (amount == null)
                  const ToolSection(child: _EmptyHint())
                else
                  ToolSection(
                    title: '换算结果',
                    icon: Icons.swap_horiz_rounded,
                    child: _ResultList(
                      amount: amount,
                      from: _from,
                      onCopy: _copy,
                    ),
                  ),
                const SizedBox(height: 12),
                ToolSection(
                  title: '常见长度',
                  icon: Icons.lightbulb_outline_rounded,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final sample in kDistanceSamples)
                        ActionChip(
                          label: Text(
                            sample.label,
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          visualDensity: VisualDensity.compact,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          onPressed: () => _applySample(sample),
                        ),
                    ],
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

/// 去掉整数末尾的 `.0`，用于把参照物数值回填到输入框。
String _trim(double value) {
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

/// 换算结果：按体系分组列出全部单位，点击任意一行复制。
class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.amount,
    required this.from,
    required this.onCopy,
  });

  final double amount;
  final DistanceUnit from;
  final void Function(DistanceUnit unit, String text) onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${formatNumber(amount, significantDigits: 10)} ${from.label}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            height: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 12),
        for (final system in DistanceSystem.values) ...[
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 2),
            child: Text(
              system.label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          for (final unit in distanceUnitsOf(system))
            _ResultRow(
              unit: unit,
              text: _format(convertDistance(amount, from: from, to: unit)),
              highlighted: unit == from,
              onTap: () => onCopy(
                unit,
                _format(convertDistance(amount, from: from, to: unit)),
              ),
            ),
        ],
        const SizedBox(height: 4),
        const Text(
          '点任意一行即可复制',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
      ],
    );
  }

  static String _format(double? value) =>
      value == null ? '—' : formatNumber(value, significantDigits: 10);
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.unit,
    required this.text,
    required this.highlighted,
    required this.onTap,
  });

  final DistanceUnit unit;
  final String text;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                unit.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: highlighted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: highlighted
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 32,
              child: Text(
                unit.symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(Icons.straighten_rounded, size: 30, color: AppColors.outline),
          SizedBox(height: 10),
          Text(
            '填入数值并选好单位后自动换算',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
