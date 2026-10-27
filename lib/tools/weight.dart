/// 重量换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「千克」为基准，折算系数用分数保存：
/// 1 磅 = 45359237/100000000 千克，1 斤 = 1/2 千克，
/// 1 两 = 1/20 千克（市制按 1 斤 = 10 两计）。
library;

import 'unit_catalog.dart';

/// 重量单位表：以千克为基准，公制 5 + 英制 6 + 市制 6 共 17 个单位。
const MeasureCatalog kWeightCatalog = MeasureCatalog(
  id: 'weight',
  name: '重量',
  baseName: '千克',
  defaultUnitId: 'kg',
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 't',
      label: '吨',
      symbol: 't',
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 吨 = 1000 千克',
    ),
    MeasureUnit(
      id: 'kg',
      label: '千克',
      symbol: 'kg',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '千克是国际单位制的质量基本单位，日常也叫公斤',
    ),
    MeasureUnit(
      id: 'g',
      label: '克',
      symbol: 'g',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
    ),
    MeasureUnit(
      id: 'mg',
      label: '毫克',
      symbol: 'mg',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    MeasureUnit(
      id: 'ug',
      label: '微克',
      symbol: 'μg',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000,
    ),
    // 英制（英制与美制质量单位相同，吨分长吨 / 短吨）
    MeasureUnit(
      id: 'longton',
      label: '长吨',
      symbol: 'ton',
      system: MeasureSystem.imperial,
      baseNumerator: 10160469088,
      baseDenominator: 10000000,
      note: '英吨，1 长吨 = 2240 磅 = 1016.0469088 千克',
    ),
    MeasureUnit(
      id: 'shortton',
      label: '短吨',
      symbol: 'sh tn',
      system: MeasureSystem.imperial,
      baseNumerator: 90718474,
      baseDenominator: 100000,
      note: '美吨，1 短吨 = 2000 磅 = 907.18474 千克',
    ),
    MeasureUnit(
      id: 'lb',
      label: '磅',
      symbol: 'lb',
      system: MeasureSystem.imperial,
      baseNumerator: 45359237,
      baseDenominator: 100000000,
      note: '1 磅 = 16 盎司 = 0.45359237 千克',
    ),
    MeasureUnit(
      id: 'oz',
      label: '盎司',
      symbol: 'oz',
      system: MeasureSystem.imperial,
      baseNumerator: 45359237,
      baseDenominator: 1600000000,
      note: '常衡盎司，1 盎司 = 1/16 磅 ≈ 28.35 克',
    ),
    MeasureUnit(
      id: 'st',
      label: '英石',
      symbol: 'st',
      system: MeasureSystem.imperial,
      baseNumerator: 635029318,
      baseDenominator: 100000000,
      note: '1 英石 = 14 磅 = 6.35029318 千克，英国人报体重常用',
    ),
    MeasureUnit(
      id: 'gr',
      label: '格令',
      symbol: 'gr',
      system: MeasureSystem.imperial,
      baseNumerator: 6479891,
      baseDenominator: 100000000000,
      note: '1 格令 = 64.79891 毫克，药量与弹药常用',
    ),
    // 市制（1 斤 = 500 克 = 10 两）
    MeasureUnit(
      id: 'dan',
      label: '担',
      symbol: '担',
      system: MeasureSystem.chinese,
      baseNumerator: 50,
      baseDenominator: 1,
      note: '1 担 = 100 斤 = 50 千克',
    ),
    MeasureUnit(
      id: 'jin',
      label: '斤',
      symbol: '斤',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 2,
      note: '1 斤 = 500 克 = 10 两',
    ),
    MeasureUnit(
      id: 'liang',
      label: '两',
      symbol: '两',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 20,
      note: '1 两 = 50 克（旧制 1 斤 = 16 两，今按 10 两计）',
    ),
    MeasureUnit(
      id: 'qian',
      label: '钱',
      symbol: '钱',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 200,
      note: '1 钱 = 5 克，中药抓药常用',
    ),
    MeasureUnit(
      id: 'fen',
      label: '分',
      symbol: '分',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 2000,
      note: '1 分 = 0.5 克',
    ),
    MeasureUnit(
      id: 'li2',
      label: '厘',
      symbol: '厘',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 20000,
      note: '1 厘 = 0.05 克',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: '一粒米', value: 0.02, unitId: 'g'),
    MeasureSample(label: '一枚鸡蛋', value: 50, unitId: 'g'),
    MeasureSample(label: '一杯牛奶', value: 250, unitId: 'g'),
    MeasureSample(label: '一瓶矿泉水', value: 550, unitId: 'g'),
    MeasureSample(label: '一个成年人', value: 65, unitId: 'kg'),
    MeasureSample(label: '一袋大米', value: 10, unitId: 'kg'),
    MeasureSample(label: '1 斤', value: 1, unitId: 'jin'),
    MeasureSample(label: '1 磅', value: 1, unitId: 'lb'),
    MeasureSample(label: '一头大象', value: 5000, unitId: 'kg'),
    MeasureSample(label: '一辆小汽车', value: 1.5, unitId: 't'),
    MeasureSample(label: '一头蓝鲸', value: 150, unitId: 't'),
  ],
);

/// 重量单位（统一模型的别名）。
typedef WeightUnit = MeasureUnit;

/// 重量体系。
typedef WeightSystem = MeasureSystem;

/// 重量参照物。
typedef WeightSample = MeasureSample;

/// 全部内置重量单位。
final List<WeightUnit> kWeightUnits = kWeightCatalog.units;

/// 重量参照物。
final List<WeightSample> kWeightSamples = kWeightCatalog.samples;

/// 某体系下的全部单位。
List<WeightUnit> weightUnitsOf(WeightSystem system) =>
    kWeightCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
WeightUnit? weightUnitById(String id) => kWeightCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertWeight(
  double value, {
  required WeightUnit from,
  required WeightUnit to,
}) => kWeightCatalog.convert(value, from: from, to: to);
