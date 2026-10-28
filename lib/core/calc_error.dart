import 'template.dart';

/// 计算错误的种类。
///
/// [template] 是简体中文模板，`lib/l10n/calc_errors.dart` 里按 [CalcError]
/// 给出其它语言的模板；界面显示走 `calcErrorMessage()`，这里的中文只作兜底
/// 与测试断言用。带参数的模板写成 `{0}` / `{1}` 占位符。
enum CalcError {
  // ---- 词法
  unknownChar('无法识别的字符 "{0}"'),
  invalidNumber('无效的数字 "{0}"'),

  // ---- 语法
  emptyExpression('表达式不能为空'),
  trailingInput('多余的输入 "{0}"'),
  missingRParen('缺少右括号 ")"'),
  extraRParen('多余的右括号 ")"'),
  misplacedOperator('运算符 "{0}" 位置不正确'),
  misplacedComma('逗号位置不正确'),
  incompleteExpression('表达式不完整'),
  unparsable('无法解析 "{0}"'),
  functionNeedsParens('函数 {0} 需要括号，例如 {1}'),
  functionMissingRParen('函数 {0} 缺少右括号 ")"'),
  functionArgCount('函数 {0} 的参数个数不正确，用法：{1}'),
  specialArgCount('特殊函数 {0} 的参数个数不正确'),

  // ---- 求值
  nesting('表达式嵌套层数过多'),
  undefinedVariable('未定义变量 "{0}"'),
  undefinedFunction('未定义的函数 "{0}"'),
  unknownPostfix('未知的后缀运算符 "{0}"'),
  unknownOperator('未知的运算符 "{0}"'),
  notEvaluable('无法求值的表达式'),
  sumTooMany('求和/求积的项数过多（上限 1000000）'),
  integralBounds('积分上下限必须是有限值'),
  integralUndefined('积分区间内函数无定义'),
  derivativeUndefined('该点导数不存在或无法计算'),
  secondArgVariable('第二个参数必须是变量名，例如 sum(k^2, k, 1, 10)'),

  // ---- 内置函数
  logBase('对数的底数必须大于 0 且不等于 1'),
  rootDegree('方根次数不能为 0'),
  randintRange('randint 的区间无效'),

  // ---- 其它
  generic('计算失败：{0}');

  const CalcError(this.template);

  /// 简体中文模板。
  final String template;
}

/// 计算过程中的异常，携带出错位置与模板参数，便于在 UI 中本地化显示。
class CalcException implements Exception {
  const CalcException(
    this.code, {
    this.position,
    this.args = const <Object?>[],
  });

  final CalcError code;

  /// 出错位置（0 基字符下标）。
  final int? position;

  /// [CalcError.template] 的占位符参数。
  final List<Object?> args;

  /// 简体中文消息（数据层兜底，界面请用 `calcErrorMessage()`）。
  String get message => fill(code.template, args);

  @override
  String toString() =>
      position == null ? message : '$message（位置 ${position! + 1}）';
}
