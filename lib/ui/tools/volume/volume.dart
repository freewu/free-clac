/// 容量换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「升」为基准，折算系数用分数保存：
/// 1 立方米 = 1000 升，1 英制加仑 = 454609/100000 升 = 4.54609 升，
/// 1 斗 = 10 升、1 石 = 100 升（市制按市升 = 1 升计）。
library;

import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

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
      names: <AppLanguage, String>{
        AppLanguage.en: 'cubic metre',
        AppLanguage.ja: '立方メートル',
        AppLanguage.es: 'metro cúbico',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 立方米 = 1000 升，自来水与燃气常按立方米计费',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 m³ = 1000 L; water and gas are billed per cubic metre',
        AppLanguage.ja: '1 m³ = 1000 L、水道・ガスは立方メートル単位で請求されます',
        AppLanguage.es:
            '1 m³ = 1000 L; el agua y el gas se facturan por metro cúbico',
      },
    ),
    MeasureUnit(
      id: 'l',
      label: '升',
      symbol: 'L',
      names: <AppLanguage, String>{
        AppLanguage.en: 'litre',
        AppLanguage.ja: 'リットル',
        AppLanguage.es: 'litro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'dl',
      label: '分升',
      symbol: 'dL',
      names: <AppLanguage, String>{
        AppLanguage.en: 'decilitre',
        AppLanguage.ja: 'デシリットル',
        AppLanguage.es: 'decilitro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10,
      note: '1 分升 = 0.1 升 = 100 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 dL = 0.1 L = 100 mL',
        AppLanguage.ja: '1 dL = 0.1 L = 100 mL',
        AppLanguage.es: '1 dL = 0,1 L = 100 mL',
      },
    ),
    MeasureUnit(
      id: 'cl',
      label: '厘升',
      symbol: 'cL',
      names: <AppLanguage, String>{
        AppLanguage.en: 'centilitre',
        AppLanguage.ja: 'センチリットル',
        AppLanguage.es: 'centilitro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
      note: '1 厘升 = 10 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 cL = 10 mL',
        AppLanguage.ja: '1 cL = 10 mL',
        AppLanguage.es: '1 cL = 10 mL',
      },
    ),
    MeasureUnit(
      id: 'ml',
      label: '毫升',
      symbol: 'mL',
      names: <AppLanguage, String>{
        AppLanguage.en: 'millilitre',
        AppLanguage.ja: 'ミリリットル',
        AppLanguage.es: 'mililitro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
      note: '1 毫升 = 1 立方厘米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 mL = 1 cm³',
        AppLanguage.ja: '1 mL = 1 cm³',
        AppLanguage.es: '1 mL = 1 cm³',
      },
    ),
    MeasureUnit(
      id: 'ul',
      label: '微升',
      symbol: 'μL',
      names: <AppLanguage, String>{
        AppLanguage.en: 'microlitre',
        AppLanguage.ja: 'マイクロリットル',
        AppLanguage.es: 'microlitro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
      note: '1 微升 = 1 立方毫米，实验室常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 µL = 1 mm³, common in labs',
        AppLanguage.ja: '1 µL = 1 mm³、実験室でよく使います',
        AppLanguage.es: '1 µL = 1 mm³, habitual en laboratorios',
      },
    ),
    // 英制（英制 UK 口径；美制加仑约 3.785 升）
    MeasureUnit(
      id: 'gal',
      label: '加仑',
      symbol: 'gal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'gallon',
        AppLanguage.ja: 'ガロン',
        AppLanguage.es: 'galón',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 100000,
      note: '英制加仑 = 4.54609 升（美制加仑 ≈ 3.785 升）',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 imperial gallon = 4.54609 L (US gallon ≈ 3.785 L)',
        AppLanguage.ja: '1 英ガロン = 4.54609 L（米ガロン ≈ 3.785 L）',
        AppLanguage.es:
            '1 galón imperial = 4,54609 L (galón estadounidense ≈ 3,785 L)',
      },
    ),
    MeasureUnit(
      id: 'qt',
      label: '夸脱',
      symbol: 'qt',
      names: <AppLanguage, String>{
        AppLanguage.en: 'quart',
        AppLanguage.ja: 'クォート',
        AppLanguage.es: 'cuarto',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 400000,
      note: '1 夸脱 = 1/4 加仑 = 1.1365225 升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 quart = 1/4 gallon = 1.1365225 L',
        AppLanguage.ja: '1 クォート = 1/4 ガロン = 1.1365225 L',
        AppLanguage.es: '1 cuarto = 1/4 de galón = 1,1365225 L',
      },
    ),
    MeasureUnit(
      id: 'pt',
      label: '品脱',
      symbol: 'pt',
      names: <AppLanguage, String>{
        AppLanguage.en: 'pint',
        AppLanguage.ja: 'パイント',
        AppLanguage.es: 'pinta',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 800000,
      note: '1 品脱 = 1/2 夸脱 ≈ 568.26 毫升，酒吧常见',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 pint = 1/2 quart ≈ 568.26 mL, common in pubs',
        AppLanguage.ja: '1 パイント = 1/2 クォート ≈ 568.26 mL、パブでよく使います',
        AppLanguage.es:
            '1 pinta = 1/2 cuarto ≈ 568,26 mL, habitual en los pubs',
      },
    ),
    MeasureUnit(
      id: 'floz',
      label: '液量盎司',
      symbol: 'fl oz',
      names: <AppLanguage, String>{
        AppLanguage.en: 'fluid ounce',
        AppLanguage.ja: '液量オンス',
        AppLanguage.es: 'onza líquida',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 454609,
      baseDenominator: 16000000,
      note: '英制液量盎司 = 1/160 加仑 ≈ 28.41 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 imperial fluid ounce = 1/160 gallon ≈ 28.41 mL',
        AppLanguage.ja: '1 英液量オンス = 1/160 ガロン ≈ 28.41 mL',
        AppLanguage.es: '1 onza líquida imperial = 1/160 de galón ≈ 28,41 mL',
      },
    ),
    MeasureUnit(
      id: 'bu',
      label: '蒲式耳',
      symbol: 'bu',
      names: <AppLanguage, String>{
        AppLanguage.en: 'bushel',
        AppLanguage.ja: 'ブッシェル',
        AppLanguage.es: 'bushel',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 3636872,
      baseDenominator: 100000,
      note: '1 蒲式耳 = 8 加仑 = 36.36872 升，谷物计量单位',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 bushel = 8 gallons = 36.36872 L, used for grain',
        AppLanguage.ja: '1 ブッシェル = 8 ガロン = 36.36872 L、穀物の計量に使います',
        AppLanguage.es:
            '1 bushel = 8 galones = 36,36872 L, se usa para el grano',
      },
    ),
    // 市制（1 石 = 10 斗 = 100 升，1 升 = 10 合 = 100 勺）
    MeasureUnit(
      id: 'dan',
      label: '石',
      symbol: '石',
      names: <AppLanguage, String>{
        AppLanguage.en: 'dan',
        AppLanguage.ja: '石',
        AppLanguage.es: 'dan',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 100,
      baseDenominator: 1,
      note: '1 石 = 10 斗 = 100 升，古代粮米常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 dan = 10 dou = 100 L, a historical grain measure',
        AppLanguage.ja: '1 石 = 10 斗 = 100 L、昔の穀物の単位です',
        AppLanguage.es: '1 dan = 10 dou = 100 L, medida histórica de grano',
      },
    ),
    MeasureUnit(
      id: 'dou',
      label: '斗',
      symbol: '斗',
      names: <AppLanguage, String>{
        AppLanguage.en: 'dou',
        AppLanguage.ja: '斗',
        AppLanguage.es: 'dou',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 10,
      baseDenominator: 1,
      note: '1 斗 = 10 升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 dou = 10 L',
        AppLanguage.ja: '1 斗 = 10 L',
        AppLanguage.es: '1 dou = 10 L',
      },
    ),
    MeasureUnit(
      id: 'sheng',
      label: '升',
      symbol: '升',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sheng',
        AppLanguage.ja: '升',
        AppLanguage.es: 'sheng',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '1 市升 = 1 升 = 1000 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sheng = 1 L = 1000 mL',
        AppLanguage.ja: '1 升 = 1 L = 1000 mL',
        AppLanguage.es: '1 sheng = 1 L = 1000 mL',
      },
    ),
    MeasureUnit(
      id: 'ge',
      label: '合',
      symbol: '合',
      names: <AppLanguage, String>{
        AppLanguage.en: 'ge',
        AppLanguage.ja: '合',
        AppLanguage.es: 'ge',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 10,
      note: '1 合 = 1/10 升 = 100 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 ge = 1/10 L = 100 mL',
        AppLanguage.ja: '1 合 = 1/10 L = 100 mL',
        AppLanguage.es: '1 ge = 1/10 L = 100 mL',
      },
    ),
    MeasureUnit(
      id: 'shao',
      label: '勺',
      symbol: '勺',
      names: <AppLanguage, String>{
        AppLanguage.en: 'shao',
        AppLanguage.ja: '勺',
        AppLanguage.es: 'shao',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 100,
      note: '1 勺 = 1/10 合 = 10 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 shao = 1/10 ge = 10 mL',
        AppLanguage.ja: '1 勺 = 1/10 合 = 10 mL',
        AppLanguage.es: '1 shao = 1/10 ge = 10 mL',
      },
    ),
    MeasureUnit(
      id: 'cuo',
      label: '撮',
      symbol: '撮',
      names: <AppLanguage, String>{
        AppLanguage.en: 'cuo',
        AppLanguage.ja: '撮',
        AppLanguage.es: 'cuo',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 1000,
      note: '1 撮 = 1/10 勺 = 1 毫升',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 cuo = 1/10 shao = 1 mL',
        AppLanguage.ja: '1 撮 = 1/10 勺 = 1 mL',
        AppLanguage.es: '1 cuo = 1/10 shao = 1 mL',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: '一勺药水',
      value: 5,
      unitId: 'ml',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Spoon of syrup',
        AppLanguage.ja: '薬のひとさじ',
        AppLanguage.es: 'Una cucharada de jarabe',
      },
    ),
    MeasureSample(
      label: '一杯水',
      value: 250,
      unitId: 'ml',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Glass of water',
        AppLanguage.ja: 'コップ 1 杯',
        AppLanguage.es: 'Un vaso de agua',
      },
    ),
    MeasureSample(
      label: '一听可乐',
      value: 330,
      unitId: 'ml',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Can of cola',
        AppLanguage.ja: '缶コーラ 1 本',
        AppLanguage.es: 'Una lata de refresco',
      },
    ),
    MeasureSample(
      label: '一瓶矿泉水',
      value: 550,
      unitId: 'ml',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Bottle of water',
        AppLanguage.ja: 'ペットボトル 1 本',
        AppLanguage.es: 'Una botella de agua',
      },
    ),
    MeasureSample(
      label: '1 升水',
      value: 1,
      unitId: 'l',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 L of water',
        AppLanguage.ja: '水 1 L',
        AppLanguage.es: '1 L de agua',
      },
    ),
    MeasureSample(
      label: '一桶食用油',
      value: 5,
      unitId: 'l',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Cooking oil',
        AppLanguage.ja: '食用油 1 本',
        AppLanguage.es: 'Una botella de aceite',
      },
    ),
    MeasureSample(
      label: '饮水机水桶',
      value: 18.9,
      unitId: 'l',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Water cooler jug',
        AppLanguage.ja: 'ウォーターサーバーのタンク',
        AppLanguage.es: 'Garrafa de dispensador',
      },
    ),
    MeasureSample(
      label: '汽车油箱',
      value: 50,
      unitId: 'l',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Car fuel tank',
        AppLanguage.ja: '車の燃料タンク',
        AppLanguage.es: 'Depósito de un coche',
      },
    ),
    MeasureSample(
      label: '1 加仑',
      value: 1,
      unitId: 'gal',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 gallon',
        AppLanguage.ja: '1 ガロン',
        AppLanguage.es: '1 galón',
      },
    ),
    MeasureSample(
      label: '1 斗',
      value: 1,
      unitId: 'dou',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 dou',
        AppLanguage.ja: '1 斗',
        AppLanguage.es: '1 dou',
      },
    ),
    MeasureSample(
      label: '标准泳池',
      value: 2500000,
      unitId: 'l',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Olympic pool',
        AppLanguage.ja: '競泳プール',
        AppLanguage.es: 'Piscina olímpica',
      },
    ),
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
