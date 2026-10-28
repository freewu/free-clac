import 'package:flutter/material.dart';

import '../../l10n/app_i18n.dart';
import '../../state/settings_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/settings_card.dart';
import 'conversion_catalogs.dart';
import 'tool_catalog.dart';
import 'unit_catalog.dart';
import 'widgets/tool_select.dart';

/// 「单位换算」的设置项：每个换算工具各记一套默认计量体系与结果默认 tab。
///
/// 六个换算工具共用 `UnitConvertPage`，但体系与 tab 各自保存，改动长度换算
/// 不会影响面积换算。
class ConversionSetting extends StatelessWidget {
  const ConversionSetting({super.key, required this.controller});

  final SettingsController controller;

  /// 体系名称统一走多语言（`MeasureSystem.label` 只有中文）。
  static String systemLabel(MeasureSystem system) => switch (system) {
    MeasureSystem.metric => t.systemMetric,
    MeasureSystem.imperial => t.systemImperial,
    MeasureSystem.chinese => t.systemChinese,
  };

  @override
  Widget build(BuildContext context) {
    final catalogs = kConversionCatalogs;
    return SettingsCard(
      icon: Icons.swap_horiz_rounded,
      title: t.settingsConversion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < catalogs.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _CatalogRow(controller: controller, catalog: catalogs[i]),
          ],
          const SizedBox(height: 8),
          Text(
            t.settingsConversionHint,
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

/// 一个换算工具的两项设置：默认体系 + 结果默认 tab。
class _CatalogRow extends StatelessWidget {
  const _CatalogRow({required this.controller, required this.catalog});

  final SettingsController controller;
  final MeasureCatalog catalog;

  @override
  Widget build(BuildContext context) {
    // 温度、速度没有市制，选项直接取自该工具支持的体系
    final systems = catalog.systems;
    final name = toolById(catalog.id)?.name ?? catalog.name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ToolSelect<MeasureSystem>(
                key: Key('settings-convert-${catalog.id}-system'),
                label: t.settingsConvertSystem,
                value: controller.convertSystemFor(catalog.id),
                items: systems,
                labelOf: ConversionSetting.systemLabel,
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
                labelOf: ConversionSetting.systemLabel,
                onChanged: (system) =>
                    controller.setConvertTab(catalog.id, system),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
