/// 单位换算的通用数据模型：长度 / 面积 / 重量共用一套体系与单位描述。
///
/// 每个单位只用「1 个该单位 = 多少基准单位」的分数（分子 / 分母）描述，
/// 避免 0.3048、0.09290304 这类十进制字面量在连续换算中累积误差。
/// 纯逻辑，不依赖 Flutter。
library;

/// 计量体系。
enum MeasureSystem {
  metric('公制'),
  imperial('英制'),
  chinese('市制');

  const MeasureSystem(this.label);

  /// 体系名称，用于分组标题与 tab。
  final String label;
}

/// 一个换算单位。
///
/// 与基准单位的关系是 `基准值 = 数值 × 系数 + 偏移`：长度 / 面积 / 重量 /
/// 容量这类比例单位偏移为 0，温度这类仿射单位才需要偏移
/// （如 摄氏 = 华氏 × 5/9 − 160/9）。
class MeasureUnit {
  const MeasureUnit({
    required this.id,
    required this.label,
    required this.symbol,
    required this.system,
    required this.baseNumerator,
    required this.baseDenominator,
    this.baseOffset = 0,
    this.note = '',
  }) : assert(baseDenominator > 0);

  /// 内部标识（也是 Web 深链参数），如 `km`、`sqm`、`kg`。
  final String id;

  /// 中文名称，如「千米」「亩」「磅」。
  final String label;

  /// 输入框后缀用的短标签，如 `km`、`m²`、`kg`。
  final String symbol;

  final MeasureSystem system;

  /// 折算成基准单位时的分子 / 分母，如 1 英尺 = 3048 / 10000 米。
  final double baseNumerator;
  final double baseDenominator;

  /// 换算到基准单位时的偏移量（比例单位都是 0，温度才非 0）。
  final double baseOffset;

  /// 需要额外解释的单位（海里、亩、长吨等）附一句说明。
  final String note;

  /// 换算系数（长度是「米」，面积是「平方米」，重量是「千克」，容量是「升」）。
  double get baseValue => baseNumerator / baseDenominator;

  /// 把该单位的数值换成基准单位的值。
  double toBase(double value) => value * baseValue + baseOffset;

  /// 把基准单位的值换回该单位的数值。
  double fromBase(double value) => (value - baseOffset) / baseValue;

  @override
  String toString() => '$label($symbol)';
}

/// 常见参照物，点一下就能代入数值（如「马拉松 42.195 千米」）。
class MeasureSample {
  const MeasureSample({
    required this.label,
    required this.value,
    required this.unitId,
  });

  /// 参照物名称。
  final String label;

  /// 对应的数值。
  final double value;

  /// 单位 id（见 [MeasureCatalog.units]）。
  final String unitId;
}

/// 一套单位表，一个工具对应一份（长度 / 面积 / 重量）。
class MeasureCatalog {
  const MeasureCatalog({
    required this.id,
    required this.name,
    required this.baseName,
    required this.defaultUnitId,
    required this.units,
    this.systems = MeasureSystem.values,
    this.samples = const <MeasureSample>[],
  });

  /// 深链参数与控件 Key 的前缀，如 `distance` / `area` / `weight`。
  final String id;

  /// 名称，如「长度」，用于「常见长度」等文案。
  final String name;

  /// 基准单位名，如「米」「平方米」「千克」。
  final String baseName;

  /// 打开页面时默认选中的单位 id。
  final String defaultUnitId;

  /// 全部单位，顺序即结果列表顺序。
  final List<MeasureUnit> units;

  /// 这套单位用到的体系（温度只有公制与英制），结果 tab 按它生成。
  final List<MeasureSystem> systems;

  /// 常见参照物。
  final List<MeasureSample> samples;

  /// 某体系下的全部单位。
  List<MeasureUnit> unitsOf(MeasureSystem system) =>
      units.where((unit) => unit.system == system).toList();

  /// 按 id 查单位，找不到返回 null。
  MeasureUnit? unitById(String id) {
    for (final unit in units) {
      if (unit.id == id) return unit;
    }
    return null;
  }

  /// 默认单位；配置写错时退回第一个，保证页面总能打开。
  MeasureUnit get defaultUnit => unitById(defaultUnitId) ?? units.first;

  /// 参照物对应的单位，id 写错时为 null。
  MeasureUnit? unitOfSample(MeasureSample sample) => unitById(sample.unitId);

  /// 把 [value] 个 [from] 换算成 [to] 的数值。
  ///
  /// 输入非有限数或单位系数非法时返回 null。
  double? convert(
    double value, {
    required MeasureUnit from,
    required MeasureUnit to,
  }) {
    if (!value.isFinite) return null;
    final fromBase = from.baseValue;
    final toBase = to.baseValue;
    if (!fromBase.isFinite || !toBase.isFinite) return null;
    if (fromBase <= 0 || toBase <= 0) return null;
    return to.fromBase(from.toBase(value));
  }
}
