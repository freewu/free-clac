/// 容量换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「升」为基准，折算系数用分数保存：
/// 1 立方米 = 1000 升，1 英制加仑 = 454609/100000 升 = 4.54609 升，
/// 1 斗 = 10 升、1 石 = 100 升（市制按市升 = 1 升计）。
library;

import 'unit_catalog.dart';

/// 容量单位表：以升为基准，公制 6 + 英制 5 + 市制 6 共 17 个单位。
const MeasureCatalog kVolumeCatalog = MeasureCatalog(
  id: 'volume',
  name: '容量',
  baseName: '升',
  defaultUnitId: 'l',
  units: <MeasureUnit>[
    // 公制
    MeasureUnit(
      id: 'm3',
      label: '立方米',
      symbol: 'm³',
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 立方米 = 1000 升，自来水与燃气常按立方米计费',
    ),
    MeasureUnit(
      id: 'l',
      label: '升',
      symbol: 'L',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'dl',
      label: '分升',
      symbol: 'dL',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10,
      note: '1 分升 = 0.1 升 = 100 毫升',
    ),
    MeasureUnit(
      id: 'cl',
      label: '厘升',
      symbol: 'cL',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
      note: '1 厘升 = 10 毫升',
    ),
    MeasureUnit(
      id: 'ml',
      label: '毫升',
      symbol: 'mL',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
      note: '1 毫升 = 1 立方厘米',
    ),
    MeasureUnit(
      id: 'ul',
      label: '微升',
      symbol: 'μL',
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
      note: '1 微升 = 1 立方毫米，实验室常用',
    ),
    // 英制（英制 UK 口径；美制加仑约 3.785 升）
    MeasureUnit(
      id: 'gal',
      label: '加仑',
      symbol: 'gal',
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 100000,
      note: '英制加仑 = 4.54609 升（美制加仑 ≈ 3.785 升）',
    ),
    MeasureUnit(
      id: 'qt',
      label: '夸脱',
      symbol: 'qt',
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 400000,
      note: '1 夸脱 = 1/4 加仑 = 1.1365225 升',
    ),
    MeasureUnit(
      id: 'pt',
      label: '品脱',
      symbol: 'pt',
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 800000,
      note: '1 品脱 = 1/2 夸脱 ≈ 568.26 毫升，酒吧常见',
    ),
    MeasureUnit(
      id: 'floz',
      label: '液量盎司',
      symbol: 'fl oz',
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 16000000,
      note: '英制液量盎司 = 1/160 加仑 ≈ 28.41 毫升',
    ),
    MeasureUnit(
      id: 'bu',
      label: '蒲式耳',
      symbol: 'bu',
      system: MeasureSystem.imperial,
      baseNumerator: 3636872,
      baseDenominator: 100000,
      note: '1 蒲式耳 = 8 加仑 = 36.36872 升，谷物计量单位',
    ),
    // 市制（1 石 = 10 斗 = 100 升，1 升 = 10 合 = 100 勺）
    MeasureUnit(
      id: 'dan',
      label: '石',
      symbol: '石',
      system: MeasureSystem.chinese,
      baseNumerator: 100,
      baseDenominator: 1,
      note: '1 石 = 10 斗 = 100 升，古代粮米常用',
    ),
    MeasureUnit(
      id: 'dou',
      label: '斗',
      symbol: '斗',
      system: MeasureSystem.chinese,
      baseNumerator: 10,
      baseDenominator: 1,
      note: '1 斗 = 10 升',
    ),
    MeasureUnit(
      id: 'sheng',
      label: '升',
      symbol: '升',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '1 市升 = 1 升 = 1000 毫升',
    ),
    MeasureUnit(
      id: 'ge',
      label: '合',
      symbol: '合',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 10,
      note: '1 合 = 1/10 升 = 100 毫升',
    ),
    MeasureUnit(
      id: 'shao',
      label: '勺',
      symbol: '勺',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 100,
      note: '1 勺 = 1/10 合 = 10 毫升',
    ),
    MeasureUnit(
      id: 'cuo',
      label: '撮',
      symbol: '撮',
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 1000,
      note: '1 撮 = 1/10 勺 = 1 毫升',
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(label: '一勺药水', value: 5, unitId: 'ml'),
    MeasureSample(label: '一杯水', value: 250, unitId: 'ml'),
    MeasureSample(label: '一听可乐', value: 330, unitId: 'ml'),
    MeasureSample(label: '一瓶矿泉水', value: 550, unitId: 'ml'),
    MeasureSample(label: '1 升水', value: 1, unitId: 'l'),
    MeasureSample(label: '一桶食用油', value: 5, unitId: 'l'),
    MeasureSample(label: '饮水机水桶', value: 18.9, unitId: 'l'),
    MeasureSample(label: '汽车油箱', value: 50, unitId: 'l'),
    MeasureSample(label: '1 加仑', value: 1, unitId: 'gal'),
    MeasureSample(label: '1 斗', value: 1, unitId: 'dou'),
    MeasureSample(label: '标准泳池', value: 2500000, unitId: 'l'),
  ],
);

/// 容量单位（统一模型的别名）。
typedef VolumeUnit = MeasureUnit;

/// 容量体系。
typedef VolumeSystem = MeasureSystem;

/// 容量参照物。
typedef VolumeSample = MeasureSample;

/// 全部内置容量单位。
final List<VolumeUnit> kVolumeUnits = kVolumeCatalog.units;

/// 容量参照物。
final List<VolumeSample> kVolumeSamples = kVolumeCatalog.samples;

/// 某体系下的全部单位。
List<VolumeUnit> volumeUnitsOf(VolumeSystem system) =>
    kVolumeCatalog.unitsOf(system);

/// 按 id 查单位，找不到返回 null。
VolumeUnit? volumeUnitById(String id) => kVolumeCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertVolume(
  double value, {
  required VolumeUnit from,
  required VolumeUnit to,
}) => kVolumeCatalog.convert(value, from: from, to: to);
