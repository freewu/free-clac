import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'speed.dart';

/// 速度换算的设置项：默认计量体系与结果默认选中的 tab。
///
/// 六个换算工具共用同一套外壳，但值各存一份（`convert.speed.system` /
/// `convert.speed.tab`），改这个不会影响其他换算工具。
class SpeedSetting extends StatelessWidget {
  const SpeedSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('speed');
    return ConvertSettingCard(
      title: tool?.name ?? '速度换算',
      icon: tool?.icon ?? Icons.swap_horiz_rounded,
      catalog: kSpeedCatalog,
      controller: controller,
    );
  }
}
