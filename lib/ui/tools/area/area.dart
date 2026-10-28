/// 面积换算：公制 / 英制 / 市制互转，纯逻辑，不依赖 Flutter。
///
/// 所有单位都以「平方米」为基准，折算系数用分数保存：
/// 1 平方英尺 = (3048/10000)² 米² = 9290304/100000000 米²，
/// 1 亩 = 60 平方丈 = 60 × (10/3)² = 2000/3 米²。
library;

import '../../../l10n/app_language.dart';
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
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq kilometre',
        AppLanguage.ja: '平方キロメートル',
        AppLanguage.es: 'km cuadrado',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000000,
      baseDenominator: 1,
      note: '1 平方千米 = 1000000 平方米 = 100 公顷',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq km = 1,000,000 m² = 100 hectares',
      },
    ),
    MeasureUnit(
      id: 'ha',
      label: '公顷',
      symbol: 'ha',
      names: <AppLanguage, String>{
        AppLanguage.en: 'hectare',
        AppLanguage.ja: 'ヘクタール',
        AppLanguage.es: 'hectárea',
      },
      system: MeasureSystem.metric,
      baseNumerator: 10000,
      baseDenominator: 1,
      note: '1 公顷 = 10000 平方米 = 15 亩',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 hectare = 10,000 m² = 15 mu',
      },
    ),
    MeasureUnit(
      id: 'are',
      label: '公亩',
      symbol: 'a',
      names: <AppLanguage, String>{
        AppLanguage.en: 'are',
        AppLanguage.ja: 'アール',
        AppLanguage.es: 'área',
      },
      system: MeasureSystem.metric,
      baseNumerator: 100,
      baseDenominator: 1,
      note: '1 公亩 = 100 平方米',
      notes: <AppLanguage, String>{AppLanguage.en: '1 are = 100 m²'},
    ),
    MeasureUnit(
      id: 'sqm',
      label: '平方米',
      symbol: 'm²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq metre',
        AppLanguage.ja: '平方メートル',
        AppLanguage.es: 'metro cuadrado',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
    ),
    MeasureUnit(
      id: 'sqdm',
      label: '平方分米',
      symbol: 'dm²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq decimetre',
        AppLanguage.ja: '平方デシメートル',
        AppLanguage.es: 'dm cuadrado',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 100,
    ),
    MeasureUnit(
      id: 'sqcm',
      label: '平方厘米',
      symbol: 'cm²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq centimetre',
        AppLanguage.ja: '平方センチメートル',
        AppLanguage.es: 'cm cuadrado',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 10000,
    ),
    MeasureUnit(
      id: 'sqmm',
      label: '平方毫米',
      symbol: 'mm²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq millimetre',
        AppLanguage.ja: '平方ミリメートル',
        AppLanguage.es: 'mm cuadrado',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1000000,
    ),
    // 英制（1 英寸 = 0.0254 米，面积按边长平方折算）
    MeasureUnit(
      id: 'sqmi',
      label: '平方英里',
      symbol: 'mi²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq mile',
        AppLanguage.ja: '平方マイル',
        AppLanguage.es: 'milla cuadrada',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 2589988110336,
      baseDenominator: 1000000,
      note: '1 平方英里 = 640 英亩 = 2.58999 平方千米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq mile = 640 acres = 2.58999 km²',
      },
    ),
    MeasureUnit(
      id: 'acre',
      label: '英亩',
      symbol: 'ac',
      names: <AppLanguage, String>{
        AppLanguage.en: 'acre',
        AppLanguage.ja: 'エーカー',
        AppLanguage.es: 'acre',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 40468564224,
      baseDenominator: 10000000,
      note: '1 英亩 = 4840 平方码 ≈ 4046.86 平方米 ≈ 6.07 亩',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 acre = 4840 sq yd ≈ 4046.86 m² ≈ 6.07 mu',
      },
    ),
    MeasureUnit(
      id: 'sqyd',
      label: '平方码',
      symbol: 'yd²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq yard',
        AppLanguage.ja: '平方ヤード',
        AppLanguage.es: 'yarda cuadrada',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 83612736,
      baseDenominator: 100000000,
      note: '1 平方码 = 9 平方英尺',
      notes: <AppLanguage, String>{AppLanguage.en: '1 sq yd = 9 sq ft'},
    ),
    MeasureUnit(
      id: 'sqft',
      label: '平方英尺',
      symbol: 'ft²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq foot',
        AppLanguage.ja: '平方フィート',
        AppLanguage.es: 'pie cuadrado',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 9290304,
      baseDenominator: 100000000,
      note: '1 平方英尺 = 144 平方英寸 ≈ 0.0929 平方米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq ft = 144 sq in ≈ 0.0929 m²',
      },
    ),
    MeasureUnit(
      id: 'sqin',
      label: '平方英寸',
      symbol: 'in²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq inch',
        AppLanguage.ja: '平方インチ',
        AppLanguage.es: 'pulgada cuadrada',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 64516,
      baseDenominator: 100000000,
      note: '1 平方英寸 = 6.4516 平方厘米',
      notes: <AppLanguage, String>{AppLanguage.en: '1 sq in = 6.4516 cm²'},
    ),
    // 市制（1 尺 = 1/3 米 → 1 平方尺 = 1/9 米²，1 亩 = 60 平方丈 = 2000/3 米²）
    MeasureUnit(
      id: 'sqli',
      label: '平方里',
      symbol: '里²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq li',
        AppLanguage.ja: '平方里',
        AppLanguage.es: 'li cuadrado',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 250000,
      baseDenominator: 1,
      note: '1 平方里 = 500² 平方米 = 0.25 平方千米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq li = 500² m² = 0.25 km²',
      },
    ),
    MeasureUnit(
      id: 'qing',
      label: '顷',
      symbol: '顷',
      names: <AppLanguage, String>{
        AppLanguage.en: 'qing',
        AppLanguage.ja: '頃',
        AppLanguage.es: 'qing',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 200000,
      baseDenominator: 3,
      note: '1 顷 = 100 亩 ≈ 6.667 公顷',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 qing = 100 mu ≈ 6.667 ha',
      },
    ),
    MeasureUnit(
      id: 'mu',
      label: '亩',
      symbol: '亩',
      names: <AppLanguage, String>{
        AppLanguage.en: 'mu',
        AppLanguage.ja: '畝',
        AppLanguage.es: 'mu',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 2000,
      baseDenominator: 3,
      note: '1 亩 = 60 平方丈 ≈ 666.67 平方米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 mu = 60 sq zhang ≈ 666.67 m²',
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
      baseNumerator: 200,
      baseDenominator: 3,
      note: '1 分 = 1/10 亩 ≈ 66.67 平方米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 fen = 1/10 mu ≈ 66.67 m²',
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
      baseNumerator: 20,
      baseDenominator: 3,
      note: '1 厘 = 1/10 分 ≈ 6.67 平方米',
      notes: <AppLanguage, String>{AppLanguage.en: '1 li = 1/10 fen ≈ 6.67 m²'},
    ),
    MeasureUnit(
      id: 'sqzhang',
      label: '平方丈',
      symbol: '丈²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq zhang',
        AppLanguage.ja: '平方丈',
        AppLanguage.es: 'zhang cuadrado',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 100,
      baseDenominator: 9,
      note: '1 平方丈 = 100/9 平方米 ≈ 11.11 平方米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq zhang = 100/9 m² ≈ 11.11 m²',
      },
    ),
    MeasureUnit(
      id: 'sqchi',
      label: '平方尺',
      symbol: '尺²',
      names: <AppLanguage, String>{
        AppLanguage.en: 'sq chi',
        AppLanguage.ja: '平方尺',
        AppLanguage.es: 'chi cuadrado',
      },
      system: MeasureSystem.chinese,
      baseNumerator: 1,
      baseDenominator: 9,
      note: '1 平方尺 = 1/9 平方米 ≈ 0.111 平方米',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 sq chi = 1/9 m² ≈ 0.111 m²',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: 'A4 纸',
      value: 0.06237,
      unitId: 'sqm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Sheet of A4',
        AppLanguage.ja: 'A4 用紙',
        AppLanguage.es: 'Un folio A4',
      },
    ),
    MeasureSample(
      label: '1 平方英尺',
      value: 1,
      unitId: 'sqft',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 sq ft',
        AppLanguage.ja: '1 平方フィート',
        AppLanguage.es: '1 pie cuadrado',
      },
    ),
    MeasureSample(
      label: '篮球场',
      value: 420,
      unitId: 'sqm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Basketball court',
        AppLanguage.ja: 'バスケットコート',
        AppLanguage.es: 'Cancha de baloncesto',
      },
    ),
    MeasureSample(
      label: '1 亩',
      value: 1,
      unitId: 'mu',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 mu',
        AppLanguage.ja: '1 畝',
        AppLanguage.es: '1 mu',
      },
    ),
    MeasureSample(
      label: '足球场',
      value: 7140,
      unitId: 'sqm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Football pitch',
        AppLanguage.ja: 'サッカーコート',
        AppLanguage.es: 'Campo de fútbol',
      },
    ),
    MeasureSample(
      label: '1 公顷',
      value: 1,
      unitId: 'ha',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 hectare',
        AppLanguage.ja: '1 ヘクタール',
        AppLanguage.es: '1 hectárea',
      },
    ),
    MeasureSample(
      label: '1 英亩',
      value: 1,
      unitId: 'acre',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 acre',
        AppLanguage.ja: '1 エーカー',
        AppLanguage.es: '1 acre',
      },
    ),
    MeasureSample(
      label: '故宫',
      value: 720000,
      unitId: 'sqm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Forbidden City',
        AppLanguage.ja: '故宮',
        AppLanguage.es: 'Ciudad Prohibida',
      },
    ),
    MeasureSample(
      label: '天安门广场',
      value: 440000,
      unitId: 'sqm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Tiananmen Square',
        AppLanguage.ja: '天安門広場',
        AppLanguage.es: 'Plaza de Tiananmen',
      },
    ),
    MeasureSample(
      label: '中国国土',
      value: 9600000,
      unitId: 'sqkm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Area of China',
        AppLanguage.ja: '中国の国土',
        AppLanguage.es: 'Superficie de China',
      },
    ),
    MeasureSample(
      label: '地球表面',
      value: 510072000,
      unitId: 'sqkm',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Earth surface',
        AppLanguage.ja: '地球の表面',
        AppLanguage.es: 'Superficie terrestre',
      },
    ),
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
