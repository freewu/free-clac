import 'ast.dart';
import 'parser.dart';
import 'token.dart';

/// 把表达式渲染成 LaTeX 源码，供复制到 Markdown / 文档里使用。
///
/// ```dart
/// toLatex(Parser('sin(30) + sqrt(2)').parse()); // \sin\left(30\right) + \sqrt{2}
/// ```
String toLatex(Expr node) => _LatexWriter().write(node);

/// 直接把用户输入的表达式转成 LaTeX，解析失败时返回 null。
String? tryExpressionToLatex(String source) {
  final text = source.trim();
  if (text.isEmpty) return null;
  try {
    return toLatex(Parser(text).parse());
  } on CalcException {
    return null;
  }
}

/// 运算符优先级，用于决定要不要补括号（数字越大结合越紧）。
const int _precAdditive = 1;
const int _precMultiplicative = 2;
const int _precUnary = 3;
const int _precPower = 4;
const int _precAtom = 5;

/// 变量与常量的 LaTeX 写法。
const Map<String, String> _symbols = {
  'pi': r'\pi',
  'tau': r'\tau',
  'phi': r'\varphi',
  'e': 'e',
  'inf': r'\infty',
  'ans': r'\mathrm{ans}',
  'mem': r'\mathrm{mem}',
};

/// 一元函数 → LaTeX 命令。
const Map<String, String> _functionCommands = {
  'sin': r'\sin',
  'cos': r'\cos',
  'tan': r'\tan',
  'csc': r'\csc',
  'sec': r'\sec',
  'cot': r'\cot',
  'asin': r'\arcsin',
  'acos': r'\arccos',
  'atan': r'\arctan',
  'sinh': r'\sinh',
  'cosh': r'\cosh',
  'tanh': r'\tanh',
  'asinh': r'\operatorname{arsinh}',
  'acosh': r'\operatorname{arcosh}',
  'atanh': r'\operatorname{artanh}',
  'ln': r'\ln',
  'expm1': r'\operatorname{expm1}',
  'sign': r'\operatorname{sgn}',
  'trunc': r'\operatorname{trunc}',
  'frac': r'\operatorname{frac}',
  'sinc': r'\operatorname{sinc}',
  'deg': r'\operatorname{deg}',
  'rad': r'\operatorname{rad}',
  'rand': r'\operatorname{rand}',
};

class _LatexWriter {
  String write(Expr node) => _write(node);

  int _precedence(Expr node) {
    if (node is BinaryExpr) {
      switch (node.operator) {
        case '+':
        case '-':
          return _precAdditive;
        case '*':
        case '/':
        case '%':
          return _precMultiplicative;
        case '^':
          return _precPower;
      }
      return _precMultiplicative;
    }
    if (node is UnaryExpr) return _precUnary;
    if (node is PostfixExpr) return _precAtom;
    return _precAtom;
  }

  /// 子节点低于 [minPrecedence] 时补一对 `\left( ... \right)`。
  String _child(Expr node, int minPrecedence) {
    final latex = _write(node);
    if (_precedence(node) < minPrecedence) {
      return '\\left($latex\\right)';
    }
    return latex;
  }

  String _write(Expr node) {
    if (node is NumberExpr) return _number(node.value);
    if (node is ConstantExpr) return _symbol(node.name);
    if (node is VariableExpr) return _symbol(node.name);
    if (node is UnaryExpr) return _unary(node);
    if (node is PostfixExpr) return _postfix(node);
    if (node is BinaryExpr) return _binary(node);
    if (node is CallExpr) return _call(node);
    return node.toSource();
  }

  String _number(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      final text = value.toInt().toString();
      return text.startsWith('-') ? '\\left($text\\right)' : text;
    }
    final text = value.toString();
    return text.startsWith('-') ? '\\left($text\\right)' : text;
  }

  String _symbol(String name) {
    final symbol = _symbols[name.toLowerCase()];
    if (symbol != null) return symbol;
    if (name.length == 1) return name;
    return '\\mathrm{${_escape(name)}}';
  }

  String _escape(String text) =>
      text.replaceAll('_', r'\_').replaceAll('#', r'\#');

  String _unary(UnaryExpr node) {
    final operand = _child(node.operand, _precUnary);
    if (node.operator == '-') return '-$operand';
    return '+$operand';
  }

  String _postfix(PostfixExpr node) {
    final operand = _child(node.operand, _precAtom);
    if (node.operator == '!') return '$operand!';
    if (node.operator == '%') return '\\frac{$operand}{100}';
    return '$operand${_escape(node.operator)}';
  }

  String _binary(BinaryExpr node) {
    switch (node.operator) {
      case '+':
        return '${_child(node.left, _precAdditive)} + '
            '${_child(node.right, _precAdditive)}';
      case '-':
        return '${_child(node.left, _precAdditive)} - '
            '${_child(node.right, _precMultiplicative)}';
      case '*':
        return '${_child(node.left, _precMultiplicative)} \\cdot '
            '${_child(node.right, _precMultiplicative)}';
      case '/':
        return '\\frac{${_write(node.left)}}{${_write(node.right)}}';
      case '%':
        return '${_child(node.left, _precMultiplicative)} \\bmod '
            '${_child(node.right, _precMultiplicative)}';
      case '^':
        return '${_child(node.left, _precAtom)}^{${_write(node.right)}}';
    }
    return '${_child(node.left, _precMultiplicative)} '
        '${_escape(node.operator)} '
        '${_child(node.right, _precMultiplicative)}';
  }

  String _call(CallExpr node) {
    final name = node.name.toLowerCase();
    final args = node.arguments;

    if (_specialForm(name, args)) return _specialFormLatex(name, args);

    switch (name) {
      case 'sqrt':
        return '\\sqrt{${_write(args[0])}}';
      case 'cbrt':
        return '\\sqrt[3]{${_write(args[0])}}';
      case 'root':
        return '\\sqrt[${_write(args[1])}]{${_write(args[0])}}';
      case 'abs':
        return '\\left|${_write(args[0])}\\right|';
      case 'floor':
        return '\\left\\lfloor ${_write(args[0])} \\right\\rfloor';
      case 'ceil':
        return '\\left\\lceil ${_write(args[0])} \\right\\rceil';
      case 'exp':
        return 'e^{${_write(args[0])}}';
      case 'pow':
        return '${_child(args[0], _precAtom)}^{${_write(args[1])}}';
      case 'log':
        if (args.length == 1) return '\\log\\left(${_write(args[0])}\\right)';
        return '\\log_{${_write(args[1])}}\\left(${_write(args[0])}\\right)';
      case 'lg':
        return '\\log_{10}\\left(${_write(args[0])}\\right)';
      case 'log2':
        return '\\log_{2}\\left(${_write(args[0])}\\right)';
      case 'mod':
        return '${_child(args[0], _precMultiplicative)} \\bmod '
            '${_child(args[1], _precMultiplicative)}';
      case 'fact':
        return '${_child(args[0], _precAtom)}!';
      case 'gamma':
        return '\\Gamma\\left(${_write(args[0])}\\right)';
      case 'ncr':
        return '\\binom{${_write(args[0])}}{${_write(args[1])}}';
      case 'npr':
        return 'P\\left(${_write(args[0])}, ${_write(args[1])}\\right)';
      case 'avg':
        return '\\operatorname{avg}${_arguments(args)}';
      case 'hypot':
        return '\\operatorname{hypot}${_arguments(args)}';
      case 'gcd':
      case 'lcm':
      case 'min':
      case 'max':
      case 'randint':
      case 'atan2':
        return '\\operatorname{$name}${_arguments(args)}';
    }

    final command = _functionCommands[name];
    if (command != null) {
      if (args.length == 1) return '$command${_parenthesised(args[0])}';
      return '$command${_arguments(args)}';
    }
    return '\\operatorname{${_escape(name)}}${_arguments(args)}';
  }

  bool _specialForm(String name, List<Expr> args) {
    if (name == 'diff') return args.length == 3;
    if (name == 'sum' || name == 'prod' || name == 'integrate') {
      return args.length == 4;
    }
    return false;
  }

  String _specialFormLatex(String name, List<Expr> args) {
    final body = _write(args[0]);
    final variable = _write(args[1]);
    switch (name) {
      case 'sum':
        return '\\sum_{$variable=${_write(args[2])}}^{${_write(args[3])}} '
            '$body';
      case 'prod':
        return '\\prod_{$variable=${_write(args[2])}}^{${_write(args[3])}} '
            '$body';
      case 'integrate':
        return '\\int_{${_write(args[2])}}^{${_write(args[3])}} '
            '$body\\,d$variable';
      case 'diff':
        return '\\left.\\frac{d}{d$variable}\\left($body\\right)'
            '\\right|_{$variable=${_write(args[2])}}';
    }
    return body;
  }

  String _parenthesised(Expr node) => '\\left(${_write(node)}\\right)';

  String _arguments(List<Expr> args) =>
      '\\left(${args.map(_write).join(', ')}\\right)';
}
