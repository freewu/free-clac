import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../../../state/settings_controller.dart';
import '../../widgets/settings_card.dart';
import '../unit_catalog.dart';
import 'measure_system_label.dart';
import 'tool_select.dart';
import 'unit_convert_strings.dart';

/// 单位换算类工具设置卡片的公共外壳。
///
/// 每个换算工具在自己的 `setting.dart` 里包一层（如 `lib/ui/tools/area/setting.dart`
/// 的 `AreaSetting`），卡片外观、两个下拉框与 Key 规则都集中在这里。
class ConvertSettingCard extends StatelessWidget {
  const ConvertSettingCard({
    super.key,
    required this.title,
    required this.icon,
    required this.catalog,
    required this.controller,
  });

  /// 卡片标题，用工具自身名称（如「面积换算」）。
  final String title;
  final IconData icon;

  /// 该工具的单位表，决定可选的计量体系与配置 id。
  final MeasureCatalog catalog;

  final SettingsController controller;

  /// 体系名称统一走多语言（`MeasureSystem.label` 只有中文）。
  static String systemLabel(MeasureSystem system) => measureSystemLabel(system);

  @override
  Widget build(BuildContext context) {
    // 温度不分公制 / 英制，只有「默认单位」一项
    if (!catalog.splitsBySystem) {
      final stored = catalog.unitById(
        controller.convertUnitFor(catalog.id) ?? '',
      );
      return SettingsCard(
        icon: icon,
        title: title,
        child: ToolSelect<String>(
          key: Key('settings-convert-${catalog.id}-unit'),
          label: t.settingsConvertUnit,
          value: (stored ?? catalog.defaultUnit).id,
          items: [for (final unit in catalog.units) unit.id],
          labelOf: (id) =>
              unitOptionLabel(catalog.unitById(id) ?? catalog.defaultUnit),
          onChanged: (id) => controller.setConvertUnit(catalog.id, id),
        ),
      );
    }
    // 速度没有市制，选项直接取自该工具支持的体系
    final systems = catalog.systems;
    return SettingsCard(
      icon: icon,
      title: title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ToolSelect<MeasureSystem>(
              key: Key('settings-convert-${catalog.id}-system'),
              label: t.settingsConvertSystem,
              value: controller.convertSystemFor(catalog.id),
              items: systems,
              labelOf: systemLabel,
              onChanged: (system) =>
                  controller.setConvertSystem(catalog.id, system),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ToolSelect<MeasureSystem>(
              key: Key('settings-convert-${catalog.id}-tab'),
              label: t.settingsConvertTab,
              value: controller.convertTabFor(catalog.id),
              items: systems,
              labelOf: systemLabel,
              onChanged: (system) =>
                  controller.setConvertTab(catalog.id, system),
            ),
          ),
        ],
      ),
    );
  }
}
