import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'hourly.dart';

/// 时薪计算页的界面文案。
///
/// 与卡片文案（`hourly_lang.dart` 的 `kHourlyLang`）分开：那份是工具列表上的
/// 名称 / 卖点 / 说明，这份是页面内部的标题、字段、结果与说明。
class HourlyStrings {
  const HourlyStrings({
    required this.title,
    required this.sectionInput,
    required this.salary,
    required this.hoursPerDay,
    required this.hoursPerDaySuffix,
    required this.schedule,
    required this.scheduleOption,
    required this.scheduleStandard,
    required this.scheduleAlternate,
    required this.scheduleOvertime,
    required this.scheduleNineFiveFive,
    required this.scheduleHint,
    required this.emptyHint,
    required this.hourlyLabel,
    required this.hourlySuffix,
    required this.breakdown,
    required this.monthlyHours,
    required this.dailyWage,
    required this.hoursValue,
    required this.save,
    required this.savedHint,
    required this.alreadySaved,
    required this.sectionHistory,
    required this.historyEmpty,
    required this.historyCount,
    required this.clearAll,
    required this.clearConfirmTitle,
    required this.clearConfirmBody,
    required this.cancel,
    required this.clearConfirmAction,
    required this.deleteTooltip,
    required this.compareHigher,
    required this.compareLower,
    required this.compareSame,
    required this.recordMeta,
    required this.restoredHint,
    required this.formulaNote,
  });

  final String title;

  /// 「月薪与工时」。
  final String sectionInput;
  final String salary;

  /// 「每日工作时长」。
  final String hoursPerDay;

  /// 工作时长的单位（小时）。
  final String hoursPerDaySuffix;

  /// 「工作日制度」。
  final String schedule;

  /// 制度选项：`{0}` 名称，`{1}` 每月工作天数。
  final String scheduleOption;

  final String scheduleStandard;
  final String scheduleAlternate;
  final String scheduleOvertime;

  /// 995：天数同双休，每天 10 小时。
  final String scheduleNineFiveFive;

  /// 制度下方的说明：选制度会顺带填上该制度的每日工时。
  final String scheduleHint;

  /// 输入不完整时的提示。
  final String emptyHint;

  /// 「时薪」。
  final String hourlyLabel;

  /// 时薪的单位（/ 小时）。
  final String hourlySuffix;

  /// 「{0} ÷ ({1} 天 × {2} 小时) = {3} 小时 / 月」。
  final String breakdown;

  /// 「月工时」。
  final String monthlyHours;

  /// 「日薪」。
  final String dailyWage;

  /// 「{0} 小时」。
  final String hoursValue;

  /// 「记下这个时薪」。
  final String save;

  /// 记下成功后的提示。
  final String savedHint;

  /// 和上一条完全相同时的提示。
  final String alreadySaved;

  /// 「历史记录」。
  final String sectionHistory;

  /// 还没有记录时的说明。
  final String historyEmpty;

  /// 「{0} 条」。
  final String historyCount;

  /// 「清空」。
  final String clearAll;

  final String clearConfirmTitle;
  final String clearConfirmBody;
  final String cancel;

  /// 确认清空的按钮。
  final String clearConfirmAction;

  /// 删除单条记录的提示。
  final String deleteTooltip;

  /// 「比当前高 {0}」。
  final String compareHigher;

  /// 「比当前低 {0}」。
  final String compareLower;

  /// 「与当前相同」。
  final String compareSame;

  /// 记录的一行说明：`{0}` 月薪，`{1}` 制度，`{2}` 每日时长。
  final String recordMeta;

  /// 把记录填回输入框后的提示。
  final String restoredHint;

  /// 公式说明。
  final String formulaNote;

  /// 制度名称。
  String scheduleLabel(WorkSchedule schedule) => switch (schedule) {
    WorkSchedule.standard => scheduleStandard,
    WorkSchedule.alternate => scheduleAlternate,
    WorkSchedule.overtime => scheduleOvertime,
    WorkSchedule.nineFiveFive => scheduleNineFiveFive,
  };
}

HourlyStrings get hourlyStrings =>
    kHourlyStrings[appLanguage] ?? hourlyStringsZh;

const Map<AppLanguage, HourlyStrings> kHourlyStrings =
    <AppLanguage, HourlyStrings>{
      AppLanguage.zhHans: hourlyStringsZh,
      AppLanguage.zhHant: hourlyStringsZhHant,
      AppLanguage.en: hourlyStringsEn,
      AppLanguage.ja: hourlyStringsJa,
      AppLanguage.es: hourlyStringsEs,
    };

const HourlyStrings hourlyStringsZh = HourlyStrings(
  title: '时薪计算器',
  sectionInput: '月薪与工时',
  salary: '月薪',
  hoursPerDay: '每日工作时长',
  hoursPerDaySuffix: '小时',
  schedule: '工作日制度',
  scheduleOption: '{0} · {1} 天/月',
  scheduleStandard: '双休',
  scheduleAlternate: '大小周',
  scheduleOvertime: '996',
  scheduleNineFiveFive: '995',
  scheduleHint: '选制度会自动填上每日工时：双休 / 大小周 8 小时，996 / 995 10 小时。',
  emptyHint: '填好月薪和每天的工作时长，就知道自己一小时值多少钱。',
  hourlyLabel: '时薪',
  hourlySuffix: '/ 小时',
  breakdown: '{0} ÷ ({1} 天 × {2} 小时) = {3} 小时/月',
  monthlyHours: '月工时',
  dailyWage: '日薪',
  hoursValue: '{0} 小时',
  save: '记下这个时薪',
  savedHint: '已记入历史，可以和后面的结果对比。',
  alreadySaved: '最新一条就是这组数据，没有重复记录。',
  sectionHistory: '历史记录',
  historyEmpty: '还没有记录。算出结果后点上面的按钮记一笔，之后就能和当前时薪对比。',
  historyCount: '{0} 条',
  clearAll: '清空',
  clearConfirmTitle: '清空历史记录？',
  clearConfirmBody: '这些记录会被删除，无法恢复。',
  cancel: '取消',
  clearConfirmAction: '清空',
  deleteTooltip: '删除这条',
  compareHigher: '比当前高 {0}',
  compareLower: '比当前低 {0}',
  compareSame: '与当前相同',
  recordMeta: '{0} · {1} · {2} 小时/天',
  restoredHint: '已把这组月薪和工时填回上面。',
  formulaNote:
      '时薪 = 月薪 ÷ (工作天数 × 每日工作时长)。工作天数按 21.75 天/月，'
      '大小周 +2 天、996 +4 天；995 天数同双休，996 与 995 都按每天 10 小时算。',
);

const HourlyStrings hourlyStringsZhHant = HourlyStrings(
  title: '時薪計算器',
  sectionInput: '月薪與工時',
  salary: '月薪',
  hoursPerDay: '每日工作時長',
  hoursPerDaySuffix: '小時',
  schedule: '工作日制度',
  scheduleOption: '{0} · {1} 天/月',
  scheduleStandard: '雙休',
  scheduleAlternate: '大小週',
  scheduleOvertime: '996',
  scheduleNineFiveFive: '995',
  scheduleHint: '選制度會自動填上每日工時：雙休 / 大小週 8 小時，996 / 995 10 小時。',
  emptyHint: '填好月薪和每天的工作時長，就知道自己一小時值多少錢。',
  hourlyLabel: '時薪',
  hourlySuffix: '/ 小時',
  breakdown: '{0} ÷ ({1} 天 × {2} 小時) = {3} 小時/月',
  monthlyHours: '月工時',
  dailyWage: '日薪',
  hoursValue: '{0} 小時',
  save: '記下這個時薪',
  savedHint: '已記入歷史，可以和後面的結果對比。',
  alreadySaved: '最新一條就是這組資料，沒有重複記錄。',
  sectionHistory: '歷史記錄',
  historyEmpty: '還沒有記錄。算出結果後點上面的按鈕記一筆，之後就能和當前時薪對比。',
  historyCount: '{0} 條',
  clearAll: '清空',
  clearConfirmTitle: '清空歷史記錄？',
  clearConfirmBody: '這些記錄會被刪除，無法恢復。',
  cancel: '取消',
  clearConfirmAction: '清空',
  deleteTooltip: '刪除這條',
  compareHigher: '比當前高 {0}',
  compareLower: '比當前低 {0}',
  compareSame: '與當前相同',
  recordMeta: '{0} · {1} · {2} 小時/天',
  restoredHint: '已把這組月薪和工時填回上面。',
  formulaNote:
      '時薪 = 月薪 ÷ (工作天數 × 每日工作時長)。工作天數按 21.75 天/月，'
      '大小週 +2 天、996 +4 天；995 天數同雙休，996 與 995 都按每天 10 小時算。',
);

const HourlyStrings hourlyStringsEn = HourlyStrings(
  title: 'Hourly wage',
  sectionInput: 'Salary & hours',
  salary: 'Monthly salary',
  hoursPerDay: 'Hours per day',
  hoursPerDaySuffix: 'h',
  schedule: 'Work schedule',
  scheduleOption: '{0} · {1} days/mo',
  scheduleStandard: 'Two days off',
  scheduleAlternate: 'Alternating weeks',
  scheduleOvertime: '996',
  scheduleNineFiveFive: '995',
  scheduleHint:
      'Picking a schedule fills in its usual daily hours: 8 for two days off '
      'and alternating weeks, 10 for 996 and 995.',
  emptyHint:
      'Enter your salary and daily hours to see what one hour of your time '
      'is worth.',
  hourlyLabel: 'Hourly wage',
  hourlySuffix: '/ h',
  breakdown: '{0} ÷ ({1} days × {2} h) = {3} h/mo',
  monthlyHours: 'Hours per month',
  dailyWage: 'Daily wage',
  hoursValue: '{0} h',
  save: 'Save this result',
  savedHint: 'Saved to history so you can compare later.',
  alreadySaved: 'The latest record is already this one.',
  sectionHistory: 'History',
  historyEmpty:
      'Nothing saved yet. Tap the button above to keep a result and compare '
      'it with the current wage.',
  historyCount: '{0} records',
  clearAll: 'Clear',
  clearConfirmTitle: 'Clear history?',
  clearConfirmBody: 'The saved records will be deleted for good.',
  cancel: 'Cancel',
  clearConfirmAction: 'Clear',
  deleteTooltip: 'Delete',
  compareHigher: '{0} above now',
  compareLower: '{0} below now',
  compareSame: 'Same as now',
  recordMeta: '{0} · {1} · {2} h/day',
  restoredHint: 'Put this salary and hours back in the fields above.',
  formulaNote:
      'Hourly wage = salary ÷ (work days × hours per day). Work days use '
      '21.75 per month, +2 for alternating weeks and +4 for 996. 995 keeps '
      'the same days as two days off; 996 and 995 both count 10 hours a day.',
);

const HourlyStrings hourlyStringsJa = HourlyStrings(
  title: '時給計算',
  sectionInput: '月給と勤務時間',
  salary: '月給',
  hoursPerDay: '1 日の勤務時間',
  hoursPerDaySuffix: '時間',
  schedule: '勤務体系',
  scheduleOption: '{0} · 月 {1} 日',
  scheduleStandard: '完全週休 2 日',
  scheduleAlternate: '隔週休 2 日',
  scheduleOvertime: '996',
  scheduleNineFiveFive: '995',
  scheduleHint:
      '勤務体系を選ぶと 1 日の勤務時間も入ります（週休 2 日・隔週休 2 日は 8 時間、996 と 995 は 10 時間）。',
  emptyHint: '月給と 1 日の勤務時間を入れると、自分の 1 時間の値打ちが出ます。',
  hourlyLabel: '時給',
  hourlySuffix: '/ 時間',
  breakdown: '{0} ÷（{1} 日 × {2} 時間）= 月 {3} 時間',
  monthlyHours: '月の勤務時間',
  dailyWage: '日給',
  hoursValue: '{0} 時間',
  save: 'この結果を保存',
  savedHint: '履歴に保存しました。あとで比べられます。',
  alreadySaved: '最新の記録がすでにこの内容です。',
  sectionHistory: '履歴',
  historyEmpty: 'まだ記録がありません。上のボタンで保存すると、今の時給と比べられます。',
  historyCount: '{0} 件',
  clearAll: '消去',
  clearConfirmTitle: '履歴を消しますか？',
  clearConfirmBody: '保存した記録は削除され、元に戻せません。',
  cancel: 'キャンセル',
  clearConfirmAction: '消去',
  deleteTooltip: 'この記録を削除',
  compareHigher: '現在より {0} 高い',
  compareLower: '現在より {0} 低い',
  compareSame: '現在と同じ',
  recordMeta: '{0} · {1} · 1 日 {2} 時間',
  restoredHint: 'この月給と勤務時間を入力欄に戻しました。',
  formulaNote:
      '時給 = 月給 ÷（勤務日数 × 1 日の勤務時間）。勤務日数は月 21.75 日、'
      '隔週休 2 日は +2 日、996 は +4 日。995 は週休 2 日と同じ日数で、'
      '996 と 995 はどちらも 1 日 10 時間で計算します。',
);

const HourlyStrings hourlyStringsEs = HourlyStrings(
  title: 'Salario por hora',
  sectionInput: 'Sueldo y horas',
  salary: 'Sueldo mensual',
  hoursPerDay: 'Horas al día',
  hoursPerDaySuffix: 'h',
  schedule: 'Jornada',
  scheduleOption: '{0} · {1} días/mes',
  scheduleStandard: 'Fin de semana libre',
  scheduleAlternate: 'Semanas alternas',
  scheduleOvertime: '996',
  scheduleNineFiveFive: '995',
  scheduleHint:
      'Al elegir una jornada se rellenan sus horas habituales: 8 para fin de '
      'semana libre y semanas alternas, 10 para 996 y 995.',
  emptyHint:
      'Introduce tu sueldo y las horas diarias para ver cuánto vale una hora '
      'de tu tiempo.',
  hourlyLabel: 'Salario por hora',
  hourlySuffix: '/ h',
  breakdown: '{0} ÷ ({1} días × {2} h) = {3} h/mes',
  monthlyHours: 'Horas al mes',
  dailyWage: 'Salario diario',
  hoursValue: '{0} h',
  save: 'Guardar este resultado',
  savedHint: 'Guardado en el historial para compararlo después.',
  alreadySaved: 'El último registro ya es este.',
  sectionHistory: 'Historial',
  historyEmpty:
      'Todavía no hay registros. Pulsa el botón de arriba para guardar un '
      'resultado y compararlo con el salario actual.',
  historyCount: '{0} registros',
  clearAll: 'Vaciar',
  clearConfirmTitle: '¿Vaciar el historial?',
  clearConfirmBody:
      'Los registros guardados se borrarán y no se podrán recuperar.',
  cancel: 'Cancelar',
  clearConfirmAction: 'Vaciar',
  deleteTooltip: 'Eliminar este registro',
  compareHigher: '{0} más que ahora',
  compareLower: '{0} menos que ahora',
  compareSame: 'Igual que ahora',
  recordMeta: '{0} · {1} · {2} h/día',
  restoredHint: 'He vuelto a poner este sueldo y estas horas arriba.',
  formulaNote:
      'Salario por hora = sueldo ÷ (días × horas). Los días son 21,75 al mes, '
      '+2 con semanas alternas y +4 con 996. 995 mantiene los días de fin de '
      'semana libre; 996 y 995 cuentan 10 horas al día.',
);
