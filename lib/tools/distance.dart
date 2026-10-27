/// 长度换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「米」为基准，用分数形式（分子 / 分母）精确保存折算系数，
/// 避免 0.3048 之类的十进制字面量在连续换算中累积误差。
library;

/// 计量体系。
enum DistanceSystem {
  metric('公制'),
  imperial('英制'),
  chinese('市制');

  const DistanceSystem(this.label);

  /// 体系名称，用于分组标题与选项按钮。
  final String label;
}

/// 一个长度单位。
class DistanceUnit {
  const DistanceUnit({
    required this.id,
    required this.label,
    required this.symbol,
    required this.system,
    required this.metersNumerator,
    required this.metersDenominator,
    this.note = '',
  }) : assert(metersDenominator > 0);

  /// 内部标识（也是 Web 深链参数），如 `km`、`foot`、`chi`。
  final String id;

  /// 中文名称，如「千米」「英尺」「丈」。
  final String label;

  /// 输入框后缀用的短标签，如 `km`、`ft`、`丈`。
  final String symbol;

  final DistanceSystem system;

  /// 折算成米时分子 / 分母，如 1 英尺 = 3048 / 10000 米。
  final double metersNumerator;
  final double metersDenominator;

  /// 需要额外解释的单位（海里、链、化朗等）附一句说明。
  final String note;

  /// 1 个该单位等于多少米。
  double get meters => metersNumerator / metersDenominator;

  @override
  String toString() => '$label($symbol)';
}

/// 全部内置长度单位，顺序即结果列表顺序。
const List<DistanceUnit> kDistanceUnits = <DistanceUnit>[
  // 公制
  DistanceUnit(
    id: 'km',
    label: '千米',
    symbol: 'km',
    system: DistanceSystem.metric,
    metersNumerator: 1000,
    metersDenominator: 1,
    note: '1 千米 = 1000 米，也叫公里',
  ),
  DistanceUnit(
    id: 'm',
    label: '米',
    symbol: 'm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 1,
  ),
  DistanceUnit(
    id: 'dm',
    label: '分米',
    symbol: 'dm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 10,
  ),
  DistanceUnit(
    id: 'cm',
    label: '厘米',
    symbol: 'cm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 100,
  ),
  DistanceUnit(
    id: 'mm',
    label: '毫米',
    symbol: 'mm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 1000,
  ),
  DistanceUnit(
    id: 'um',
    label: '微米',
    symbol: 'μm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 1000000,
  ),
  DistanceUnit(
    id: 'nm',
    label: '纳米',
    symbol: 'nm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 1000000000,
  ),
  DistanceUnit(
    id: 'pm',
    label: '皮米',
    symbol: 'pm',
    system: DistanceSystem.metric,
    metersNumerator: 1,
    metersDenominator: 1000000000000,
  ),
  DistanceUnit(
    id: 'nmile',
    label: '海里',
    symbol: 'nmi',
    system: DistanceSystem.metric,
    metersNumerator: 1852,
    metersDenominator: 1,
    note: '1 海里 = 1852 米，按地球子午线 1 分弧长定义',
  ),
  // 英制
  DistanceUnit(
    id: 'inch',
    label: '英寸',
    symbol: 'in',
    system: DistanceSystem.imperial,
    metersNumerator: 254,
    metersDenominator: 10000,
    note: '1 英寸 = 2.54 厘米',
  ),
  DistanceUnit(
    id: 'foot',
    label: '英尺',
    symbol: 'ft',
    system: DistanceSystem.imperial,
    metersNumerator: 3048,
    metersDenominator: 10000,
    note: '1 英尺 = 12 英寸 = 0.3048 米',
  ),
  DistanceUnit(
    id: 'yard',
    label: '码',
    symbol: 'yd',
    system: DistanceSystem.imperial,
    metersNumerator: 9144,
    metersDenominator: 10000,
    note: '1 码 = 3 英尺 = 0.9144 米',
  ),
  DistanceUnit(
    id: 'mile',
    label: '英里',
    symbol: 'mi',
    system: DistanceSystem.imperial,
    metersNumerator: 1609344,
    metersDenominator: 1000,
    note: '1 英里 = 1760 码 = 1609.344 米',
  ),
  DistanceUnit(
    id: 'fathom',
    label: '英寻',
    symbol: 'fth',
    system: DistanceSystem.imperial,
    metersNumerator: 1829,
    metersDenominator: 1000,
    note: '1 英寻 = 6 英尺 = 1.8288 米，航海测深常用',
  ),
  DistanceUnit(
    id: 'chain',
    label: '链',
    symbol: 'ch',
    system: DistanceSystem.imperial,
    metersNumerator: 201168,
    metersDenominator: 10000,
    note: '测链，1 链 = 66 英尺 = 20.1168 米',
  ),
  DistanceUnit(
    id: 'furlong',
    label: '化朗',
    symbol: 'fur',
    system: DistanceSystem.imperial,
    metersNumerator: 201168,
    metersDenominator: 1000,
    note: '1 化朗 = 10 链 = 201.168 米，赛马距离常用',
  ),
  // 市制（1 尺 = 1/3 米，故 1 丈 = 10/3 米、1 里 = 500 米）
  DistanceUnit(
    id: 'li',
    label: '里',
    symbol: '里',
    system: DistanceSystem.chinese,
    metersNumerator: 500,
    metersDenominator: 1,
    note: '1 里 = 150 丈 = 500 米',
  ),
  DistanceUnit(
    id: 'yin',
    label: '引',
    symbol: '引',
    system: DistanceSystem.chinese,
    metersNumerator: 500,
    metersDenominator: 15,
    note: '1 引 = 10 丈 ≈ 33.33 米',
  ),
  DistanceUnit(
    id: 'zhang',
    label: '丈',
    symbol: '丈',
    system: DistanceSystem.chinese,
    metersNumerator: 50,
    metersDenominator: 15,
    note: '1 丈 = 10 尺 ≈ 3.333 米',
  ),
  DistanceUnit(
    id: 'chi',
    label: '尺',
    symbol: '尺',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 15,
    note: '1 尺 = 1/3 米 ≈ 33.33 厘米',
  ),
  DistanceUnit(
    id: 'cun',
    label: '寸',
    symbol: '寸',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 150,
    note: '1 寸 = 1/10 尺 ≈ 3.333 厘米',
  ),
  DistanceUnit(
    id: 'fen',
    label: '分',
    symbol: '分',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 1500,
    note: '1 分 = 1/10 寸 ≈ 3.333 毫米',
  ),
  DistanceUnit(
    // 厘与「里」同音，id 加后缀区分
    id: 'li2',
    label: '厘',
    symbol: '厘',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 15000,
    note: '1 厘 = 1/10 分 ≈ 0.333 毫米',
  ),
  DistanceUnit(
    id: 'hao',
    label: '毫',
    symbol: '毫',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 150000,
    note: '1 毫 = 1/10 厘 ≈ 33.3 微米',
  ),
  DistanceUnit(
    id: 'si',
    label: '丝',
    symbol: '丝',
    system: DistanceSystem.chinese,
    metersNumerator: 5,
    metersDenominator: 1500000,
    note: '1 丝 = 1/10 毫 ≈ 3.33 微米',
  ),
];

/// 某体系下的全部单位。
List<DistanceUnit> distanceUnitsOf(DistanceSystem system) =>
    kDistanceUnits.where((unit) => unit.system == system).toList();

/// 按 id 查单位，找不到返回 null。
DistanceUnit? distanceUnitById(String id) {
  for (final unit in kDistanceUnits) {
    if (unit.id == id) return unit;
  }
  return null;
}

/// 把 [value] 个 [from] 换算成 [to] 的数值。
///
/// 输入非有限数或单位系数非法时返回 null。
///
/// ```dart
/// convertDistance(1, from: distanceUnitById('m')!,
///     to: distanceUnitById('cm')!); // 100
/// ```
double? convertDistance(
  double value, {
  required DistanceUnit from,
  required DistanceUnit to,
}) {
  if (!value.isFinite) return null;
  final fromMeters = from.meters;
  final toMeters = to.meters;
  if (!fromMeters.isFinite || !toMeters.isFinite) return null;
  if (fromMeters <= 0 || toMeters <= 0) return null;
  return value * fromMeters / toMeters;
}

/// 常见长度参照物，点一下就能代入数值（如「马拉松 42.195 千米」）。
class DistanceSample {
  const DistanceSample({
    required this.label,
    required this.value,
    required this.unitId,
  });

  /// 参照物名称。
  final String label;

  /// 对应的数值。
  final double value;

  /// 单位 id（见 [kDistanceUnits]）。
  final String unitId;

  /// 对应的单位，id 写错时为 null。
  DistanceUnit? get unit => distanceUnitById(unitId);

  /// 「42.195 千米」这样的完整描述。
  String get text => '$value ${unit?.label ?? unitId}';
}

/// 常见长度参照物，来自日常与天文尺度，用于一键代入。
const List<DistanceSample> kDistanceSamples = <DistanceSample>[
  DistanceSample(label: 'A4 纸厚', value: 0.1, unitId: 'mm'),
  DistanceSample(label: '身份证宽', value: 85.6, unitId: 'mm'),
  DistanceSample(label: '身高', value: 170, unitId: 'cm'),
  DistanceSample(label: '马拉松', value: 42.195, unitId: 'km'),
  DistanceSample(label: '珠峰高度', value: 8848.86, unitId: 'm'),
  DistanceSample(label: '地球直径', value: 12756, unitId: 'km'),
  DistanceSample(label: '地月距离', value: 384400, unitId: 'km'),
  DistanceSample(label: '日地距离', value: 149600000, unitId: 'km'),
  DistanceSample(label: '1 光年', value: 9460730472580.8, unitId: 'km'),
  DistanceSample(label: '1 英里', value: 1, unitId: 'mile'),
  DistanceSample(label: '1 海里', value: 1, unitId: 'nmile'),
  DistanceSample(label: '1 里', value: 1, unitId: 'li'),
];
