/// 温度换算：摄氏度 / 华氏度 / 开尔文 / 兰氏度互转，纯逻辑，不依赖 Flutter。
///
/// 温度是仿射换算（有零点偏移），基准取摄氏度：
/// `摄氏 = 数值 × 系数 + 偏移`，例如 华氏 32 °F → 32 × 5/9 − 160/9 = 0 °C。
/// 所以不能像长度那样只存比例，[MeasureUnit.baseOffset] 就是为此存在的。
/// 温度只有公制（摄氏 / 开尔文）与英制（华氏 / 兰氏）两套体系。
library;

import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

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
      names: <AppLanguage, String>{
        AppLanguage.en: 'Celsius',
        AppLanguage.ja: '摂氏',
        AppLanguage.es: 'Celsius',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '水的冰点 0 °C、沸点 100 °C（标准大气压）',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            'Water freezes at 0 °C and boils at 100 °C (standard pressure)',
        AppLanguage.ja: '水は 0 °C で凍り、100 °C で沸騰します（標準気圧）',
        AppLanguage.es:
            'El agua se congela a 0 °C y hierve a 100 °C (presión estándar)',
      },
    ),
    MeasureUnit(
      id: 'k',
      label: '开尔文',
      symbol: 'K',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kelvin',
        AppLanguage.ja: 'ケルビン',
        AppLanguage.es: 'kelvin',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      baseOffset: -273.15,
      note: '绝对零度 = 0 K = −273.15 °C，温差与摄氏度一致',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            'Absolute zero = 0 K = −273.15 °C; same step size as Celsius',
        AppLanguage.ja: '絶対零度 = 0 K = −273.15 °C、目盛りの間隔は摂氏と同じです',
        AppLanguage.es:
            'Cero absoluto = 0 K = −273,15 °C; el intervalo es igual que en Celsius',
      },
    ),
    // 英制
    MeasureUnit(
      id: 'f',
      label: '华氏度',
      symbol: '°F',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Fahrenheit',
        AppLanguage.ja: '華氏',
        AppLanguage.es: 'Fahrenheit',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 5,
      baseDenominator: 9,
      baseOffset: -160 / 9,
      note: '水的冰点 32 °F、沸点 212 °F，摄氏 = (华氏 − 32) × 5/9',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            'Water freezes at 32 °F and boils at 212 °F; C = (F − 32) × 5/9',
        AppLanguage.ja: '水は 32 °F で凍り、212 °F で沸騰します；C = (F − 32) × 5/9',
        AppLanguage.es:
            'El agua se congela a 32 °F y hierve a 212 °F; C = (F − 32) × 5/9',
      },
    ),
    MeasureUnit(
      id: 'r',
      label: '兰氏度',
      symbol: '°R',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Rankine',
        AppLanguage.ja: 'ランキン',
        AppLanguage.es: 'Rankine',
      },
      system: MeasureSystem.imperial,
      baseNumerator: 5,
      baseDenominator: 9,
      baseOffset: -273.15,
      note: '绝对零度 = 0 °R，1 °R = 1 °F 的间隔',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'Absolute zero = 0 °R; 1 °R has the same step as 1 °F',
        AppLanguage.ja: '絶対零度 = 0 °R、1 °R の間隔は 1 °F と同じです',
        AppLanguage.es:
            'Cero absoluto = 0 °R; 1 °R tiene el mismo intervalo que 1 °F',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: '绝对零度',
      value: -273.15,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Absolute zero',
        AppLanguage.ja: '絶対零度',
        AppLanguage.es: 'Cero absoluto',
      },
    ),
    MeasureSample(
      label: '水的冰点',
      value: 0,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Water freezes',
        AppLanguage.ja: '水の氷点',
        AppLanguage.es: 'Congelación del agua',
      },
    ),
    MeasureSample(
      label: '冰箱冷藏',
      value: 4,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Fridge',
        AppLanguage.ja: '冷蔵庫',
        AppLanguage.es: 'Nevera',
      },
    ),
    MeasureSample(
      label: '人体体温',
      value: 36.5,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Body temperature',
        AppLanguage.ja: '体温',
        AppLanguage.es: 'Temperatura corporal',
      },
    ),
    MeasureSample(
      label: '发烧 38.5',
      value: 38.5,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Fever 38.5',
        AppLanguage.ja: '発熱 38.5',
        AppLanguage.es: 'Fiebre 38,5',
      },
    ),
    MeasureSample(
      label: '水的沸点',
      value: 100,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Water boils',
        AppLanguage.ja: '水の沸点',
        AppLanguage.es: 'Ebullición del agua',
      },
    ),
    MeasureSample(
      label: '桑拿房',
      value: 90,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Sauna',
        AppLanguage.ja: 'サウナ',
        AppLanguage.es: 'Sauna',
      },
    ),
    MeasureSample(
      label: '烤箱烘焙',
      value: 180,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Oven baking',
        AppLanguage.ja: 'オーブン',
        AppLanguage.es: 'Horno',
      },
    ),
    MeasureSample(
      label: '铁的熔点',
      value: 1538,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Iron melts',
        AppLanguage.ja: '鉄の融点',
        AppLanguage.es: 'Hierro fundido',
      },
    ),
    MeasureSample(
      label: '太阳表面',
      value: 5500,
      unitId: 'c',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Sun surface',
        AppLanguage.ja: '太陽の表面',
        AppLanguage.es: 'Superficie del Sol',
      },
    ),
    MeasureSample(
      label: '1 华氏冰点',
      value: 32,
      unitId: 'f',
      names: <AppLanguage, String>{
        AppLanguage.en: '32 °F freezing',
        AppLanguage.ja: '華氏の氷点',
        AppLanguage.es: '32 °F congelación',
      },
    ),
    MeasureSample(
      label: '100 °F',
      value: 100,
      unitId: 'f',
      names: <AppLanguage, String>{
        AppLanguage.en: '100 °F',
        AppLanguage.ja: '100 °F',
        AppLanguage.es: '100 °F',
      },
    ),
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
