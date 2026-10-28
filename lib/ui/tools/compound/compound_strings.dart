import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'compound.dart';

/// 复利页的界面文案。
class CompoundStrings {
  const CompoundStrings({
    required this.title,
    required this.sectionInput,
    required this.principal,
    required this.yearsSuffix,
    required this.annualRate,
    required this.years,
    required this.contribution,
    required this.contributionSuffix,
    required this.frequency,
    required this.sectionTable,
    required this.frequencyNote,
    required this.emptyHint,
    required this.futureValue,
    required this.periodsNote,
    required this.totalInvested,
    required this.totalGain,
    required this.gainRate,
    required this.noYearly,
    required this.colYear,
    required this.colInvested,
    required this.colBalance,
    required this.colGain,
    required this.yearRow,
    required this.yearly,
    required this.semiannual,
    required this.quarterly,
    required this.monthly,
    required this.daily,
  });

  final String title;
  final String sectionInput;
  final String principal;

  /// 金额后缀（复利工具固定用人民币口径）。

  /// 年限输入框的后缀。
  final String yearsSuffix;
  final String annualRate;
  final String years;

  /// 「每期追加（可选）」。
  final String contribution;

  /// 追加金额的后缀：`{0}` 是计息频率名。
  final String contributionSuffix;
  final String frequency;
  final String sectionTable;

  /// 「按 {0} 计息」，`{0}` 是计息频率名。
  final String frequencyNote;
  final String emptyHint;
  final String futureValue;

  /// 「{0} 计息 {1} 期 · 有效年利率 {2}%」。
  final String periodsNote;
  final String totalInvested;
  final String totalGain;
  final String gainRate;
  final String noYearly;
  final String colYear;
  final String colInvested;
  final String colBalance;
  final String colGain;

  /// 表格首列里的「第 {0} 年」。
  final String yearRow;
  final String yearly;
  final String semiannual;
  final String quarterly;
  final String monthly;
  final String daily;

  /// 计息频率名称（数据层的 `CompoundFrequency.label` 只有中文）。
  String frequencyLabel(CompoundFrequency value) => switch (value) {
    CompoundFrequency.yearly => yearly,
    CompoundFrequency.semiannual => semiannual,
    CompoundFrequency.quarterly => quarterly,
    CompoundFrequency.monthly => monthly,
    CompoundFrequency.daily => daily,
  };
}

/// 各语言的复利页文案。
const Map<AppLanguage, CompoundStrings> kCompoundStrings =
    <AppLanguage, CompoundStrings>{
      AppLanguage.zhHans: CompoundStrings(
        title: '复利计算',
        sectionInput: '输入',
        principal: '期初本金',
        yearsSuffix: '年',
        annualRate: '年利率',
        years: '年限',
        contribution: '每期追加（可选）',
        contributionSuffix: '元 / {0}',
        frequency: '复利频率',
        sectionTable: '逐年增长',
        frequencyNote: '按{0}计息',
        emptyHint: '填写本金与年限后自动计算',
        futureValue: '到期本息合计',
        periodsNote: '{0}计息 {1} 期 · 有效年利率 {2}%',
        totalInvested: '总投入',
        totalGain: '总收益',
        gainRate: '收益率',
        noYearly: '年限不足 1 年，没有逐年数据。',
        colYear: '年份',
        colInvested: '累计投入',
        colBalance: '期末余额',
        colGain: '累计收益',
        yearRow: '第 {0} 年',
        yearly: '每年',
        semiannual: '每半年',
        quarterly: '每季度',
        monthly: '每月',
        daily: '每日',
      ),
      AppLanguage.zhHant: CompoundStrings(
        title: '複利計算',
        sectionInput: '輸入',
        principal: '期初本金',
        yearsSuffix: '年',
        annualRate: '年利率',
        years: '年限',
        contribution: '每期追加（選填）',
        contributionSuffix: '元 / {0}',
        frequency: '複利頻率',
        sectionTable: '逐年成長',
        frequencyNote: '按{0}計息',
        emptyHint: '填寫本金與年限後自動計算',
        futureValue: '到期本息合計',
        periodsNote: '{0}計息 {1} 期 · 有效年利率 {2}%',
        totalInvested: '總投入',
        totalGain: '總收益',
        gainRate: '收益率',
        noYearly: '年限不足 1 年，沒有逐年資料。',
        colYear: '年份',
        colInvested: '累計投入',
        colBalance: '期末餘額',
        colGain: '累計收益',
        yearRow: '第 {0} 年',
        yearly: '每年',
        semiannual: '每半年',
        quarterly: '每季',
        monthly: '每月',
        daily: '每日',
      ),
      AppLanguage.en: CompoundStrings(
        title: 'Compound interest',
        sectionInput: 'Input',
        principal: 'Starting principal',
        yearsSuffix: 'yrs',
        annualRate: 'Annual rate',
        years: 'Years',
        contribution: 'Added each period (optional)',
        contributionSuffix: 'per {0}',
        frequency: 'Compounding',
        sectionTable: 'Year by year',
        frequencyNote: 'Compounded {0}',
        emptyHint: 'Enter principal and years to calculate',
        futureValue: 'Balance at maturity',
        periodsNote: 'Compounded {1} times {0} · effective annual rate {2}%',
        totalInvested: 'Invested',
        totalGain: 'Interest',
        gainRate: 'Return',
        noYearly: 'Less than a year, so there is no yearly breakdown.',
        colYear: 'Year',
        colInvested: 'Invested',
        colBalance: 'Balance',
        colGain: 'Interest',
        yearRow: 'Year {0}',
        yearly: 'yearly',
        semiannual: 'semiannually',
        quarterly: 'quarterly',
        monthly: 'monthly',
        daily: 'daily',
      ),
      AppLanguage.ja: CompoundStrings(
        title: '複利計算',
        sectionInput: '入力',
        principal: '元本',
        yearsSuffix: '年',
        annualRate: '年利率',
        years: '年数',
        contribution: '毎期の追加額（任意）',
        contributionSuffix: '{0}あたり',
        frequency: '複利の頻度',
        sectionTable: '年ごとの推移',
        frequencyNote: '{0}複利',
        emptyHint: '元本と年数を入力すると自動計算します',
        futureValue: '満期時の元利合計',
        periodsNote: '{0}複利 {1} 回 · 実効年利 {2}%',
        totalInvested: '元本合計',
        totalGain: '利息合計',
        gainRate: '利回り',
        noYearly: '1 年未満のため、年ごとのデータはありません。',
        colYear: '年',
        colInvested: '元本累計',
        colBalance: '残高',
        colGain: '利息累計',
        yearRow: '{0} 年目',
        yearly: '年',
        semiannual: '半年',
        quarterly: '四半期',
        monthly: '月',
        daily: '日',
      ),
      AppLanguage.es: CompoundStrings(
        title: 'Interés compuesto',
        sectionInput: 'Datos',
        principal: 'Capital inicial',
        yearsSuffix: 'años',
        annualRate: 'Tipo anual',
        years: 'Años',
        contribution: 'Aportación por periodo (opcional)',
        contributionSuffix: 'por {0}',
        frequency: 'Capitalización',
        sectionTable: 'Año a año',
        frequencyNote: 'Capitaliza {0}',
        emptyHint: 'Introduce capital y años para calcular',
        futureValue: 'Saldo al vencimiento',
        periodsNote: 'Capitaliza {1} veces ({0}) · TAE {2}%',
        totalInvested: 'Aportado',
        totalGain: 'Intereses',
        gainRate: 'Rentabilidad',
        noYearly: 'Menos de un año: no hay desglose anual.',
        colYear: 'Año',
        colInvested: 'Aportado',
        colBalance: 'Saldo',
        colGain: 'Intereses',
        yearRow: 'Año {0}',
        yearly: 'anual',
        semiannual: 'semestral',
        quarterly: 'trimestral',
        monthly: 'mensual',
        daily: 'diaria',
      ),
    };

/// 当前语言的复利页文案。
CompoundStrings get compoundStrings => toolText(kCompoundStrings);
