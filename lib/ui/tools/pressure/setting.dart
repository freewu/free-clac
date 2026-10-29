import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'pressure.dart';

/// 压力换算的设置项：只有「默认单位」。
///
/// 压力和温度一样不分计量体系，所以卡片比长度换算少一项；值存在
/// `convert.pressure.unit`，不影响其他换算工具。
class PressureSetting extends StatelessWidget {
  const PressureSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('pressure');
    return ConvertSettingCard(
      title: tool?.name ?? '压力换算',
      icon: tool?.icon ?? Icons.compress_rounded,
      catalog: kPressureCatalog,
      controller: controller,
    );
  }
}
