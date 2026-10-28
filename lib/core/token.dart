export 'calc_error.dart';

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
