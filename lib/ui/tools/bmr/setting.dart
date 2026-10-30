import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../../theme/app_theme.dart';
import '../../widgets/settings_card.dart';
import '../widgets/tool_select.dart';
import 'bmr.dart';
import 'bmr_strings.dart';

/// 基础代谢工具的设置项：默认性别与默认活动水平。
///
/// 放在全局「设置」页里，`BmrPage` 打开时按这里的值预填，页内仍可切换。
class BmrSetting extends StatelessWidget {
  const BmrSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final s = bmrStrings;
    return SettingsCard(
      icon: Icons.local_fire_department_outlined,
      title: t.settingsBmr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSelect<BmrGender>(
            key: const Key('settings-bmr-gender'),
            label: s.gender,
            value: controller.bmrGender,
            items: BmrGender.values,
            labelOf: s.genderLabel,
            onChanged: controller.setBmrGender,
          ),
          const SizedBox(height: 10),
          ToolSelect<BmrActivity>(
            key: const Key('settings-bmr-activity'),
            label: t.settingsBmrActivity,
            value: controller.bmrActivity,
            items: BmrActivity.values,
            labelOf: s.activityOptionOf,
            onChanged: controller.setBmrActivity,
          ),
          const SizedBox(height: 8),
          Text(
            t.settingsBmrHint,
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
