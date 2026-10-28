import 'ast.dart';
import 'builtins.dart';
import 'lexer.dart';
import 'token.dart';

/// 递归下降语法分析器。
///
/// 优先级（从低到高）：
/// ```text
/// 加法/减法   + -
/// 乘法/除法   * / %        （含隐式乘法 2x、(1+2)(3+4)）
/// 一元        +x -x
/// 幂          ^            （右结合，2^3^2 = 2^(3^2)）
/// 后缀        ! %          （阶乘、百分号）
/// 原子        数字 常量 变量 函数调用 (表达式)
/// ```
class Parser {
  Parser(String source) : _tokens = Lexer(source).tokenize();

  final List<Token> _tokens;
  int _index = 0;

  Expr parse() {
    if (_peek.isEnd) {
      throw CalcException(CalcError.emptyExpression);
    }
    final expression = _parseAdditive();
    if (!_peek.isEnd) {
      throw CalcException(
        CalcError.trailingInput,
        position: _peek.start,
        args: [_peek.lexeme],
      );
    }
    return expression;
  }

  Token get _peek => _tokens[_index];

  Token get _peekNext =>
      _index + 1 < _tokens.length ? _tokens[_index + 1] : _tokens.last;

  Token _advance() => _tokens[_index++];

  // ---------------- 层叠的优先级 ----------------

  Expr _parseAdditive() {
    var left = _parseMultiplicative();
    while (_peek.type == TokenType.operator &&
        (_peek.lexeme == '+' || _peek.lexeme == '-')) {
      final operator = _advance().lexeme;
      final right = _parseMultiplicative();
      left = BinaryExpr(operator, left, right);
    }
    return left;
  }

  Expr _parseMultiplicative() {
    var left = _parseUnary();
    while (true) {
      if (_peek.type == TokenType.operator &&
          (_peek.lexeme == '*' || _peek.lexeme == '/')) {
        final operator = _advance().lexeme;
        final right = _parseUnary();
        left = BinaryExpr(operator, left, right);
        continue;
      }
      if (_peek.type == TokenType.operator && _peek.lexeme == '%') {
        // `10 % 3` 是取模运算，`50%` 是百分号后缀（已在 _parsePostfix 处理）
        if (_startsValue(_peekNext)) {
          _advance();
          final right = _parseUnary();
          left = BinaryExpr('%', left, right);
          continue;
        }
        // 百分号作为后缀（50%）会在 _parsePostfix 中处理
        break;
      }
      if (_startsImplicitOperand(_peek)) {
        // 隐式乘法：2x、3sin(x)、2(3+4)、(x+1)(x-1)
        // 两个数字紧挨着（如 `1.2.3`）视为输入错误，不当作乘法。
        final right = _parseUnary();
        left = BinaryExpr('*', left, right, implicit: true);
        continue;
      }
      break;
    }
    return left;
  }

  Expr _parseUnary() {
    if (_peek.type == TokenType.operator &&
        (_peek.lexeme == '+' || _peek.lexeme == '-')) {
      final operator = _advance().lexeme;
      final operand = _parseUnary();
      return UnaryExpr(operator, operand);
    }
    return _parsePower();
  }

  Expr _parsePower() {
    final base = _parsePostfix();
    if (_peek.type == TokenType.operator && _peek.lexeme == '^') {
      _advance();
      final exponent = _parseUnary(); // 右结合，且允许 2^-3
      return BinaryExpr('^', base, exponent);
    }
    return base;
  }

  Expr _parsePostfix() {
    var expression = _parsePrimary();
    while (_peek.type == TokenType.operator) {
      if (_peek.lexeme == '!') {
        _advance();
        expression = PostfixExpr(expression, '!');
        continue;
      }
      if (_peek.lexeme == '%' && !_startsValue(_peekNext)) {
        _advance();
        expression = PostfixExpr(expression, '%');
        continue;
      }
      break;
    }
    return expression;
  }

  Expr _parsePrimary() {
    final token = _peek;
    switch (token.type) {
      case TokenType.number:
        _advance();
        return NumberExpr(token.value!);
      case TokenType.lparen:
        _advance();
        final inner = _parseAdditive();
        if (_peek.type != TokenType.rparen) {
          throw CalcException(CalcError.missingRParen, position: _peek.start);
        }
        _advance();
        return inner;
      case TokenType.identifier:
        return _parseIdentifier();
      case TokenType.operator:
        if (token.lexeme == ')') {
          throw CalcException(CalcError.extraRParen, position: token.start);
        }
        throw CalcException(
          CalcError.misplacedOperator,
          position: token.start,
          args: [token.lexeme],
        );
      case TokenType.comma:
        throw CalcException(CalcError.misplacedComma, position: token.start);
      case TokenType.end:
        throw CalcException(
          CalcError.incompleteExpression,
          position: token.start,
        );
      default:
        throw CalcException(
          CalcError.unparsable,
          position: token.start,
          args: [token.lexeme],
        );
    }
  }

  Expr _parseIdentifier() {
    final token = _advance();
    final rawName = token.lexeme;
    final name = rawName.toLowerCase();

    // 函数调用：sin(x)、log(x, 2)、integrate(x^2, x, 0, 1)
    if (isBuiltinFunction(name)) {
      if (_peek.type != TokenType.lparen) {
        // 允许省略括号的一元函数：sin 30、ln 2
        final function = builtinFunctions[name];
        if (function != null && function.maxArgs == 1) {
          final argument = _parsePower();
          return CallExpr(name, [argument]);
        }
        throw CalcException(
          CalcError.functionNeedsParens,
          position: token.start,
          args: [name, _signatureOf(name)],
        );
      }
      _advance(); // 吃掉 '('
      final arguments = <Expr>[];
      if (_peek.type != TokenType.rparen) {
        arguments.add(_parseAdditive());
        while (_peek.type == TokenType.comma) {
          _advance();
          arguments.add(_parseAdditive());
        }
      }
      if (_peek.type != TokenType.rparen) {
        throw CalcException(
          CalcError.functionMissingRParen,
          position: _peek.start,
          args: [name],
        );
      }
      _advance();
      final function = builtinFunctions[name];
      if (function != null && !function.acceptsArity(arguments.length)) {
        throw CalcException(
          CalcError.functionArgCount,
          position: token.start,
          args: [name, function.signature],
        );
      }
      if (function == null && !_hasSpecialArity(name, arguments.length)) {
        throw CalcException(
          CalcError.specialArgCount,
          position: token.start,
          args: [name],
        );
      }
      return CallExpr(name, arguments);
    }

    final constant = builtinConstants[name];
    if (constant != null) {
      return ConstantExpr(name, constant.value);
    }

    // 变量：x、y、n、ans、mem ……
    return VariableExpr(rawName);
  }

  bool _hasSpecialArity(String name, int count) {
    switch (name) {
      case 'sum':
      case 'prod':
      case 'integrate':
        return count == 4;
      case 'diff':
        return count == 3;
    }
    return false;
  }

  String _signatureOf(String name) {
    final function = builtinFunctions[name];
    if (function != null) return function.signature;
    switch (name) {
      case 'sum':
        return 'sum(表达式, 变量, 起始, 结束)';
      case 'prod':
        return 'prod(表达式, 变量, 起始, 结束)';
      case 'integrate':
        return 'integrate(表达式, 变量, 下限, 上限)';
      case 'diff':
        return 'diff(表达式, 变量, 取值点)';
    }
    return '$name(...)';
  }

  static bool _startsImplicitOperand(Token token) =>
      token.type == TokenType.identifier || token.type == TokenType.lparen;

  static bool _startsValue(Token token) {
    switch (token.type) {
      case TokenType.number:
      case TokenType.identifier:
      case TokenType.lparen:
        return true;
      default:
        return false;
    }
  }
}
