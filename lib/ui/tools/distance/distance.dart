/// 长度换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「米」为基准，用分数形式（分子 / 分母）精确保存折算系数，
/// 避免 0.3048 之类的十进制字面量在连续换算中累积误差。
library;

import '../unit_catalog.dart';

/// 长度单位表：以米为基准，公制 9 + 英制 7 + 市制 9 共 25 个单位。
const MeasureCatalog kLengthCatalog = MeasureCatalog(
  id: 'distance',
  name: '长度',
  baseName: '米',
  defaultUnitId: 'm',
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 'km',
      label: '千米',
      symbol: 'km',
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 千米 = 1000 米，也叫公里',
    ),
    MeasureUnit(
      id: 'm',
      label: '米',
      symbol: 'm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'dm',
      label: '分米',
      symbol: 'dm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10,
    ),
    MeasureUnit(
      id: 'cm',
      label: '厘米',
      symbol: 'cm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
    ),
    MeasureUnit(
      id: 'mm',
      label: '毫米',
      symbol: 'mm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
    ),
    MeasureUnit(
      id: 'um',
      label: '微米',
      symbol: 'μm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    MeasureUnit(
      id: 'nm',
      label: '纳米',
      symbol: 'nm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000,
    ),
    MeasureUnit(
      id: 'pm',
      label: '皮米',
      symbol: 'pm',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000000,
    ),
    MeasureUnit(
      id: 'nmile',
      label: '海里',
      symbol: 'nmi',
      system: MeasureSystem.metric,
      baseNumerator: 1852,
      baseDenominator: 1,
      note: '1 海里 = 1852 米，按地球子午线 1 分弧长定义',
    ),
    // 英制
    MeasureUnit(
      id: 'inch',
      label: '英寸',
      symbol: 'in',
      system: MeasureSystem.imperial,
      baseNumerator: 254,
      baseDenominator: 10000,
      note: '1 英寸 = 2.54 厘米',
    ),
    MeasureUnit(
      id: 'foot',
      label: '英尺',
      symbol: 'ft',
      system: MeasureSystem.imperial,
      baseNumerator: 3048,
      baseDenominator: 10000,
      note: '1 英尺 = 12 英寸 = 0.3048 米',
    ),
    MeasureUnit(
      id: 'yard',
      label: '码',
      symbol: 'yd',
      system: MeasureSystem.imperial,
      baseNumerator: 9144,
      baseDenominator: 10000,
      note: '1 码 = 3 英尺 = 0.9144 米',
    ),
    MeasureUnit(
      id: 'mile',
      label: '英里',
      symbol: 'mi',
      system: MeasureSystem.imperial,
      baseNumerator: 1609344,
      baseDenominator: 1000,
      note: '1 英里 = 1760 码 = 1609.344 米',
    ),
    MeasureUnit(
      id: 'fathom',
      label: '英寻',
      symbol: 'fth',
      system: MeasureSystem.imperial,
      baseNumerator: 1829,
      baseDenominator: 1000,
      note: '1 英寻 = 6 英尺 = 1.8288 米，航海测深常用',
    ),
    MeasureUnit(
      id: 'chain',
      label: '链',
      symbol: 'ch',
      system: MeasureSystem.imperial,
      baseNumerator: 201168,
      baseDenominator: 10000,
      note: '测链，1 链 = 66 英尺 = 20.1168 米',
    ),
    MeasureUnit(
      id: 'furlong',
      label: '化朗',
      symbol: 'fur',
      system: MeasureSystem.imperial,
      baseNumerator: 201168,
      baseDenominator: 1000,
      note: '1 化朗 = 10 链 = 201.168 米，赛马距离常用',
    ),
    // 市制（1 尺 = 1/3 米，故 1 丈 = 10/3 米、1 里 = 500 米）
    MeasureUnit(
      id: 'li',
      label: '里',
      symbol: '里',
      system: MeasureSystem.chinese,
      baseNumerator: 500,
      baseDenominator: 1,
      note: '1 里 = 150 丈 = 500 米',
    ),
    MeasureUnit(
      id: 'yin',
      label: '引',
      symbol: '引',
      system: MeasureSystem.chinese,
      baseNumerator: 500,
      baseDenominator: 15,
      note: '1 引 = 10 丈 ≈ 33.33 米',
    ),
    MeasureUnit(
      id: 'zhang',
      label: '丈',
      symbol: '丈',
      system: MeasureSystem.chinese,
      baseNumerator: 50,
      baseDenominator: 15,
      note: '1 丈 = 10 尺 ≈ 3.333 米',
    ),
    MeasureUnit(
      id: 'chi',
      label: '尺',
      symbol: '尺',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 15,
      note: '1 尺 = 1/3 米 ≈ 33.33 厘米',
    ),
    MeasureUnit(
      id: 'cun',
      label: '寸',
      symbol: '寸',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 150,
      note: '1 寸 = 1/10 尺 ≈ 3.333 厘米',
    ),
    MeasureUnit(
      id: 'fen',
      label: '分',
      symbol: '分',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 1500,
      note: '1 分 = 1/10 寸 ≈ 3.333 毫米',
    ),
    MeasureUnit(
      // 厘与「里」同音，id 加后缀区分
      id: 'li2',
      label: '厘',
      symbol: '厘',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 15000,
      note: '1 厘 = 1/10 分 ≈ 0.333 毫米',
    ),
    MeasureUnit(
      id: 'hao',
      label: '毫',
      symbol: '毫',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 150000,
      note: '1 毫 = 1/10 厘 ≈ 33.3 微米',
    ),
    MeasureUnit(
      id: 'si',
      label: '丝',
      symbol: '丝',
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 1500000,
      note: '1 丝 = 1/10 毫 ≈ 3.33 微米',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: 'A4 纸厚', value: 0.1, unitId: 'mm'),
    MeasureSample(label: '身份证宽', value: 85.6, unitId: 'mm'),
    MeasureSample(label: '身高', value: 170, unitId: 'cm'),
    MeasureSample(label: '马拉松', value: 42.195, unitId: 'km'),
    MeasureSample(label: '珠峰高度', value: 8848.86, unitId: 'm'),
    MeasureSample(label: '地球直径', value: 12756, unitId: 'km'),
    MeasureSample(label: '地月距离', value: 384400, unitId: 'km'),
    MeasureSample(label: '日地距离', value: 149600000, unitId: 'km'),
    MeasureSample(label: '1 光年', value: 9460730472580.8, unitId: 'km'),
    MeasureSample(label: '1 英里', value: 1, unitId: 'mile'),
    MeasureSample(label: '1 海里', value: 1, unitId: 'nmile'),
    MeasureSample(label: '1 里', value: 1, unitId: 'li'),
  ],
);

/// 长度单位：保留原来「长度专用」的命名，方便调用处读起来更具体。
typedef DistanceUnit = MeasureUnit;

/// 长度体系。
typedef DistanceSystem = MeasureSystem;

/// 长度参照物。
typedef DistanceSample = MeasureSample;

/// 全部内置长度单位，顺序即结果列表顺序。
final List<DistanceUnit> kDistanceUnits = kLengthCatalog.units;

/// 长度参照物（同 [MeasureCatalog.samples]）。
final List<DistanceSample> kDistanceSamples = kLengthCatalog.samples;

/// 某体系下的全部单位。
List<DistanceUnit> distanceUnitsOf(DistanceSystem system) =>
    kLengthCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
DistanceUnit? distanceUnitById(String id) => kLengthCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
///
/// ```dart
/// convertDistance(1, from: distanceUnitById('m')!,
///     to: distanceUnitById('cm')!); // 100
/// ```
double? convertDistance(
  double value, {
  required DistanceUnit from,
  required DistanceUnit to,
}) => kLengthCatalog.convert(value, from: from, to: to);

/// 长度单位的米数（用统一模型时叫 [MeasureUnit.baseValue]）。
extension DistanceUnitMeters on DistanceUnit {
  /// 1 个该单位等于多少米。
  double get meters => baseValue;
}
