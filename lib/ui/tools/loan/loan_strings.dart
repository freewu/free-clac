import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'loan.dart';

/// 贷款计算器页的界面文案。
class LoanStrings {
  const LoanStrings({
    required this.title,
    required this.sectionInput,
    required this.amount,
    required this.currency,
    required this.annualRate,
    required this.term,
    required this.termUnit,
    required this.years,
    required this.months,
    required this.method,
    required this.equalInstallment,
    required this.equalPrincipal,
    required this.sectionSchedule,
    required this.emptyHint,
    required this.byMonth,
    required this.byYear,
    required this.monthlyPayment,
    required this.firstPayment,
    required this.summaryFixed,
    required this.summaryDecreasing,
    required this.loanTotal,
    required this.totalInterest,
    required this.totalPayment,
    required this.principalShare,
    required this.interestShare,
    required this.periodColumn,
    required this.paymentThisYear,
    required this.paymentThisPeriod,
    required this.barNote,
    required this.yearRow,
    required this.periodRow,
    required this.principalRow,
    required this.interestRow,
  });

  final String title;
  final String sectionInput;
  final String amount;
  final String currency;
  final String annualRate;
  final String term;
  final String termUnit;
  final String years;
  final String months;
  final String method;
  final String equalInstallment;
  final String equalPrincipal;
  final String sectionSchedule;
  final String emptyHint;
  final String byMonth;
  final String byYear;
  final String monthlyPayment;
  final String firstPayment;

  /// 「{0} · 共 {1} 期 · 每期还款额固定」，`{0}` 是还款方式名。
  final String summaryFixed;

  /// 「{0} · 共 {1} 期 · 月供逐月递减 ¥ {2}」。
  final String summaryDecreasing;
  final String loanTotal;
  final String totalInterest;
  final String totalPayment;

  /// 「本金 {0}%」。
  final String principalShare;

  /// 「利息 {0}%」。
  final String interestShare;
  final String periodColumn;
  final String paymentThisYear;
  final String paymentThisPeriod;
  final String barNote;

  /// 「第 {0} 年」。
  final String yearRow;

  /// 「第 {0} 期」。
  final String periodRow;

  /// 「本金 ¥ {0}」。
  final String principalRow;

  /// 「利息 ¥ {0}」。
  final String interestRow;

  /// 还款方式名称（数据层的 `LoanMethod.label` 只有中文）。
  String methodLabel(LoanMethod value) => switch (value) {
    LoanMethod.equalInstallment => equalInstallment,
    LoanMethod.equalPrincipal => equalPrincipal,
  };

  /// 期限单位名称（数据层的 `LoanTermUnit.label` 只有中文）。
  String termUnitLabel(LoanTermUnit value) =>
      value == LoanTermUnit.years ? years : months;
}

/// 各语言的贷款计算器文案。
const Map<AppLanguage, LoanStrings> kLoanStrings = <AppLanguage, LoanStrings>{
  AppLanguage.zhHans: LoanStrings(
    title: '贷款计算器',
    sectionInput: '输入',
    amount: '贷款金额',
    currency: '元',
    annualRate: '年利率',
    term: '期限',
    termUnit: '期限单位',
    years: '年',
    months: '月',
    method: '还款方式',
    equalInstallment: '等额本息',
    equalPrincipal: '等额本金',
    sectionSchedule: '还款明细',
    emptyHint: '填写金额、利率与期限后自动计算',
    byMonth: '按月',
    byYear: '按年',
    monthlyPayment: '每月还款',
    firstPayment: '首月还款',
    summaryFixed: '{0} · 共 {1} 期 · 每期还款额固定',
    summaryDecreasing: '{0} · 共 {1} 期 · 月供逐月递减 ¥ {2}',
    loanTotal: '贷款总额',
    totalInterest: '总利息',
    totalPayment: '总还款',
    principalShare: '本金 {0}%',
    interestShare: '利息 {0}%',
    periodColumn: '期数',
    paymentThisYear: '当年还款',
    paymentThisPeriod: '本期还款',
    barNote: '条长按当期还款额缩放：首期 100%，末期 60%',
    yearRow: '第 {0} 年',
    periodRow: '第 {0} 期',
    principalRow: '本金 ¥ {0}',
    interestRow: '利息 ¥ {0}',
  ),
  AppLanguage.zhHant: LoanStrings(
    title: '貸款試算',
    sectionInput: '輸入',
    amount: '貸款金額',
    currency: '元',
    annualRate: '年利率',
    term: '期限',
    termUnit: '期限單位',
    years: '年',
    months: '月',
    method: '還款方式',
    equalInstallment: '本息平均攤還',
    equalPrincipal: '本金平均攤還',
    sectionSchedule: '還款明細',
    emptyHint: '填寫金額、利率與期限後自動計算',
    byMonth: '按月',
    byYear: '按年',
    monthlyPayment: '每月還款',
    firstPayment: '首期還款',
    summaryFixed: '{0} · 共 {1} 期 · 每期還款額固定',
    summaryDecreasing: '{0} · 共 {1} 期 · 月付逐月遞減 ¥ {2}',
    loanTotal: '貸款總額',
    totalInterest: '總利息',
    totalPayment: '總還款',
    principalShare: '本金 {0}%',
    interestShare: '利息 {0}%',
    periodColumn: '期數',
    paymentThisYear: '當年還款',
    paymentThisPeriod: '本期還款',
    barNote: '條長按當期還款額縮放：首期 100%，末期 60%',
    yearRow: '第 {0} 年',
    periodRow: '第 {0} 期',
    principalRow: '本金 ¥ {0}',
    interestRow: '利息 ¥ {0}',
  ),
  AppLanguage.en: LoanStrings(
    title: 'Loan calculator',
    sectionInput: 'Input',
    amount: 'Loan amount',
    currency: 'CNY',
    annualRate: 'Annual rate',
    term: 'Term',
    termUnit: 'Term unit',
    years: 'years',
    months: 'months',
    method: 'Repayment',
    equalInstallment: 'Equal payment',
    equalPrincipal: 'Equal principal',
    sectionSchedule: 'Schedule',
    emptyHint: 'Enter amount, rate and term to calculate',
    byMonth: 'Monthly',
    byYear: 'Yearly',
    monthlyPayment: 'Monthly payment',
    firstPayment: 'First payment',
    summaryFixed: '{0} · {1} periods · same payment every period',
    summaryDecreasing: '{0} · {1} periods · drops by ¥ {2} each month',
    loanTotal: 'Principal',
    totalInterest: 'Interest',
    totalPayment: 'Total repayment',
    principalShare: 'Principal {0}%',
    interestShare: 'Interest {0}%',
    periodColumn: 'Period',
    paymentThisYear: 'Paid that year',
    paymentThisPeriod: 'Paid that period',
    barNote: 'Bar length follows the payment: 100% first period, 60% last',
    yearRow: 'Year {0}',
    periodRow: 'Period {0}',
    principalRow: 'Principal ¥ {0}',
    interestRow: 'Interest ¥ {0}',
  ),
  AppLanguage.ja: LoanStrings(
    title: 'ローン計算',
    sectionInput: '入力',
    amount: '借入額',
    currency: '元',
    annualRate: '年利',
    term: '期間',
    termUnit: '期間の単位',
    years: '年',
    months: 'か月',
    method: '返済方式',
    equalInstallment: '元利均等返済',
    equalPrincipal: '元金均等返済',
    sectionSchedule: '返済予定表',
    emptyHint: '金額・金利・期間を入力すると自動計算します',
    byMonth: '月ごと',
    byYear: '年ごと',
    monthlyPayment: '毎月の返済額',
    firstPayment: '初回の返済額',
    summaryFixed: '{0} · 全 {1} 回 · 毎回の返済額は一定',
    summaryDecreasing: '{0} · 全 {1} 回 · 毎月 ¥ {2} ずつ減額',
    loanTotal: '借入額',
    totalInterest: '利息合計',
    totalPayment: '返済総額',
    principalShare: '元金 {0}%',
    interestShare: '利息 {0}%',
    periodColumn: '回数',
    paymentThisYear: 'その年の返済額',
    paymentThisPeriod: 'その回の返済額',
    barNote: 'バーの長さは返済額に比例：初回 100%、最終 60%',
    yearRow: '{0} 年目',
    periodRow: '{0} 回目',
    principalRow: '元金 ¥ {0}',
    interestRow: '利息 ¥ {0}',
  ),
  AppLanguage.es: LoanStrings(
    title: 'Calculadora de préstamo',
    sectionInput: 'Datos',
    amount: 'Importe',
    currency: 'CNY',
    annualRate: 'Tipo anual',
    term: 'Plazo',
    termUnit: 'Unidad del plazo',
    years: 'años',
    months: 'meses',
    method: 'Sistema de amortización',
    equalInstallment: 'Cuota constante',
    equalPrincipal: 'Capital constante',
    sectionSchedule: 'Cuadro de amortización',
    emptyHint: 'Introduce importe, tipo y plazo para calcular',
    byMonth: 'Por mes',
    byYear: 'Por año',
    monthlyPayment: 'Cuota mensual',
    firstPayment: 'Primera cuota',
    summaryFixed: '{0} · {1} cuotas · misma cuota siempre',
    summaryDecreasing: '{0} · {1} cuotas · baja ¥ {2} al mes',
    loanTotal: 'Capital',
    totalInterest: 'Intereses',
    totalPayment: 'Total a pagar',
    principalShare: 'Capital {0}%',
    interestShare: 'Intereses {0}%',
    periodColumn: 'Cuota',
    paymentThisYear: 'Pagado ese año',
    paymentThisPeriod: 'Pagado esa cuota',
    barNote: 'La barra sigue la cuota: 100 % la primera, 60 % la última',
    yearRow: 'Año {0}',
    periodRow: 'Cuota {0}',
    principalRow: 'Capital ¥ {0}',
    interestRow: 'Intereses ¥ {0}',
  ),
};

/// 当前语言的贷款计算器文案。
LoanStrings get loanStrings => toolText(kLoanStrings);
