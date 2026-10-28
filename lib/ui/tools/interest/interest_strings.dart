import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'interest.dart';

/// 利率换算页的界面文案。
class InterestStrings {
  const InterestStrings({
    required this.title,
    required this.sectionInput,
    required this.principal,
    required this.mode,
    required this.modeFromPayment,
    required this.modeFromRate,
    required this.period,
    required this.daily,
    required this.monthly,
    required this.yearly,
    required this.everyDaily,
    required this.everyMonthly,
    required this.everyYearly,
    required this.paymentLabel,
    required this.paymentSuffix,
    required this.annualRate,
    required this.emptyHint,
    required this.annualHeadline,
    required this.annualCaption,
    required this.paymentCaption,
    required this.periodRate,
    required this.perTenThousand,
    required this.annualNote,
  });

  final String title;
  final String sectionInput;
  final String principal;
  final String mode;
  final String modeFromPayment;
  final String modeFromRate;
  final String period;
  final String daily;
  final String monthly;
  final String yearly;
  final String everyDaily;
  final String everyMonthly;
  final String everyYearly;

  /// 期付金额输入框的标题：`{0}` 是「每天」等。
  final String paymentLabel;

  /// 期付金额的后缀：`{0}` 是「每天」等。
  final String paymentSuffix;
  final String annualRate;
  final String emptyHint;

  /// 结果大标题（由期付算年化）。
  final String annualHeadline;

  /// 结果说明（由期付算年化）：`{0}` 本金、`{1}` 周期名、`{2}` 期付。
  final String annualCaption;

  /// 结果说明（由年化算期付）：`{0}` 周期名、`{1}` 年化率、`{2}` 本金。
  final String paymentCaption;

  /// 「{0}利率 {1}」，`{0}` 是「每天」等。
  final String periodRate;

  /// 「每万元{0} {1}」，`{0}` 是周期名。
  final String perTenThousand;

  /// 「年化 {0}」。
  final String annualNote;

  /// 周期名称（数据层的 `InterestPeriod.label` 只有中文）。
  String periodLabel(InterestPeriod value) => switch (value) {
    InterestPeriod.daily => daily,
    InterestPeriod.monthly => monthly,
    InterestPeriod.yearly => yearly,
  };

  /// 「每 X」说法（数据层的 `InterestPeriod.everyLabel` 只有中文）。
  String everyLabel(InterestPeriod value) => switch (value) {
    InterestPeriod.daily => everyDaily,
    InterestPeriod.monthly => everyMonthly,
    InterestPeriod.yearly => everyYearly,
  };
}

/// 各语言的利率换算页文案。
const Map<AppLanguage, InterestStrings> kInterestStrings =
    <AppLanguage, InterestStrings>{
      AppLanguage.zhHans: InterestStrings(
        title: '利率计算',
        sectionInput: '输入',
        principal: '本金',
        mode: '换算方向',
        modeFromPayment: '由期付算年化',
        modeFromRate: '由年化算期付',
        period: '付息周期',
        daily: '日付',
        monthly: '月付',
        yearly: '年付',
        everyDaily: '每天',
        everyMonthly: '每月',
        everyYearly: '每年',
        paymentLabel: '{0}收益',
        paymentSuffix: '元 / {0}',
        annualRate: '年化率',
        emptyHint: '填写本金与期付 / 年化率后自动换算',
        annualHeadline: '年化率',
        annualCaption: '年化率 · 本金 {0} · {1} {2}',
        paymentCaption: '{0}收益 · 年化率 {1} · 本金 {2}',
        periodRate: '{0}利率 {1}',
        perTenThousand: '每万元{0} {1}',
        annualNote: '年化 {0}',
      ),
      AppLanguage.zhHant: InterestStrings(
        title: '利率計算',
        sectionInput: '輸入',
        principal: '本金',
        mode: '換算方向',
        modeFromPayment: '由期付算年化',
        modeFromRate: '由年化算期付',
        period: '付息週期',
        daily: '日付',
        monthly: '月付',
        yearly: '年付',
        everyDaily: '每天',
        everyMonthly: '每月',
        everyYearly: '每年',
        paymentLabel: '{0}收益',
        paymentSuffix: '元 / {0}',
        annualRate: '年化率',
        emptyHint: '填寫本金與期付 / 年化率後自動換算',
        annualHeadline: '年化率',
        annualCaption: '年化率 · 本金 {0} · {1} {2}',
        paymentCaption: '{0}收益 · 年化率 {1} · 本金 {2}',
        periodRate: '{0}利率 {1}',
        perTenThousand: '每萬元{0} {1}',
        annualNote: '年化 {0}',
      ),
      AppLanguage.en: InterestStrings(
        title: 'Interest rate',
        sectionInput: 'Input',
        principal: 'Principal',
        mode: 'Direction',
        modeFromPayment: 'Payment → annual rate',
        modeFromRate: 'Annual rate → payment',
        period: 'Payout period',
        daily: 'Daily',
        monthly: 'Monthly',
        yearly: 'Yearly',
        everyDaily: 'daily',
        everyMonthly: 'monthly',
        everyYearly: 'yearly',
        paymentLabel: 'Income per {0}',
        paymentSuffix: 'CNY per {0}',
        annualRate: 'Annual rate',
        emptyHint: 'Enter principal and a payment or rate to convert',
        annualHeadline: 'Annual rate',
        annualCaption: 'Annual rate · principal {0} · {1} pays {2}',
        paymentCaption: 'Income {0} · annual rate {1} · principal {2}',
        periodRate: '{0} rate {1}',
        perTenThousand: 'Per 10,000 {0} {1}',
        annualNote: 'Annual {0}',
      ),
      AppLanguage.ja: InterestStrings(
        title: '利率計算',
        sectionInput: '入力',
        principal: '元本',
        mode: '換算の向き',
        modeFromPayment: '受取額 → 年利',
        modeFromRate: '年利 → 受取額',
        period: '利息の支払い周期',
        daily: '日払い',
        monthly: '月払い',
        yearly: '年払い',
        everyDaily: '毎日',
        everyMonthly: '毎月',
        everyYearly: '毎年',
        paymentLabel: '{0}の受取額',
        paymentSuffix: '元 / {0}',
        annualRate: '年利',
        emptyHint: '元本と受取額または年利を入力すると換算します',
        annualHeadline: '年利',
        annualCaption: '年利 · 元本 {0} · {1} {2}',
        paymentCaption: '{0}の受取額 · 年利 {1} · 元本 {2}',
        periodRate: '{0}の利率 {1}',
        perTenThousand: '1 万元あたり{0} {1}',
        annualNote: '年利 {0}',
      ),
      AppLanguage.es: InterestStrings(
        title: 'Tipo de interés',
        sectionInput: 'Datos',
        principal: 'Capital',
        mode: 'Dirección',
        modeFromPayment: 'Pago → tasa anual',
        modeFromRate: 'Tasa anual → pago',
        period: 'Periodo de pago',
        daily: 'Diario',
        monthly: 'Mensual',
        yearly: 'Anual',
        everyDaily: 'diario',
        everyMonthly: 'mensual',
        everyYearly: 'anual',
        paymentLabel: 'Ingreso {0}',
        paymentSuffix: 'CNY por {0}',
        annualRate: 'Tasa anual',
        emptyHint: 'Introduce capital y un pago o una tasa',
        annualHeadline: 'Tasa anual',
        annualCaption: 'Tasa anual · capital {0} · {1} paga {2}',
        paymentCaption: 'Ingreso {0} · tasa anual {1} · capital {2}',
        periodRate: 'Tasa {0} {1}',
        perTenThousand: 'Por 10.000 {0} {1}',
        annualNote: 'Anual {0}',
      ),
    };

/// 当前语言的利率换算页文案。
InterestStrings get interestStrings => toolText(kInterestStrings);
