import 'dart:math' as math;

import 'eval_context.dart';
import 'token.dart';

/// 内置函数签名。
typedef CalcFunction = double Function(List<double> args, EvalContext ctx);

class BuiltinFunction {
  const BuiltinFunction({
    required this.signature,
    required this.description,
    required this.body,
    this.minArgs = 1,
    this.maxArgs = 1,
  });

  /// 例如 `sin(x)` / `log(x, base)`。
  final String signature;
  final String description;
  final CalcFunction body;
  final int minArgs;
  final int maxArgs;

  bool acceptsArity(int count) => count >= minArgs && count <= maxArgs;
}

class BuiltinConstant {
  const BuiltinConstant(this.name, this.value, this.description);

  final String name;
  final double value;
  final String description;
}

const double _pi = math.pi;

double _factorial(double value) {
  if (value < 0 || value != value.roundToDouble()) {
    // 非整数使用 Gamma 函数延拓：n! = Γ(n + 1)
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

/// Lanczos 近似（g = 7，n = 9），精度约 1e-13。
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
    // 反射公式：Γ(x)Γ(1-x) = π / sin(πx)
    return _pi / (math.sin(_pi * x) * _gamma(1 - x));
  }

  final z = x - 1;
  var a = coefficients[0];
  final t = z + 7.5;
  for (var i = 1; i < coefficients.length; i++) {
    a += coefficients[i] / (z + i);
  }
  return math.sqrt(2 * _pi) * math.pow(t, z + 0.5) * math.exp(-t) * a;
}

double _logBase(double value, double base) {
  if (base <= 0 || base == 1) {
    throw const CalcException(CalcError.logBase);
  }
  return math.log(value) / math.log(base);
}

double _round2(double value, int digits) {
  final factor = math.pow(10, digits).toDouble();
  return (value * factor).roundToDouble() / factor;
}

final Map<String, BuiltinFunction> builtinFunctions = {
  // ---------- 三角 ----------
  'sin': BuiltinFunction(
    signature: 'sin(x)',
    description: '正弦',
    body: (args, ctx) => math.sin(ctx.angleMode.toRadians(args[0])),
  ),
  'cos': BuiltinFunction(
    signature: 'cos(x)',
    description: '余弦',
    body: (args, ctx) => math.cos(ctx.angleMode.toRadians(args[0])),
  ),
  'tan': BuiltinFunction(
    signature: 'tan(x)',
    description: '正切',
    body: (args, ctx) => math.tan(ctx.angleMode.toRadians(args[0])),
  ),
  'csc': BuiltinFunction(
    signature: 'csc(x)',
    description: '余割',
    body: (args, ctx) => 1 / math.sin(ctx.angleMode.toRadians(args[0])),
  ),
  'sec': BuiltinFunction(
    signature: 'sec(x)',
    description: '正割',
    body: (args, ctx) => 1 / math.cos(ctx.angleMode.toRadians(args[0])),
  ),
  'cot': BuiltinFunction(
    signature: 'cot(x)',
    description: '余切',
    body: (args, ctx) => 1 / math.tan(ctx.angleMode.toRadians(args[0])),
  ),
  'asin': BuiltinFunction(
    signature: 'asin(x)',
    description: '反正弦',
    body: (args, ctx) => ctx.angleMode.fromRadians(math.asin(args[0])),
  ),
  'acos': BuiltinFunction(
    signature: 'acos(x)',
    description: '反余弦',
    body: (args, ctx) => ctx.angleMode.fromRadians(math.acos(args[0])),
  ),
  'atan': BuiltinFunction(
    signature: 'atan(x)',
    description: '反正切',
    body: (args, ctx) => ctx.angleMode.fromRadians(math.atan(args[0])),
  ),
  'atan2': BuiltinFunction(
    signature: 'atan2(y, x)',
    description: '两参数反正切（返回象限角）',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) =>
        ctx.angleMode.fromRadians(math.atan2(args[0], args[1])),
  ),

  // ---------- 双曲 ----------
  'sinh': BuiltinFunction(
    signature: 'sinh(x)',
    description: '双曲正弦',
    body: (args, ctx) => _sinh(args[0]),
  ),
  'cosh': BuiltinFunction(
    signature: 'cosh(x)',
    description: '双曲余弦',
    body: (args, ctx) => _cosh(args[0]),
  ),
  'tanh': BuiltinFunction(
    signature: 'tanh(x)',
    description: '双曲正切',
    body: (args, ctx) => _sinh(args[0]) / _cosh(args[0]),
  ),
  'asinh': BuiltinFunction(
    signature: 'asinh(x)',
    description: '反双曲正弦',
    body: (args, ctx) => _asinh(args[0]),
  ),
  'acosh': BuiltinFunction(
    signature: 'acosh(x)',
    description: '反双曲余弦',
    body: (args, ctx) => _acosh(args[0]),
  ),
  'atanh': BuiltinFunction(
    signature: 'atanh(x)',
    description: '反双曲正切',
    body: (args, ctx) => _atanh(args[0]),
  ),

  // ---------- 指数 / 对数 ----------
  'exp': BuiltinFunction(
    signature: 'exp(x)',
    description: 'e 的 x 次幂',
    body: (args, ctx) => math.exp(args[0]),
  ),
  'ln': BuiltinFunction(
    signature: 'ln(x)',
    description: '自然对数',
    body: (args, ctx) => math.log(args[0]),
  ),
  'log': BuiltinFunction(
    signature: 'log(x[, base])',
    description: '常用对数（默认底 10）',
    maxArgs: 2,
    body: (args, ctx) =>
        args.length == 1 ? _logBase(args[0], 10) : _logBase(args[0], args[1]),
  ),
  'lg': BuiltinFunction(
    signature: 'lg(x)',
    description: '常用对数（底 10）',
    body: (args, ctx) => _logBase(args[0], 10),
  ),
  'log2': BuiltinFunction(
    signature: 'log2(x)',
    description: '以 2 为底的对数',
    body: (args, ctx) => _logBase(args[0], 2),
  ),
  'expm1': BuiltinFunction(
    signature: 'expm1(x)',
    description: 'exp(x) − 1（小 x 时更精确）',
    body: (args, ctx) {
      final x = args[0];
      if (x.abs() < 1e-5) return x + x * x / 2 + x * x * x / 6;
      return math.exp(x) - 1;
    },
  ),

  // ---------- 幂 / 根 ----------
  'sqrt': BuiltinFunction(
    signature: 'sqrt(x)',
    description: '平方根',
    body: (args, ctx) => math.sqrt(args[0]),
  ),
  'cbrt': BuiltinFunction(
    signature: 'cbrt(x)',
    description: '立方根',
    body: (args, ctx) => _cbrt(args[0]),
  ),
  'root': BuiltinFunction(
    signature: 'root(x, n)',
    description: 'n 次方根',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) {
      final value = args[0];
      final n = args[1];
      if (n == 0) throw const CalcException(CalcError.rootDegree);
      if (value < 0 && n == n.roundToDouble() && n.toInt() % 2 != 0) {
        return -math.pow(-value, 1 / n).toDouble();
      }
      return math.pow(value, 1 / n).toDouble();
    },
  ),
  'hypot': BuiltinFunction(
    signature: 'hypot(x, y)',
    description: '直角三角形斜边 √(x²+y²)',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) => math.sqrt(args[0] * args[0] + args[1] * args[1]),
  ),

  // ---------- 取整 / 符号 ----------
  'abs': BuiltinFunction(
    signature: 'abs(x)',
    description: '绝对值',
    body: (args, ctx) => args[0].abs(),
  ),
  'sign': BuiltinFunction(
    signature: 'sign(x)',
    description: '符号函数（−1 / 0 / 1）',
    body: (args, ctx) => args[0] == 0 ? 0 : (args[0] > 0 ? 1 : -1),
  ),
  'floor': BuiltinFunction(
    signature: 'floor(x)',
    description: '向下取整',
    body: (args, ctx) => args[0].floorToDouble(),
  ),
  'ceil': BuiltinFunction(
    signature: 'ceil(x)',
    description: '向上取整',
    body: (args, ctx) => args[0].ceilToDouble(),
  ),
  'round': BuiltinFunction(
    signature: 'round(x[, digits])',
    description: '四舍五入（可选小数位）',
    maxArgs: 2,
    body: (args, ctx) => args.length == 1
        ? (args[0] < 0
              ? -((-args[0] + 0.5).floorToDouble())
              : (args[0] + 0.5).floorToDouble())
        : _round2(args[0], args[1].toInt()),
  ),
  'trunc': BuiltinFunction(
    signature: 'trunc(x)',
    description: '截断取整',
    body: (args, ctx) => args[0].truncateToDouble(),
  ),
  'frac': BuiltinFunction(
    signature: 'frac(x)',
    description: '小数部分',
    body: (args, ctx) => args[0] - args[0].truncateToDouble(),
  ),
  'mod': BuiltinFunction(
    signature: 'mod(a, b)',
    description: '取余（结果符号随除数）',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) => args[0] % args[1],
  ),

  // ---------- 组合 / 统计 ----------
  'fact': BuiltinFunction(
    signature: 'fact(n)',
    description: '阶乘',
    body: (args, ctx) => _factorial(args[0]),
  ),
  'gamma': BuiltinFunction(
    signature: 'gamma(x)',
    description: 'Gamma 函数 Γ(x)',
    body: (args, ctx) => _gamma(args[0]),
  ),
  'ncr': BuiltinFunction(
    signature: 'ncr(n, r)',
    description: '组合数 C(n, r)',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) => _combinations(args[0], args[1]),
  ),
  'npr': BuiltinFunction(
    signature: 'npr(n, r)',
    description: '排列数 P(n, r)',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) {
      final n = args[0];
      final r = args[1];
      if (r < 0 || r > n) return 0;
      var result = 1.0;
      for (var i = 0; i < r.round(); i++) {
        result *= n - i;
      }
      return result;
    },
  ),
  'gcd': BuiltinFunction(
    signature: 'gcd(a, b)',
    description: '最大公约数',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) => _gcd(args[0].round(), args[1].round()).toDouble(),
  ),
  'lcm': BuiltinFunction(
    signature: 'lcm(a, b)',
    description: '最小公倍数',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) {
      final a = args[0].round();
      final b = args[1].round();
      if (a == 0 || b == 0) return 0;
      return ((a * b).abs() ~/ _gcd(a, b)).toDouble();
    },
  ),
  'min': BuiltinFunction(
    signature: 'min(a, b, ...)',
    description: '最小值',
    minArgs: 1,
    maxArgs: 32,
    body: (args, ctx) => args.reduce(math.min),
  ),
  'max': BuiltinFunction(
    signature: 'max(a, b, ...)',
    description: '最大值',
    minArgs: 1,
    maxArgs: 32,
    body: (args, ctx) => args.reduce(math.max),
  ),
  'avg': BuiltinFunction(
    signature: 'avg(a, b, ...)',
    description: '平均值',
    minArgs: 1,
    maxArgs: 32,
    body: (args, ctx) =>
        args.fold<double>(0, (sum, value) => sum + value) / args.length,
  ),

  // ---------- 单位转换 / 其它 ----------
  'deg': BuiltinFunction(
    signature: 'deg(rad)',
    description: '弧度 → 角度',
    body: (args, ctx) => args[0] * 180 / _pi,
  ),
  'rad': BuiltinFunction(
    signature: 'rad(deg)',
    description: '角度 → 弧度',
    body: (args, ctx) => args[0] * _pi / 180,
  ),
  'sinc': BuiltinFunction(
    signature: 'sinc(x)',
    description: '归一化 sinc：sin(x)/x',
    body: (args, ctx) {
      final x = ctx.angleMode.toRadians(args[0]);
      return x == 0 ? 1 : math.sin(x) / x;
    },
  ),
  'rand': BuiltinFunction(
    signature: 'rand()',
    description: '[0, 1) 均匀随机数',
    minArgs: 0,
    maxArgs: 0,
    body: (args, ctx) => ctx.random.nextDouble(),
  ),
  'randint': BuiltinFunction(
    signature: 'randint(a, b)',
    description: '[a, b] 随机整数',
    minArgs: 2,
    maxArgs: 2,
    body: (args, ctx) {
      final low = args[0].ceil();
      final high = args[1].floor();
      if (high < low) throw const CalcException(CalcError.randintRange);
      return (low + ctx.random.nextInt(high - low + 1)).toDouble();
    },
  ),
};

/// 需要“延迟求值”的特殊形式：表达式作为参数传入，而非先求值。
const Set<String> specialFormNames = {'sum', 'prod', 'integrate', 'diff'};

final Map<String, BuiltinConstant> builtinConstants = {
  'pi': const BuiltinConstant('pi', _pi, '圆周率 π'),
  'e': const BuiltinConstant('e', math.e, '自然常数 e'),
  'tau': const BuiltinConstant('tau', 2 * _pi, 'τ = 2π'),
  'phi': const BuiltinConstant('phi', 1.618033988749895, '黄金比例 φ = (1+√5)/2'),
  'inf': const BuiltinConstant('inf', double.infinity, '无穷大'),
};

bool isBuiltinFunction(String name) =>
    builtinFunctions.containsKey(name) || specialFormNames.contains(name);

bool isBuiltinConstant(String name) => builtinConstants.containsKey(name);

double _sinh(double x) {
  if (x.abs() > 20) return math.exp(x.abs()) / 2 * (x > 0 ? 1 : -1);
  return (math.exp(x) - math.exp(-x)) / 2;
}

double _cosh(double x) {
  if (x.abs() > 20) return math.exp(x.abs()) / 2;
  return (math.exp(x) + math.exp(-x)) / 2;
}

double _asinh(double x) => math.log(x + math.sqrt(x * x + 1));

double _acosh(double x) => math.log(x + math.sqrt(x * x - 1));

double _atanh(double x) => math.log((1 + x) / (1 - x)) / 2;

double _cbrt(double x) =>
    x < 0 ? -math.pow(-x, 1 / 3).toDouble() : math.pow(x, 1 / 3).toDouble();

double _combinations(double n, double r) {
  if (r < 0 || r > n) return 0;
  final k = math.min(r, n - r);
  var result = 1.0;
  for (var i = 0; i < k.round(); i++) {
    result = result * (n - i) / (i + 1);
  }
  return result;
}

int _gcd(int a, int b) {
  var x = a.abs();
  var y = b.abs();
  while (y != 0) {
    final temp = y;
    y = x % y;
    x = temp;
  }
  return x;
}
