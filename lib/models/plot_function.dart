import 'package:flutter/material.dart';

/// 曲线类型。
enum PlotMode {
  cartesian('直角坐标', 'y = ', 'x', 'y = f(x)'),
  polar('极坐标', 'r = ', 't', 'r(t)，t 为角度'),
  parametric('参数方程', '', 't', 'x(t) 与 y(t)'),
  implicit('隐式方程', '0 = ', 'x, y', 'f(x, y) = 0');

  const PlotMode(this.label, this.prefix, this.variable, this.hint);

  final String label;
  final String prefix;
  final String variable;
  final String hint;

  bool get needsSecondExpression => this == PlotMode.parametric;

  IconData get icon => switch (this) {
    PlotMode.cartesian => Icons.show_chart,
    PlotMode.polar => Icons.radar,
    PlotMode.parametric => Icons.multiline_chart,
    PlotMode.implicit => Icons.gesture,
  };
}

/// 一条待绘制曲线。
class PlotFunction {
  PlotFunction({
    required this.id,
    required this.color,
    this.mode = PlotMode.cartesian,
    this.expression = '',
    this.secondExpression = '',
    this.visible = true,
  });

  final String id;
  final PlotMode mode;
  final Color color;
  final String expression;

  /// 参数方程的 y(t) 部分。
  final String secondExpression;
  final bool visible;

  String get variable => mode.variable;

  bool get isValid =>
      expression.trim().isNotEmpty &&
      (!mode.needsSecondExpression || secondExpression.trim().isNotEmpty);

  /// 曲线在列表中展示的文本。
  String get title {
    switch (mode) {
      case PlotMode.cartesian:
        return 'y = $expression';
      case PlotMode.polar:
        return 'r = $expression';
      case PlotMode.parametric:
        return '($expression, $secondExpression)';
      case PlotMode.implicit:
        return '0 = $expression';
    }
  }

  PlotFunction copyWith({
    PlotMode? mode,
    Color? color,
    String? expression,
    String? secondExpression,
    bool? visible,
  }) => PlotFunction(
    id: id,
    mode: mode ?? this.mode,
    color: color ?? this.color,
    expression: expression ?? this.expression,
    secondExpression: secondExpression ?? this.secondExpression,
    visible: visible ?? this.visible,
  );
}
