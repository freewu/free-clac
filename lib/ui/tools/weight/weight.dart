/// 重量换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「千克」为基准，折算系数用分数保存：
/// 1 磅 = 45359237/100000000 千克，1 斤 = 1/2 千克，
/// 1 两 = 1/20 千克（市制按 1 斤 = 10 两计）。
library;

import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

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
      names: <AppLanguage, String>{
        AppLanguage.en: 'tonne',
        AppLanguage.ja: 'トン',
        AppLanguage.es: 'tonelada',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 吨 = 1000 千克',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 tonne = 1000 kg',
        AppLanguage.ja: '1 トン = 1000 kg',
        AppLanguage.es: '1 tonelada = 1000 kg',
      },
    ),
    MeasureUnit(
      id: 'kg',
      label: '千克',
      symbol: 'kg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilogram',
        AppLanguage.ja: 'キログラム',
        AppLanguage.es: 'kilogramo',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '千克是国际单位制的质量基本单位，日常也叫公斤',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'The kilogram is the SI base unit of mass',
        AppLanguage.ja: 'キログラムは SI の質量の基本単位です',
        AppLanguage.es: 'El kilogramo es la unidad básica de masa del SI',
      },
    ),
    MeasureUnit(
      id: 'g',
      label: '克',
      symbol: 'g',
      names: <AppLanguage, String>{
        AppLanguage.en: 'gram',
        AppLanguage.ja: 'グラム',
        AppLanguage.es: 'gramo',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
    ),
    MeasureUnit(
      id: 'mg',
      label: '毫克',
      symbol: 'mg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'milligram',
        AppLanguage.ja: 'ミリグラム',
        AppLanguage.es: 'miligramo',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    MeasureUnit(
      id: 'ug',
      label: '微克',
      symbol: 'μg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'microgram',
        AppLanguage.ja: 'マイクログラム',
        AppLanguage.es: 'microgramo',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000,
    ),
    // 英制（英制与美制质量单位相同，吨分长吨 / 短吨）
    MeasureUnit(
      id: 'longton',
      label: '长吨',
      symbol: 'ton',
      names: <AppLanguage, String>{
        AppLanguage.en: 'long ton',
        AppLanguage.ja: '英トン',
        AppLanguage.es: 'tonelada larga',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 10160469088,
      baseDenominator: 10000000,
      note: '英吨，1 长吨 = 2240 磅 = 1016.0469088 千克',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'Long ton: 1 long ton = 2240 lb = 1016.0469088 kg',
        AppLanguage.ja: '英トン：1 英トン = 2240 ポンド = 1016.0469088 kg',
        AppLanguage.es:
            'Tonelada larga: 1 tonelada larga = 2240 lb = 1016,0469088 kg',
      },
    ),
    MeasureUnit(
      id: 'shortton',
      label: '短吨',
      symbol: 'sh tn',
      names: <AppLanguage, String>{
        AppLanguage.en: 'short ton',
        AppLanguage.ja: '米トン',
        AppLanguage.es: 'tonelada corta',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 90718474,
      baseDenominator: 100000,
      note: '美吨，1 短吨 = 2000 磅 = 907.18474 千克',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'Short ton: 1 short ton = 2000 lb = 907.18474 kg',
        AppLanguage.ja: '米トン：1 米トン = 2000 ポンド = 907.18474 kg',
        AppLanguage.es:
            'Tonelada corta: 1 tonelada corta = 2000 lb = 907,18474 kg',
      },
    ),
    MeasureUnit(
      id: 'lb',
      label: '磅',
      symbol: 'lb',
      names: <AppLanguage, String>{
        AppLanguage.en: 'pound',
        AppLanguage.ja: 'ポンド',
        AppLanguage.es: 'libra',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 45359237,
      baseDenominator: 100000000,
      note: '1 磅 = 16 盎司 = 0.45359237 千克',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 lb = 16 oz = 0.45359237 kg',
        AppLanguage.ja: '1 ポンド = 16 オンス = 0.45359237 kg',
        AppLanguage.es: '1 lb = 16 oz = 0,45359237 kg',
      },
    ),
    MeasureUnit(
      id: 'oz',
      label: '盎司',
      symbol: 'oz',
      names: <AppLanguage, String>{
        AppLanguage.en: 'ounce',
        AppLanguage.ja: 'オンス',
        AppLanguage.es: 'onza',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 45359237,
      baseDenominator: 1600000000,
      note: '常衡盎司，1 盎司 = 1/16 磅 ≈ 28.35 克',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'Avoirdupois ounce: 1 oz = 1/16 lb ≈ 28.35 g',
        AppLanguage.ja: '常用オンス：1 オンス = 1/16 ポンド ≈ 28.35 g',
        AppLanguage.es: 'Onza avoirdupois: 1 oz = 1/16 lb ≈ 28,35 g',
      },
    ),
    MeasureUnit(
      id: 'st',
      label: '英石',
      symbol: 'st',
      names: <AppLanguage, String>{
        AppLanguage.en: 'stone',
        AppLanguage.ja: 'ストーン',
        AppLanguage.es: 'stone',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 635029318,
      baseDenominator: 100000000,
      note: '1 英石 = 14 磅 = 6.35029318 千克，英国人报体重常用',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 stone = 14 lb = 6.35029318 kg, used for body weight in the UK',
        AppLanguage.ja: '1 ストーン = 14 ポンド = 6.35029318 kg、英国で体重に使います',
        AppLanguage.es:
            '1 stone = 14 lb = 6,35029318 kg, se usa para el peso corporal en el Reino Unido',
      },
    ),
    MeasureUnit(
      id: 'gr',
      label: '格令',
      symbol: 'gr',
      names: <AppLanguage, String>{
        AppLanguage.en: 'grain',
        AppLanguage.ja: 'グレイン',
        AppLanguage.es: 'grano',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 6479891,
      baseDenominator: 100000000000,
      note: '1 格令 = 64.79891 毫克，药量与弹药常用',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 grain = 64.79891 mg, used in pharmacy and ammunition',
        AppLanguage.ja: '1 グレーン = 64.79891 mg、薬学や弾薬で使います',
        AppLanguage.es: '1 grano = 64,79891 mg, se usa en farmacia y munición',
      },
    ),
    // 市制（1 斤 = 500 克 = 10 两）
    MeasureUnit(
      id: 'dan',
      label: '担',
      symbol: '担',
      names: <AppLanguage, String>{
        AppLanguage.en: 'dan',
        AppLanguage.ja: '担',
        AppLanguage.es: 'dan',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 50,
      baseDenominator: 1,
      note: '1 担 = 100 斤 = 50 千克',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 dan = 100 jin = 50 kg',
        AppLanguage.ja: '1 担 = 100 斤 = 50 kg',
        AppLanguage.es: '1 dan = 100 jin = 50 kg',
      },
    ),
    MeasureUnit(
      id: 'jin',
      label: '斤',
      symbol: '斤',
      names: <AppLanguage, String>{
        AppLanguage.en: 'jin',
        AppLanguage.ja: '斤',
        AppLanguage.es: 'jin',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 2,
      note: '1 斤 = 500 克 = 10 两',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 jin = 500 g = 10 liang',
        AppLanguage.ja: '1 斤 = 500 g = 10 両',
        AppLanguage.es: '1 jin = 500 g = 10 liang',
      },
    ),
    MeasureUnit(
      id: 'liang',
      label: '两',
      symbol: '两',
      names: <AppLanguage, String>{
        AppLanguage.en: 'liang',
        AppLanguage.ja: '両',
        AppLanguage.es: 'liang',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 20,
      note: '1 两 = 50 克（旧制 1 斤 = 16 两，今按 10 两计）',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 liang = 50 g (the old system had 16 liang per jin)',
        AppLanguage.ja: '1 両 = 50 g（昔は 1 斤 = 16 両でした）',
        AppLanguage.es:
            '1 liang = 50 g (el sistema antiguo tenía 16 liang por jin)',
      },
    ),
    MeasureUnit(
      id: 'qian',
      label: '钱',
      symbol: '钱',
      names: <AppLanguage, String>{
        AppLanguage.en: 'qian',
        AppLanguage.ja: '銭',
        AppLanguage.es: 'qian',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 200,
      note: '1 钱 = 5 克，中药抓药常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 qian = 5 g, used in Chinese herbal medicine',
        AppLanguage.ja: '1 銭 = 5 g、漢方薬で使います',
        AppLanguage.es: '1 qian = 5 g, se usa en la medicina herbal china',
      },
    ),
    MeasureUnit(
      id: 'fen',
      label: '分',
      symbol: '分',
      names: <AppLanguage, String>{
        AppLanguage.en: 'fen',
        AppLanguage.ja: '分',
        AppLanguage.es: 'fen',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 2000,
      note: '1 分 = 0.5 克',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 fen = 0.5 g',
        AppLanguage.ja: '1 分 = 0.5 g',
        AppLanguage.es: '1 fen = 0,5 g',
      },
    ),
    MeasureUnit(
      id: 'li2',
      label: '厘',
      symbol: '厘',
      names: <AppLanguage, String>{
        AppLanguage.en: 'li',
        AppLanguage.ja: '厘',
        AppLanguage.es: 'li',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 20000,
      note: '1 厘 = 0.05 克',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 li = 0.05 g',
        AppLanguage.ja: '1 厘 = 0.05 g',
        AppLanguage.es: '1 li (厘) = 0,05 g',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: '一粒米',
      value: 0.02,
      unitId: 'g',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Grain of rice',
        AppLanguage.ja: '米粒 1 粒',
        AppLanguage.es: 'Un grano de arroz',
      },
    ),
    MeasureSample(
      label: '一枚鸡蛋',
      value: 50,
      unitId: 'g',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Egg',
        AppLanguage.ja: '卵 1 個',
        AppLanguage.es: 'Un huevo',
      },
    ),
    MeasureSample(
      label: '一杯牛奶',
      value: 250,
      unitId: 'g',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Glass of milk',
        AppLanguage.ja: 'コップ 1 杯の牛乳',
        AppLanguage.es: 'Un vaso de leche',
      },
    ),
    MeasureSample(
      label: '一瓶矿泉水',
      value: 550,
      unitId: 'g',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Bottle of water',
        AppLanguage.ja: 'ペットボトル 1 本',
        AppLanguage.es: 'Una botella de agua',
      },
    ),
    MeasureSample(
      label: '一个成年人',
      value: 65,
      unitId: 'kg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Adult',
        AppLanguage.ja: '大人 1 人',
        AppLanguage.es: 'Una persona adulta',
      },
    ),
    MeasureSample(
      label: '一袋大米',
      value: 10,
      unitId: 'kg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Bag of rice',
        AppLanguage.ja: '米 1 袋',
        AppLanguage.es: 'Un saco de arroz',
      },
    ),
    MeasureSample(
      label: '1 斤',
      value: 1,
      unitId: 'jin',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 jin',
        AppLanguage.ja: '1 斤',
        AppLanguage.es: '1 jin',
      },
    ),
    MeasureSample(
      label: '1 磅',
      value: 1,
      unitId: 'lb',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 pound',
        AppLanguage.ja: '1 ポンド',
        AppLanguage.es: '1 libra',
      },
    ),
    MeasureSample(
      label: '一头大象',
      value: 5000,
      unitId: 'kg',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Elephant',
        AppLanguage.ja: 'ゾウ 1 頭',
        AppLanguage.es: 'Un elefante',
      },
    ),
    MeasureSample(
      label: '一辆小汽车',
      value: 1.5,
      unitId: 't',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Car',
        AppLanguage.ja: '乗用車 1 台',
        AppLanguage.es: 'Un coche',
      },
    ),
    MeasureSample(
      label: '一头蓝鲸',
      value: 150,
      unitId: 't',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Blue whale',
        AppLanguage.ja: 'シロナガスクジラ',
        AppLanguage.es: 'Una ballena azul',
      },
    ),
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
