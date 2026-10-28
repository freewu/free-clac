/// 面积换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「平方米」为基准，折算系数用分数保存：
/// 1 平方英尺 = (3048/10000)² 米² = 9290304/100000000 米²，
/// 1 亩 = 60 平方丈 = 60 × (10/3)² = 2000/3 米²。
library;

import '../unit_catalog.dart';

/// 面积单位表：以平方米为基准，公制 7 + 英制 5 + 市制 7 共 19 个单位。
const MeasureCatalog kAreaCatalog = MeasureCatalog(
  id: 'area',
  name: '面积',
  baseName: '平方米',
  defaultUnitId: 'sqm',
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 'sqkm',
      label: '平方千米',
      symbol: 'km²',
      system: MeasureSystem.metric,
      baseNumerator: 1000000,
      baseDenominator: 1,
      note: '1 平方千米 = 1000000 平方米 = 100 公顷',
    ),
    MeasureUnit(
      id: 'ha',
      label: '公顷',
      symbol: 'ha',
      system: MeasureSystem.metric,
      baseNumerator: 10000,
      baseDenominator: 1,
      note: '1 公顷 = 10000 平方米 = 15 亩',
    ),
    MeasureUnit(
      id: 'are',
      label: '公亩',
      symbol: 'a',
      system: MeasureSystem.metric,
      baseNumerator: 100,
      baseDenominator: 1,
      note: '1 公亩 = 100 平方米',
    ),
    MeasureUnit(
      id: 'sqm',
      label: '平方米',
      symbol: 'm²',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'sqdm',
      label: '平方分米',
      symbol: 'dm²',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
    ),
    MeasureUnit(
      id: 'sqcm',
      label: '平方厘米',
      symbol: 'cm²',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10000,
    ),
    MeasureUnit(
      id: 'sqmm',
      label: '平方毫米',
      symbol: 'mm²',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    // 英制（1 英寸 = 0.0254 米，面积按边长平方折算）
    MeasureUnit(
      id: 'sqmi',
      label: '平方英里',
      symbol: 'mi²',
      system: MeasureSystem.imperial,
      baseNumerator: 2589988110336,
      baseDenominator: 1000000,
      note: '1 平方英里 = 640 英亩 = 2.58999 平方千米',
    ),
    MeasureUnit(
      id: 'acre',
      label: '英亩',
      symbol: 'ac',
      system: MeasureSystem.imperial,
      baseNumerator: 40468564224,
      baseDenominator: 10000000,
      note: '1 英亩 = 4840 平方码 ≈ 4046.86 平方米 ≈ 6.07 亩',
    ),
    MeasureUnit(
      id: 'sqyd',
      label: '平方码',
      symbol: 'yd²',
      system: MeasureSystem.imperial,
      baseNumerator: 83612736,
      baseDenominator: 100000000,
      note: '1 平方码 = 9 平方英尺',
    ),
    MeasureUnit(
      id: 'sqft',
      label: '平方英尺',
      symbol: 'ft²',
      system: MeasureSystem.imperial,
      baseNumerator: 9290304,
      baseDenominator: 100000000,
      note: '1 平方英尺 = 144 平方英寸 ≈ 0.0929 平方米',
    ),
    MeasureUnit(
      id: 'sqin',
      label: '平方英寸',
      symbol: 'in²',
      system: MeasureSystem.imperial,
      baseNumerator: 64516,
      baseDenominator: 100000000,
      note: '1 平方英寸 = 6.4516 平方厘米',
    ),
    // 市制（1 尺 = 1/3 米 → 1 平方尺 = 1/9 米²，1 亩 = 60 平方丈 = 2000/3 米²）
    MeasureUnit(
      id: 'sqli',
      label: '平方里',
      symbol: '里²',
      system: MeasureSystem.chinese,
      baseNumerator: 250000,
      baseDenominator: 1,
      note: '1 平方里 = 500² 平方米 = 0.25 平方千米',
    ),
    MeasureUnit(
      id: 'qing',
      label: '顷',
      symbol: '顷',
      system: MeasureSystem.chinese,
      baseNumerator: 200000,
      baseDenominator: 3,
      note: '1 顷 = 100 亩 ≈ 6.667 公顷',
    ),
    MeasureUnit(
      id: 'mu',
      label: '亩',
      symbol: '亩',
      system: MeasureSystem.chinese,
      baseNumerator: 2000,
      baseDenominator: 3,
      note: '1 亩 = 60 平方丈 ≈ 666.67 平方米',
    ),
    MeasureUnit(
      id: 'fen',
      label: '分',
      symbol: '分',
      system: MeasureSystem.chinese,
      baseNumerator: 200,
      baseDenominator: 3,
      note: '1 分 = 1/10 亩 ≈ 66.67 平方米',
    ),
    MeasureUnit(
      id: 'li2',
      label: '厘',
      symbol: '厘',
      system: MeasureSystem.chinese,
      baseNumerator: 20,
      baseDenominator: 3,
      note: '1 厘 = 1/10 分 ≈ 6.67 平方米',
    ),
    MeasureUnit(
      id: 'sqzhang',
      label: '平方丈',
      symbol: '丈²',
      system: MeasureSystem.chinese,
      baseNumerator: 100,
      baseDenominator: 9,
      note: '1 平方丈 = 100/9 平方米 ≈ 11.11 平方米',
    ),
    MeasureUnit(
      id: 'sqchi',
      label: '平方尺',
      symbol: '尺²',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 9,
      note: '1 平方尺 = 1/9 平方米 ≈ 0.111 平方米',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: 'A4 纸', value: 0.06237, unitId: 'sqm'),
    MeasureSample(label: '1 平方英尺', value: 1, unitId: 'sqft'),
    MeasureSample(label: '篮球场', value: 420, unitId: 'sqm'),
    MeasureSample(label: '1 亩', value: 1, unitId: 'mu'),
    MeasureSample(label: '足球场', value: 7140, unitId: 'sqm'),
    MeasureSample(label: '1 公顷', value: 1, unitId: 'ha'),
    MeasureSample(label: '1 英亩', value: 1, unitId: 'acre'),
    MeasureSample(label: '故宫', value: 720000, unitId: 'sqm'),
    MeasureSample(label: '天安门广场', value: 440000, unitId: 'sqm'),
    MeasureSample(label: '中国国土', value: 9600000, unitId: 'sqkm'),
    MeasureSample(label: '地球表面', value: 510072000, unitId: 'sqkm'),
  ],
);

/// 面积单位（统一模型的别名，便于调用处读起来更具体）。
typedef AreaUnit = MeasureUnit;

/// 面积体系。
typedef AreaSystem = MeasureSystem;

/// 面积参照物。
typedef AreaSample = MeasureSample;

/// 全部内置面积单位。
final List<AreaUnit> kAreaUnits = kAreaCatalog.units;

/// 面积参照物。
final List<AreaSample> kAreaSamples = kAreaCatalog.samples;

/// 某体系下的全部单位。
List<AreaUnit> areaUnitsOf(AreaSystem system) => kAreaCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
AreaUnit? areaUnitById(String id) => kAreaCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertArea(
  double value, {
  required AreaUnit from,
  required AreaUnit to,
}) => kAreaCatalog.convert(value, from: from, to: to);
