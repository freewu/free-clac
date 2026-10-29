/// 热量换算：瓦时系（Wh / kWh …）与焦耳系（J / kJ）、卡路里系（cal / kcal）互转。
///
/// 纯逻辑，不依赖 Flutter。全部单位都以焦耳为基准（系数都是精确分数）：
/// `1 瓦时 = 3600 焦`、`1 卡 = 4.184 焦 = 523/125 焦`、`1 千卡 = 4184 焦`。
///
/// 和温度一样，能量不是「公制 / 英制」两套单位，所以 `groupedBySystem: false`：
/// 页面只有一个单位下拉，结果一次全部列出。
library;

import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

/// 热量单位表：以焦耳为基准，共 8 个单位。
const MeasureCatalog kEnergyCatalog = MeasureCatalog(
  id: 'energy',
  name: '热量',
  baseName: '焦耳',
  defaultUnitId: 'wh',
  systems: <MeasureSystem>[MeasureSystem.metric],
  // 热量不区分公制 / 英制：瓦时、焦耳、卡路里放在同一个下拉里
  groupedBySystem: false,
  units: <MeasureUnit>[
    MeasureUnit(
      id: 'milliwh',
      label: '毫瓦时',
      symbol: 'mWh',
      names: <AppLanguage, String>{
        AppLanguage.en: 'milliwatt-hour',
        AppLanguage.ja: 'ミリワット時',
        AppLanguage.es: 'milivatio-hora',
      },
      system: MeasureSystem.metric,
      baseNumerator: 18,
      baseDenominator: 5,
      note: '1 毫瓦时 = 3.6 焦耳，常用于电池容量的小数值',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 mWh = 3.6 J; handy for small battery figures',
        AppLanguage.ja: '1 ミリワット時 = 3.6 ジュール。小さな電池容量に',
        AppLanguage.es: '1 mWh = 3,6 J; útil para baterías pequeñas',
      },
    ),
    MeasureUnit(
      id: 'wh',
      label: '瓦时',
      symbol: 'Wh',
      names: <AppLanguage, String>{
        AppLanguage.en: 'watt-hour',
        AppLanguage.ja: 'ワット時',
        AppLanguage.es: 'vatio-hora',
      },
      system: MeasureSystem.metric,
      baseNumerator: 3600,
      baseDenominator: 1,
      note: '1 瓦时 = 3600 焦耳，电池容量常用它标注',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 Wh = 3600 J; the usual unit on battery labels',
        AppLanguage.ja: '1 ワット時 = 3600 ジュール。電池の容量表記に',
        AppLanguage.es: '1 Wh = 3600 J; la unidad de las baterías',
      },
    ),
    MeasureUnit(
      id: 'kwh',
      label: '千瓦时',
      symbol: 'kWh',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilowatt-hour',
        AppLanguage.ja: 'キロワット時',
        AppLanguage.es: 'kilovatio-hora',
      },
      system: MeasureSystem.metric,
      baseNumerator: 3600000,
      baseDenominator: 1,
      note: '1 千瓦时 = 360 万焦耳，也就是电表上的「1 度电」',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 kWh = 3.6 MJ, i.e. one unit on an electricity meter',
        AppLanguage.ja: '1 キロワット時 = 360 万ジュール。電気メーターの 1 単位',
        AppLanguage.es:
            '1 kWh = 3,6 MJ, es decir, un kilovatio hora del contador',
      },
    ),
    MeasureUnit(
      id: 'mwh',
      label: '兆瓦时',
      symbol: 'MWh',
      names: <AppLanguage, String>{
        AppLanguage.en: 'megawatt-hour',
        AppLanguage.ja: 'メガワット時',
        AppLanguage.es: 'megavatio-hora',
      },
      system: MeasureSystem.metric,
      baseNumerator: 3600000000,
      baseDenominator: 1,
      note: '1 兆瓦时 = 1000 千瓦时，电厂与年度用电量常用它',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 MWh = 1000 kWh; used for plants and yearly demand',
        AppLanguage.ja: '1 メガワット時 = 1000 キロワット時。発電量や年間使用量に',
        AppLanguage.es: '1 MWh = 1000 kWh; para plantas y consumo anual',
      },
    ),
    MeasureUnit(
      id: 'j',
      label: '焦耳',
      symbol: 'J',
      names: <AppLanguage, String>{
        AppLanguage.en: 'joule',
        AppLanguage.ja: 'ジュール',
        AppLanguage.es: 'julio',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1,
      baseDenominator: 1,
      note: '国际单位制的能量单位，1 焦耳 = 1 牛·米',
      notes: <AppLanguage, String>{
        AppLanguage.en: 'The SI unit of energy; 1 J = 1 N·m',
        AppLanguage.ja: '国際単位系のエネルギー単位。1 ジュール = 1 ニュートン・メートル',
        AppLanguage.es: 'La unidad de energía del SI; 1 J = 1 N·m',
      },
    ),
    MeasureUnit(
      id: 'kj',
      label: '千焦',
      symbol: 'kJ',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilojoule',
        AppLanguage.ja: 'キロジュール',
        AppLanguage.es: 'kilojulio',
      },
      system: MeasureSystem.metric,
      baseNumerator: 1000,
      baseDenominator: 1,
      note: '1 千焦 = 1000 焦耳，营养成分表上的能量常用它',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 kJ = 1000 J; the energy figure on food labels',
        AppLanguage.ja: '1 キロジュール = 1000 ジュール。栄養成分表示のエネルギーに',
        AppLanguage.es: '1 kJ = 1000 J; la energía de las etiquetas de comida',
      },
    ),
    MeasureUnit(
      id: 'cal',
      label: '卡路里',
      symbol: 'cal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'calorie',
        AppLanguage.ja: 'カロリー',
        AppLanguage.es: 'caloría',
      },
      system: MeasureSystem.metric,
      baseNumerator: 523,
      baseDenominator: 125,
      note: '1 卡 = 4.184 焦耳，指把 1 克水升温 1 °C 所需的热量',
      notes: <AppLanguage, String>{
        AppLanguage.en:
            '1 cal = 4.184 J; heat that raises 1 g of water by 1 °C',
        AppLanguage.ja: '1 カロリー = 4.184 ジュール。水 1 グラムを 1 °C 上げる熱量',
        AppLanguage.es: '1 cal = 4,184 J; calor para subir 1 g de agua 1 °C',
      },
    ),
    MeasureUnit(
      id: 'kcal',
      label: '千卡',
      symbol: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'kilocalorie',
        AppLanguage.ja: 'キロカロリー',
        AppLanguage.es: 'kilocaloría',
      },
      system: MeasureSystem.metric,
      baseNumerator: 4184,
      baseDenominator: 1,
      note: '1 千卡 = 1000 卡 = 4184 焦耳，就是食品标签上的「大卡」',
      notes: <AppLanguage, String>{
        AppLanguage.en: '1 kcal = 1000 cal = 4184 J; the "Calorie" on labels',
        AppLanguage.ja: '1 キロカロリー = 1000 カロリー = 4184 ジュール。食品表示の「kcal」',
        AppLanguage.es:
            '1 kcal = 1000 cal = 4184 J; la «caloría» de las etiquetas',
      },
    ),
  ],
  samples: <MeasureSample>[
    MeasureSample(
      label: '一节 5 号电池',
      value: 10,
      unitId: 'kj',
      names: <AppLanguage, String>{
        AppLanguage.en: 'AA battery',
        AppLanguage.ja: '単三電池 1 本',
        AppLanguage.es: 'Pila AA',
      },
    ),
    MeasureSample(
      label: '手机电池',
      value: 15,
      unitId: 'wh',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Phone battery',
        AppLanguage.ja: 'スマホの電池',
        AppLanguage.es: 'Batería del móvil',
      },
    ),
    MeasureSample(
      label: '1 度电',
      value: 1,
      unitId: 'kwh',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 kWh of power',
        AppLanguage.ja: '電気 1 kWh',
        AppLanguage.es: '1 kWh de luz',
      },
    ),
    MeasureSample(
      label: '1 克糖',
      value: 4,
      unitId: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: '1 g of sugar',
        AppLanguage.ja: '砂糖 1 グラム',
        AppLanguage.es: '1 g de azúcar',
      },
    ),
    MeasureSample(
      label: '一根香蕉',
      value: 89,
      unitId: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'One banana',
        AppLanguage.ja: 'バナナ 1 本',
        AppLanguage.es: 'Un plátano',
      },
    ),
    MeasureSample(
      label: '一杯牛奶',
      value: 155,
      unitId: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Glass of milk',
        AppLanguage.ja: '牛乳 1 杯',
        AppLanguage.es: 'Vaso de leche',
      },
    ),
    MeasureSample(
      label: '一碗米饭',
      value: 232,
      unitId: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Bowl of rice',
        AppLanguage.ja: 'ご飯 1 杯',
        AppLanguage.es: 'Tazón de arroz',
      },
    ),
    MeasureSample(
      label: '跑 1 公里',
      value: 60,
      unitId: 'kcal',
      names: <AppLanguage, String>{
        AppLanguage.en: 'Running 1 km',
        AppLanguage.ja: '1 キロ走る',
        AppLanguage.es: 'Correr 1 km',
      },
    ),
  ],
);

/// 热量单位（统一模型的别名）。
typedef EnergyUnit = MeasureUnit;

/// 热量参照物。
typedef EnergySample = MeasureSample;

/// 全部内置热量单位。
final List<EnergyUnit> kEnergyUnits = kEnergyCatalog.units;

/// 热量参照物。
final List<EnergySample> kEnergySamples = kEnergyCatalog.samples;

/// 按 id 查单位，找不到返回 null。
EnergyUnit? energyUnitById(String id) => kEnergyCatalog.unitById(id);

/// 把 [value] 个 [from] 换算成 [to] 的数值。
double? convertEnergy(
  double value, {
  required EnergyUnit from,
  required EnergyUnit to,
}) => kEnergyCatalog.convert(value, from: from, to: to);
