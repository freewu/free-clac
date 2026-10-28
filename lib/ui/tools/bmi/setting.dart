import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import 'bmi.dart';
import '../../widgets/settings_card.dart';
import '../widgets/tool_select.dart';

/// BMI 工具的设置项：默认计量单位（公制 / 英制）。
///
/// 放在全局「设置」页里，`BmiPage` 打开时按这里的值决定初始单位。
class BmiSetting extends StatelessWidget {
  const BmiSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      icon: Icons.straighten_rounded,
      title: t.settingsBmiUnit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSelect<BmiUnitSystem>(
            key: const Key('settings-bmi-unit'),
            value: controller.bmiUnit,
            items: BmiUnitSystem.values,
            labelOf: (unit) => switch (unit) {
              BmiUnitSystem.metric => t.unitMetricDetail,
              BmiUnitSystem.imperial => t.unitImperialDetail,
            },
            onChanged: controller.setBmiUnit,
          ),
          const SizedBox(height: 8),
          Text(
            t.settingsBmiUnitHint,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
