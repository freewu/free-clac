/// 温度换算：摄氏度 / 华氏度 / 开尔文 / 兰氏度互转，纯逻辑，不依赖 Flutter。
///
/// 温度是仿射换算（有零点偏移），基准取摄氏度：
/// `摄氏 = 数值 × 系数 + 偏移`，例如 华氏 32 °F → 32 × 5/9 − 160/9 = 0 °C。
/// 所以不能像长度那样只存比例，[MeasureUnit.baseOffset] 就是为此存在的。
/// 温度只有公制（摄氏 / 开尔文）与英制（华氏 / 兰氏）两套体系。
library;

import 'unit_catalog.dart';

/// 温度单位表：以摄氏度为基准，公制 2 + 英制 2 共 4 个单位。
const MeasureCatalog kTemperatureCatalog = MeasureCatalog(
  id: 'temperature',
  name: '温度',
  baseName: '摄氏度',
  defaultUnitId: 'c',
  systems: <MeasureSystem>[MeasureSystem.metric, MeasureSystem.imperial],
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 'c',
      label: '摄氏度',
      symbol: '°C',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '水的冰点 0 °C、沸点 100 °C（标准大气压）',
    ),
    MeasureUnit(
      id: 'k',
      label: '开尔文',
      symbol: 'K',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      baseOffset: -273.15,
      note: '绝对零度 = 0 K = −273.15 °C，温差与摄氏度一致',
    ),
    // 英制
    MeasureUnit(
      id: 'f',
      label: '华氏度',
      symbol: '°F',
      system: MeasureSystem.imperial,
      baseNumerator: 5,
      baseDenominator: 9,
      baseOffset: -160 / 9,
      note: '水的冰点 32 °F、沸点 212 °F，摄氏 = (华氏 − 32) × 5/9',
    ),
    MeasureUnit(
      id: 'r',
      label: '兰氏度',
      symbol: '°R',
      system: MeasureSystem.imperial,
      baseNumerator: 5,
      baseDenominator: 9,
      baseOffset: -273.15,
      note: '绝对零度 = 0 °R，1 °R = 1 °F 的间隔',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: '绝对零度', value: -273.15, unitId: 'c'),
    MeasureSample(label: '水的冰点', value: 0, unitId: 'c'),
    MeasureSample(label: '冰箱冷藏', value: 4, unitId: 'c'),
    MeasureSample(label: '人体体温', value: 36.5, unitId: 'c'),
    MeasureSample(label: '发烧 38.5', value: 38.5, unitId: 'c'),
    MeasureSample(label: '水的沸点', value: 100, unitId: 'c'),
    MeasureSample(label: '桑拿房', value: 90, unitId: 'c'),
    MeasureSample(label: '烤箱烘焙', value: 180, unitId: 'c'),
    MeasureSample(label: '铁的熔点', value: 1538, unitId: 'c'),
    MeasureSample(label: '太阳表面', value: 5500, unitId: 'c'),
    MeasureSample(label: '1 华氏冰点', value: 32, unitId: 'f'),
    MeasureSample(label: '100 °F', value: 100, unitId: 'f'),
  ],
);

/// 温度单位（统一模型的别名）。
typedef TemperatureUnit = MeasureUnit;

/// 温度体系。
typedef TemperatureSystem = MeasureSystem;

/// 温度参照物。
typedef TemperatureSample = MeasureSample;

/// 全部内置温度单位。
final List<TemperatureUnit> kTemperatureUnits = kTemperatureCatalog.units;

/// 温度参照物。
final List<TemperatureSample> kTemperatureSamples = kTemperatureCatalog.samples;

/// 某体系下的全部单位。
List<TemperatureUnit> temperatureUnitsOf(TemperatureSystem system) =>
    kTemperatureCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
TemperatureUnit? temperatureUnitById(String id) =>
    kTemperatureCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertTemperature(
  double value, {
  required TemperatureUnit from,
  required TemperatureUnit to,
}) => kTemperatureCatalog.convert(value, from: from, to: to);
