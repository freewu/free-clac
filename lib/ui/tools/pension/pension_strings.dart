import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';

/// 养老金计算器页的界面文案。
///
/// 只有简繁中文两种：测算口径按国发〔2005〕38 号设计，`ToolInfo.availableIn`
/// 限定为中文，其他语言界面不展示。
class PensionStrings {
  const PensionStrings({
    required this.title,
    required this.sectionPerson,
    required this.age,
    required this.ageSuffix,
    required this.retireAge,
    required this.retireAgeOption,
    required this.paidYears,
    required this.yearsSuffix,
    required this.sectionMoney,
    required this.wage,
    required this.socialWage,
    required this.socialWageSuffix,
    required this.balance,
    required this.sectionAdvanced,
    required this.expand,
    required this.collapse,
    required this.growth,
    required this.accountRate,
    required this.accountNote,
    required this.emptyHint,
    required this.expectedMonthly,
    required this.replacement,
    required this.basePension,
    required this.accountPension,
    required this.paidYearsRow,
    required this.paidYearsValue,
    required this.avgIndex,
    required this.accountAtRetire,
    required this.accountAtRetireValue,
    required this.payoutMonths,
    required this.payoutMonthsValue,
    required this.wageAtRetire,
    required this.policyNote,
  });

  final String title;
  final String sectionPerson;
  final String age;
  final String ageSuffix;

  /// 「预计退休年龄」。
  final String retireAge;

  /// 「{0} 岁 · 计发 {1} 个月」。
  final String retireAgeOption;
  final String paidYears;
  final String yearsSuffix;
  final String sectionMoney;
  final String wage;
  final String socialWage;
  final String socialWageSuffix;
  final String balance;
  final String sectionAdvanced;
  final String expand;
  final String collapse;
  final String growth;
  final String accountRate;

  /// 「个人账户按本人缴费基数的 {0}% 记入…」。
  final String accountNote;
  final String emptyHint;
  final String expectedMonthly;

  /// 「替代率 {0}% · 退休时社平工资 {1}/月」。
  final String replacement;
  final String basePension;
  final String accountPension;
  final String paidYearsRow;

  /// 「已缴 {0} 年 + 续缴 {1} 年 = {2} 年」。
  final String paidYearsValue;
  final String avgIndex;
  final String accountAtRetire;

  /// 「{0}（其中利息 {1}）」，金额含符号。
  final String accountAtRetireValue;
  final String payoutMonths;

  /// 「{0} 个月」。
  final String payoutMonthsValue;
  final String wageAtRetire;
  final String policyNote;
}

/// 各语言的养老金计算器文案。
const Map<AppLanguage, PensionStrings> kPensionStrings =
    <AppLanguage, PensionStrings>{
      AppLanguage.zhHans: PensionStrings(
        title: '养老金计算器',
        sectionPerson: '参保情况',
        age: '当前年龄',
        ageSuffix: '岁',
        retireAge: '预计退休年龄',
        retireAgeOption: '{0} 岁 · 计发 {1} 个月',
        paidYears: '已缴费年限',
        yearsSuffix: '年',
        sectionMoney: '缴费与账户',
        wage: '月缴费工资',
        socialWage: '当地社平工资',
        socialWageSuffix: '元/月',
        balance: '个人账户余额',
        sectionAdvanced: '增长假设',
        expand: '展开',
        collapse: '收起',
        growth: '社平工资年增长',
        accountRate: '个人账户记账利率',
        accountNote: '个人账户按本人缴费基数的 {0}% 记入，缴费基数随社平工资同步增长。',
        emptyHint: '填入年龄、缴费工资与账户余额后自动测算',
        expectedMonthly: '预计每月养老金',
        replacement: '替代率 {0}% · 退休时社平工资 {1}/月',
        basePension: '基础养老金',
        accountPension: '个人账户',
        paidYearsRow: '缴费年限',
        paidYearsValue: '已缴 {0} 年 + 续缴 {1} 年 = {2} 年',
        avgIndex: '平均缴费指数',
        accountAtRetire: '退休时个人账户',
        accountAtRetireValue: '{0}（其中利息 {1}）',
        payoutMonths: '计发月数',
        payoutMonthsValue: '{0} 个月',
        wageAtRetire: '退休前月工资',
        policyNote:
            '按国发〔2005〕38 号口径测算：基础养老金 =（社平工资 + 本人指数化月平均'
            '缴费工资）÷ 2 × 缴费年限 × 1%，个人账户养老金 = 账户储存额 ÷ 计发月数。'
            '不含过渡性养老金、企业年金与地方补贴，结果仅供参考。',
      ),
      AppLanguage.zhHant: PensionStrings(
        title: '養老金計算器',
        sectionPerson: '參保情況',
        age: '當前年齡',
        ageSuffix: '歲',
        retireAge: '預計退休年齡',
        retireAgeOption: '{0} 歲 · 計發 {1} 個月',
        paidYears: '已繳費年限',
        yearsSuffix: '年',
        sectionMoney: '繳費與賬戶',
        wage: '月繳費工資',
        socialWage: '當地社平工資',
        socialWageSuffix: '元/月',
        balance: '個人賬戶餘額',
        sectionAdvanced: '增長假設',
        expand: '展開',
        collapse: '收起',
        growth: '社平工資年增長',
        accountRate: '個人賬戶記賬利率',
        accountNote: '個人賬戶按本人繳費基數的 {0}% 記入，繳費基數隨社平工資同步增長。',
        emptyHint: '填入年齡、繳費工資與賬戶餘額後自動測算',
        expectedMonthly: '預計每月養老金',
        replacement: '替代率 {0}% · 退休時社平工資 {1}/月',
        basePension: '基礎養老金',
        accountPension: '個人賬戶',
        paidYearsRow: '繳費年限',
        paidYearsValue: '已繳 {0} 年 + 續繳 {1} 年 = {2} 年',
        avgIndex: '平均繳費指數',
        accountAtRetire: '退休時個人賬戶',
        accountAtRetireValue: '{0}（其中利息 {1}）',
        payoutMonths: '計發月數',
        payoutMonthsValue: '{0} 個月',
        wageAtRetire: '退休前月工資',
        policyNote:
            '按國發〔2005〕38 號口徑測算：基礎養老金 =（社平工資 + 本人指數化月平均'
            '繳費工資）÷ 2 × 繳費年限 × 1%，個人賬戶養老金 = 賬戶儲存額 ÷ 計發月數。'
            '不含過渡性養老金、企業年金與地方補貼，結果僅供參考。',
      ),
    };

/// 当前语言的养老金计算器文案。
PensionStrings get pensionStrings => toolText(kPensionStrings);
