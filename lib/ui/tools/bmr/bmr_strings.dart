import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'bmr.dart';

/// 基础代谢页的界面文案。
///
/// 与卡片文案（`bmr_lang.dart` 的 `kBmrLang`）分开：那份是工具列表上的
/// 名称 / 卖点 / 说明，这份是页面内部的标题、字段、结果与说明。
class BmrStrings {
  const BmrStrings({
    required this.title,
    required this.sectionBody,
    required this.gender,
    required this.genderMale,
    required this.genderFemale,
    required this.age,
    required this.ageSuffix,
    required this.height,
    required this.heightHint,
    required this.weight,
    required this.sectionActivity,
    required this.activityOption,
    required this.emptyHint,
    required this.bmrLabel,
    required this.tdeeLabel,
    required this.energySuffix,
    required this.summary,
    required this.activityShare,
    required this.byActivity,
    required this.keepWeight,
    required this.formulaNote,
    required this.disclaimer,
    required this.activitySedentary,
    required this.activitySedentaryHint,
    required this.activityLight,
    required this.activityLightHint,
    required this.activityModerate,
    required this.activityModerateHint,
    required this.activityActive,
    required this.activityActiveHint,
    required this.activityVeryActive,
    required this.activityVeryActiveHint,
  });

  final String title;
  final String sectionBody;
  final String gender;
  final String genderMale;
  final String genderFemale;
  final String age;

  /// 年龄后缀（岁 / yrs / 歳 / años）。
  final String ageSuffix;
  final String height;

  /// 身高的输入提示（`170 或 1.7`）。
  final String heightHint;
  final String weight;
  final String sectionActivity;

  /// 活动水平下拉项：`{0}` 是名称，`{1}` 是频次说明。
  final String activityOption;
  final String emptyHint;

  /// 「基础代谢 BMR」。
  final String bmrLabel;

  /// 「每日总消耗 TDEE」。
  final String tdeeLabel;

  /// 消耗单位（千卡 / 天）。
  final String energySuffix;

  /// 「{0} · {1} 岁 · {2} cm · {3} kg」。
  final String summary;

  /// 「其中日常活动额外消耗 {0}」。
  final String activityShare;

  /// 「各活动水平的每日总消耗」。
  final String byActivity;

  /// 「按此水平可维持当前体重」。
  final String keepWeight;
  final String formulaNote;
  final String disclaimer;
  final String activitySedentary;
  final String activitySedentaryHint;
  final String activityLight;
  final String activityLightHint;
  final String activityModerate;
  final String activityModerateHint;
  final String activityActive;
  final String activityActiveHint;
  final String activityVeryActive;
  final String activityVeryActiveHint;

  /// 性别名称（数据层的 `BmrGender` 只有中文）。
  String genderLabel(BmrGender value) =>
      value == BmrGender.male ? genderMale : genderFemale;

  /// 活动水平名称（短）。
  String activityLabel(BmrActivity value) => switch (value) {
    BmrActivity.sedentary => activitySedentary,
    BmrActivity.light => activityLight,
    BmrActivity.moderate => activityModerate,
    BmrActivity.active => activityActive,
    BmrActivity.veryActive => activityVeryActive,
  };

  /// 活动水平的频次说明。
  String activityHint(BmrActivity value) => switch (value) {
    BmrActivity.sedentary => activitySedentaryHint,
    BmrActivity.light => activityLightHint,
    BmrActivity.moderate => activityModerateHint,
    BmrActivity.active => activityActiveHint,
    BmrActivity.veryActive => activityVeryActiveHint,
  };

  /// 下拉框里的完整选项：「中度活动（每周运动 3–5 次）」。
  String activityOptionOf(BmrActivity value) =>
      fill(activityOption, [activityLabel(value), activityHint(value)]);
}

/// 各语言的基础代谢页文案。
const Map<AppLanguage, BmrStrings> kBmrStrings = <AppLanguage, BmrStrings>{
  AppLanguage.zhHans: BmrStrings(
    title: '基础代谢 BMR',
    sectionBody: '身体数据',
    gender: '性别',
    genderMale: '男',
    genderFemale: '女',
    age: '年龄',
    ageSuffix: '岁',
    height: '身高',
    heightHint: '170 或 1.7',
    weight: '体重',
    sectionActivity: '活动水平',
    activityOption: '{0}（{1}）',
    emptyHint: '填写体重、身高与年龄后自动计算',
    bmrLabel: '基础代谢 BMR',
    tdeeLabel: '每日总消耗 TDEE',
    energySuffix: '千卡 / 天',
    summary: '{0} · {1} 岁 · {2} cm · {3} kg',
    activityShare: '其中日常活动额外消耗 {0}',
    byActivity: '各活动水平的每日总消耗',
    keepWeight: '按这个活动量大致可维持当前体重',
    formulaNote:
        'Mifflin-St Jeor 公式：10×体重(kg) + 6.25×身高(cm) − 5×年龄 + 5（男）'
        '/ − 161（女）；TDEE = BMR × 活动系数。',
    disclaimer: '结果为估算值，个体差异较大；孕期、增肌或患病期间建议以专业评估为准。',
    activitySedentary: '久坐',
    activitySedentaryHint: '几乎不动',
    activityLight: '轻度活动',
    activityLightHint: '每周运动 1–3 次',
    activityModerate: '中度活动',
    activityModerateHint: '每周运动 3–5 次',
    activityActive: '高强度',
    activityActiveHint: '每周运动 6–7 次',
    activityVeryActive: '极高强度',
    activityVeryActiveHint: '体力工作 + 训练',
  ),
  AppLanguage.zhHant: BmrStrings(
    title: '基礎代謝 BMR',
    sectionBody: '身體數據',
    gender: '性別',
    genderMale: '男',
    genderFemale: '女',
    age: '年齡',
    ageSuffix: '歲',
    height: '身高',
    heightHint: '170 或 1.7',
    weight: '體重',
    sectionActivity: '活動水平',
    activityOption: '{0}（{1}）',
    emptyHint: '填寫體重、身高與年齡後自動計算',
    bmrLabel: '基礎代謝 BMR',
    tdeeLabel: '每日總消耗 TDEE',
    energySuffix: '千卡 / 天',
    summary: '{0} · {1} 歲 · {2} cm · {3} kg',
    activityShare: '其中日常活動額外消耗 {0}',
    byActivity: '各活動水平的每日總消耗',
    keepWeight: '按這個活動量大致可維持目前體重',
    formulaNote:
        'Mifflin-St Jeor 公式：10×體重(kg) + 6.25×身高(cm) − 5×年齡 + 5（男）'
        '/ − 161（女）；TDEE = BMR × 活動係數。',
    disclaimer: '結果為估算值，個體差異較大；孕期、增肌或患病期間建議以專業評估為準。',
    activitySedentary: '久坐',
    activitySedentaryHint: '幾乎不動',
    activityLight: '輕度活動',
    activityLightHint: '每週運動 1–3 次',
    activityModerate: '中度活動',
    activityModerateHint: '每週運動 3–5 次',
    activityActive: '高強度',
    activityActiveHint: '每週運動 6–7 次',
    activityVeryActive: '極高強度',
    activityVeryActiveHint: '體力工作 + 訓練',
  ),
  AppLanguage.en: BmrStrings(
    title: 'BMR & TDEE',
    sectionBody: 'Body data',
    gender: 'Sex',
    genderMale: 'Male',
    genderFemale: 'Female',
    age: 'Age',
    ageSuffix: 'yrs',
    height: 'Height',
    heightHint: 'e.g. 170 or 1.7',
    weight: 'Weight',
    sectionActivity: 'Activity level',
    activityOption: '{0} ({1})',
    emptyHint: 'Fill in weight, height and age to calculate',
    bmrLabel: 'Basal metabolic rate',
    tdeeLabel: 'Total daily energy',
    energySuffix: 'kcal / day',
    summary: '{0} · {1} yrs · {2} cm · {3} kg',
    activityShare: 'Everyday activity burns an extra {0}',
    byActivity: 'Daily burn by activity level',
    keepWeight: 'At this activity level your weight stays roughly the same',
    formulaNote:
        'Mifflin-St Jeor: 10 × weight(kg) + 6.25 × height(cm) − 5 × age '
        '+ 5 (male) / − 161 (female); TDEE = BMR × activity factor.',
    disclaimer:
        'An estimate — needs vary a lot between people. If you are pregnant, '
        'training hard or ill, treat a professional assessment as the guide.',
    activitySedentary: 'Sedentary',
    activitySedentaryHint: 'Hardly any movement',
    activityLight: 'Light',
    activityLightHint: 'Exercise 1–3 days a week',
    activityModerate: 'Moderate',
    activityModerateHint: 'Exercise 3–5 days a week',
    activityActive: 'High',
    activityActiveHint: 'Exercise 6–7 days a week',
    activityVeryActive: 'Very high',
    activityVeryActiveHint: 'Physical job plus training',
  ),
  AppLanguage.ja: BmrStrings(
    title: '基礎代謝 BMR',
    sectionBody: '身体データ',
    gender: '性別',
    genderMale: '男性',
    genderFemale: '女性',
    age: '年齢',
    ageSuffix: '歳',
    height: '身長',
    heightHint: '例：170 または 1.7',
    weight: '体重',
    sectionActivity: '活動レベル',
    activityOption: '{0}（{1}）',
    emptyHint: '体重・身長・年齢を入力すると自動計算します',
    bmrLabel: '基礎代謝（BMR）',
    tdeeLabel: '1 日の総消費（TDEE）',
    energySuffix: 'kcal / 日',
    summary: '{0} · {1} 歳 · {2} cm · {3} kg',
    activityShare: 'うち日常活動での消費は {0}',
    byActivity: '活動レベル別の 1 日消費量',
    keepWeight: 'この活動量なら現在の体重がほぼ維持できます',
    formulaNote:
        'Mifflin-St Jeor 式：10×体重(kg) + 6.25×身長(cm) − 5×年齢 + 5（男性）'
        '／− 161（女性）。TDEE = BMR × 活動係数。',
    disclaimer: '推定値であり個人差が大きいため、妊娠中・増量期・治療中の方は専門家の評価を参考にしてください。',
    activitySedentary: '座位中心',
    activitySedentaryHint: 'ほとんど動かない',
    activityLight: '軽い活動',
    activityLightHint: '週 1〜3 回の運動',
    activityModerate: '中程度',
    activityModerateHint: '週 3〜5 回の運動',
    activityActive: '高強度',
    activityActiveHint: '週 6〜7 回の運動',
    activityVeryActive: '非常に高い',
    activityVeryActiveHint: '肉体労働＋トレーニング',
  ),
  AppLanguage.es: BmrStrings(
    title: 'Metabolismo basal',
    sectionBody: 'Datos corporales',
    gender: 'Sexo',
    genderMale: 'Hombre',
    genderFemale: 'Mujer',
    age: 'Edad',
    ageSuffix: 'años',
    height: 'Altura',
    heightHint: 'p. ej. 170 o 1.7',
    weight: 'Peso',
    sectionActivity: 'Nivel de actividad',
    activityOption: '{0} ({1})',
    emptyHint: 'Introduce peso, altura y edad para calcularlo',
    bmrLabel: 'Metabolismo basal (BMR)',
    tdeeLabel: 'Gasto diario total (TDEE)',
    energySuffix: 'kcal / día',
    summary: '{0} · {1} años · {2} cm · {3} kg',
    activityShare: 'La actividad diaria suma {0}',
    byActivity: 'Gasto diario según el nivel de actividad',
    keepWeight: 'Con esta actividad el peso se mantiene más o menos igual',
    formulaNote:
        'Mifflin-St Jeor: 10 × peso(kg) + 6,25 × altura(cm) − 5 × edad '
        '+ 5 (hombre) / − 161 (mujer); TDEE = BMR × factor de actividad.',
    disclaimer:
        'Es una estimación y las necesidades varían mucho. Si estás '
        'embarazada, entrenas fuerte o estás enferma, guíate por una '
        'valoración profesional.',
    activitySedentary: 'Sedentario',
    activitySedentaryHint: 'Casi sin movimiento',
    activityLight: 'Ligera',
    activityLightHint: 'Ejercicio 1–3 días por semana',
    activityModerate: 'Moderada',
    activityModerateHint: 'Ejercicio 3–5 días por semana',
    activityActive: 'Alta',
    activityActiveHint: 'Ejercicio 6–7 días por semana',
    activityVeryActive: 'Muy alta',
    activityVeryActiveHint: 'Trabajo físico y entrenamiento',
  ),
};

/// 当前语言的基础代谢页文案。
BmrStrings get bmrStrings => toolText(kBmrStrings);
