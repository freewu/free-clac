import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../state/settings_controller.dart';
import '../../../tools/bmi.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_unit_picker.dart';
import 'bmi_gauge.dart';

/// BMI 计算页：输入身高体重，实时给出分级、标准体重区间与建议。
///
/// 支持公制（cm / kg）与英制（ft·in / lb）切换，切换时按当前数值换算，
/// 结果不变。
class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  /// 默认值来自设置页（`BmiSetting`），页内仍可随时切换。
  BmiUnitSystem _unit =
      currentSettings?.bmiUnit ?? BmiUnitSystem.metric;

  /// 英制身高输入框的单位（ft / in），点输入框右侧的按钮切换。
  BmiImperialHeightUnit _heightUnit = BmiImperialHeightUnit.feet;

  /// 公制为身高（cm），英制为 ft 或 in（见 [_heightUnit]）。
  final TextEditingController _height = TextEditingController(text: '170');

  /// 公制为体重（kg），英制为磅（lb）。
  final TextEditingController _weight = TextEditingController(text: '65');

  @override
  void initState() {
    super.initState();
    // 默认单位是英制时，初始数值也跟着换成英制，别把 170 cm 当 170 ft。
    if (_unit == BmiUnitSystem.imperial) {
      _height.text = _formatImperialHeight(170);
      _weight.text = poundsFromKg(65).toStringAsFixed(1);
    }
  }

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double get _heightCm {
    final value = double.tryParse(_height.text) ?? 0;
    return switch (_unit) {
      BmiUnitSystem.metric => value,
      BmiUnitSystem.imperial =>
        _heightUnit == BmiImperialHeightUnit.feet
            ? cmFromFeet(value)
            : cmFromInches(value),
    };
  }

  double get _weightKg => _unit == BmiUnitSystem.metric
      ? double.tryParse(_weight.text) ?? 0
      : kgFromPounds(double.tryParse(_weight.text) ?? 0);

  BmiResult? get _result =>
      calculateBmi(heightCm: _heightCm, weightKg: _weightKg);

  void _switchUnit(BmiUnitSystem unit) {
    if (unit == _unit) return;
    final current = _result;
    setState(() {
      _unit = unit;
      if (current == null) return;
      if (unit == BmiUnitSystem.imperial) {
        _height.text = _formatImperialHeight(current.heightCm);
        _weight.text = current.weightPounds.toStringAsFixed(1);
      } else {
        _height.text = current.heightCm.toStringAsFixed(1);
        _weight.text = current.weightKg.toStringAsFixed(1);
      }
    });
  }

  /// ft / in 之间切换：按当前单位换算数值，BMI 保持不变。
  void _switchHeightUnit(BmiImperialHeightUnit unit) {
    if (unit == _heightUnit) return;
    final cm = _heightCm;
    setState(() {
      _heightUnit = unit;
      if (cm > 0) _height.text = _formatImperialHeight(cm);
    });
  }

  /// 厘米按当前英制单位格式化（两位小数）。
  String _formatImperialHeight(double cm) =>
      (_heightUnit == BmiImperialHeightUnit.feet
              ? feetFromCm(cm)
              : inchesFromCm(cm))
          .toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI 计算'),
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
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSection(
                  title: '输入',
                  icon: Icons.straighten_rounded,
                  trailing: _UnitSwitch(unit: _unit, onChanged: _switchUnit),
                  child: _unit == BmiUnitSystem.metric
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ToolNumberField(
                                label: '身高',
                                hint: '170 或 1.7',
                                suffix: 'cm',
                                controller: _height,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ToolNumberField(
                                label: '体重',
                                suffix: 'kg',
                                controller: _weight,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: ToolNumberField(
                                label: '身高',
                                controller: _height,
                                trailing: ToolUnitPicker<BmiImperialHeightUnit>(
                                  value: _heightUnit,
                                  items: BmiImperialHeightUnit.values,
                                  labelOf: (value) => value.symbol,
                                  menuLabelOf: (value) =>
                                      '${value.symbol}（${value.label}）',
                                  tooltip: '身高单位',
                                  onSelected: _switchHeightUnit,
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ToolNumberField(
                                label: '体重',
                                // 与身高单位同一套 suffixIcon 插槽，保证两个单位上下齐平
                                trailing: Text(
                                  'lb',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                                controller: _weight,
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  child: result == null
                      ? const _EmptyHint()
                      : _ResultBody(
                          result: result,
                          unit: _unit,
                          heightUnit: _heightUnit,
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

/// 公制 / 英制切换。
class _UnitSwitch extends StatelessWidget {
  const _UnitSwitch({required this.unit, required this.onChanged});

  final BmiUnitSystem unit;
  final ValueChanged<BmiUnitSystem> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in BmiUnitSystem.values)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              label: Text(value.label, style: const TextStyle(fontSize: 11.5)),
              selected: unit == value,
              onSelected: (_) => onChanged(value),
              visualDensity: VisualDensity.compact,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
      ],
    );
  }
}

/// 英制身高的输入单位：点开菜单切换 ft / in。
class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 30,
            color: AppColors.outline,
          ),
          SizedBox(height: 10),
          Text(
            '输入身高与体重后自动计算',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.result,
    required this.unit,
    required this.heightUnit,
  });

  final BmiResult result;
  final BmiUnitSystem unit;
  final BmiImperialHeightUnit heightUnit;

  bool get _metric => unit == BmiUnitSystem.metric;

  String get _heightText => _metric
      ? '${formatNumber(result.heightCm, significantDigits: 5)} cm'
      : '${(heightUnit == BmiImperialHeightUnit.feet ? feetFromCm(result.heightCm) : inchesFromCm(result.heightCm)).toStringAsFixed(2)} '
            '${heightUnit.symbol}';

  String get _weightText => _metric
      ? '${formatNumber(result.weightKg, significantDigits: 5)} kg'
      : '${result.weightPounds.toStringAsFixed(1)} lb';

  @override
  Widget build(BuildContext context) {
    final color = bmiCategoryColor(result.category);
    final unitLabel = _metric ? 'kg' : 'lb';
    final healthyMin = _metric ? result.healthyMinKg : result.healthyMinPounds;
    final healthyMax = _metric ? result.healthyMaxKg : result.healthyMaxPounds;
    final delta = _metric
        ? result.weightToHealthyCenter
        : result.weightToHealthyCenterPounds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'BMI',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              result.bmi.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 40,
                height: 1,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Text(
                result.category.label,
                style: TextStyle(
                  color: color,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '身高 $_heightText · 体重 $_weightText',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 16),
        BmiGauge(bmi: result.bmi),
        const SizedBox(height: 18),
        _StatRow(
          icon: Icons.check_circle_outline_rounded,
          label: '正常体重范围',
          value:
              '${healthyMin.toStringAsFixed(1)} ~ '
              '${healthyMax.toStringAsFixed(1)} $unitLabel',
          valueColor: AppColors.tertiary,
        ),
        const SizedBox(height: 10),
        _StatRow(
          icon: Icons.flag_outlined,
          label: result.weightToHealthyCenter >= 0 ? '距理想体重还需增重' : '距理想体重还需减重',
          value: '${delta.abs().toStringAsFixed(1)} $unitLabel',
          valueColor: AppColors.textPrimary,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 15, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.advice,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '分级依据：中国成人 BMI 标准（WS/T 428—2013）。结果仅供健康参考，不构成医疗建议。',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
