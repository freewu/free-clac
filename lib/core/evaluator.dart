import 'dart:math' as math;

import 'ast.dart';
import 'builtins.dart';
import 'eval_context.dart';
import 'token.dart';

/// AST 求值器。
class Evaluator {
  const Evaluator();

  double evaluate(Expr expression, EvalContext context) {
    if (context.depth > EvalContext.maxDepth) {
      throw CalcException('表达式嵌套层数过多');
    }
    context.depth++;
    try {
      return _evaluate(expression, context);
    } finally {
      context.depth--;
    }
  }

  double _evaluate(Expr expression, EvalContext context) {
    if (expression is NumberExpr) return expression.value;
    if (expression is ConstantExpr) return expression.value;
    if (expression is VariableExpr) {
      final name = expression.name;
      final value =
          context.lookup(name) ??
          context.lookup(name.toLowerCase()) ??
          context.lookup(name.toUpperCase());
      if (value == null) {
        throw CalcException('未定义变量 "$name"');
      }
      return value;
    }
    if (expression is UnaryExpr) {
      final value = _evaluate(expression.operand, context);
      return expression.operator == '-' ? -value : value;
    }
    if (expression is PostfixExpr) {
      final value = _evaluate(expression.operand, context);
      switch (expression.operator) {
        case '!':
          return _factorial(value);
        case '%':
          return value / 100;
      }
      throw CalcException('未知的后缀运算符 "${expression.operator}"');
    }
    if (expression is BinaryExpr) {
      final left = _evaluate(expression.left, context);
      final right = _evaluate(expression.right, context);
      switch (expression.operator) {
        case '+':
          return left + right;
        case '-':
          return left - right;
        case '*':
          return left * right;
        case '/':
          return left / right;
        case '%':
          return left % right;
        case '^':
          return math.pow(left, right).toDouble();
      }
      throw CalcException('未知的运算符 "${expression.operator}"');
    }
    if (expression is CallExpr) {
      return _call(expression, context);
    }
    throw CalcException('无法求值的表达式');
  }

  double _call(CallExpr expression, EvalContext context) {
    final name = expression.name.toLowerCase();
    switch (name) {
      case 'sum':
        return _reduceRange(expression.arguments, context, isProduct: false);
      case 'prod':
        return _reduceRange(expression.arguments, context, isProduct: true);
      case 'integrate':
        return _integrate(expression.arguments, context);
      case 'diff':
        return _differentiate(expression.arguments, context);
    }

    final function = builtinFunctions[name];
    if (function == null) {
      throw CalcException('未定义的函数 "$name"');
    }
    final arguments = <double>[
      for (final argument in expression.arguments) _evaluate(argument, context),
    ];
    final value = function.body(arguments, context);
    return value;
  }

  /// `sum(expr, k, from, to)` / `prod(expr, k, from, to)`
  double _reduceRange(
    List<Expr> arguments,
    EvalContext context, {
    required bool isProduct,
  }) {
    final body = arguments[0];
    final variable = _requireVariable(arguments[1]);
    final start = _evaluate(arguments[2], context);
    final end = _evaluate(arguments[3], context);
    if (start.isNaN || end.isNaN) return double.nan;
    final from = start.ceil();
    final to = end.floor();
    if (to - from > 1000000) {
      throw CalcException('求和/求积的项数过多（上限 1000000）');
    }
    final previous = context.variables[variable];
    var accumulator = isProduct ? 1.0 : 0.0;
    try {
      for (var index = from; index <= to; index++) {
        context.variables[variable] = index.toDouble();
        final value = _evaluate(body, context);
        if (isProduct) {
          accumulator *= value;
        } else {
          accumulator += value;
        }
      }
    } finally {
      _restore(context, variable, previous);
    }
    return accumulator;
  }

  /// `integrate(expr, x, a, b)` —— 自适应 Simpson 数值积分。
  double _integrate(List<Expr> arguments, EvalContext context) {
    final body = arguments[0];
    final variable = _requireVariable(arguments[1]);
    final lower = _evaluate(arguments[2], context);
    final upper = _evaluate(arguments[3], context);
    if (!lower.isFinite || !upper.isFinite) {
      throw CalcException('积分上下限必须是有限值');
    }
    if (lower == upper) return 0;

    final previous = context.variables[variable];
    double f(double x) {
      context.variables[variable] = x;
      try {
        return _evaluate(body, context);
      } catch (_) {
        return double.nan;
      }
    }

    try {
      final sign = upper > lower ? 1.0 : -1.0;
      final a = math.min(lower, upper);
      final b = math.max(lower, upper);
      final epsilon = 1e-10 * math.max(1.0, (b - a));
      final fa = f(a);
      final fb = f(b);
      final middle = (a + b) / 2;
      final fm = f(middle);
      if (!fa.isFinite || !fb.isFinite || !fm.isFinite) {
        throw CalcException('积分区间内函数无定义');
      }
      final whole = (b - a) / 6 * (fa + 4 * fm + fb);
      return sign * _adaptiveSimpson(f, a, b, fa, fm, fb, whole, epsilon, 24);
    } finally {
      _restore(context, variable, previous);
    }
  }

  double _adaptiveSimpson(
    double Function(double) f,
    double a,
    double b,
    double fa,
    double fm,
    double fb,
    double whole,
    double epsilon,
    int depth,
  ) {
    final middle = (a + b) / 2;
    final leftMiddle = (a + middle) / 2;
    final rightMiddle = (middle + b) / 2;
    final flm = f(leftMiddle);
    final frm = f(rightMiddle);
    final left = (middle - a) / 6 * (fa + 4 * flm + fm);
    final right = (b - middle) / 6 * (fm + 4 * frm + fb);
    final delta = left + right - whole;

    if (depth <= 0 || delta.abs() <= 15 * epsilon) {
      return left + right + delta / 15;
    }
    return _adaptiveSimpson(
          f,
          a,
          middle,
          fa,
          flm,
          fm,
          left,
          epsilon / 2,
          depth - 1,
        ) +
        _adaptiveSimpson(
          f,
          middle,
          b,
          fm,
          frm,
          fb,
          right,
          epsilon / 2,
          depth - 1,
        );
  }

  /// `diff(expr, x, at)` —— 数值导数（中心差分 + Richardson 外推）。
  double _differentiate(List<Expr> arguments, EvalContext context) {
    final body = arguments[0];
    final variable = _requireVariable(arguments[1]);
    final at = _evaluate(arguments[2], context);
    final previous = context.variables[variable];
    double f(double x) {
      context.variables[variable] = x;
      try {
        return _evaluate(body, context);
      } catch (_) {
        return double.nan;
      }
    }

    try {
      final h = 1e-5 * math.max(1.0, at.abs());
      final d1 = (f(at + h) - f(at - h)) / (2 * h);
      final d2 = (f(at + h / 2) - f(at - h / 2)) / h;
      final result = (4 * d2 - d1) / 3;
      if (!result.isFinite) {
        throw CalcException('该点导数不存在或无法计算');
      }
      return result;
    } finally {
      _restore(context, variable, previous);
    }
  }

  String _requireVariable(Expr expression) {
    if (expression is VariableExpr) return expression.name;
    throw CalcException('第二个参数必须是变量名，例如 sum(k^2, k, 1, 10)');
  }

  void _restore(EvalContext context, String name, double? previous) {
    if (previous == null) {
      context.variables.remove(name);
    } else {
      context.variables[name] = previous;
    }
  }

  double _factorial(double value) {
    if (value < 0 || value != value.roundToDouble()) {
      // n! = Γ(n+1)
      return _gamma(value + 1);
    }
    final n = value.toInt();
    if (n > 170) return double.infinity;
    var result = 1.0;
    for (var i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  double _gamma(double x) {
    const coefficients = <double>[
      0.99999999999980993,
      676.5203681218851,
      -1259.1392167224028,
      771.32342877765313,
      -176.61502916214059,
      12.507343278686905,
      -0.13857109526572012,
      9.9843695780195716e-6,
      1.5056327351493116e-7,
    ];
    if (x < 0.5) {
      return math.pi / (math.sin(math.pi * x) * _gamma(1 - x));
    }
    final z = x - 1;
    var a = coefficients[0];
    final t = z + 7.5;
    for (var i = 1; i < coefficients.length; i++) {
      a += coefficients[i] / (z + i);
    }
    return math.sqrt(2 * math.pi) * math.pow(t, z + 0.5) * math.exp(-t) * a;
  }
}
