/// 养老金计算器：城镇职工基本养老金测算，纯逻辑，不依赖 Flutter。
///
/// 公式按国发〔2005〕38 号《关于完善企业职工基本养老保险制度的决定》：
///
/// * 基础养老金 =（退休时上年度社平工资 + 本人指数化月平均缴费工资）÷ 2
///   × 缴费年限 × 1%
///   = 社平工资 × (1 + 平均缴费指数) ÷ 2 × 缴费年限 × 1%
/// * 个人账户养老金 = 退休时个人账户储存额 ÷ 计发月数
/// * 合计 = 基础养老金 + 个人账户养老金
///
/// 这里不包含过渡性养老金（1996 年前参加工作的「中人」才有）、企业年金 /
/// 职业年金与地方性补贴，测算结果只作参考。
library;

/// 个人账户的法定缴费比例（本人缴费基数的 8%）。
const double kPensionPersonalRate = 8;

/// 计发月数表（国发〔2005〕38 号附表）：退休年龄 → 计发月数。
///
/// 退休越晚，预期余命越短，同样的账户余额每月能领得越多。
const Map<int, int> kPensionPayoutMonths = <int, int>{
  40: 233,
  41: 230,
  42: 226,
  43: 223,
  44: 220,
  45: 216,
  46: 212,
  47: 208,
  48: 204,
  49: 199,
  50: 195,
  51: 190,
  52: 185,
  53: 180,
  54: 175,
  55: 170,
  56: 164,
  57: 158,
  58: 152,
  59: 145,
  60: 139,
  61: 132,
  62: 125,
  63: 117,
  64: 109,
  65: 101,
  66: 93,
  67: 84,
  68: 75,
  69: 65,
  70: 56,
};

/// 下拉框里提供的退休年龄：法定退休年龄附近的常见档位。
const List<int> kPensionRetireAges = <int>[50, 55, 58, 60, 63, 65];

/// 计发月数，年龄不在 40~70 之间时返回 null。
int? pensionPayoutMonthsOf(int retireAge) => kPensionPayoutMonths[retireAge];

/// 一件「养老金测算」的输入。
class PensionInput {
  const PensionInput({
    required this.age,
    required this.retireAge,
    required this.paidYears,
    required this.balance,
    required this.monthlyWage,
    required this.socialAverageWage,
    this.socialGrowthPercent = 5,
    this.accountRatePercent = 3,
    this.personalRatePercent = kPensionPersonalRate,
  });

  /// 当前年龄（岁）。
  final int age;

  /// 预计退休年龄（岁），决定计发月数。
  final int retireAge;

  /// 已累计缴费年限（年，可含视同缴费年限）。
  final double paidYears;

  /// 当前个人账户余额（元）。
  final double balance;

  /// 本人月缴费工资，即缴费基数（元）。
  final double monthlyWage;

  /// 当地上年度在岗职工月平均工资（元）。
  final double socialAverageWage;

  /// 社平工资年增长率（%），缴费基数按同一幅度增长。
  final double socialGrowthPercent;

  /// 个人账户记账利率（%）。
  final double accountRatePercent;

  /// 个人账户缴费比例（%），法定为 8%。
  final double personalRatePercent;
}

/// 测算结果。
class PensionResult {
  const PensionResult({
    required this.paidYears,
    required this.remainingYears,
    required this.totalYears,
    required this.contributionIndex,
    required this.wageAtRetire,
    required this.socialWageAtRetire,
    required this.accountAtRetire,
    required this.futureContributions,
    required this.basePension,
    required this.accountPension,
    required this.payoutMonths,
    required this.startBalance,
  });

  /// 已经缴费的年数。
  final double paidYears;

  /// 还要缴多少年。
  final int remainingYears;

  /// 退休时的总缴费年限（年）。
  final double totalYears;

  /// 平均缴费指数（本人缴费基数 ÷ 社平工资）。
  final double contributionIndex;

  /// 退休前的月缴费工资（元）。
  final double wageAtRetire;

  /// 退休时的上年度社平工资（元/月）。
  final double socialWageAtRetire;

  /// 退休时个人账户储存额（元）。
  final double accountAtRetire;

  /// 其中未来缴纳的本金（元），用来对比利息贡献。
  final double futureContributions;

  /// 基础养老金（元/月）。
  final double basePension;

  /// 个人账户养老金（元/月）。
  final double accountPension;

  /// 计发月数。
  final int payoutMonths;

  /// 测算起点的账户余额（元）。
  final double startBalance;

  /// 合计月养老金（元/月）。
  double get totalMonthly => basePension + accountPension;

  /// 替代率：养老金 ÷ 退休前工资。
  double get replacementRate =>
      wageAtRetire <= 0 ? 0 : totalMonthly / wageAtRetire;

  /// 账户里靠记账利率滚出来的部分（元）。
  double get accountInterest =>
      accountAtRetire - startBalance - futureContributions;
}

/// 测算养老金；输入非法（负值、退休年龄超出计发月数表、社平工资为 0）时返回 null。
///
/// 个人账户按**月**复利滚动：每月先计息，再存入当月个人缴费；
/// 缴费基数每年随社平工资增长率调整一次。
PensionResult? calculatePension(PensionInput input) {
  final months = pensionPayoutMonthsOf(input.retireAge);
  if (months == null) return null;
  if (input.age < 0 ||
      input.paidYears < 0 ||
      input.balance < 0 ||
      input.monthlyWage <= 0 ||
      input.socialAverageWage <= 0 ||
      input.personalRatePercent < 0 ||
      input.personalRatePercent > 100 ||
      input.accountRatePercent < -100 ||
      input.socialGrowthPercent < -100) {
    return null;
  }
  final retireAge = input.retireAge < input.age ? input.age : input.retireAge;
  final remainingYears = (retireAge - input.age).clamp(0, 80);
  final totalYears = input.paidYears + remainingYears;

  final growth = input.socialGrowthPercent / 100;
  final monthlyRate = input.accountRatePercent / 100 / 12;
  final personalRate = input.personalRatePercent / 100;

  var account = input.balance;
  var wage = input.monthlyWage;
  var contributions = 0.0;
  for (var month = 0; month < remainingYears * 12; month++) {
    // 满一年时缴费基数随社平工资一起涨
    if (month > 0 && month % 12 == 0) wage *= 1 + growth;
    account = account * (1 + monthlyRate) + wage * personalRate;
    contributions += wage * personalRate;
  }

  final socialWageAtRetire =
      input.socialAverageWage * _pow(1 + growth, remainingYears);
  final index = input.monthlyWage / input.socialAverageWage;
  final basePension = socialWageAtRetire * (1 + index) / 2 * totalYears * 0.01;
  final accountPension = account / months;

  return PensionResult(
    paidYears: input.paidYears,
    remainingYears: remainingYears,
    totalYears: totalYears,
    contributionIndex: index,
    wageAtRetire: wage,
    socialWageAtRetire: socialWageAtRetire,
    accountAtRetire: account,
    futureContributions: contributions,
    basePension: basePension,
    accountPension: accountPension,
    payoutMonths: months,
    startBalance: input.balance,
  );
}

/// 只支持整数次幂的快速幂，避免为一个 `pow` 引入 dart:math 的浮点差异。
double _pow(double base, int exponent) {
  var result = 1.0;
  var factor = base;
  var power = exponent;
  while (power > 0) {
    if (power.isOdd) result *= factor;
    factor *= factor;
    power >>= 1;
  }
  return result;
}
