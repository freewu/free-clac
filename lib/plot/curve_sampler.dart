import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import '../core/angle_mode.dart';
import 'plot_viewport.dart';

/// 采样结果：屏幕坐标系下的折线集合（遇到无定义 / 间断处会断开）。
class SampledCurve {
  const SampledCurve(this.segments);

  static const SampledCurve empty = SampledCurve(<List<Offset>>[]);

  final List<List<Offset>> segments;

  bool get isEmpty => segments.isEmpty;

  int get pointCount =>
      segments.fold<int>(0, (total, segment) => total + segment.length);
}

/// 自适应曲线采样器。
///
/// 先按 1 像素步长采样，再对相邻点之间做递归细分：
///  * 与弦的偏差大于 [tolerance] 时继续细分，保证曲线平滑；
///  * 出现 NaN / 无穷 / 巨大跳变时断开，避免画出“假的”竖直渐近线。
class CurveSampler {
  const CurveSampler({
    this.tolerance = 0.55,
    this.maxDepth = 4,
    this.maxPoints = 60000,
  });

  final double tolerance;
  final int maxDepth;
  final int maxPoints;

  /// 直角坐标 y = f(x)。
  SampledCurve cartesian({
    required double Function(double x) evaluate,
    required PlotViewport viewport,
    required Size size,
  }) {
    final steps = math.max(2, size.width.round());
    return _sample(
      from: viewport.minX,
      to: viewport.maxX,
      steps: steps,
      viewport: viewport,
      size: size,
      evaluate: (t) {
        final y = evaluate(t);
        return y.isFinite ? Offset(t, y) : null;
      },
    );
  }

  /// 极坐标 r = f(t)，t 按当前角度模式解释。
  ///
  /// [from] / [to] 指定参数区间（缺省时取视口的 x 范围）。
  SampledCurve polar({
    required double Function(double t) evaluateRadius,
    required PlotViewport viewport,
    required Size size,
    required AngleMode angleMode,
    double? from,
    double? to,
  }) {
    final steps = math.max(2, (size.width * 1.5).round());
    return _sample(
      from: from ?? viewport.minX,
      to: to ?? viewport.maxX,
      steps: steps,
      viewport: viewport,
      size: size,
      evaluate: (t) {
        final radius = evaluateRadius(t);
        if (!radius.isFinite) return null;
        final radians = angleMode.toRadians(t);
        return Offset(radius * math.cos(radians), radius * math.sin(radians));
      },
    );
  }

  /// 参数方程 (x(t), y(t))。
  ///
  /// [from] / [to] 指定参数区间（缺省时取视口的 x 范围）。
  SampledCurve parametric({
    required double Function(double t) evaluateX,
    required double Function(double t) evaluateY,
    required PlotViewport viewport,
    required Size size,
    double? from,
    double? to,
  }) {
    final steps = math.max(2, (size.width * 1.5).round());
    return _sample(
      from: from ?? viewport.minX,
      to: to ?? viewport.maxX,
      steps: steps,
      viewport: viewport,
      size: size,
      evaluate: (t) {
        final x = evaluateX(t);
        final y = evaluateY(t);
        if (!x.isFinite || !y.isFinite) return null;
        return Offset(x, y);
      },
    );
  }

  /// 隐式方程 `f(x, y) = 0` 的等值线（marching squares）。
  ///
  /// 网格按屏幕像素划分（[cellSize] 为一个网格的像素宽度），逐格比较四个角的
  /// 函数值符号，用线性插值求交点，再把相邻网格的线段拼接成折线。
  /// 交点按“从左到右 / 从上到下”的固定顺序计算，因此相邻网格的共享端点坐标
  /// 完全一致，可以直接首尾相连。
  SampledCurve implicit({
    required double Function(double x, double y) evaluate,
    required PlotViewport viewport,
    required Size size,
    double cellSize = 6,
  }) {
    if (size.width <= 0 || size.height <= 0) return SampledCurve.empty;
    // 大画布上限制网格数量，避免隐式采样拖慢拖动 / 缩放。
    final effectiveCell = math.max(
      cellSize,
      math.max(size.width, size.height) / 300,
    );
    final columns = math.max(1, (size.width / effectiveCell).ceil());
    final rows = math.max(1, (size.height / effectiveCell).ceil());
    final cellW = size.width / columns;
    final cellH = size.height / rows;
    final fieldWidth = columns + 1;

    // 先算一遍网格顶点，marching squares 的每个角会被相邻 4 个格子复用。
    final values = Float64List(fieldWidth * (rows + 1));
    for (var row = 0; row <= rows; row++) {
      for (var column = 0; column <= columns; column++) {
        final data = viewport.toData(Offset(column * cellW, row * cellH), size);
        values[row * fieldWidth + column] = evaluate(data.dx, data.dy);
      }
    }

    final segments = <List<Offset>>[];
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final topLeftIndex = row * fieldWidth + column;
        final topRightIndex = topLeftIndex + 1;
        final bottomLeftIndex = topLeftIndex + fieldWidth;
        final bottomRightIndex = bottomLeftIndex + 1;

        final v0 = values[topLeftIndex];
        final v1 = values[topRightIndex];
        final v2 = values[bottomRightIndex];
        final v3 = values[bottomLeftIndex];
        if (!v0.isFinite || !v1.isFinite || !v2.isFinite || !v3.isFinite) {
          continue;
        }

        final p0 = v0 >= 0;
        final p1 = v1 >= 0;
        final p2 = v2 >= 0;
        final p3 = v3 >= 0;
        if (p0 == p1 && p1 == p2 && p2 == p3) continue;

        final x0 = column * cellW;
        final x1 = x0 + cellW;
        final y0 = row * cellH;
        final y1 = y0 + cellH;

        final top = p0 != p1
            ? Offset(x0 + cellW * _crossRatio(v0, v1), y0)
            : null;
        final right = p1 != p2
            ? Offset(x1, y0 + cellH * _crossRatio(v1, v2))
            : null;
        final bottom = p3 != p2
            ? Offset(x0 + cellW * _crossRatio(v3, v2), y1)
            : null;
        final left = p0 != p3
            ? Offset(x0, y0 + cellH * _crossRatio(v0, v3))
            : null;

        // 2 个交点时直接相连（可能出现在相邻边，也可能在相对的边上）；
        // 4 个交点（鞍点）用格心符号决定配对，否则会把两条等值线错连在一起。
        final crossings = <Offset>[?top, ?right, ?bottom, ?left];
        if (crossings.length == 2) {
          segments.add([crossings[0], crossings[1]]);
        } else if (crossings.length == 4) {
          final center = viewport.toData(
            Offset(x0 + cellW / 2, y0 + cellH / 2),
            size,
          );
          final centerPositive = evaluate(center.dx, center.dy) >= 0;
          if (centerPositive == p0) {
            segments
              ..add([top!, right!])
              ..add([bottom!, left!]);
          } else {
            segments
              ..add([top!, left!])
              ..add([right!, bottom!]);
          }
        }
      }
    }

    if (segments.isEmpty) return SampledCurve.empty;
    return SampledCurve(_chainSegments(segments));
  }

  /// 交点在边上的参数位置（0 = [a] 端，1 = [b] 端）。
  double _crossRatio(double a, double b) {
    final denominator = a - b;
    if (denominator == 0) return 0.5;
    return (a / denominator).clamp(0.0, 1.0).toDouble();
  }

  /// 把首尾相接的线段拼成尽量长的折线，减少绘制与导出时的 path 数量。
  List<List<Offset>> _chainSegments(List<List<Offset>> segments) {
    if (segments.length == 1) return segments;
    final adjacency = <(int, int), List<int>>{};
    for (var index = 0; index < segments.length; index++) {
      for (final point in segments[index]) {
        adjacency.putIfAbsent(_pointKey(point), () => <int>[]).add(index);
      }
    }

    final used = List<bool>.filled(segments.length, false);
    final chains = <List<Offset>>[];
    for (var index = 0; index < segments.length; index++) {
      if (used[index]) continue;
      used[index] = true;
      final chain = <Offset>[segments[index][0], segments[index][1]];
      _extendChain(chain, adjacency, segments, used, forward: true);
      _extendChain(chain, adjacency, segments, used, forward: false);
      chains.add(chain);
    }
    return chains;
  }

  void _extendChain(
    List<Offset> chain,
    Map<(int, int), List<int>> adjacency,
    List<List<Offset>> segments,
    List<bool> used, {
    required bool forward,
  }) {
    while (chain.length < maxPoints) {
      final endpoint = forward ? chain.last : chain.first;
      final endpointKey = _pointKey(endpoint);
      final candidates = adjacency[endpointKey];
      if (candidates == null) return;
      int? next;
      for (final index in candidates) {
        if (!used[index]) {
          next = index;
          break;
        }
      }
      if (next == null) return;
      used[next] = true;
      final segment = segments[next];
      final other = _pointKey(segment[1]) == endpointKey
          ? segment[0]
          : segment[1];
      if (forward) {
        chain.add(other);
      } else {
        chain.insert(0, other);
      }
    }
  }

  /// 量化到 1e-6 像素，保证不同网格里算出的同一个端点得到相同 key。
  (int, int) _pointKey(Offset point) =>
      ((point.dx * 1e6).round(), (point.dy * 1e6).round());

  SampledCurve _sample({
    required double from,
    required double to,
    required int steps,
    required Offset? Function(double t) evaluate,
    required PlotViewport viewport,
    required Size size,
  }) {
    final builder = _SegmentBuilder();
    final breakDistance = math.max(size.width, size.height) * 3;

    double? previousT;
    Offset? previousData;
    Offset? previousScreen;

    for (var index = 0; index <= steps; index++) {
      final t = from + (to - from) * index / steps;
      final data = evaluate(t);
      final screen = data == null ? null : _toScreen(data, viewport, size);
      if (screen == null) {
        builder.cut();
        previousT = null;
        previousData = null;
        previousScreen = null;
        continue;
      }
      if (previousScreen == null || previousT == null || previousData == null) {
        builder.add(screen);
      } else {
        _connect(
          builder: builder,
          evaluate: evaluate,
          viewport: viewport,
          size: size,
          fromT: previousT,
          fromData: previousData,
          fromScreen: previousScreen,
          toT: t,
          toData: data!,
          toScreen: screen,
          depth: maxDepth,
          breakDistance: breakDistance,
        );
        builder.add(screen);
      }
      previousT = t;
      previousData = data;
      previousScreen = screen;
      if (builder.pointCount > maxPoints) break;
    }
    builder.finish();
    return SampledCurve(builder.segments);
  }

  void _connect({
    required _SegmentBuilder builder,
    required Offset? Function(double t) evaluate,
    required PlotViewport viewport,
    required Size size,
    required double fromT,
    required Offset fromData,
    required Offset fromScreen,
    required double toT,
    required Offset toData,
    required Offset toScreen,
    required int depth,
    required double breakDistance,
  }) {
    final chord = (toScreen - fromScreen).distance;
    if (depth <= 0) {
      // 细分到极限仍然跳变巨大 → 视为间断（例如 tan(x) 在 π/2 处）
      if (chord > breakDistance) builder.cut();
      return;
    }

    final middleT = (fromT + toT) / 2;
    final middleData = evaluate(middleT);
    final middleScreen = middleData == null
        ? null
        : _toScreen(middleData, viewport, size);

    if (middleScreen == null) {
      // 中间点无定义：说明这里存在定义域空洞，断开折线。
      builder.cut();
      return;
    }

    final deviation = _distanceToSegment(middleScreen, fromScreen, toScreen);

    if (deviation > tolerance || chord > breakDistance * 0.4) {
      _connect(
        builder: builder,
        evaluate: evaluate,
        viewport: viewport,
        size: size,
        fromT: fromT,
        fromData: fromData,
        fromScreen: fromScreen,
        toT: middleT,
        toData: middleData!,
        toScreen: middleScreen,
        depth: depth - 1,
        breakDistance: breakDistance,
      );
      builder.add(middleScreen);
      _connect(
        builder: builder,
        evaluate: evaluate,
        viewport: viewport,
        size: size,
        fromT: middleT,
        fromData: middleData,
        fromScreen: middleScreen,
        toT: toT,
        toData: toData,
        toScreen: toScreen,
        depth: depth - 1,
        breakDistance: breakDistance,
      );
      return;
    }

    if (chord > breakDistance) builder.cut();
  }

  Offset _toScreen(Offset data, PlotViewport viewport, Size size) {
    final x = (data.dx - viewport.minX) / viewport.spanX * size.width;
    final y =
        size.height - (data.dy - viewport.minY) / viewport.spanY * size.height;
    return Offset(
      x.clamp(-size.width * 2, size.width * 3).toDouble(),
      y.clamp(-size.height * 2, size.height * 3).toDouble(),
    );
  }

  double _distanceToSegment(Offset point, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lengthSquared = dx * dx + dy * dy;
    if (lengthSquared < 1e-9) return (point - start).distance;
    var t =
        ((point.dx - start.dx) * dx + (point.dy - start.dy) * dy) /
        lengthSquared;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(start.dx + dx * t, start.dy + dy * t);
    return (point - projection).distance;
  }
}

class _SegmentBuilder {
  final List<List<Offset>> segments = <List<Offset>>[];
  List<Offset>? _current;
  int _pointCount = 0;

  int get pointCount => _pointCount;

  void add(Offset point) {
    final current = _current;
    if (current == null) {
      _current = <Offset>[point];
      _pointCount++;
      return;
    }
    final last = current.last;
    if ((last - point).distanceSquared < 0.04) return;
    current.add(point);
    _pointCount++;
  }

  void cut() {
    final current = _current;
    if (current != null && current.length >= 2) {
      segments.add(current);
    }
    _current = null;
  }

  void finish() => cut();
}
