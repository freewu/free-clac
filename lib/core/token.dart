enum TokenType { number, identifier, operator, lparen, rparen, comma, end }

class Token {
  const Token(this.type, this.lexeme, this.start, this.end, {this.value});

  final TokenType type;
  final String lexeme;
  final int start;
  final int end;
  final double? value;

  bool get isEnd => type == TokenType.end;

  @override
  String toString() => '$type("$lexeme")';
}

/// 计算过程中的异常，携带出错位置，便于在 UI 中高亮。
class CalcException implements Exception {
  CalcException(this.message, [this.position]);

  final String message;
  final int? position;

  @override
  String toString() =>
      position == null ? message : '$message（位置 ${position! + 1}）';
}
