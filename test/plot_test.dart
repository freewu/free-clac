import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/core/angle_mode.dart';
import 'package:free_clac/core/math_engine.dart';
import 'package:free_clac/models/plot_function.dart';
import 'package:free_clac/plot/curve_sampler.dart';
import 'package:free_clac/plot/plot_presets.dart';
import 'package:free_clac/plot/plot_viewport.dart';
import 'package:free_clac/state/plot_controller.dart';
import 'package:free_clac/ui/widgets/plot_canvas.dart' show PlotCanvas;

void main() {
  const size = Size(800, 500);

  group('视口', () {
    test('屏幕与数据坐标可互相转换', () {
      const viewport = PlotViewport(minX: -10, maxX: 10, minY: -5, maxY: 5);
      final screen = viewport.toScreen(0, 0, size);
      expect(screen.dx, closeTo(400, 1e-9));
      expect(screen.dy, closeTo(250, 1e-9));
      final data = viewport.toData(screen, size);
      expect(data.dx, closeTo(0, 1e-9));
      expect(data.dy, closeTo(0, 1e-9));
    });

    test('等比缩放后 x/y 单位长度一致', () {
      const viewport = PlotViewport(minX: -10, maxX: 10, minY: -5, maxY: 5);
      final equal = viewport.withEqualScale(size);
      final unitX = size.width / equal.spanX;
      final unitY = size.height / equal.spanY;
      expect(unitX, closeTo(unitY, 1e-6));
      expect(equal.containsData(const Offset(0, 0)), isTrue);
    });

    test('拖拽像素与缩放保持中心', () {
      const viewport = PlotViewport(minX: -10, maxX: 10, minY: -10, maxY: 10);
      final panned = viewport.pannedByPixels(const Offset(80, 0), size);
      // 向右拖拽 → 数据向左移动
      expect(panned.minX, lessThan(viewport.minX));
      expect(panned.spanX, closeTo(viewport.spanX, 1e-9));

      final zoomed = viewport.zoomedAt(const Offset(0, 0), 2, size);
      expect(zoomed.spanX, lessThan(viewport.spanX));
      expect(zoomed.centerX, closeTo(0, 1e-9));
    });
  });

  group('采样器', () {
    const sampler = CurveSampler();

    test('正弦曲线为单段且覆盖整个视口', () {
      const viewport = PlotViewport(minX: -10, maxX: 10, minY: -2, maxY: 2);
      final curve = sampler.cartesian(
        evaluate: math.sin,
        viewport: viewport,
        size: size,
      );
      expect(curve.segments.length, 1);
      expect(curve.pointCount, greaterThan(700));
      final first = curve.segments.first.first;
      final last = curve.segments.first.last;
      expect(first.dx, closeTo(0, 1.0));
      expect(last.dx, closeTo(size.width, 1.0));
      // 曲线始终落在 y ∈ [-1, 1] 对应的屏幕区间内
      for (final segment in curve.segments) {
        for (final point in segment) {
          expect(point.dy, inInclusiveRange(125, 375));
        }
      }
    });

    test('断点会拆分成多段（1/x）', () {
      const viewport = PlotViewport(minX: -10, maxX: 10, minY: -10, maxY: 10);
      final curve = sampler.cartesian(
        evaluate: (x) => 1 / x,
        viewport: viewport,
        size: size,
      );
      expect(curve.segments.length, greaterThanOrEqualTo(2));
    });

    test('极坐标按角度模式取样', () {
      const viewport = PlotViewport(minX: -5, maxX: 5, minY: -5, maxY: 5);
      final degrees = sampler.polar(
        evaluateRadius: (t) => 3,
        viewport: viewport,
        size: size,
        angleMode: AngleMode.degrees,
      );
      expect(degrees.isEmpty, isFalse);
      // 半径 3 的圆：所有点距原点约 3 个单位
      final center = viewport.toScreen(0, 0, size);
      final scale = size.width / viewport.spanX;
      for (final segment in degrees.segments) {
        for (final point in segment) {
          final distance = (point - center).distance / scale;
          expect(distance, closeTo(3, 0.15));
        }
      }
    });

    test('参数方程采样闭合曲线', () {
      const viewport = PlotViewport(minX: -5, maxX: 5, minY: -5, maxY: 5);
      final curve = sampler.parametric(
        evaluateX: (t) => 2 * math.cos(t),
        evaluateY: (t) => 2 * math.sin(t),
        viewport: viewport,
        size: size,
      );
      expect(curve.isEmpty, isFalse);
      expect(curve.pointCount, greaterThan(300));
    });

    test('隐式方程采样单位圆等值线', () {
      const viewport = PlotViewport(minX: -2, maxX: 2, minY: -2, maxY: 2);
      final curve = sampler.implicit(
        evaluate: (x, y) => x * x + y * y - 1,
        viewport: viewport,
        size: size,
        cellSize: 3,
      );
      expect(curve.isEmpty, isFalse);
      expect(curve.pointCount, greaterThan(200));
      // 闭合等值线应被拼接成一条折线（至多因起点断开成两段）
      expect(curve.segments.length, lessThanOrEqualTo(2));

      for (final segment in curve.segments) {
        for (final point in segment) {
          final data = viewport.toData(point, size);
          expect(data.distance, closeTo(1, 0.02));
        }
      }
    });

    test('隐式方程无解时返回空曲线', () {
      const viewport = PlotViewport(minX: -2, maxX: 2, minY: -2, maxY: 2);
      final curve = sampler.implicit(
        evaluate: (x, y) => x * x + y * y + 1,
        viewport: viewport,
        size: size,
      );
      expect(curve.isEmpty, isTrue);
    });

    test('隐式方程遇到无定义区域不会崩溃', () {
      const viewport = PlotViewport(minX: -2, maxX: 2, minY: -2, maxY: 2);
      final curve = sampler.implicit(
        evaluate: (x, y) => x == 0 ? double.nan : y - 1 / x,
        viewport: viewport,
        size: size,
      );
      // 双曲线 y = 1/x 的两支都能画出来
      expect(curve.segments.length, greaterThanOrEqualTo(2));
    });
  });

  group('绘图控制器', () {
    test('默认曲线可采样且追踪有读数', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      final samples = controller.buildSamples(size);
      expect(samples.length, 2);
      for (final sample in samples) {
        expect(sample.error, isNull);
        expect(sample.curve.isEmpty, isFalse);
      }

      final values = controller.traceValues(0);
      expect(values.length, 2);
      expect(values.first.text, contains('y ='));
    });

    test('新增极坐标与参数方程曲线可正常采样', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      controller.addFunction(mode: PlotMode.polar);
      controller.addFunction(mode: PlotMode.parametric);
      expect(controller.functions.length, 4);

      for (final function in controller.functions) {
        expect(controller.validate(function), isNull);
      }
      final samples = controller.buildSamples(size);
      expect(samples.length, 4);
      for (final sample in samples) {
        expect(sample.error, isNull, reason: sample.function.title);
        expect(
          sample.curve.pointCount,
          greaterThan(0),
          reason: sample.function.title,
        );
      }
    });

    test('新增隐式曲线可采样、校验与追踪', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      controller.viewport = const PlotViewport(
        minX: -2,
        maxX: 2,
        minY: -2,
        maxY: 2,
      );
      final added = controller.addFunction(mode: PlotMode.implicit);
      expect(added.mode, PlotMode.implicit);
      expect(added.title, startsWith('0 = '));
      expect(controller.validate(added), isNull);

      final sample = controller.buildSamples(size).last;
      expect(sample.error, isNull);
      expect(sample.curve.pointCount, greaterThan(100));

      final values = controller.traceValues(0.5, y: 0.5);
      expect(values.last.text, startsWith('f = '));

      controller.updateExpression(added.id, expression: 'x+');
      expect(controller.validate(controller.functions.last), isNotNull);
    });

    test('非法表达式给出错误且不影响其它曲线', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      final added = controller.addFunction();
      controller.updateExpression(added.id, expression: 'x+');
      expect(controller.validate(controller.functions.last), isNotNull);

      final samples = controller.buildSamples(size);
      expect(samples.first.curve.isEmpty, isFalse);
    });

    test('纵向自适应与显示全部改变视口', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      final before = controller.viewport;
      controller.fitY(size);
      expect(controller.viewport.minY, isNot(before.minY));

      controller.fitAll(size);
      expect(controller.viewport.containsData(const Offset(0, 0)), isTrue);

      controller.resetView(size);
      expect(controller.viewport.minX, closeTo(-10, 1e-6));
    });

    test('角度模式切换后极坐标重新采样', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      controller.addFunction(mode: PlotMode.polar);
      final before = controller.revision;
      engine.angleMode = AngleMode.radians;
      expect(controller.revision, greaterThan(before));
      expect(engine.angleMode, AngleMode.radians);
    });

    test('默认参数区间跟随角度模式', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      expect(controller.parameterDomain.$1, 0);
      expect(controller.parameterDomain.$2, closeTo(360, 1e-9));

      engine.angleMode = AngleMode.radians;
      expect(controller.parameterDomain.$2, closeTo(2 * math.pi, 1e-9));
    });

    test('参数区间缺省时回退到视口范围', () {
      const viewport = PlotViewport(minX: -3, maxX: 3, minY: -3, maxY: 3);
      const sampler = CurveSampler();
      final curve = sampler.polar(
        evaluateRadius: (t) => 1,
        viewport: viewport,
        size: size,
        angleMode: AngleMode.radians,
      );
      // 半径恒为 1 时，采样点全部落在单位圆上
      final points = curve.segments.expand((segment) => segment).toList();
      expect(points, isNotEmpty);
      for (final point in points) {
        final data = viewport.toData(point, size);
        expect(data.distance, closeTo(1, 0.05));
      }
    });

    test('示例曲线全部可编译且能采样出可见曲线', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      expect(kPlotPresets, isNotEmpty);
      for (final preset in kPlotPresets) {
        for (final requested in <AngleMode>[
          AngleMode.degrees,
          AngleMode.radians,
        ]) {
          engine.angleMode = requested;
          // 载入示例（必要时示例会把角度模式切回自己需要的一种）
          controller.applyPreset(preset, replaceAll: true);
          if (preset.angleMode != null) {
            expect(engine.angleMode, preset.angleMode, reason: preset.name);
          }
          _expectPresetRenders(controller, preset, size, requested);
        }
      }
    });

    test('示例曲线追加到画布而不清空已有曲线', () {
      final engine = MathEngine();
      final controller = PlotController(engine: engine);
      addTearDown(controller.dispose);

      final before = controller.functions
          .map((function) => function.expression)
          .toList();
      final initialViewport = controller.viewport;
      final preset = kPlotPresets.firstWhere(
        (preset) => preset.name.contains('参数方程'),
      );

      expect(controller.applyPreset(preset), preset.curves.length);
      expect(controller.functions.length, before.length + preset.curves.length);
      // 原有曲线仍在，且排在前面
      expect(
        controller.functions
            .take(before.length)
            .map((function) => function.expression),
        before,
      );
      // 视口取并集：既有视口与示例视口都在视野内，不会“看起来被清空”
      expect(controller.viewport, initialViewport.union(preset.viewport));
      expect(controller.buildSamples(size).length, controller.functions.length);

      // 再追加另一个示例：曲线继续累积，视口仍是并集
      final second = kPlotPresets.firstWhere((preset) => preset.name == '玫瑰线');
      final afterFirst = controller.viewport;
      expect(controller.applyPreset(second), second.curves.length);
      expect(controller.viewport, afterFirst.union(second.viewport));
      expect(
        controller.functions.length,
        before.length + preset.curves.length + second.curves.length,
      );

      // 重复载入不会叠加重复曲线
      expect(controller.applyPreset(preset), 0);
      expect(
        controller.functions.length,
        before.length + preset.curves.length + second.curves.length,
      );
    });
  });

  test('示例：填充爱心在两种角度模式下都能铺满区域', () {
    final engine = MathEngine();
    final controller = PlotController(engine: engine);
    addTearDown(controller.dispose);

    final preset = kPlotPresets.firstWhere(
      (preset) => preset.name.contains('填充'),
    );
    controller.applyPreset(preset, replaceAll: true);
    final samples = controller.buildSamples(size);
    final curve = samples.single.curve;
    expect(curve.isEmpty, isFalse);

    // 高频正弦会让折线反复上下扫：累计长度远超单条曲线的跨度
    var length = 0.0;
    for (final segment in curve.segments) {
      for (var i = 1; i < segment.length; i++) {
        length += (segment[i] - segment[i - 1]).distance;
      }
    }
    final span = size.height;
    expect(length, greaterThan(span * 20), reason: '正弦项应该产生密集的上下扫线');
  });

  testWidgets('绘图画布可渲染并响应缩放', (tester) async {
    final engine = MathEngine();
    final controller = PlotController(engine: engine);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: size.width,
            height: size.height,
            child: PlotCanvas(controller: controller),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(PlotCanvas), findsOneWidget);

    final zoomBefore = controller.viewport.spanX;
    await tester.tap(find.byTooltip('放大（+）'));
    await tester.pumpAndSettle();
    expect(controller.viewport.spanX, lessThan(zoomBefore));
    expect(tester.takeException(), isNull);
  });
}

/// 断言示例在给定角度模式下采样正常且落在画面内。
void _expectPresetRenders(
  PlotController controller,
  PlotPreset preset,
  Size size,
  AngleMode requested,
) {
  final samples = controller.buildSamples(size);
  expect(samples.length, preset.curves.length, reason: preset.name);
  for (final sample in samples) {
    expect(sample.error, isNull, reason: '${preset.name}: ${sample.error}');
    expect(
      sample.curve.pointCount,
      greaterThan(50),
      reason: '${preset.name} ${requested.shortLabel} ${sample.function.title}',
    );
    final visible = sample.curve.segments
        .expand((segment) => segment)
        .where(
          (point) =>
              Rect.fromLTWH(0, 0, size.width, size.height).contains(point),
        );
    expect(
      visible.length,
      greaterThan(20),
      reason: '${preset.name} ${requested.shortLabel} ${sample.function.title}',
    );
  }
}
