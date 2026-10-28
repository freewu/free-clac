import 'package:flutter/material.dart';

import '../../../state/settings_controller.dart';
import '../tool_catalog.dart';
import '../widgets/convert_setting_card.dart';
import 'area.dart';

/// 面积换算的设置项：默认计量体系与结果默认选中的 tab。
///
/// 六个换算工具共用同一套外壳，但值各存一份（`convert.area.system` /
/// `convert.area.tab`），改这个不会影响其他换算工具。
class AreaSetting extends StatelessWidget {
  const AreaSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final tool = toolById('area');
    return ConvertSettingCard(
      title: tool?.name ?? '面积换算',
      icon: tool?.icon ?? Icons.swap_horiz_rounded,
      catalog: kAreaCatalog,
      controller: controller,
    );
  }
}
