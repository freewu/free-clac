/// 表达式节点：数字 / 变量 / 一元 / 二元 / 函数调用 / 后缀运算。
abstract class Expr {
  const Expr();

  /// 用于展示的表达式文本（会尽量还原用户输入的可读形式）。
  String toSource();

  @override
  String toString() => toSource();
}

class NumberExpr extends Expr {
  const NumberExpr(this.value);

  final double value;

  @override
  String toSource() {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}

class VariableExpr extends Expr {
  const VariableExpr(this.name);

  final String name;

  @override
  String toSource() => name;
}

class UnaryExpr extends Expr {
  const UnaryExpr(this.operator, this.operand);

  final String operator;
  final Expr operand;

  @override
  String toSource() => '$operator(${operand.toSource()})';
}

class PostfixExpr extends Expr {
  const PostfixExpr(this.operand, this.operator);

  final Expr operand;
  final String operator;

  @override
  String toSource() => '(${operand.toSource()})$operator';
}

class BinaryExpr extends Expr {
  const BinaryExpr(
    this.operator,
    this.left,
    this.right, {
    this.implicit = false,
  });

  final String operator;
  final Expr left;
  final Expr right;

  /// 是否为隐式乘法（如 `2x`、`3(4+5)`），展示时补上 `*`。
  final bool implicit;

  @override
  String toSource() => '(${left.toSource()} $operator ${right.toSource()})';
}

class CallExpr extends Expr {
  const CallExpr(this.name, this.arguments);

  final String name;
  final List<Expr> arguments;

  @override
  String toSource() =>
      '$name(${arguments.map((argument) => argument.toSource()).join(', ')})';
}

/// 常量引用（pi、e ……），在求值阶段直接返回对应数值。
class ConstantExpr extends Expr {
  const ConstantExpr(this.name, this.value);

  final String name;
  final double value;

  @override
  String toSource() => name;
}
