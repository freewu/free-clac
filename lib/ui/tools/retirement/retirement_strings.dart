import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import 'retirement.dart';

/// 退休年龄计算器页的界面文案。
///
/// 只有简繁中文两种：工具本身按中国延迟退休政策设计，`ToolInfo.availableIn`
/// 限定为中文，其他语言界面不展示。
class RetirementStrings {
  const RetirementStrings({
    required this.title,
    required this.sectionPerson,
    required this.birthYear,
    required this.birthMonth,
    required this.group,
    required this.groupMale,
    required this.groupFemale55,
    required this.groupFemale50,
    required this.yearOption,
    required this.monthOption,
    required this.retireTime,
    required this.yearMonth,
    required this.countdown,
    required this.countdownDone,
    required this.spanMonths,
    required this.spanYears,
    required this.spanYearsMonths,
    required this.legalAge,
    required this.ageYears,
    required this.ageYearsMonths,
    required this.minContribution,
    required this.yearsValue,
    required this.contributionValue,
    required this.earliest,
    required this.latest,
    required this.flexValue,
    required this.summaryNoDelay,
    required this.summaryDelay,
    required this.capped,
    required this.policyNote,
  });

  final String title;
  final String sectionPerson;
  final String birthYear;
  final String birthMonth;
  final String group;

  /// 「男职工 · 原 {0} 岁」。
  final String groupMale;

  /// 「女职工（管理技术）· 原 {0} 岁」。
  final String groupFemale55;

  /// 「女职工（工人）· 原 {0} 岁」。
  final String groupFemale50;

  /// 「{0} 年」，出生年份下拉框。
  final String yearOption;

  /// 「{0} 月」，出生月份下拉框。
  final String monthOption;
  final String retireTime;

  /// 「{0} 年 {1} 月」。
  final String yearMonth;

  /// 「还需奋斗 {0}」。
  final String countdown;
  final String countdownDone;

  /// 「{0} 个月」。
  final String spanMonths;

  /// 「{0} 年」。
  final String spanYears;

  /// 「{0} 年 {1} 个月」。
  final String spanYearsMonths;
  final String legalAge;

  /// 「{0} 岁」。
  final String ageYears;

  /// 「{0} 岁 {1} 个月」。
  final String ageYearsMonths;
  final String minContribution;

  /// 「{0} 年」。
  final String yearsValue;

  /// 「{0}（{1} 年退休）」。
  final String contributionValue;
  final String earliest;
  final String latest;

  /// 「{0} · {1} 岁」，`{0}` 是「2045 年 6 月」这样的年月。
  final String flexValue;

  /// 「原法定退休年龄 {0} 岁，不受延迟退休影响。」
  final String summaryNoDelay;

  /// 「原法定退休年龄 {0} 岁，延迟 {1} 个月{2}。…」
  final String summaryDelay;

  /// 「，已到 {0} 岁的改革目标」。
  final String capped;
  final String policyNote;

  /// 人员类别名称（数据层的 [RetirementGroup] 只有枚举值）。
  String groupLabel(RetirementGroup value) {
    final ages = value.baseAge;
    return switch (value) {
      RetirementGroup.male => fill(groupMale, [ages]),
      RetirementGroup.female55 => fill(groupFemale55, [ages]),
      RetirementGroup.female50 => fill(groupFemale50, [ages]),
    };
  }
}

/// 各语言的退休年龄计算器文案。
const Map<AppLanguage, RetirementStrings> kRetirementStrings =
    <AppLanguage, RetirementStrings>{
      AppLanguage.zhHans: RetirementStrings(
        title: '退休年龄计算器',
        sectionPerson: '参保人',
        birthYear: '出生年份',
        birthMonth: '出生月份',
        group: '人员类别',
        groupMale: '男职工 · 原 {0} 岁',
        groupFemale55: '女职工（管理技术）· 原 {0} 岁',
        groupFemale50: '女职工（工人）· 原 {0} 岁',
        yearOption: '{0} 年',
        monthOption: '{0} 月',
        retireTime: '法定退休时间',
        yearMonth: '{0} 年 {1} 月',
        countdown: '还需奋斗 {0}',
        countdownDone: '已达到法定退休年龄',
        spanMonths: '{0} 个月',
        spanYears: '{0} 年',
        spanYearsMonths: '{0} 年 {1} 个月',
        legalAge: '法定退休年龄',
        ageYears: '{0} 岁',
        ageYearsMonths: '{0} 岁 {1} 个月',
        minContribution: '最低缴费年限',
        yearsValue: '{0} 年',
        contributionValue: '{0}（{1} 年退休）',
        earliest: '弹性提前最早',
        latest: '弹性延迟最晚',
        flexValue: '{0} · {1} 岁',
        summaryNoDelay: '原法定退休年龄 {0} 岁，不受延迟退休影响。',
        summaryDelay:
            '原法定退休年龄 {0} 岁，延迟 {1} 个月{2}。'
            '可在法定退休年龄前后各 3 年内弹性选择。',
        capped: '，已到 {0} 岁的改革目标',
        policyNote:
            '口径：《全国人民代表大会常务委员会关于实施渐进式延迟法定退休年龄的'
            '决定》，2025 年 1 月 1 日起施行。男职工 60 → 63 岁、原 55 岁女职工 '
            '55 → 58 岁（每 4 个月出生延迟 1 个月），原 50 岁女职工 50 → 55 岁'
            '（每 2 个月出生延迟 1 个月）；最低缴费年限自 2030 年起每年提高 6 '
            '个月，2039 年及以后为 20 年。可自愿提前（不低于原法定退休年龄）或'
            '协商延迟，前后各不超过 3 年。不含特殊工种提前退休、病退与军龄折算。',
      ),
      AppLanguage.zhHant: RetirementStrings(
        title: '退休年齡計算器',
        sectionPerson: '參保人',
        birthYear: '出生年份',
        birthMonth: '出生月份',
        group: '人員類別',
        groupMale: '男職工 · 原 {0} 歲',
        groupFemale55: '女職工（管理技術）· 原 {0} 歲',
        groupFemale50: '女職工（工人）· 原 {0} 歲',
        yearOption: '{0} 年',
        monthOption: '{0} 月',
        retireTime: '法定退休時間',
        yearMonth: '{0} 年 {1} 月',
        countdown: '還需奮鬥 {0}',
        countdownDone: '已達法定退休年齡',
        spanMonths: '{0} 個月',
        spanYears: '{0} 年',
        spanYearsMonths: '{0} 年 {1} 個月',
        legalAge: '法定退休年齡',
        ageYears: '{0} 歲',
        ageYearsMonths: '{0} 歲 {1} 個月',
        minContribution: '最低繳費年限',
        yearsValue: '{0} 年',
        contributionValue: '{0}（{1} 年退休）',
        earliest: '彈性提前最早',
        latest: '彈性延遲最晚',
        flexValue: '{0} · {1} 歲',
        summaryNoDelay: '原法定退休年齡 {0} 歲，不受延遲退休影響。',
        summaryDelay:
            '原法定退休年齡 {0} 歲，延遲 {1} 個月{2}。'
            '可在法定退休年齡前後各 3 年內彈性選擇。',
        capped: '，已到 {0} 歲的改革目標',
        policyNote:
            '口徑：《全國人民代表大會常務委員會關於實施漸進式延遲法定退休年齡'
            '的決定》，2025 年 1 月 1 日起施行。男職工 60 → 63 歲、原 55 歲女職'
            '工 55 → 58 歲（每 4 個月出生延遲 1 個月），原 50 歲女職工 50 → 55 '
            '歲（每 2 個月出生延遲 1 個月）；最低繳費年限自 2030 年起每年提高 6 '
            '個月，2039 年及以後為 20 年。可自願提前（不低於原法定退休年齡）或'
            '協商延遲，前後各不超過 3 年。不含特殊工種提前退休、病退與軍齡折算。',
      ),
    };

/// 当前语言的退休年龄计算器文案。
RetirementStrings get retirementStrings => toolText(kRetirementStrings);
