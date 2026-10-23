/// 词法分析器：把表达式字符串切分成 token 序列。
///
/// 支持：
///  * 十进制 / 科学计数法数字：`3`, `3.14`, `1.2e-5`, `.5`
///  * 标识符（函数名、常量名、变量名）：`sin`, `pi`, `x1`, `_tmp`
///  * 运算符：`+ - * / ^ % !`
///  * 分组符：`( ) ,`
///  * 常见的 Unicode 数学符号：`× ÷ − π τ φ √ ² ³`
library;

import 'token.dart';

class Lexer {
  Lexer(String source) : _src = _normalize(source);

  final String _src;
  int _pos = 0;

  static const Map<String, String> _unicodeReplacements = {
    '×': '*',
    '·': '*',
    '⋅': '*',
    '÷': '/',
    '−': '-',
    '–': '-',
    '—': '-',
    '（': '(',
    '）': ')',
    '，': ',',
    'π': 'pi',
    'τ': 'tau',
    'φ': 'phi',
    '√': 'sqrt',
    '∞': 'inf',
  };

  static String _normalize(String source) {
    var result = source;
    _unicodeReplacements.forEach((from, to) {
      result = result.replaceAll(from, to);
    });
    // 上标数字转换成幂运算：x² -> x^2
    const superscripts = {
      '⁰': '0',
      '¹': '1',
      '²': '2',
      '³': '3',
      '⁴': '4',
      '⁵': '5',
      '⁶': '6',
      '⁷': '7',
      '⁸': '8',
      '⁹': '9',
    };
    superscripts.forEach((from, to) {
      result = result.replaceAll(from, '^$to');
    });
    return result;
  }

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (true) {
      _skipWhitespace();
      if (_pos >= _src.length) {
        tokens.add(Token(TokenType.end, '', _pos, _pos));
        return tokens;
      }
      final start = _pos;
      final char = _src[_pos];

      if (_isDigit(char) || (char == '.' && _isDigit(_peek(1)))) {
        tokens.add(_readNumber(start));
        continue;
      }
      if (_isIdentifierStart(char)) {
        tokens.add(_readIdentifier(start));
        continue;
      }
      switch (char) {
        case '+':
        case '-':
        case '*':
        case '/':
        case '^':
        case '%':
        case '!':
          _pos++;
          tokens.add(Token(TokenType.operator, char, start, _pos));
          continue;
        case '(':
          _pos++;
          tokens.add(Token(TokenType.lparen, char, start, _pos));
          continue;
        case ')':
          _pos++;
          tokens.add(Token(TokenType.rparen, char, start, _pos));
          continue;
        case ',':
          _pos++;
          tokens.add(Token(TokenType.comma, char, start, _pos));
          continue;
        default:
          throw CalcException('无法识别的字符 "$char"（位置 ${start + 1}）', start);
      }
    }
  }

  Token _readNumber(int start) {
    var seenDot = false;
    while (_pos < _src.length) {
      final char = _src[_pos];
      if (_isDigit(char)) {
        _pos++;
      } else if (char == '.' && !seenDot) {
        seenDot = true;
        _pos++;
      } else {
        break;
      }
    }
    // 科学计数法：1e10 / 1.5E-3
    if (_pos < _src.length && (_src[_pos] == 'e' || _src[_pos] == 'E')) {
      final next = _peek(1);
      final nextNext = _peek(2);
      final hasExponent =
          _isDigit(next) ||
          ((next == '+' || next == '-') && _isDigit(nextNext));
      if (hasExponent) {
        _pos += 2;
        while (_pos < _src.length && _isDigit(_src[_pos])) {
          _pos++;
        }
      }
    }
    final text = _src.substring(start, _pos);
    final value = double.tryParse(text);
    if (value == null) {
      throw CalcException('无效的数字 "$text"', start);
    }
    return Token(TokenType.number, text, start, _pos, value: value);
  }

  Token _readIdentifier(int start) {
    while (_pos < _src.length && _isIdentifierPart(_src[_pos])) {
      _pos++;
    }
    final text = _src.substring(start, _pos);
    return Token(TokenType.identifier, text, start, _pos);
  }

  void _skipWhitespace() {
    while (_pos < _src.length && _isWhitespace(_src[_pos])) {
      _pos++;
    }
  }

  String _peek(int offset) {
    final index = _pos + offset;
    if (index < 0 || index >= _src.length) return '';
    return _src[index];
  }

  static bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 0x30 && char.codeUnitAt(0) <= 0x39;

  static bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';

  static bool _isIdentifierStart(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return (code >= 0x41 && code <= 0x5A) || // A-Z
        (code >= 0x61 && code <= 0x7A) || // a-z
        char == '_';
  }

  static bool _isIdentifierPart(String char) {
    return _isIdentifierStart(char) || _isDigit(char);
  }
}
