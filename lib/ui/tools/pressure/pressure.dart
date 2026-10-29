/// 压力换算：帕 / 百帕 / 千帕 / 兆帕 / 巴 / 托 / 磅力每平方英寸互转。
///
/// 纯逻辑，不依赖 Flutter。全部单位都以帕斯卡为基准：
/// `1 百帕 = 100 帕`、`1 兆帕 = 10⁶ 帕`、`1 巴 = 10⁵ 帕`、
/// `1 托 = 101325/760 帕`（即 1 mmHg）、
/// `1 psi = 44482216152605/6451600000 帕 ≈ 6894.757 帕`（1 lbf = 4.4482216152605 N 精确值）。
///
/// 和温度一样，压力没有「公制 / 英制」两套并列单位，所以 `groupedBySystem: false`：
/// 页面只有一个单位下拉，结果一次全部列出。
library;

import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

/// 压力单位表：以帕斯卡为基准，共 7 个单位。
const MeasureCatalog kPressureCatalog = MeasureCatalog(
  id: 'pressure',
  name: '压力',
  baseName: '帕斯卡',
  defaultUnitId: 'pa',
  systems: <MeasureSystem>[MeasureSystem.metric],
  // 压力不区分公制 / 英制：帕、巴、psi 放在同一个下拉里
  groupedBySystem: false,
  units: <MeasureUnit>[
    MeasureUnit(
      id: 'pa',
      label: '帕',
      symbol: 'Pa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'pascal',
        AppLanguage.ja: 'パスカル',
        AppLanguage.es: 'pascal',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '1 帕 = 1 牛/平方米，国际单位制的压强单位',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 Pa = 1 N/m², the SI unit of pressure',
        AppLanguage.ja: '1 パスカル = 1 ニュートン毎平方メートル。SI の圧力単位です',
        AppLanguage.es: '1 Pa = 1 N/m², la unidad de presión del SI',
      },
    ),
    MeasureUnit(
      id: 'hpa',
      label: '百帕',
      symbol: 'hPa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'hectopascal',
        AppLanguage.ja: 'ヘクトパスカル',
        AppLanguage.es: 'hectopascal',
      },
      system: MeasureSystem.metric,
      baseNumerator: 100,
      baseDenominator: 1,
      note: '1 百帕 = 100 帕，天气预报里的标准大气压是 1013.25 hPa',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 hPa = 100 Pa; standard pressure is 1013.25 hPa',
        AppLanguage.ja: '1 ヘクトパスカル = 100 パスカル。標準大気圧は 1013.25 hPa',
        AppLanguage.es: '1 hPa = 100 Pa; la presión estándar es 1013,25 hPa',
      },
    ),
    MeasureUnit(
      id: 'kpa',
      label: '千帕',
      symbol: 'kPa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilopascal',
        AppLanguage.ja: 'キロパスカル',
        AppLanguage.es: 'kilopascal',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 千帕 = 1000 帕 ≈ 0.01 个大气压，胎压表与气压罐常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 kPa = 1000 Pa ≈ 0.01 atm; used on gauges and tanks',
        AppLanguage.ja: '1 キロパスカル = 1000 パスカル ≈ 0.01 気圧。圧力計やタンクに',
        AppLanguage.es: '1 kPa = 1000 Pa ≈ 0,01 atm; manómetros y tanques',
      },
    ),
    MeasureUnit(
      id: 'mpa',
      label: '兆帕',
      symbol: 'MPa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'megapascal',
        AppLanguage.ja: 'メガパスカル',
        AppLanguage.es: 'megapascal',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000000,
      baseDenominator: 1,
      note: '1 兆帕 = 1000 千帕 ≈ 10 个大气压，混凝土强度与液压系统常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 MPa = 1000 kPa ≈ 10 atm; concrete and hydraulics',
        AppLanguage.ja: '1 メガパスカル = 1000 キロパスカル ≈ 10 気圧。コンクリート強度や油圧に',
        AppLanguage.es: '1 MPa = 1000 kPa ≈ 10 atm; hormigón e hidráulica',
      },
    ),
    MeasureUnit(
      id: 'bar',
      label: '巴',
      symbol: 'bar',
      names: <AppLanguage, String>{
        AppLanguage.en: 'bar',
        AppLanguage.ja: 'バール',
        AppLanguage.es: 'bar',
      },
      system: MeasureSystem.metric,
      baseNumerator: 100000,
      baseDenominator: 1,
      note: '1 巴 = 100 千帕 ≈ 0.987 个大气压，轮胎与潜水气瓶常用',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 bar = 100 kPa ≈ 0.987 atm; tyres and diving tanks',
        AppLanguage.ja: '1 バール = 100 キロパスカル ≈ 0.987 気圧。タイヤやダイビングタンクに',
        AppLanguage.es:
            '1 bar = 100 kPa ≈ 0,987 atm; neumáticos y botellas de buceo',
      },
    ),
    MeasureUnit(
      id: 'torr',
      label: '托',
      symbol: 'torr',
      names: <AppLanguage, String>{
        AppLanguage.en: 'torr',
        AppLanguage.ja: 'トル',
        AppLanguage.es: 'torr',
      },
      system: MeasureSystem.metric,
      baseNumerator: 101325,
      baseDenominator: 760,
      note: '1 托 = 1 毫米汞柱 = 101325/760 帕 ≈ 133.32 帕，血压与真空常用',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 torr = 1 mmHg = 101325/760 Pa ≈ 133.32 Pa; blood pressure, vacuum',
        AppLanguage.ja: '1 トル = 1 水銀柱ミリメートル = 101325/760 パスカル ≈ 133.32 パスカル',
        AppLanguage.es: '1 torr = 1 mmHg = 101325/760 Pa ≈ 133,32 Pa',
      },
    ),
    MeasureUnit(
      id: 'psi',
      label: '磅力/平方英寸',
      symbol: 'psi',
      names: <AppLanguage, String>{
        AppLanguage.en: 'pound per square inch',
        AppLanguage.ja: '重量ポンド毎平方インチ',
        AppLanguage.es: 'libra por pulgada cuadrada',
      },
      system: MeasureSystem.metric,
      baseNumerator: 44482216152605,
      baseDenominator: 6451600000,
      note: '1 psi ≈ 6.895 千帕 ≈ 0.0689 巴，英美胎压与液压常用',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 psi ≈ 6.895 kPa ≈ 0.0689 bar; US tyres and hydraulics',
        AppLanguage.ja: '1 psi ≈ 6.895 キロパスカル ≈ 0.0689 バール。米英のタイヤや油圧に',
        AppLanguage.es: '1 psi ≈ 6,895 kPa ≈ 0,0689 bar; neumáticos en EE. UU.',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: '标准大气压',
      value: 101.325,
      unitId: 'kpa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Standard atmosphere',
        AppLanguage.ja: '標準大気圧',
        AppLanguage.es: 'Presión atmosférica',
      },
    ),
    MeasureSample(
      label: '高原 5000 米',
      value: 54,
      unitId: 'kpa',
      names: <AppLanguage, String>{
        AppLanguage.en: '5000 m altitude',
        AppLanguage.ja: '標高 5000 メートル',
        AppLanguage.es: 'A 5000 m de altura',
      },
    ),
    MeasureSample(
      label: '汽车胎压',
      value: 2.4,
      unitId: 'bar',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Car tyre',
        AppLanguage.ja: '車のタイヤ',
        AppLanguage.es: 'Neumático de coche',
      },
    ),
    MeasureSample(
      label: '潜水 10 米',
      value: 2,
      unitId: 'bar',
      names: <AppLanguage, String>{
        AppLanguage.en: '10 m under water',
        AppLanguage.ja: '水深 10 メートル',
        AppLanguage.es: '10 m bajo el agua',
      },
    ),
    MeasureSample(
      label: '收缩压 120 毫米汞柱',
      value: 120,
      unitId: 'torr',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Systolic 120 mmHg',
        AppLanguage.ja: '最高血圧 120 mmHg',
        AppLanguage.es: 'Sistólica 120 mmHg',
      },
    ),
    MeasureSample(
      label: '吸尘器吸力',
      value: 20,
      unitId: 'kpa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Vacuum suction',
        AppLanguage.ja: '掃除機の吸引力',
        AppLanguage.es: 'Succión de aspiradora',
      },
    ),
    MeasureSample(
      label: 'C30 混凝土强度',
      value: 30,
      unitId: 'mpa',
      names: <AppLanguage, String>{
        AppLanguage.en: 'C30 concrete',
        AppLanguage.ja: 'C30 コンクリート',
        AppLanguage.es: 'Hormigón C30',
      },
    ),
    MeasureSample(
      label: '美式胎压 32 psi',
      value: 32,
      unitId: 'psi',
      names: <AppLanguage, String>{
        AppLanguage.en: '32 psi tyre',
        AppLanguage.ja: 'タイヤ 32 psi',
        AppLanguage.es: 'Neumático 32 psi',
      },
    ),
  ],
);

/// 压力单位（统一模型的别名）。
typedef PressureUnit = MeasureUnit;

/// 压力参照物。
typedef PressureSample = MeasureSample;

/// 全部内置压力单位。
final List<PressureUnit> kPressureUnits = kPressureCatalog.units;

/// 压力参照物。
final List<PressureSample> kPressureSamples = kPressureCatalog.samples;

/// 按 id 查单位，找不到返回 null。
PressureUnit? pressureUnitById(String id) => kPressureCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertPressure(
  double value, {
  required PressureUnit from,
  required PressureUnit to,
}) => kPressureCatalog.convert(value, from: from, to: to);
