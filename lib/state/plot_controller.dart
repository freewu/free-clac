import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../core/angle_mode.dart';
import '../core/math_engine.dart';
import '../core/number_format.dart';
import '../l10n/plot_strings.dart';
import '../plot/curve_sampler.dart';
import '../plot/plot_presets.dart';
import '../plot/plot_viewport.dart';
import '../models/plot_function.dart';
import '../theme/app_theme.dart';

/// 一条曲线的采样结果（含错误信息）。
class PlotSample {
  const PlotSample({
    required this.function,
    this.curve = SampledCurve.empty,
    this.error,
  });

  final PlotFunction function;
  final SampledCurve curve;
  final String? error;

  bool get hasError => error != null;
}

/// 跟踪点处某条曲线的读数。
class TraceValue {
  const TraceValue({required this.function, required this.text, this.point});

  final PlotFunction function;
  final String text;
  final Offset? point;
}

/// 绘图页面状态：函数列表、视口、追踪点。
class PlotController extends ChangeNotifier {
  PlotController({required this.engine}) {
    engine.addListener(_onEngineChanged);
    _seedDefaults();
  }

  final MathEngine engine;
  final CurveSampler _sampler = const CurveSampler();

  final List<PlotFunction> _functions = <PlotFunction>[];
  List<PlotFunction> get functions => List.unmodifiable(_functions);

  final Map<String, CompiledCurve> _curveCache = <String, CompiledCurve>{};
  final Map<String, CompiledSurface> _surfaceCache =
      <String, CompiledSurface>{};

  PlotViewport _viewport = PlotViewport.standard();
  PlotViewport get viewport => _viewport;
  set viewport(PlotViewport value) {
    if (value == _viewport) return;
    _viewport = value;
    notifyListeners();
  }

  Offset? _trace;
  Offset? get trace => _trace;

  bool _showGrid = true;
  bool get showGrid => _showGrid;

  bool _traceEnabled = false;
  bool get traceEnabled => _traceEnabled;

  String? _lastError;
  String? get lastError => _lastError;

  int _counter = 0;

  /// 载入示例后置位：首次布局时保留示例视口，不要重置成标准视口。
  bool _viewportPinned = false;

  /// 取走（并清除）“保留示例视口”的标记。
  bool consumeViewportPin() {
    final pinned = _viewportPinned;
    _viewportPinned = false;
    return pinned;
  }

  Size _canvasSize = const Size(900, 600);
  Size get canvasSize => _canvasSize;

  /// 画布在布局阶段回报自身尺寸，供工具栏的缩放 / 适配操作使用。
  void reportCanvasSize(Size size) {
    if (size.width > 1 && size.height > 1 && size != _canvasSize) {
      _canvasSize = size;
    }
  }

  /// 采样相关状态版本号：曲线定义 / 可见性 / 颜色 / 角度模式变化时递增，
  /// 画布据此决定是否需要重新采样。
  int _revision = 0;
  int get revision => _revision;

  AngleMode get angleMode => engine.angleMode;

  /// 极坐标 / 参数方程的默认参数区间：角度模式 0~360°，弧度模式 0~2π。
  (double, double) get parameterDomain =>
      defaultParameterDomain(degrees: angleMode == AngleMode.degrees);

  void _seedDefaults() {
    _functions.addAll([
      _create('sin(x)', color: AppColors.curvePalette[0]),
      _create('0.12x^2 - 2', color: AppColors.curvePalette[1]),
    ]);
  }

  PlotFunction _create(
    String expression, {
    required Color color,
    PlotMode mode = PlotMode.cartesian,
    String secondExpression = '',
  }) {
    return PlotFunction(
      id: 'curve_${_counter++}',
      color: color,
      mode: mode,
      expression: expression,
      secondExpression: secondExpression,
    );
  }

  /// 取下一个配色：优先选还没被占用的颜色，全部用完后再循环。
  Color _nextColor() {
    final used = _functions.map((function) => function.color).toSet();
    for (final color in AppColors.curvePalette) {
      if (!used.contains(color)) return color;
    }
    return AppColors.curvePalette[_functions.length %
        AppColors.curvePalette.length];
  }

  void _onEngineChanged() {
    _curveCache.clear();
    _surfaceCache.clear();
    _revision++;
    notifyListeners();
  }

  // ------------------------------------------------------------ 函数列表

  PlotFunction addFunction({PlotMode mode = PlotMode.cartesian}) {
    final color = _nextColor();
    final created = _create(
      switch (mode) {
        PlotMode.cartesian => 'x^2 / 4',
        PlotMode.polar => '4cos(3t)',
        PlotMode.parametric => '3cos(t)',
        PlotMode.implicit => 'x^2 + y^2 - 1',
      },
      secondExpression: mode == PlotMode.parametric ? '3sin(t)' : '',
      mode: mode,
      color: color,
    );
    _functions.add(created);
    _revision++;
    notifyListeners();
    return created;
  }

  void removeFunction(String id) {
    _functions.removeWhere((function) => function.id == id);
    _revision++;
    notifyListeners();
  }

  void clearFunctions() {
    _functions.clear();
    _revision++;
    notifyListeners();
  }

  /// 把示例 [preset] 的曲线添加到画布，并同步切换视口。
  ///
  /// 默认**保留**已有曲线，只追加示例里还没有的曲线，因此重复点同一个示例
  /// 不会堆出一串重复曲线；[replaceAll] 为 true 时才清空现有曲线
  /// （Web 深链 `?preset=` 启动时用）。
  ///
  /// 返回实际新增的曲线数量。
  int applyPreset(PlotPreset preset, {bool replaceAll = false}) {
    if (replaceAll) _functions.clear();
    final mode = preset.angleMode;
    if (mode != null) engine.angleMode = mode;
    var added = 0;
    for (final curve in preset.curves) {
      final exists = _functions.any(
        (function) =>
            function.mode == curve.mode &&
            function.expression == curve.expression &&
            function.secondExpression == curve.secondExpression,
      );
      if (exists) continue;
      _functions.add(
        _create(
          curve.expression,
          color: _nextColor(),
          mode: curve.mode,
          secondExpression: curve.secondExpression,
        ),
      );
      added++;
    }
    // 追加时取视口并集：不把已有图形挤出视野（否则看起来就像被清空了）。
    // 深链启动（replaceAll）才直接使用示例视口。
    _viewport = replaceAll ? preset.viewport : _viewport.union(preset.viewport);
    _viewportPinned = true;
    _trace = null;
    _lastError = null;
    _revision++;
    notifyListeners();
    return added;
  }

  void updateExpression(
    String id, {
    String? expression,
    String? secondExpression,
    PlotMode? mode,
  }) {
    final index = _functions.indexWhere((function) => function.id == id);
    if (index < 0) return;
    _functions[index] = _functions[index].copyWith(
      expression: expression,
      secondExpression: secondExpression,
      mode: mode,
    );
    _revision++;
    notifyListeners();
  }

  void toggleVisibility(String id) {
    final index = _functions.indexWhere((function) => function.id == id);
    if (index < 0) return;
    _functions[index] = _functions[index].copyWith(
      visible: !_functions[index].visible,
    );
    _revision++;
    notifyListeners();
  }

  void cycleColor(String id) {
    final index = _functions.indexWhere((function) => function.id == id);
    if (index < 0) return;
    final current = AppColors.curvePalette.indexOf(_functions[index].color);
    final next =
        AppColors.curvePalette[(current + 1) % AppColors.curvePalette.length];
    _functions[index] = _functions[index].copyWith(color: next);
    _revision++;
    notifyListeners();
  }

  void setShowGrid(bool value) {
    _showGrid = value;
    notifyListeners();
  }

  void setTraceEnabled(bool value) {
    _traceEnabled = value;
    if (!value) _trace = null;
    notifyListeners();
  }

  void setTrace(Offset? dataPoint) {
    if (dataPoint == _trace) return;
    _trace = dataPoint;
    notifyListeners();
  }

  /// 检查曲线表达式是否可解析；返回错误信息或 null。
  String? validate(PlotFunction function) {
    if (!function.isValid) return null;
    try {
      if (function.mode == PlotMode.implicit) {
        _compileSurface(function.expression);
      } else {
        _compile(
          function.expression,
          function.mode == PlotMode.cartesian ? 'x' : 't',
        );
        if (function.mode == PlotMode.parametric) {
          _compile(function.secondExpression, 't');
        }
      }
      return null;
    } catch (error) {
      return error.toString();
    }
  }

  // ------------------------------------------------------------ 采样

  CompiledCurve _compile(String source, String variable) {
    final key = '$variable::$source';
    final cached = _curveCache[key];
    if (cached != null) return cached;
    final compiled = engine.compileCurve(source, variable: variable);
    if (_curveCache.length > 64) _curveCache.clear();
    _curveCache[key] = compiled;
    return compiled;
  }

  CompiledSurface _compileSurface(String source) {
    final cached = _surfaceCache[source];
    if (cached != null) return cached;
    final compiled = engine.compileSurface(source);
    if (_surfaceCache.length > 64) _surfaceCache.clear();
    _surfaceCache[source] = compiled;
    return compiled;
  }

  /// 计算所有可见曲线的屏幕坐标折线。
  List<PlotSample> buildSamples(Size size) {
    if (size.width <= 0 || size.height <= 0) return const <PlotSample>[];
    final samples = <PlotSample>[];
    _lastError = null;
    for (final function in _functions) {
      if (!function.visible) {
        samples.add(PlotSample(function: function));
        continue;
      }
      if (!function.isValid) {
        samples.add(PlotSample(function: function));
        continue;
      }
      try {
        final curve = _sampleFunction(function, size);
        samples.add(PlotSample(function: function, curve: curve));
      } catch (error) {
        final message = error.toString();
        _lastError = message;
        samples.add(PlotSample(function: function, error: message));
      }
    }
    return samples;
  }

  SampledCurve _sampleFunction(PlotFunction function, Size size) {
    final (from, to) = parameterDomain;
    switch (function.mode) {
      case PlotMode.cartesian:
        final compiled = _compile(function.expression, 'x');
        return _sampler.cartesian(
          evaluate: compiled.call,
          viewport: _viewport,
          size: size,
        );
      case PlotMode.polar:
        final compiled = _compile(function.expression, 't');
        return _sampler.polar(
          evaluateRadius: compiled.call,
          viewport: _viewport,
          size: size,
          angleMode: angleMode,
          from: from,
          to: to,
        );
      case PlotMode.parametric:
        final x = _compile(function.expression, 't');
        final y = _compile(function.secondExpression, 't');
        return _sampler.parametric(
          evaluateX: x.call,
          evaluateY: y.call,
          viewport: _viewport,
          size: size,
          from: from,
          to: to,
        );
      case PlotMode.implicit:
        final compiled = _compileSurface(function.expression);
        return _sampler.implicit(
          evaluate: compiled.call,
          viewport: _viewport,
          size: size,
        );
    }
  }

  // ------------------------------------------------------------ 追踪读数

  /// 求 [x] 处每条可见曲线的读数。
  ///
  /// [y] 只在隐式曲线中用到：隐式方程需要整个点 `(x, y)` 才能求 `f(x, y)`。
  List<TraceValue> traceValues(double x, {double? y}) {
    final values = <TraceValue>[];
    for (final function in _functions) {
      if (!function.visible || !function.isValid) continue;
      try {
        switch (function.mode) {
          case PlotMode.cartesian:
            final compiled = _compile(function.expression, 'x');
            final y = compiled(x);
            if (!y.isFinite) {
              values.add(
                TraceValue(
                  function: function,
                  text: plotStrings.traceUndefined,
                ),
              );
            } else {
              values.add(
                TraceValue(
                  function: function,
                  text: 'y = ${formatNumber(y, significantDigits: 6)}',
                  point: Offset(x, y),
                ),
              );
            }
            break;
          case PlotMode.polar:
            final compiled = _compile(function.expression, 't');
            final radius = compiled(x);
            if (!radius.isFinite) {
              values.add(
                TraceValue(
                  function: function,
                  text: plotStrings.traceUndefined,
                ),
              );
            } else {
              final radians = angleMode.toRadians(x);
              values.add(
                TraceValue(
                  function: function,
                  text: 'r = ${formatNumber(radius, significantDigits: 6)}',
                  point: Offset(
                    radius * math.cos(radians),
                    radius * math.sin(radians),
                  ),
                ),
              );
            }
            break;
          case PlotMode.parametric:
            final fx = _compile(function.expression, 't');
            final fy = _compile(function.secondExpression, 't');
            final px = fx(x);
            final py = fy(x);
            if (!px.isFinite || !py.isFinite) {
              values.add(
                TraceValue(
                  function: function,
                  text: plotStrings.traceUndefined,
                ),
              );
            } else {
              values.add(
                TraceValue(
                  function: function,
                  text:
                      '(${formatNumber(px, significantDigits: 5)}, ${formatNumber(py, significantDigits: 5)})',
                  point: Offset(px, py),
                ),
              );
            }
            break;
          case PlotMode.implicit:
            final compiled = _compileSurface(function.expression);
            final value = compiled(x, y ?? 0);
            values.add(
              TraceValue(
                function: function,
                text: value.isFinite
                    ? 'f = ${formatNumber(value, significantDigits: 4)}'
                    : plotStrings.traceUndefined,
              ),
            );
            break;
        }
      } catch (_) {
        values.add(
          TraceValue(function: function, text: plotStrings.traceError),
        );
      }
    }
    return values;
  }

  // ------------------------------------------------------------ 视口操作

  void zoom(double factor, Size size) {
    viewport = _viewport.zoomedAt(
      Offset(_viewport.centerX, _viewport.centerY),
      factor,
      size,
    );
  }

  void zoomAtPixel(Offset pixel, double factor, Size size) {
    final focus = _viewport.toData(pixel, size);
    viewport = _viewport.zoomedAt(focus, factor, size);
  }

  void panByPixels(Offset delta, Size size) {
    viewport = _viewport.pannedByPixels(delta, size);
  }

  /// 按画布尺寸的比例移动视图：
  /// [fx] > 0 向左看（内容右移），[fy] > 0 向上看（内容下移）。
  void panByFraction(double fx, double fy, Size size) {
    panByPixels(Offset(fx * size.width, fy * size.height), size);
  }

  void resetView(Size size) {
    _trace = null;
    viewport = PlotViewport.standard().withEqualScale(size);
    notifyListeners();
  }

  /// 纵向自动适配：取当前 x 范围内所有曲线的值域。
  void fitY(Size size) {
    var low = double.infinity;
    var high = double.negativeInfinity;
    const samples = 480;
    for (final function in _functions) {
      if (!function.visible || !function.isValid) continue;
      if (function.mode == PlotMode.parametric) continue;
      // 隐式曲线没有 y = f(x) 的表达式，无法按 x 采样求值域。
      if (function.mode == PlotMode.implicit) continue;
      try {
        final compiled = _compile(
          function.expression,
          function.mode == PlotMode.polar ? 't' : 'x',
        );
        for (var i = 0; i <= samples; i++) {
          final x = _viewport.minX + _viewport.spanX * i / samples;
          if (function.mode == PlotMode.polar) {
            final radius = compiled(x);
            if (!radius.isFinite) continue;
            final radians = angleMode.toRadians(x);
            final px = radius * math.cos(radians);
            final py = radius * math.sin(radians);
            if (!px.isFinite || !py.isFinite) continue;
            low = math.min(low, py);
            high = math.max(high, py);
            continue;
          }
          final y = compiled(x);
          if (!y.isFinite) continue;
          if (y.abs() > 1e12) continue;
          low = math.min(low, y);
          high = math.max(high, y);
        }
      } catch (_) {
        // 忽略出错的函数
      }
    }
    if (!low.isFinite || !high.isFinite || high - low < 1e-9) {
      viewport = _viewport.withYRange(-10, 10);
      return;
    }
    final padding = (high - low) * 0.12 + 1e-9;
    viewport = _viewport.withYRange(low - padding, high + padding);
  }

  /// 把视口移动到所有可见曲线所在区域。
  void fitAll(Size size) {
    var lowX = double.infinity;
    var highX = double.negativeInfinity;
    var lowY = double.infinity;
    var highY = double.negativeInfinity;
    const samples = 320;

    void include(Offset point) {
      if (!point.dx.isFinite || !point.dy.isFinite) return;
      if (point.dx.abs() > 1e10 || point.dy.abs() > 1e10) return;
      lowX = math.min(lowX, point.dx);
      highX = math.max(highX, point.dx);
      lowY = math.min(lowY, point.dy);
      highY = math.max(highY, point.dy);
    }

    for (final function in _functions) {
      if (!function.visible || !function.isValid) continue;
      try {
        final from = _viewport.minX;
        final to = _viewport.maxX;
        switch (function.mode) {
          case PlotMode.cartesian:
            final compiled = _compile(function.expression, 'x');
            for (var i = 0; i <= samples; i++) {
              final x = from + (to - from) * i / samples;
              final y = compiled(x);
              if (y.isFinite && y.abs() < 1e10) include(Offset(x, y));
            }
            break;
          case PlotMode.polar:
            final compiled = _compile(function.expression, 't');
            for (var i = 0; i <= samples; i++) {
              final t = from + (to - from) * i / samples;
              final radius = compiled(t);
              if (!radius.isFinite) continue;
              final radians = angleMode.toRadians(t);
              include(
                Offset(radius * math.cos(radians), radius * math.sin(radians)),
              );
            }
            break;
          case PlotMode.parametric:
            final fx = _compile(function.expression, 't');
            final fy = _compile(function.secondExpression, 't');
            for (var i = 0; i <= samples; i++) {
              final t = from + (to - from) * i / samples;
              include(Offset(fx(t), fy(t)));
            }
            break;
          case PlotMode.implicit:
            // 等值线的范围只能靠网格搜索，成本较高；保持当前视口不变。
            break;
        }
      } catch (_) {
        // 忽略
      }
    }

    if (!lowX.isFinite || !highX.isFinite || highX - lowX < 1e-6) {
      resetView(size);
      return;
    }
    final padX = (highX - lowX) * 0.08 + 1e-6;
    final padY = (highY - lowY) * 0.08 + 1e-6;
    viewport = PlotViewport(
      minX: lowX - padX,
      maxX: highX + padX,
      minY: lowY - padY,
      maxY: highY + padY,
    ).withEqualScale(size);
  }

  @override
  void dispose() {
    engine.removeListener(_onEngineChanged);
    super.dispose();
  }
}
