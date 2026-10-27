import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../../../tools/bmi.dart';
import '../widgets/tool_field.dart';
import 'bmi_gauge.dart';

/// BMI 计算页：输入身高体重，实时给出分级、标准体重区间与建议。
class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final TextEditingController _height = TextEditingController(text: '170');
  final TextEditingController _weight = TextEditingController(text: '65');

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  BmiResult? get _result => calculateBmi(
    heightCm: double.tryParse(_height.text) ?? 0,
    weightKg: double.tryParse(_weight.text) ?? 0,
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI 计算'),
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
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSection(
                  title: '输入',
                  icon: Icons.straighten_rounded,
                  child: Row(
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
                  ),
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
    return const Padding(
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
  const _ResultBody({required this.result});

  final BmiResult result;

  @override
  Widget build(BuildContext context) {
    final color = bmiCategoryColor(result.category);
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
          '身高 ${formatNumber(result.heightCm, significantDigits: 5)} cm · '
          '体重 ${formatNumber(result.weightKg, significantDigits: 5)} kg',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
        ),
        const SizedBox(height: 16),
        BmiGauge(bmi: result.bmi),
        const SizedBox(height: 18),
        _StatRow(
          icon: Icons.check_circle_outline_rounded,
          label: '正常体重范围',
          value:
              '${result.healthyMinKg.toStringAsFixed(1)} ~ '
              '${result.healthyMaxKg.toStringAsFixed(1)} kg',
          valueColor: AppColors.tertiary,
        ),
        const SizedBox(height: 10),
        _StatRow(
          icon: Icons.flag_outlined,
          label: result.weightToHealthyCenter >= 0 ? '距理想体重还需增重' : '距理想体重还需减重',
          value: '${result.weightToHealthyCenter.abs().toStringAsFixed(1)} kg',
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
                  style: const TextStyle(
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
        const Text(
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
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
          ),
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
