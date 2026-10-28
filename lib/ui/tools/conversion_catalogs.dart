import 'area/area.dart';
import 'distance/distance.dart';
import 'speed/speed.dart';
import 'temperature/temperature.dart';
import 'unit_catalog.dart';
import 'volume/volume.dart';
import 'weight/weight.dart';

/// 全部「单位换算」类工具的目录，顺序即设置页里的顺序。
///
/// 这些工具共用 `UnitConvertPage`，因此也共用一套设置项（默认计量体系与
/// 结果默认选中的 tab），但每个工具各存一份，互不影响。
List<MeasureCatalog> get kConversionCatalogs => <MeasureCatalog>[
  kLengthCatalog,
  kAreaCatalog,
  kVolumeCatalog,
  kWeightCatalog,
  kTemperatureCatalog,
  kSpeedCatalog,
];
