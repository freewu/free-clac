import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_bars.dart';
import '../widgets/tool_field.dart';
import '../widgets/tool_select.dart';
import 'bmr.dart';
import 'bmr_strings.dart';

/// 基础代谢页：填体重、身高、年龄并选活动水平，
/// 用 Mifflin-St Jeor 公式输出 BMR 与各活动水平下的 TDEE。
class BmrPage extends StatefulWidget {
  const BmrPage({super.key});

  @override
  State<BmrPage> createState() => _BmrPageState();
}

class _BmrPageState extends State<BmrPage> {
  /// 上次填的年龄身高体重与选的性别 / 活动水平。
  final ToolDraft _draft = ToolDraft('bmr');

  /// 默认性别与活动水平来自设置页（`BmrSetting`），页内仍可随时切换；
  /// 打开过一次后以草稿里的上次选择为准。
  late BmrGender _gender =
      BmrGender.fromCode(_draft.text('gender')) ??
      currentSettings?.bmrGender ??
      BmrGender.male;
  late BmrActivity _activity =
      BmrActivity.fromCode(_draft.text('activity')) ??
      currentSettings?.bmrActivity ??
      BmrActivity.light;

  late final TextEditingController _age = _draft.controller('age', '30');
  late final TextEditingController _height = _draft.controller('height', '170');
  late final TextEditingController _weight = _draft.controller('weight', '65');

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  BmrResult? get _result => calculateBmr(
    gender: _gender,
    age: _parse(_age),
    heightCm: _parse(_height),
    weightKg: _parse(_weight),
    activity: _activity,
  );

  @override
  Widget build(BuildContext context) {
    final result = _result;
    final s = bmrStrings;
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
                  title: s.sectionBody,
                  icon: Icons.person_outline_rounded,
                  trailing: _GenderSwitch(
                    gender: _gender,
                    onChanged: (gender) {
                      _draft.setEnum('gender', gender);
                      setState(() => _gender = gender);
                    },
                  ),
                  child: _BodyFields(
                    height: ToolNumberField(
                      label: s.height,
                      hint: s.heightHint,
                      suffix: 'cm',
                      controller: _height,
                      onChanged: (_) => setState(() {}),
                    ),
                    weight: ToolNumberField(
                      label: s.weight,
                      suffix: 'kg',
                      controller: _weight,
                      onChanged: (_) => setState(() {}),
                    ),
                    age: ToolNumberField(
                      label: s.age,
                      suffix: s.ageSuffix,
                      controller: _age,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  title: s.sectionActivity,
                  icon: Icons.directions_run_rounded,
                  child: ToolSelect<BmrActivity>(
                    key: const Key('bmr-activity'),
                    value: _activity,
                    items: BmrActivity.values,
                    labelOf: s.activityOptionOf,
                    onChanged: (activity) {
                      _draft.setEnum('activity', activity);
                      setState(() => _activity = activity);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  key: const Key('bmr-result'),
                  child: result == null
                      ? const _EmptyHint()
                      : _ResultBody(result: result),
                ),
                if (result != null) ...[
                  const SizedBox(height: 12),
                  _LevelTable(result: result),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 性别切换：男 / 女两枚 chip，放在输入卡片的标题行右侧。
class _GenderSwitch extends StatelessWidget {
  const _GenderSwitch({required this.gender, required this.onChanged});

  final BmrGender gender;
  final ValueChanged<BmrGender> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in BmrGender.values)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ChoiceChip(
              key: Key('bmr-gender-${value.code}'),
              label: Text(
                bmrStrings.genderLabel(value),
                style: const TextStyle(fontSize: 11.5),
              ),
              selected: gender == value,
              onSelected: (_) => onChanged(value),
              visualDensity: VisualDensity.compact,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
      ],
    );
  }
}

/// 身高 / 体重 / 年龄三个输入框：宽屏排一行，窄屏把年龄单独放一行。
class _BodyFields extends StatelessWidget {
  const _BodyFields({
    required this.height,
    required this.weight,
    required this.age,
  });

  final Widget height;
  final Widget weight;
  final Widget age;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pair = Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: height),
            const SizedBox(width: 12),
            Expanded(child: weight),
          ],
        );
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [pair, const SizedBox(height: 12), age],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: height),
            const SizedBox(width: 12),
            Expanded(child: weight),
            const SizedBox(width: 12),
            Expanded(child: age),
          ],
        );
      },
    );
  }
}

/// 输入的千卡值：四舍五入到整数，去掉多余的分隔符。
String _kcal(double value) =>
    formatNumber(value.roundToDouble(), significantDigits: 5);

class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result});

  final BmrResult result;

  @override
  Widget build(BuildContext context) {
    final s = bmrStrings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Figure(
          label: s.bmrLabel,
          value: _kcal(result.bmr),
          suffix: s.energySuffix,
          color: AppColors.primary,
          valueKey: const Key('bmr-bmr'),
        ),
        const SizedBox(height: 12),
        // 基础代谢 + 活动额外消耗 = TDEE，用双色条把两者的比例画出来
        SegmentedBar(
          segments: [
            RatioSegment(value: result.bmr, color: AppColors.primary),
            RatioSegment(
              value: result.activityCalories,
              color: AppColors.tertiary,
            ),
          ],
          height: 8,
          radius: 4,
        ),
        const SizedBox(height: 7),
        Text(
          fill(s.activityShare, [
            '${_kcal(result.activityCalories)} ${s.energySuffix}',
          ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 16),
        _Figure(
          label: s.tdeeLabel,
          value: _kcal(result.tdee),
          suffix: s.energySuffix,
          color: AppColors.tertiary,
          valueKey: const Key('bmr-tdee'),
          badge: s.activityLabel(result.activity),
        ),
        const SizedBox(height: 6),
        Text(
          s.keepWeight,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 12),
        Text(
          fill(s.summary, [
            s.genderLabel(result.gender),
            result.age,
            formatNumber(result.heightCm, significantDigits: 5),
            formatNumber(result.weightKg, significantDigits: 5),
          ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 15,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  s.formulaNote,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          s.disclaimer,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
      ],
    );
  }
}

/// 一行「标签 + 活动水平角标 + 大数字 + 单位」。
class _Figure extends StatelessWidget {
  const _Figure({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
    this.badge,
    this.valueKey,
  });

  final String label;
  final String value;
  final String suffix;
  final Color color;

  /// 数字左边的活动水平角标（只有 TDEE 行有）。
  final String? badge;

  /// 大数字的 key，方便测试断言具体数值。
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (badge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          value,
          key: valueKey,
          style: TextStyle(
            fontSize: 28,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(
            suffix,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

/// 五种活动水平的每日总消耗：条长按最大的那一档缩放，当前档高亮。
class _LevelTable extends StatelessWidget {
  const _LevelTable({required this.result});

  final BmrResult result;

  @override
  Widget build(BuildContext context) {
    final s = bmrStrings;
    final values = result.tdeeByActivity;
    final max = values.reduce((a, b) => a > b ? a : b);
    return ToolSection(
      key: const Key('bmr-levels'),
      title: s.byActivity,
      icon: Icons.insights_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < BmrActivity.values.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            AmountBar(
              key: Key('bmr-level-${BmrActivity.values[i].code}'),
              label: s.activityLabel(BmrActivity.values[i]),
              value: _kcal(values[i]),
              ratio: max <= 0 ? 0 : values[i] / max,
              labelWidth: 76,
              valueWidth: 66,
              segments: [
                RatioSegment(
                  value: values[i],
                  color: BmrActivity.values[i] == result.activity
                      ? AppColors.tertiary
                      : AppColors.primary,
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Text(
            '×${BmrActivity.values.map((value) => value.factor).join(' / ×')}',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department_outlined,
            size: 30,
            color: AppColors.outline,
          ),
          const SizedBox(height: 10),
          Text(
            bmrStrings.emptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
