import 'package:flutter/material.dart';

import '../core/number_format.dart';
import '../state/plot_controller.dart';
import 'plot_painter.dart';
import 'plot_viewport.dart';

/// 把当前画面序列化成 SVG 文本。
///
/// 结构与 [PlotPainter] 保持一致：背景渐变 → 网格 → 坐标轴 → 刻度 → 曲线，
/// 因此导出的矢量图与屏幕上看到的画面基本相同（曲线保留光晕效果）。
String buildPlotSvg({
  required PlotViewport viewport,
  required List<PlotSample> samples,
  required Size size,
  bool showGrid = true,
  String title = 'free-clac 函数绘图',
  String? subtitle,
}) {
  final width = _num(size.width);
  final height = _num(size.height);
  final out = StringBuffer()
    ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
    ..writeln(
      '<svg xmlns="http://www.w3.org/2000/svg" '
      'width="$width" height="$height" '
      'viewBox="0 0 $width $height" '
      'font-family="\'Segoe UI\', Roboto, Helvetica, Arial, sans-serif">',
    )
    ..writeln('  <title>${_escape(title)}</title>');
  if (subtitle != null && subtitle.isNotEmpty) {
    out.writeln('  <desc>${_escape(subtitle)}</desc>');
  }
  _writeDefs(out);
  _writeBackground(out, size);
  if (showGrid) _writeGrid(out, viewport, size);
  _writeAxes(out, viewport, size);
  _writeCurves(out, samples);
  out.writeln('</svg>');
  return out.toString();
}

void _writeDefs(StringBuffer out) {
  out
    ..writeln('  <defs>')
    ..writeln('    <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1">')
    ..writeln('      <stop offset="0" stop-color="#0D141D"/>')
    ..writeln('      <stop offset="1" stop-color="#0A0E14"/>')
    ..writeln('    </linearGradient>')
    ..writeln(
      '    <filter id="glow" x="-20%" y="-20%" width="140%" '
      'height="140%">',
    )
    ..writeln('      <feGaussianBlur stdDeviation="2"/>')
    ..writeln('    </filter>')
    ..writeln('  </defs>');
}

void _writeBackground(StringBuffer out, Size size) {
  out.writeln(
    '  <rect width="${_num(size.width)}" height="${_num(size.height)}" '
    'fill="url(#bg)"/>',
  );
}

void _writeGrid(StringBuffer out, PlotViewport viewport, Size size) {
  final stepX = PlotPainter.niceStep(viewport.spanX / (size.width / 88));
  final stepY = PlotPainter.niceStep(viewport.spanY / (size.height / 88));

  out.writeln('  <g stroke-width="1">');
  // 细网格：与画布一致的 7 像素阈值，避免糊成一片
  if (stepX / 5 * size.width / viewport.spanX >= 7) {
    _writeLines(
      out,
      viewport,
      size,
      stepX / 5,
      vertical: true,
      opacity: 0.067,
      stroke: '#FFFFFF',
    );
  }
  if (stepY / 5 * size.height / viewport.spanY >= 7) {
    _writeLines(
      out,
      viewport,
      size,
      stepY / 5,
      vertical: false,
      opacity: 0.067,
      stroke: '#FFFFFF',
    );
  }
  // 主网格
  _writeLines(
    out,
    viewport,
    size,
    stepX,
    vertical: true,
    opacity: 0.122,
    stroke: '#FFFFFF',
  );
  _writeLines(
    out,
    viewport,
    size,
    stepY,
    vertical: false,
    opacity: 0.122,
    stroke: '#FFFFFF',
  );
  out.writeln('  </g>');
}

void _writeLines(
  StringBuffer out,
  PlotViewport viewport,
  Size size,
  double step, {
  required bool vertical,
  required double opacity,
  required String stroke,
}) {
  if (!step.isFinite || step <= 0) return;
  final min = vertical ? viewport.minX : viewport.minY;
  final max = vertical ? viewport.maxX : viewport.maxY;
  final first = (min / step).ceil();
  final last = (max / step).floor();
  if (last - first > 2000) return;
  for (var index = first; index <= last; index++) {
    final value = index * step;
    final point = viewport.toScreen(
      vertical ? value : viewport.minX,
      vertical ? viewport.minY : value,
      size,
    );
    final coords = vertical
        ? 'x1="${_num(point.dx)}" y1="0" x2="${_num(point.dx)}" '
              'y2="${_num(size.height)}"'
        : 'x1="0" y1="${_num(point.dy)}" x2="${_num(size.width)}" '
              'y2="${_num(point.dy)}"';
    out.writeln(
      '    <line $coords stroke="$stroke" stroke-opacity="$opacity"/>',
    );
  }
}

void _writeAxes(StringBuffer out, PlotViewport viewport, Size size) {
  const axisColor = '#7C8CA3';
  const labelColor = '#9AAABF';
  final origin = viewport.toScreen(0, 0, size);
  final axisXVisible = origin.dy >= 0 && origin.dy <= size.height;
  final axisYVisible = origin.dx >= 0 && origin.dx <= size.width;
  final axisY = origin.dy.clamp(0.0, size.height);
  final axisX = origin.dx.clamp(0.0, size.width);

  out.writeln('  <g>');
  // 坐标轴（不在视野内时退化成淡色边框，提示方向）
  out.writeln(
    '    <line x1="0" y1="${_num(axisY)}" x2="${_num(size.width)}" '
    'y2="${_num(axisY)}" stroke="$axisColor" stroke-width="1.4" '
    'stroke-opacity="${axisXVisible ? 1 : 0.25}"/>',
  );
  out.writeln(
    '    <line x1="${_num(axisX)}" y1="0" x2="${_num(axisX)}" '
    'y2="${_num(size.height)}" stroke="$axisColor" stroke-width="1.4" '
    'stroke-opacity="${axisYVisible ? 1 : 0.25}"/>',
  );

  // 刻度与标签
  _writeXTicks(out, viewport, size, axisY, labelColor, axisColor);
  _writeYTicks(out, viewport, size, axisX, labelColor, axisColor);

  if (axisXVisible && axisYVisible) {
    final below = axisY > size.height - 22;
    final labelY = below ? axisY - 6 : axisY + 6;
    out.writeln(
      '    <text x="${_num(axisX - 6)}" y="${_num(labelY)}" '
      'fill="$labelColor" font-size="11" text-anchor="end" '
      'dominant-baseline="${below ? 'auto' : 'hanging'}" '
      'font-variant-numeric="tabular-nums">0</text>',
    );
  }
  out.writeln('  </g>');
}

void _writeXTicks(
  StringBuffer out,
  PlotViewport viewport,
  Size size,
  double axisY,
  String labelColor,
  String tickColor,
) {
  final step = PlotPainter.niceStep(viewport.spanX / (size.width / 88));
  final first = (viewport.minX / step).ceil();
  final last = (viewport.maxX / step).floor();
  if (last - first > 400) return;
  final labelY = axisY > size.height - 24 ? axisY - 20 : axisY + 6;
  for (var index = first; index <= last; index++) {
    final value = index * step;
    if (value.abs() < step * 1e-6) continue;
    final x = viewport.toScreen(value, 0, size).dx;
    out
      ..writeln(
        '    <line x1="${_num(x)}" y1="${_num(axisY - 4)}" '
        'x2="${_num(x)}" y2="${_num(axisY + 4)}" stroke="$tickColor" '
        'stroke-width="1.2"/>',
      )
      ..writeln(
        '    <text x="${_num(x)}" y="${_num(labelY)}" fill="$labelColor" '
        'font-size="11" text-anchor="middle" dominant-baseline="hanging" '
        'font-variant-numeric="tabular-nums">'
        '${_escape(formatTick(value))}</text>',
      );
  }
}

void _writeYTicks(
  StringBuffer out,
  PlotViewport viewport,
  Size size,
  double axisX,
  String labelColor,
  String tickColor,
) {
  final step = PlotPainter.niceStep(viewport.spanY / (size.height / 88));
  final first = (viewport.minY / step).ceil();
  final last = (viewport.maxY / step).floor();
  if (last - first > 400) return;
  final rightSide = axisX < 44;
  for (var index = first; index <= last; index++) {
    final value = index * step;
    if (value.abs() < step * 1e-6) continue;
    final y = viewport.toScreen(0, value, size).dy;
    final x = rightSide ? axisX + 8 : axisX - 8;
    out
      ..writeln(
        '    <line x1="${_num(axisX - 4)}" y1="${_num(y)}" '
        'x2="${_num(axisX + 4)}" y2="${_num(y)}" stroke="$tickColor" '
        'stroke-width="1.2"/>',
      )
      ..writeln(
        '    <text x="${_num(x)}" y="${_num(y)}" fill="$labelColor" '
        'font-size="11" text-anchor="${rightSide ? 'start' : 'end'}" '
        'dominant-baseline="middle" font-variant-numeric="tabular-nums">'
        '${_escape(formatTick(value))}</text>',
      );
  }
}

void _writeCurves(StringBuffer out, List<PlotSample> samples) {
  for (final sample in samples) {
    if (!sample.function.visible || sample.curve.isEmpty) continue;
    final data = _pathData(sample);
    if (data.isEmpty) continue;
    final color = _hex(sample.function.color);
    out
      ..writeln('  <g>')
      // 光晕：与画布一致的 5px 模糊描边
      ..writeln(
        '    <path d="$data" fill="none" stroke="$color" stroke-width="5" '
        'stroke-opacity="0.22" stroke-linecap="round" '
        'stroke-linejoin="round" filter="url(#glow)"/>',
      )
      ..writeln(
        '    <path d="$data" fill="none" stroke="$color" '
        'stroke-width="1.8" stroke-linecap="round" '
        'stroke-linejoin="round"/>',
      )
      ..writeln('  </g>');
  }
}

String _pathData(PlotSample sample) {
  final out = StringBuffer();
  for (final segment in sample.curve.segments) {
    if (segment.length < 2) continue;
    out.write('M ${_num(segment.first.dx)} ${_num(segment.first.dy)}');
    for (var i = 1; i < segment.length; i++) {
      out.write(' L ${_num(segment[i].dx)} ${_num(segment[i].dy)}');
    }
  }
  return out.toString();
}

/// 数字紧凑化：最多两位小数，去掉多余的空格。
String _num(double value) {
  if (!value.isFinite) return '0';
  final rounded = (value * 100).roundToDouble() / 100;
  if (rounded == rounded.roundToDouble()) return rounded.round().toString();
  return rounded
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String _hex(Color color) {
  final value = color.toARGB32() & 0xFFFFFF;
  return '#${value.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

String _escape(String text) => text
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;');
