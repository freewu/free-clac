import 'dart:math' as math;
import 'dart:ui';

/// 二维绘图坐标系（数据空间 ↔ 屏幕空间）。
class PlotViewport {
  const PlotViewport({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  }) : assert(maxX > minX, 'x 轴范围无效'),
       assert(maxY > minY, 'y 轴范围无效');

  factory PlotViewport.standard() =>
      const PlotViewport(minX: -10, maxX: 10, minY: -10, maxY: 10);

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  static const double minSpan = 1e-9;
  static const double maxSpan = 1e12;

  double get spanX => maxX - minX;
  double get spanY => maxY - minY;
  double get centerX => (minX + maxX) / 2;
  double get centerY => (minY + maxY) / 2;

  double unitsPerPixelX(Size size) => spanX / math.max(size.width, 1);
  double unitsPerPixelY(Size size) => spanY / math.max(size.height, 1);

  /// 数据坐标 → 屏幕坐标（y 轴向上为正）。
  Offset toScreen(double x, double y, Size size) => Offset(
    (x - minX) / spanX * size.width,
    size.height - (y - minY) / spanY * size.height,
  );

  Offset toScreenOffset(Offset point, Size size) =>
      toScreen(point.dx, point.dy, size);

  /// 屏幕坐标 → 数据坐标。
  Offset toData(Offset screen, Size size) => Offset(
    minX + screen.dx / math.max(size.width, 1) * spanX,
    minY + (size.height - screen.dy) / math.max(size.height, 1) * spanY,
  );

  PlotViewport copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
  }) => PlotViewport(
    minX: minX ?? this.minX,
    maxX: maxX ?? this.maxX,
    minY: minY ?? this.minY,
    maxY: maxY ?? this.maxY,
  );

  /// 以 [focus]（数据坐标）为中心缩放；[factor] > 1 表示放大。
  PlotViewport zoomedAt(Offset focus, double factor, Size size) {
    if (!factor.isFinite || factor <= 0) return this;
    final targetSpanX = (spanX / factor).clamp(minSpan, maxSpan).toDouble();
    final targetSpanY = (spanY / factor).clamp(minSpan, maxSpan).toDouble();
    final scaleX = targetSpanX / spanX;
    final scaleY = targetSpanY / spanY;
    return PlotViewport(
      minX: focus.dx - (focus.dx - minX) * scaleX,
      maxX: focus.dx + (maxX - focus.dx) * scaleX,
      minY: focus.dy - (focus.dy - minY) * scaleY,
      maxY: focus.dy + (maxY - focus.dy) * scaleY,
    );
  }

  /// 以屏幕像素为单位平移：向右拖动 → 内容右移。
  PlotViewport pannedByPixels(Offset delta, Size size) {
    final dx = delta.dx * unitsPerPixelX(size);
    final dy = delta.dy * unitsPerPixelY(size);
    return PlotViewport(
      minX: minX - dx,
      maxX: maxX - dx,
      minY: minY + dy,
      maxY: maxY + dy,
    );
  }

  /// 让 x / y 单位长度在屏幕上相等（正方形网格）。
  PlotViewport withEqualScale(Size size, {bool keepX = true}) {
    if (size.width <= 0 || size.height <= 0) return this;
    if (keepX) {
      final ratio = spanX / size.width * size.height;
      final half = ratio / 2;
      return PlotViewport(
        minX: minX,
        maxX: maxX,
        minY: centerY - half,
        maxY: centerY + half,
      );
    }
    final ratio = spanY / size.height * size.width;
    final half = ratio / 2;
    return PlotViewport(
      minX: centerX - half,
      maxX: centerX + half,
      minY: minY,
      maxY: maxY,
    );
  }

  PlotViewport shiftedTo(double x, double y) {
    final halfX = spanX / 2;
    final halfY = spanY / 2;
    return PlotViewport(
      minX: x - halfX,
      maxX: x + halfX,
      minY: y - halfY,
      maxY: y + halfY,
    );
  }

  /// 纵向范围替换（用于自动适配 y 轴）。
  PlotViewport withYRange(double low, double high) {
    if (!low.isFinite || !high.isFinite || high <= low) return this;
    return copyWith(minY: low, maxY: high);
  }

  PlotViewport withXRange(double low, double high) {
    if (!low.isFinite || !high.isFinite || high <= low) return this;
    return copyWith(minX: low, maxX: high);
  }

  /// 把范围扩大（用于“缩放到合适”）。
  PlotViewport inflate(double fraction) {
    final dx = spanX * fraction / 2;
    final dy = spanY * fraction / 2;
    return PlotViewport(
      minX: minX - dx,
      maxX: maxX + dx,
      minY: minY - dy,
      maxY: maxY + dy,
    );
  }

  bool containsData(Offset point) =>
      point.dx >= minX &&
      point.dx <= maxX &&
      point.dy >= minY &&
      point.dy <= maxY;

  Map<String, double> toMap() => {
    'minX': minX,
    'maxX': maxX,
    'minY': minY,
    'maxY': maxY,
  };

  @override
  bool operator ==(Object other) =>
      other is PlotViewport &&
      other.minX == minX &&
      other.maxX == maxX &&
      other.minY == minY &&
      other.maxY == maxY;

  @override
  int get hashCode => Object.hash(minX, maxX, minY, maxY);

  @override
  String toString() => 'PlotViewport(x: [$minX, $maxX], y: [$minY, $maxY])';
}
