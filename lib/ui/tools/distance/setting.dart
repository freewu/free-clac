import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'distance.dart';

/// 长度换算的设置项：默认计量体系与结果默认选中的 tab。
///
/// 六个换算工具共用同一套外壳，但值各存一份（`convert.distance.system` /
/// `convert.distance.tab`），改这个不会影响其他换算工具。
class LengthSetting extends StatelessWidget {
  const LengthSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('distance');
    return ConvertSettingCard(
      title: tool?.name ?? '长度换算',
      icon: tool?.icon ?? Icons.swap_horiz_rounded,
      catalog: kLengthCatalog,
      controller: controller,
    );
  }
}
