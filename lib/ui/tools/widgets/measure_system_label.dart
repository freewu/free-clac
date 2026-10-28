import '../../../l10n/app_i18n.dart';
import '../unit_catalog.dart';

/// 计量体系的多语言名称（`MeasureSystem.label` 只有中文，不能直接上界面）。
String measureSystemLabel(MeasureSystem system) => switch (system) {
  MeasureSystem.metric => t.systemMetric,
  MeasureSystem.imperial => t.systemImperial,
  MeasureSystem.chinese => t.systemChinese,
};
