import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../state/plot_controller.dart';
import 'plot_viewport.dart';

/// 曲线绘制器：网格、坐标轴、曲线、追踪辅助线。
class PlotPainter extends CustomPainter {
  PlotPainter({
    required this.viewport,
    required this.samples,
    required this.showGrid,
    this.trace,
    this.traceDots = const <TraceDot>[],
  });

  final PlotViewport viewport;
  final List<PlotSample> samples;
  final bool showGrid;
  final Offset? trace;
  final List<TraceDot> traceDots;

  static const Color _minorGrid = Color(0x11FFFFFF);
  static const Color _majorGrid = Color(0x1FFFFFFF);
  static const Color _axisColor = Color(0xFF7C8CA3);
  static const Color _labelColor = Color(0xFF9AAABF);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    _paintBackground(canvas, size);
    if (showGrid) {
      _paintGrid(canvas, size);
    }
    _paintAxes(canvas, size);
    _paintCurves(canvas, size);
    _paintTrace(canvas, size);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0D141D), Color(0xFF0A0E14)],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
  }

  void _paintGrid(Canvas canvas, Size size) {
    final stepX = niceStep(viewport.spanX / (size.width / 88));
    final stepY = niceStep(viewport.spanY / (size.height / 88));
    final minorX = stepX / 5;
    final minorY = stepY / 5;

    final thin = Paint()
      ..color = _minorGrid
      ..strokeWidth = 1;
    if (minorX * size.width / viewport.spanX >= 7) {
      _drawVerticalLines(canvas, size, minorX, thin);
    }
    if (minorY * size.height / viewport.spanY >= 7) {
      _drawHorizontalLines(canvas, size, minorY, thin);
    }

    final thick = Paint()
      ..color = _majorGrid
      ..strokeWidth = 1;
    _drawVerticalLines(canvas, size, stepX, thick);
    _drawHorizontalLines(canvas, size, stepY, thick);
  }

  void _drawVerticalLines(Canvas canvas, Size size, double step, Paint paint) {
    if (!step.isFinite || step <= 0) return;
    final first = (viewport.minX / step).ceil();
    final last = (viewport.maxX / step).floor();
    if (last - first > 2000) return;
    for (var index = first; index <= last; index++) {
      final x = viewport.toScreen(index * step, viewport.minY, size).dx;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawHorizontalLines(
    Canvas canvas,
    Size size,
    double step,
    Paint paint,
  ) {
    if (!step.isFinite || step <= 0) return;
    final first = (viewport.minY / step).ceil();
    final last = (viewport.maxY / step).floor();
    if (last - first > 2000) return;
    for (var index = first; index <= last; index++) {
      final y = viewport.toScreen(viewport.minX, index * step, size).dy;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintAxes(Canvas canvas, Size size) {
    final origin = viewport.toScreen(0, 0, size);
    final axisPaint = Paint()
      ..color = _axisColor
      ..strokeWidth = 1.4;

    final axisXVisible = origin.dy >= 0 && origin.dy <= size.height;
    final axisYVisible = origin.dx >= 0 && origin.dx <= size.width;

    final axisY = origin.dy.clamp(0.0, size.height);
    final axisX = origin.dx.clamp(0.0, size.width);

    if (axisXVisible) {
      canvas.drawLine(Offset(0, axisY), Offset(size.width, axisY), axisPaint);
    } else {
      // 坐标轴不在视野内时，用淡色边框提示
      final borderPaint = Paint()
        ..color = _axisColor.withValues(alpha: 0.25)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(0, axisY), Offset(size.width, axisY), borderPaint);
    }
    if (axisYVisible) {
      canvas.drawLine(Offset(axisX, 0), Offset(axisX, size.height), axisPaint);
    } else {
      final borderPaint = Paint()
        ..color = _axisColor.withValues(alpha: 0.25)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(axisX, 0),
        Offset(axisX, size.height),
        borderPaint,
      );
    }

    _paintXTicks(canvas, size, axisY);
    _paintYTicks(canvas, size, axisX);

    // 原点标签
    if (axisXVisible && axisYVisible) {
      final below = axisY > size.height - 22;
      _drawText(
        canvas,
        '0',
        Offset(axisX - 6, below ? axisY - 6 : axisY + 6),
        align: Alignment(1, below ? 1 : -1),
        color: _labelColor,
        bounds: size,
      );
    }
  }

  void _paintXTicks(Canvas canvas, Size size, double axisY) {
    final step = niceStep(viewport.spanX / (size.width / 88));
    final first = (viewport.minX / step).ceil();
    final last = (viewport.maxX / step).floor();
    if (last - first > 400) return;
    final tickPaint = Paint()
      ..color = _axisColor
      ..strokeWidth = 1.2;
    final labelY = axisY > size.height - 24 ? axisY - 20 : axisY + 6;
    for (var index = first; index <= last; index++) {
      final value = index * step;
      if (value.abs() < step * 1e-6) continue;
      final x = viewport.toScreen(value, 0, size).dx;
      canvas.drawLine(Offset(x, axisY - 4), Offset(x, axisY + 4), tickPaint);
      _drawText(
        canvas,
        formatTick(value),
        Offset(x, labelY),
        align: const Alignment(0, -1),
        color: _labelColor,
        bounds: size,
      );
    }
  }

  void _paintYTicks(Canvas canvas, Size size, double axisX) {
    final step = niceStep(viewport.spanY / (size.height / 88));
    final first = (viewport.minY / step).ceil();
    final last = (viewport.maxY / step).floor();
    if (last - first > 400) return;
    final tickPaint = Paint()
      ..color = _axisColor
      ..strokeWidth = 1.2;
    final rightSide = axisX < 44;
    for (var index = first; index <= last; index++) {
      final value = index * step;
      if (value.abs() < step * 1e-6) continue;
      final y = viewport.toScreen(0, value, size).dy;
      canvas.drawLine(Offset(axisX - 4, y), Offset(axisX + 4, y), tickPaint);
      _drawText(
        canvas,
        formatTick(value),
        Offset(rightSide ? axisX + 8 : axisX - 8, y),
        align: Alignment(rightSide ? -1 : 1, 0),
        color: _labelColor,
        bounds: size,
      );
    }
  }

  void _paintCurves(Canvas canvas, Size size) {
    for (final sample in samples) {
      if (!sample.function.visible || sample.curve.isEmpty) continue;
      final color = sample.function.color;
      final path = Path();
      for (final segment in sample.curve.segments) {
        if (segment.length < 2) continue;
        path.moveTo(segment.first.dx, segment.first.dy);
        for (var i = 1; i < segment.length; i++) {
          path.lineTo(segment[i].dx, segment[i].dy);
        }
      }

      // 光晕
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: 0.22)
        ..maskFilter = const ui.MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(path, glow);

      final stroke = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color;
      canvas.drawPath(path, stroke);
    }
  }

  void _paintTrace(Canvas canvas, Size size) {
    final point = trace;
    if (point == null) return;
    final screen = viewport.toScreen(point.dx, 0, size);
    if (screen.dx < -2 || screen.dx > size.width + 2) return;

    final dashed = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..strokeWidth = 1;
    _drawDashedLine(
      canvas,
      Offset(screen.dx, 0),
      Offset(screen.dx, size.height),
      dashed,
    );

    for (final dot in traceDots) {
      final position = viewport.toScreen(
        dot.position.dx,
        dot.position.dy,
        size,
      );
      if (position.dy < -40 || position.dy > size.height + 40) continue;
      canvas.drawCircle(
        position,
        5.5,
        Paint()..color = dot.color.withValues(alpha: 0.25),
      );
      canvas.drawCircle(position, 3.2, Paint()..color = dot.color);
      canvas.drawCircle(
        position,
        3.2,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.85),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const dash = 5.0;
    const gap = 5.0;
    final delta = to - from;
    final length = delta.distance;
    if (length == 0) return;
    final direction = delta / length;
    var travelled = 0.0;
    while (travelled < length) {
      final end = math.min(travelled + dash, length);
      canvas.drawLine(
        from + direction * travelled,
        from + direction * end,
        paint,
      );
      travelled = end + gap;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    Alignment align = Alignment.center,
    Color color = _labelColor,
    double fontSize = 11,
    Size? bounds,
  }) {
    if (text.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontFeatures: const [ui.FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var dx = position.dx - painter.width * (align.x + 1) / 2;
    var dy = position.dy - painter.height * (align.y + 1) / 2;
    if (bounds != null) {
      // 避免刻度标签被画布边缘裁掉
      if (painter.width > bounds.width || painter.height > bounds.height) {
        return;
      }
      dx = dx.clamp(2.0, bounds.width - painter.width - 2);
      dy = dy.clamp(2.0, bounds.height - painter.height - 2);
    }
    painter.paint(canvas, Offset(dx, dy));
  }

  /// 把任意步长调整为 1 / 2 / 2.5 / 5 / 10 × 10ⁿ。
  static double niceStep(double raw) {
    if (!raw.isFinite || raw <= 0) return 1;
    final exponent = (math.log(raw) / math.ln10).floor();
    final power = math.pow(10.0, exponent).toDouble();
    final fraction = raw / power;
    final double nice;
    if (fraction <= 1) {
      nice = 1;
    } else if (fraction <= 2) {
      nice = 2;
    } else if (fraction <= 2.5) {
      nice = 2.5;
    } else if (fraction <= 5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * power;
  }

  @override
  bool shouldRepaint(covariant PlotPainter oldDelegate) {
    return oldDelegate.viewport != viewport ||
        !identical(oldDelegate.samples, samples) ||
        oldDelegate.showGrid != showGrid ||
        oldDelegate.trace != trace ||
        !identical(oldDelegate.traceDots, traceDots);
  }
}

/// 追踪点上的标记。
class TraceDot {
  const TraceDot({required this.position, required this.color});

  final Offset position;
  final Color color;
}

/// 曲线颜色（供图例使用）。
Color curveLegendColor(PlotSample sample) => sample.function.color;
