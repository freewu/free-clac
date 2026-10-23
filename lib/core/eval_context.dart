import 'dart:math' as math;

import 'angle_mode.dart';

/// 求值上下文：保存变量表、角度模式和随机数发生器。
///
/// 同一个上下文可以在多次求值之间复用（例如 `ans` 变量、绘图时传入 `x`）。
class EvalContext {
  EvalContext({
    this.angleMode = AngleMode.radians,
    Map<String, double>? variables,
    math.Random? random,
  }) : variables = variables ?? <String, double>{},
       random = random ?? math.Random();

  AngleMode angleMode;
  final Map<String, double> variables;
  final math.Random random;

  /// 递归深度，用于防止 `sum(sum(...))` 之类的滥用导致栈溢出。
  int depth = 0;

  static const int maxDepth = 64;

  double? lookup(String name) => variables[name];

  void bind(String name, double value) => variables[name] = value;

  EvalContext copy() => EvalContext(
    angleMode: angleMode,
    variables: Map<String, double>.from(variables),
    random: random,
  );
}
