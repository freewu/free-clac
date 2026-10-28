import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'bmi.dart';

/// BMI 页的界面文案。
///
/// 与卡片文案（`bmi_lang.dart` 的 `kBmiLang`）分开：那份是工具列表上的
/// 名称 / 卖点 / 说明，这份是页面内部的标题、字段、结果与说明。
class BmiStrings {
  const BmiStrings({
    required this.title,
    required this.sectionInput,
    required this.height,
    required this.heightHint,
    required this.weight,
    required this.heightUnit,
    required this.emptyHint,
    required this.summary,
    required this.healthyRange,
    required this.needGain,
    required this.needLose,
    required this.disclaimer,
    required this.categoryThin,
    required this.categoryNormal,
    required this.categoryOverweight,
    required this.categoryObese,
    required this.adviceThin,
    required this.adviceNormal,
    required this.adviceOverweight,
    required this.adviceObese,
    required this.unitMetric,
    required this.unitImperial,
    required this.feet,
    required this.inches,
    required this.unitOption,
  });

  final String title;
  final String sectionInput;
  final String height;

  /// 公制身高的输入提示（`170 或 1.7`）。
  final String heightHint;
  final String weight;

  /// 英制身高单位选择器的提示。
  final String heightUnit;
  final String emptyHint;

  /// 「身高 {0} · 体重 {1}」。
  final String summary;
  final String healthyRange;
  final String needGain;
  final String needLose;
  final String disclaimer;
  final String categoryThin;
  final String categoryNormal;
  final String categoryOverweight;
  final String categoryObese;
  final String adviceThin;
  final String adviceNormal;
  final String adviceOverweight;
  final String adviceObese;
  final String unitMetric;
  final String unitImperial;
  final String feet;
  final String inches;

  /// 身高单位下拉项：`{0}` 是符号（ft / in），`{1}` 是名称。
  final String unitOption;

  /// 分级名称（数据层的 `BmiCategory` 只有中文）。
  String categoryLabel(BmiCategory category) => switch (category) {
    BmiCategory.underweight => categoryThin,
    BmiCategory.normal => categoryNormal,
    BmiCategory.overweight => categoryOverweight,
    BmiCategory.obese => categoryObese,
  };

  /// 分级建议。
  String adviceOf(BmiCategory category) => switch (category) {
    BmiCategory.underweight => adviceThin,
    BmiCategory.normal => adviceNormal,
    BmiCategory.overweight => adviceOverweight,
    BmiCategory.obese => adviceObese,
  };

  /// 计量体系名称。
  String unitLabel(BmiUnitSystem unit) =>
      unit == BmiUnitSystem.metric ? unitMetric : unitImperial;

  /// 英制身高单位名称。
  String heightUnitLabel(BmiImperialHeightUnit unit) =>
      unit == BmiImperialHeightUnit.feet ? feet : inches;
}

/// 各语言的 BMI 页文案。
const Map<AppLanguage, BmiStrings> kBmiStrings = <AppLanguage, BmiStrings>{
  AppLanguage.zhHans: BmiStrings(
    title: 'BMI 计算',
    sectionInput: '输入',
    height: '身高',
    heightHint: '170 或 1.7',
    weight: '体重',
    heightUnit: '身高单位',
    emptyHint: '输入身高与体重后自动计算',
    summary: '身高 {0} · 体重 {1}',
    healthyRange: '正常体重范围',
    needGain: '距理想体重还需增重',
    needLose: '距理想体重还需减重',
    disclaimer:
        '分级依据：中国成人 BMI 标准（WS/T 428—2013）。'
        '结果仅供健康参考，不构成医疗建议。',
    categoryThin: '偏瘦',
    categoryNormal: '正常',
    categoryOverweight: '超重',
    categoryObese: '肥胖',
    adviceThin: '体重偏低，注意均衡饮食并适当增加力量训练。',
    adviceNormal: '体重处于正常范围，保持现有作息与运动习惯即可。',
    adviceOverweight: '体重偏高，建议控制精制碳水摄入并增加有氧运动。',
    adviceObese: '已进入肥胖区间，建议咨询医生或营养师制定减重方案。',
    unitMetric: '公制',
    unitImperial: '英制',
    feet: '英尺',
    inches: '英寸',
    unitOption: '{0}（{1}）',
  ),
  AppLanguage.zhHant: BmiStrings(
    title: 'BMI 計算',
    sectionInput: '輸入',
    height: '身高',
    heightHint: '170 或 1.7',
    weight: '體重',
    heightUnit: '身高單位',
    emptyHint: '輸入身高與體重後自動計算',
    summary: '身高 {0} · 體重 {1}',
    healthyRange: '正常體重範圍',
    needGain: '距理想體重還需增重',
    needLose: '距理想體重還需減重',
    disclaimer:
        '分級依據：中國成人 BMI 標準（WS/T 428—2013）。'
        '結果僅供健康參考，不構成醫療建議。',
    categoryThin: '偏瘦',
    categoryNormal: '正常',
    categoryOverweight: '超重',
    categoryObese: '肥胖',
    adviceThin: '體重偏低，注意均衡飲食並適當增加力量訓練。',
    adviceNormal: '體重處於正常範圍，保持現有作息與運動習慣即可。',
    adviceOverweight: '體重偏高，建議控制精製碳水攝入並增加有氧運動。',
    adviceObese: '已進入肥胖區間，建議諮詢醫生或營養師制定減重方案。',
    unitMetric: '公制',
    unitImperial: '英制',
    feet: '英尺',
    inches: '英寸',
    unitOption: '{0}（{1}）',
  ),
  AppLanguage.en: BmiStrings(
    title: 'BMI',
    sectionInput: 'Input',
    height: 'Height',
    heightHint: 'e.g. 170 or 1.7',
    weight: 'Weight',
    heightUnit: 'Height unit',
    emptyHint: 'Enter height and weight to calculate',
    summary: 'Height {0} · Weight {1}',
    healthyRange: 'Healthy weight range',
    needGain: 'Gain to reach ideal weight',
    needLose: 'Lose to reach ideal weight',
    disclaimer:
        'Based on the Chinese adult BMI standard (WS/T 428—2013). '
        'For reference only, not medical advice.',
    categoryThin: 'Underweight',
    categoryNormal: 'Normal',
    categoryOverweight: 'Overweight',
    categoryObese: 'Obese',
    adviceThin:
        'Below the healthy range — eat balanced meals and add strength '
        'training.',
    adviceNormal: 'In the healthy range — keep your current routine.',
    adviceOverweight:
        'Above the healthy range — cut refined carbs and add cardio.',
    adviceObese:
        'In the obese range — consider seeing a doctor or dietitian about '
        'losing weight.',
    unitMetric: 'Metric',
    unitImperial: 'Imperial',
    feet: 'feet',
    inches: 'inches',
    unitOption: '{0} ({1})',
  ),
  AppLanguage.ja: BmiStrings(
    title: 'BMI 計算',
    sectionInput: '入力',
    height: '身長',
    heightHint: '例：170 または 1.7',
    weight: '体重',
    heightUnit: '身長の単位',
    emptyHint: '身長と体重を入力すると自動計算します',
    summary: '身長 {0} · 体重 {1}',
    healthyRange: '標準体重の範囲',
    needGain: '理想体重まで増量',
    needLose: '理想体重まで減量',
    disclaimer:
        '中国成人 BMI 基準（WS/T 428—2013）に基づきます。'
        '健康の参考情報であり、医療上の助言ではありません。',
    categoryThin: 'やせ',
    categoryNormal: '標準',
    categoryOverweight: '過体重',
    categoryObese: '肥満',
    adviceThin: 'やせ気味です。バランスの良い食事と筋力トレーニングを心がけましょう。',
    adviceNormal: '標準的な範囲です。今の生活リズムと運動習慣を保ちましょう。',
    adviceOverweight: 'やや重めです。精製炭水化物を控え、有酸素運動を増やしましょう。',
    adviceObese: '肥満の範囲です。医師や栄養士に減量の相談をしましょう。',
    unitMetric: 'メートル法',
    unitImperial: 'ヤード・ポンド法',
    feet: 'フィート',
    inches: 'インチ',
    unitOption: '{0}（{1}）',
  ),
  AppLanguage.es: BmiStrings(
    title: 'IMC',
    sectionInput: 'Datos',
    height: 'Altura',
    heightHint: 'p. ej. 170 o 1.7',
    weight: 'Peso',
    heightUnit: 'Unidad de altura',
    emptyHint: 'Introduce altura y peso para calcularlo',
    summary: 'Altura {0} · Peso {1}',
    healthyRange: 'Rango de peso saludable',
    needGain: 'Sube para llegar al peso ideal',
    needLose: 'Baja para llegar al peso ideal',
    disclaimer:
        'Según el estándar chino de IMC para adultos (WS/T 428—2013). '
        'Solo orientativo, no es consejo médico.',
    categoryThin: 'Bajo peso',
    categoryNormal: 'Normal',
    categoryOverweight: 'Sobrepeso',
    categoryObese: 'Obesidad',
    adviceThin:
        'Estás por debajo del rango saludable: come de forma '
        'equilibrada y añade fuerza.',
    adviceNormal: 'Tu peso está en el rango saludable: mantén tu rutina.',
    adviceOverweight:
        'Tu peso está por encima del rango saludable: reduce '
        'carbohidratos refinados y añade cardio.',
    adviceObese:
        'Estás en el rango de obesidad: consulta a un médico o '
        'nutricionista.',
    unitMetric: 'Métrico',
    unitImperial: 'Imperial',
    feet: 'pies',
    inches: 'pulgadas',
    unitOption: '{0} ({1})',
  ),
};

/// 当前语言的 BMI 页文案。
BmiStrings get bmiStrings => toolText(kBmiStrings);
