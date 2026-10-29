import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'energy.dart';

/// 热量换算的设置项：只有「默认单位」。
///
/// 热量和温度一样不分计量体系，所以卡片比长度换算少一项；值存在
/// `convert.energy.unit`，不影响其他换算工具。
class EnergySetting extends StatelessWidget {
  const EnergySetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('energy');
    return ConvertSettingCard(
      title: tool?.name ?? '热量换算',
      icon: tool?.icon ?? Icons.local_fire_department_rounded,
      catalog: kEnergyCatalog,
      controller: controller,
    );
  }
}
