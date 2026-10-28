/// 速度换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「米/秒」为基准，折算系数用分数保存：
/// 1 千米/小时 = 5/18 米/秒，1 英里/小时 = 0.44704 米/秒，
/// 1 节 = 1 海里/小时 = 463/900 米/秒。
library;

import '../unit_catalog.dart';

/// 速度单位表：以米/秒为基准，公制 5 + 英制 3 + 市制 3 共 11 个单位。
const MeasureCatalog kSpeedCatalog = MeasureCatalog(
  id: 'speed',
  name: '速度',
  baseName: '米/秒',
  defaultUnitId: 'kmh',
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 'kmh',
      label: '千米/小时',
      symbol: 'km/h',
      system: MeasureSystem.metric,
      baseNumerator: 5,
      baseDenominator: 18,
      note: '1 千米/小时 = 5/18 米/秒 ≈ 0.278 米/秒，车速表常用',
    ),
    MeasureUnit(
      id: 'ms',
      label: '米/秒',
      symbol: 'm/s',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '国际单位制的速度单位',
    ),
    MeasureUnit(
      id: 'kms',
      label: '千米/秒',
      symbol: 'km/s',
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 千米/秒 = 3600 千米/小时，航天器与天体常用',
    ),
    MeasureUnit(
      id: 'kn',
      label: '节',
      symbol: 'kn',
      system: MeasureSystem.metric,
      baseNumerator: 463,
      baseDenominator: 900,
      note: '1 节 = 1 海里/小时 = 1852/3600 米/秒 ≈ 1.852 千米/小时',
    ),
    MeasureUnit(
      id: 'mach',
      label: '马赫',
      symbol: 'Ma',
      system: MeasureSystem.metric,
      baseNumerator: 3403,
      baseDenominator: 10,
      note: '按 15 °C 海平面声速 340.3 米/秒计，随温度变化',
    ),
    // 英制
    MeasureUnit(
      id: 'mph',
      label: '英里/小时',
      symbol: 'mph',
      system: MeasureSystem.imperial,
      baseNumerator: 2794,
      baseDenominator: 6250,
      note: '1 英里/小时 = 0.44704 米/秒 ≈ 1.609 千米/小时',
    ),
    MeasureUnit(
      id: 'fts',
      label: '英尺/秒',
      symbol: 'ft/s',
      system: MeasureSystem.imperial,
      baseNumerator: 381,
      baseDenominator: 1250,
      note: '1 英尺/秒 = 0.3048 米/秒',
    ),
    MeasureUnit(
      id: 'miin',
      label: '英里/分',
      symbol: 'mi/min',
      system: MeasureSystem.imperial,
      baseNumerator: 268224,
      baseDenominator: 10000,
      note: '1 英里/分 = 60 英里/小时 ≈ 26.82 米/秒',
    ),
    // 市制（1 尺 = 1/3 米、1 丈 = 10/3 米、1 里 = 500 米）
    MeasureUnit(
      id: 'lishi',
      label: '里/小时',
      symbol: '里/时',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 36,
      note: '1 里/小时 = 500/3600 米/秒 ≈ 0.139 米/秒',
    ),
    MeasureUnit(
      id: 'zhangs',
      label: '丈/秒',
      symbol: '丈/s',
      system: MeasureSystem.chinese,
      baseNumerator: 10,
      baseDenominator: 3,
      note: '1 丈/秒 = 10/3 米/秒 ≈ 3.33 米/秒',
    ),
    MeasureUnit(
      id: 'chis',
      label: '尺/秒',
      symbol: '尺/s',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 3,
      note: '1 尺/秒 = 1/3 米/秒 ≈ 0.333 米/秒',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: '散步', value: 4, unitId: 'kmh'),
    MeasureSample(label: '城市骑行', value: 18, unitId: 'kmh'),
    MeasureSample(label: '城市限速', value: 60, unitId: 'kmh'),
    MeasureSample(label: '高速限速', value: 120, unitId: 'kmh'),
    MeasureSample(label: '高铁', value: 350, unitId: 'kmh'),
    MeasureSample(label: '客机巡航', value: 901, unitId: 'kmh'),
    MeasureSample(label: '声速', value: 1, unitId: 'mach'),
    MeasureSample(label: '步枪子弹', value: 900, unitId: 'ms'),
    MeasureSample(label: '第一宇宙速度', value: 7.9, unitId: 'kms'),
    MeasureSample(label: '光速', value: 299792.458, unitId: 'kms'),
    MeasureSample(label: '1 英里/小时', value: 1, unitId: 'mph'),
    MeasureSample(label: '1 节', value: 1, unitId: 'kn'),
  ],
);

/// 速度单位（统一模型的别名）。
typedef SpeedUnit = MeasureUnit;

/// 速度体系。
typedef SpeedSystem = MeasureSystem;

/// 速度参照物。
typedef SpeedSample = MeasureSample;

/// 全部内置速度单位。
final List<SpeedUnit> kSpeedUnits = kSpeedCatalog.units;

/// 速度参照物。
final List<SpeedSample> kSpeedSamples = kSpeedCatalog.samples;

/// 某体系下的全部单位。
List<SpeedUnit> speedUnitsOf(SpeedSystem system) =>
    kSpeedCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
SpeedUnit? speedUnitById(String id) => kSpeedCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertSpeed(
  double value, {
  required SpeedUnit from,
  required SpeedUnit to,
}) => kSpeedCatalog.convert(value, from: from, to: to);
