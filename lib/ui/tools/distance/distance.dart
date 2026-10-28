/// 长度换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「米」为基准，用分数形式（分子 / 分母）精确保存折算系数，
/// 避免 0.3048 之类的十进制字面量在连续换算中累积误差。
library;

import '../../../l10n/app_language.dart';
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
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilometre',
        AppLanguage.ja: 'キロメートル',
        AppLanguage.es: 'kilómetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 千米 = 1000 米，也叫公里',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 km = 1000 m, also called a kilometre',
        AppLanguage.ja: '1 km = 1000 m、キロメートルとも呼びます',
        AppLanguage.es: '1 km = 1000 m, también llamado kilómetro',
      },
    ),
    MeasureUnit(
      id: 'm',
      label: '米',
      symbol: 'm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'metre',
        AppLanguage.ja: 'メートル',
        AppLanguage.es: 'metro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'dm',
      label: '分米',
      symbol: 'dm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'decimetre',
        AppLanguage.ja: 'デシメートル',
        AppLanguage.es: 'decímetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10,
    ),
    MeasureUnit(
      id: 'cm',
      label: '厘米',
      symbol: 'cm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'centimetre',
        AppLanguage.ja: 'センチメートル',
        AppLanguage.es: 'centímetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
    ),
    MeasureUnit(
      id: 'mm',
      label: '毫米',
      symbol: 'mm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'millimetre',
        AppLanguage.ja: 'ミリメートル',
        AppLanguage.es: 'milímetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000,
    ),
    MeasureUnit(
      id: 'um',
      label: '微米',
      symbol: 'μm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'micrometre',
        AppLanguage.ja: 'マイクロメートル',
        AppLanguage.es: 'micrómetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    MeasureUnit(
      id: 'nm',
      label: '纳米',
      symbol: 'nm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'nanometre',
        AppLanguage.ja: 'ナノメートル',
        AppLanguage.es: 'nanómetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000,
    ),
    MeasureUnit(
      id: 'pm',
      label: '皮米',
      symbol: 'pm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'picometre',
        AppLanguage.ja: 'ピコメートル',
        AppLanguage.es: 'picómetro',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000000000,
    ),
    MeasureUnit(
      id: 'nmile',
      label: '海里',
      symbol: 'nmi',
      names: <AppLanguage, String>{
        AppLanguage.en: 'nautical mile',
        AppLanguage.ja: '海里',
        AppLanguage.es: 'milla náutica',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1852,
      baseDenominator: 1,
      note: '1 海里 = 1852 米，按地球子午线 1 分弧长定义',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 nautical mile = 1852 m, one arc-minute of the meridian',
        AppLanguage.ja: '1 海里 = 1852 m、子午線 1 分の長さ',
        AppLanguage.es:
            '1 milla náutica = 1852 m, un minuto de arco del meridiano',
      },
    ),
    // 英制
    MeasureUnit(
      id: 'inch',
      label: '英寸',
      symbol: 'in',
      names: <AppLanguage, String>{
        AppLanguage.en: 'inch',
        AppLanguage.ja: 'インチ',
        AppLanguage.es: 'pulgada',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 254,
      baseDenominator: 10000,
      note: '1 英寸 = 2.54 厘米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 inch = 2.54 cm',
        AppLanguage.ja: '1 インチ = 2.54 cm',
        AppLanguage.es: '1 pulgada = 2.54 cm',
      },
    ),
    MeasureUnit(
      id: 'foot',
      label: '英尺',
      symbol: 'ft',
      names: <AppLanguage, String>{
        AppLanguage.en: 'foot',
        AppLanguage.ja: 'フィート',
        AppLanguage.es: 'pie',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 3048,
      baseDenominator: 10000,
      note: '1 英尺 = 12 英寸 = 0.3048 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 foot = 12 inches = 0.3048 m',
        AppLanguage.ja: '1 フィート = 12 インチ = 0.3048 m',
        AppLanguage.es: '1 pie = 12 pulgadas = 0,3048 m',
      },
    ),
    MeasureUnit(
      id: 'yard',
      label: '码',
      symbol: 'yd',
      names: <AppLanguage, String>{
        AppLanguage.en: 'yard',
        AppLanguage.ja: 'ヤード',
        AppLanguage.es: 'yarda',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 9144,
      baseDenominator: 10000,
      note: '1 码 = 3 英尺 = 0.9144 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 yard = 3 feet = 0.9144 m',
        AppLanguage.ja: '1 ヤード = 3 フィート = 0.9144 m',
        AppLanguage.es: '1 yarda = 3 pies = 0,9144 m',
      },
    ),
    MeasureUnit(
      id: 'mile',
      label: '英里',
      symbol: 'mi',
      names: <AppLanguage, String>{
        AppLanguage.en: 'mile',
        AppLanguage.ja: 'マイル',
        AppLanguage.es: 'milla',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 1609344,
      baseDenominator: 1000,
      note: '1 英里 = 1760 码 = 1609.344 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 mile = 1760 yards = 1609.344 m',
        AppLanguage.ja: '1 マイル = 1760 ヤード = 1609.344 m',
        AppLanguage.es: '1 milla = 1760 yardas = 1609,344 m',
      },
    ),
    MeasureUnit(
      id: 'fathom',
      label: '英寻',
      symbol: 'fth',
      names: <AppLanguage, String>{
        AppLanguage.en: 'fathom',
        AppLanguage.ja: 'ファゾム',
        AppLanguage.es: 'braza',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 1829,
      baseDenominator: 1000,
      note: '1 英寻 = 6 英尺 = 1.8288 米，航海测深常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 fathom = 6 feet = 1.8288 m, used for sea depth',
        AppLanguage.ja: '1 尋 = 6 フィート = 1.8288 m、海の深さに使います',
        AppLanguage.es:
            '1 braza = 6 pies = 1,8288 m, se usa para la profundidad marina',
      },
    ),
    MeasureUnit(
      id: 'chain',
      label: '链',
      symbol: 'ch',
      names: <AppLanguage, String>{
        AppLanguage.en: 'chain',
        AppLanguage.ja: 'チェーン',
        AppLanguage.es: 'cadena',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 201168,
      baseDenominator: 10000,
      note: '测链，1 链 = 66 英尺 = 20.1168 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'Surveying chain: 1 chain = 66 feet = 20.1168 m',
        AppLanguage.ja: '測量用のチェーン：1 チェーン = 66 フィート = 20.1168 m',
        AppLanguage.es: 'Cadena de agrimensor: 1 cadena = 66 pies = 20,1168 m',
      },
    ),
    MeasureUnit(
      id: 'furlong',
      label: '化朗',
      symbol: 'fur',
      names: <AppLanguage, String>{
        AppLanguage.en: 'furlong',
        AppLanguage.ja: 'ハロン',
        AppLanguage.es: 'furlong',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 201168,
      baseDenominator: 1000,
      note: '1 化朗 = 10 链 = 201.168 米，赛马距离常用',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 furlong = 10 chains = 201.168 m, used in horse racing',
        AppLanguage.ja: '1 ハロン = 10 チェーン = 201.168 m、競馬で使います',
        AppLanguage.es:
            '1 furlong = 10 cadenas = 201,168 m, se usa en carreras de caballos',
      },
    ),
    // 市制（1 尺 = 1/3 米，故 1 丈 = 10/3 米、1 里 = 500 米）
    MeasureUnit(
      id: 'li',
      label: '里',
      symbol: '里',
      names: <AppLanguage, String>{
        AppLanguage.en: 'li',
        AppLanguage.ja: '里',
        AppLanguage.es: 'li',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 500,
      baseDenominator: 1,
      note: '1 里 = 150 丈 = 500 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 li = 150 zhang = 500 m',
        AppLanguage.ja: '1 里 = 150 丈 = 500 m',
        AppLanguage.es: '1 li = 150 zhang = 500 m',
      },
    ),
    MeasureUnit(
      id: 'yin',
      label: '引',
      symbol: '引',
      names: <AppLanguage, String>{
        AppLanguage.en: 'yin',
        AppLanguage.ja: '引',
        AppLanguage.es: 'yin',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 500,
      baseDenominator: 15,
      note: '1 引 = 10 丈 ≈ 33.33 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 yin = 10 zhang ≈ 33.33 m',
        AppLanguage.ja: '1 引 = 10 丈 ≈ 33.33 m',
        AppLanguage.es: '1 yin = 10 zhang ≈ 33,33 m',
      },
    ),
    MeasureUnit(
      id: 'zhang',
      label: '丈',
      symbol: '丈',
      names: <AppLanguage, String>{
        AppLanguage.en: 'zhang',
        AppLanguage.ja: '丈',
        AppLanguage.es: 'zhang',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 50,
      baseDenominator: 15,
      note: '1 丈 = 10 尺 ≈ 3.333 米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 zhang = 10 chi ≈ 3.333 m',
        AppLanguage.ja: '1 丈 = 10 尺 ≈ 3.333 m',
        AppLanguage.es: '1 zhang = 10 chi ≈ 3,333 m',
      },
    ),
    MeasureUnit(
      id: 'chi',
      label: '尺',
      symbol: '尺',
      names: <AppLanguage, String>{
        AppLanguage.en: 'chi',
        AppLanguage.ja: '尺',
        AppLanguage.es: 'chi',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 15,
      note: '1 尺 = 1/3 米 ≈ 33.33 厘米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 chi = 1/3 m ≈ 33.33 cm',
        AppLanguage.ja: '1 尺 = 1/3 m ≈ 33.33 cm',
        AppLanguage.es: '1 chi = 1/3 m ≈ 33,33 cm',
      },
    ),
    MeasureUnit(
      id: 'cun',
      label: '寸',
      symbol: '寸',
      names: <AppLanguage, String>{
        AppLanguage.en: 'cun',
        AppLanguage.ja: '寸',
        AppLanguage.es: 'cun',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 150,
      note: '1 寸 = 1/10 尺 ≈ 3.333 厘米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 cun = 1/10 chi ≈ 3.333 cm',
        AppLanguage.ja: '1 寸 = 1/10 尺 ≈ 3.333 cm',
        AppLanguage.es: '1 cun = 1/10 chi ≈ 3,333 cm',
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
      baseNumerator: 5,
      baseDenominator: 1500,
      note: '1 分 = 1/10 寸 ≈ 3.333 毫米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 fen = 1/10 cun ≈ 3.333 mm',
        AppLanguage.ja: '1 分 = 1/10 寸 ≈ 3.333 mm',
        AppLanguage.es: '1 fen = 1/10 cun ≈ 3,333 mm',
      },
    ),
    MeasureUnit(
      // 厘与「里」同音，id 加后缀区分
      id: 'li2',
      label: '厘',
      symbol: '厘',
      names: <AppLanguage, String>{
        AppLanguage.en: 'li',
        AppLanguage.ja: '厘',
        AppLanguage.es: 'li',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 15000,
      note: '1 厘 = 1/10 分 ≈ 0.333 毫米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 li = 1/10 fen ≈ 0.333 mm',
        AppLanguage.ja: '1 厘 = 1/10 分 ≈ 0.333 mm',
        AppLanguage.es: '1 li (厘) = 1/10 fen ≈ 0,333 mm',
      },
    ),
    MeasureUnit(
      id: 'hao',
      label: '毫',
      symbol: '毫',
      names: <AppLanguage, String>{
        AppLanguage.en: 'hao',
        AppLanguage.ja: '毫',
        AppLanguage.es: 'hao',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 150000,
      note: '1 毫 = 1/10 厘 ≈ 33.3 微米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 hao = 1/10 li ≈ 33.3 µm',
        AppLanguage.ja: '1 毛 = 1/10 厘 ≈ 33.3 µm',
        AppLanguage.es: '1 hao = 1/10 li ≈ 33,3 µm',
      },
    ),
    MeasureUnit(
      id: 'si',
      label: '丝',
      symbol: '丝',
      names: <AppLanguage, String>{
        AppLanguage.en: 'si',
        AppLanguage.ja: '丝',
        AppLanguage.es: 'si',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 5,
      baseDenominator: 1500000,
      note: '1 丝 = 1/10 毫 ≈ 3.33 微米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 si = 1/10 hao ≈ 3.33 µm',
        AppLanguage.ja: '1 糸 = 1/10 毛 ≈ 3.33 µm',
        AppLanguage.es: '1 si = 1/10 hao ≈ 3,33 µm',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: 'A4 纸厚',
      value: 0.1,
      unitId: 'mm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'A4 thickness',
        AppLanguage.ja: 'A4 用紙の厚さ',
        AppLanguage.es: 'Grosor de un A4',
      },
    ),
    MeasureSample(
      label: '身份证宽',
      value: 85.6,
      unitId: 'mm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'ID card',
        AppLanguage.ja: '身分証の幅',
        AppLanguage.es: 'Ancho de un carné',
      },
    ),
    MeasureSample(
      label: '身高',
      value: 170,
      unitId: 'cm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Body height',
        AppLanguage.ja: '身長',
        AppLanguage.es: 'Altura de una persona',
      },
    ),
    MeasureSample(
      label: '马拉松',
      value: 42.195,
      unitId: 'km',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Marathon',
        AppLanguage.ja: 'マラソン',
        AppLanguage.es: 'Maratón',
      },
    ),
    MeasureSample(
      label: '珠峰高度',
      value: 8848.86,
      unitId: 'm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Everest',
        AppLanguage.ja: 'エベレストの高さ',
        AppLanguage.es: 'Altura del Everest',
      },
    ),
    MeasureSample(
      label: '地球直径',
      value: 12756,
      unitId: 'km',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Earth diameter',
        AppLanguage.ja: '地球の直径',
        AppLanguage.es: 'Diámetro de la Tierra',
      },
    ),
    MeasureSample(
      label: '地月距离',
      value: 384400,
      unitId: 'km',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Earth-Moon',
        AppLanguage.ja: '地球と月の距離',
        AppLanguage.es: 'Distancia Tierra-Luna',
      },
    ),
    MeasureSample(
      label: '日地距离',
      value: 149600000,
      unitId: 'km',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Earth-Sun',
        AppLanguage.ja: '地球と太陽の距離',
        AppLanguage.es: 'Distancia Tierra-Sol',
      },
    ),
    MeasureSample(
      label: '1 光年',
      value: 9460730472580.8,
      unitId: 'km',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 light year',
        AppLanguage.ja: '1 光年',
        AppLanguage.es: '1 año luz',
      },
    ),
    MeasureSample(
      label: '1 英里',
      value: 1,
      unitId: 'mile',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 mile',
        AppLanguage.ja: '1 マイル',
        AppLanguage.es: '1 milla',
      },
    ),
    MeasureSample(
      label: '1 海里',
      value: 1,
      unitId: 'nmile',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 nautical mile',
        AppLanguage.ja: '1 海里',
        AppLanguage.es: '1 milla náutica',
      },
    ),
    MeasureSample(
      label: '1 里',
      value: 1,
      unitId: 'li',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 li',
        AppLanguage.ja: '1 里',
        AppLanguage.es: '1 li',
      },
    ),
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
