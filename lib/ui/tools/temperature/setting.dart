import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'temperature.dart';

/// 温度换算的设置项：默认计量体系与结果默认选中的 tab。
///
/// 六个换算工具共用同一套外壳，但值各存一份（`convert.temperature.system` /
/// `convert.temperature.tab`），改这个不会影响其他换算工具。
class TemperatureSetting extends StatelessWidget {
  const TemperatureSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('temperature');
    return ConvertSettingCard(
      title: tool?.name ?? '温度换算',
      icon: tool?.icon ?? Icons.swap_horiz_rounded,
      catalog: kTemperatureCatalog,
      controller: controller,
    );
  }
}
