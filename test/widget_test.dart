import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/app.dart';
import 'package:free_clac/core/math_engine.dart';
import 'package:free_clac/plot/plot_export.dart';
import 'package:free_clac/services/saved_plot_file.dart';
import 'package:free_clac/state/plot_controller.dart';
import 'package:free_clac/ui/widgets/plot_export_dialog.dart';
import 'package:free_clac/ui/tools/bmi/bmi_page.dart';
import 'package:free_clac/ui/tools/compound/compound_page.dart';
import 'package:free_clac/ui/widgets/calc_display.dart';
import 'package:free_clac/ui/widgets/keypad.dart';
import 'package:free_clac/plot/plot_painter.dart';
import 'package:free_clac/ui/widgets/plot_canvas.dart';

void main() {
  Future<void> tapKey(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(of: find.byType(Keypad), matching: find.text(label)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const FreeCalcApp());
    await tester.pumpAndSettle();
  }

  testWidgets('桌面尺寸：键盘输入并计算 30° 的正弦', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    expect(find.byType(Keypad), findsOneWidget);

    await tapKey(tester, 'sin');
    await tapKey(tester, '3');
    await tapKey(tester, '0');
    await tapKey(tester, ')');
    await tapKey(tester, '=');

    // 显示屏上的实时结果与历史记录都应出现 0.5
    expect(find.text('0.5'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('表达式错误时展示提示且不崩溃', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tapKey(tester, '7');
    await tapKey(tester, '+');
    expect(find.textContaining('表达式不完整'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('切换到绘图页并平移画布', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    expect(find.byType(PlotCanvas), findsOneWidget);

    // 拖拽平移
    await tester.drag(find.byType(PlotCanvas), const Offset(-80, 40));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 缩放按钮
    await tester.tap(find.byTooltip('放大（+）'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图画布：方向按钮与键盘平移视图', (tester) async {
    final controller = PlotController(engine: MathEngine());
    tester.view.physicalSize = const Size(900, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: PlotCanvas(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final start = controller.viewport;

    // 上移视图：y 范围整体变大，比例不变
    await tester.tap(find.byTooltip('上移视图（↑）'));
    await tester.pumpAndSettle();
    expect(controller.viewport.minY, greaterThan(start.minY));
    expect(controller.viewport.spanY, closeTo(start.spanY, 1e-6));
    expect(controller.viewport.minX, closeTo(start.minX, 1e-6));

    // 右移视图：向右看，minX 变大
    final afterUp = controller.viewport;
    await tester.tap(find.byTooltip('右移视图（→）'));
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, greaterThan(afterUp.minX));
    expect(controller.viewport.spanX, closeTo(afterUp.spanX, 1e-6));

    // 键盘 ← 向左看
    final afterButton = controller.viewport;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, lessThan(afterButton.minX));

    // 键盘 ↓ 向下看
    final afterLeft = controller.viewport;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(controller.viewport.minY, lessThan(afterLeft.minY));

    // 键盘 0 重置视图
    await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
    await tester.pumpAndSettle();
    expect(controller.viewport.minX, closeTo(start.minX, 1e-6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：布局不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    expect(find.byType(Keypad), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(find.byType(PlotCanvas), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：进入并打开 BMI 计算', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.text('BMI 计算'), findsOneWidget);
    expect(find.text('复利计算'), findsOneWidget);
    // 卡片上不再出现「打开」角标
    expect(find.text('打开'), findsNothing);

    await tester.tap(find.text('BMI 计算'));
    await tester.pumpAndSettle();

    // 工具在「工具」tab 内打开，外层导航菜单保留
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(BmiPage), findsOneWidget);

    // 默认 170 cm / 65 kg → BMI 22.5，属于正常
    expect(find.text('22.5'), findsOneWidget);
    expect(find.text('正常'), findsWidgets);

    // 体重改成 80 kg → 27.7，进入超重
    await tester.enterText(find.byType(TextField).at(1), '80');
    await tester.pumpAndSettle();
    expect(find.text('27.7'), findsOneWidget);
    expect(find.text('超重'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('BMI：公制 / 英制与 ft·in 切换', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('BMI 计算'));
    await tester.pumpAndSettle();

    // 默认公制：cm / kg
    expect(find.text('cm'), findsOneWidget);
    expect(find.text('kg'), findsOneWidget);
    expect(find.textContaining('身高 170 cm'), findsOneWidget);

    // 切到英制：170 cm / 65 kg → 5.58 ft / 143.3 lb，BMI 不变
    await tester.tap(find.text('英制'));
    await tester.pumpAndSettle();
    expect(find.text('lb'), findsOneWidget);
    expect(find.text('cm'), findsNothing);
    // 身高仍然只有一个输入框（右侧下拉切换 ft / in）
    expect(find.text('身高'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('5.58'), findsOneWidget);
    expect(find.textContaining('身高 5.58 ft'), findsOneWidget);
    // 身高单位（ft ▾）与体重单位（lb）上下齐平
    expect(
      tester.getCenter(find.text('ft')).dy,
      closeTo(tester.getCenter(find.text('lb')).dy, 1),
    );
    expect(find.textContaining('143.3 lb'), findsWidgets);
    expect(find.text('22.5'), findsOneWidget);

    // 身高单位 ft → in：仍是同一个输入框，数值换算
    await tester.tap(find.text('ft'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('in（英寸）'));
    await tester.pumpAndSettle();
    expect(find.text('66.96'), findsOneWidget);
    expect(find.textContaining('身高 66.96 in'), findsOneWidget);
    expect(find.text('22.5'), findsOneWidget);

    // 改成 5 ft 7 in（67 in）、165 lb → BMI 25.8，超重
    await tester.enterText(find.byType(TextField).at(0), '67');
    await tester.enterText(find.byType(TextField).at(1), '165');
    await tester.pumpAndSettle();
    expect(find.text('25.8'), findsOneWidget);
    expect(find.text('超重'), findsWidgets);

    // 切回公制：身高 170.2 cm、体重 74.8 kg
    await tester.tap(find.text('公制'));
    await tester.pumpAndSettle();
    expect(find.text('cm'), findsOneWidget);
    expect(find.textContaining('170.2 cm'), findsOneWidget);
    expect(find.textContaining('74.8 kg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：复利计算显示本息与逐年表格', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('复利计算'));
    await tester.pumpAndSettle();

    // 10 万本金、5% 年利率、10 年，按年计息 → 162,889.46
    expect(find.textContaining('162,889.46'), findsOneWidget);
    expect(find.text('¥ 62,889.46'), findsOneWidget);
    expect(find.text('逐年增长'), findsOneWidget);
    expect(find.text('第 1 年'), findsOneWidget);

    // 切换成按月计息后金额变高
    await tester.tap(find.text('每月'));
    await tester.pumpAndSettle();
    expect(find.textContaining('164,700.95'), findsOneWidget);
    expect(find.textContaining('每月计息'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：打开工具后可与其它 tab 来回切换', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('复利计算'));
    await tester.pumpAndSettle();

    // 工具页内仍能看到导航菜单
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.text('计算'), findsOneWidget);
    expect(find.text('绘图'), findsOneWidget);

    // 切到计算器再切回工具，工具页面不丢
    await tester.tap(find.text('计算'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.byType(CompoundPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：深链 ?tool=bmi 直接打开工具并可返回', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'bmi'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BmiPage), findsOneWidget);
    expect(find.text('22.5'), findsOneWidget);
    // 深链打开工具时导航菜单同样保留
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(BmiPage), findsNothing);
    expect(find.text('复利计算'), findsOneWidget);
  });

  testWidgets('工具页：手机尺寸下卡片与工具页不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    expect(find.text('BMI 计算'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('BMI 计算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 手机上打开工具后底部菜单仍在
    expect(find.byType(NavigationBar), findsOneWidget);

    // 手机上英制输入也不溢出
    await tester.tap(find.text('英制'));
    await tester.pumpAndSettle();
    expect(find.text('ft'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('复利计算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('平板尺寸：绘图页切换导航不溢出', (tester) async {
    await pumpApp(tester, const Size(900, 1200));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('计算'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：添加曲线、编辑表达式、错误提示与删除', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    // 初始有两条默认曲线
    expect(find.byType(TextField), findsNWidgets(2));

    // 通过 + 菜单新增一条直角坐标曲线
    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('直角坐标 y = f(x)').last);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(3));

    // 输入非法表达式应给出错误提示
    await tester.enterText(find.byType(TextField).last, 'x+');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsWidgets);

    // 改成合法表达式后错误消失
    await tester.enterText(find.byType(TextField).last, 'x^2 - 3');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：切换到参数方程需要两个表达式', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('参数方程').last);
    await tester.pumpAndSettle();

    // 2 条默认 + 参数方程的两行
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('y ='), findsNWidgets(3));
    expect(find.text('x ='), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：添加隐式方程曲线并输入表达式', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('添加曲线'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('隐式方程 f(x, y) = 0').last);
    await tester.pumpAndSettle();

    // 2 条默认曲线 + 隐式方程的一行输入框
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('0 ='), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, '(x^2+y^2-1)^3-x^2y^3');
    await tester.pumpAndSettle();
    expect(find.textContaining('不完整'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：追踪模式与纵向自适应', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('纵向自适应'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('显示全部'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('重置视图（0）'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('开启触摸追踪（拖动查看数值）'));
    await tester.pumpAndSettle();

    // 开启追踪后拖动应出现读数
    await tester.drag(find.byType(PlotCanvas), const Offset(-40, 0));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('乘号按键显示 * 并参与计算', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    expect(
      find.descendant(of: find.byType(Keypad), matching: find.text('*')),
      findsOneWidget,
    );

    await tapKey(tester, '7');
    await tapKey(tester, '*');
    await tapKey(tester, '8');
    await tapKey(tester, '=');

    expect(find.text('56'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：示例追加曲线且不把已有图形挤出视野', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    final canvasSize = tester.getSize(find.byType(PlotCanvas));
    final before = _plotPainter(tester);
    expect(before.samples.length, 2);
    final beforeViewport = before.viewport;

    await tester.tap(find.byTooltip('示例曲线'));
    await tester.pumpAndSettle();
    expect(find.text('示例曲线'), findsWidgets);
    expect(find.text('心形 · 参数方程'), findsOneWidget);

    await tester.tap(find.text('心形 · 参数方程'));
    await tester.pumpAndSettle();

    // 示例只追加曲线：默认两条 + 参数方程的两行输入
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.textContaining('16sin(t)^3'), findsWidgets);
    expect(find.textContaining('0.12x^2 - 2'), findsWidgets);
    expect(find.textContaining('已添加示例'), findsOneWidget);

    // 画布实际绘制的曲线条数增加，且原有曲线仍在视野内
    final after = _plotPainter(tester);
    // 默认两条 + 参数方程一条
    expect(after.samples.length, 3);
    expect(after.viewport.minX, lessThanOrEqualTo(beforeViewport.minX));
    expect(after.viewport.maxX, greaterThanOrEqualTo(beforeViewport.maxX));
    expect(after.viewport.minY, lessThanOrEqualTo(beforeViewport.minY));
    expect(after.viewport.maxY, greaterThanOrEqualTo(beforeViewport.maxY));
    for (final sample in after.samples.take(2)) {
      final visible = sample.curve.segments
          .expand((segment) => segment)
          .any(
            (point) => after.viewport.containsData(
              after.viewport.toData(point, canvasSize),
            ),
          );
      expect(visible, isTrue, reason: sample.function.expression);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：连续载入两个示例后曲线都还在视野内', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    for (final name in ['心形 · 极坐标', '玫瑰线']) {
      await tester.tap(find.byTooltip('示例曲线'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(name));
      await tester.pumpAndSettle();
    }

    final canvasSize = tester.getSize(find.byType(PlotCanvas));
    final painter = _plotPainter(tester);
    // 两条默认曲线 + 心形 + 玫瑰线
    expect(painter.samples.length, 4);
    for (final sample in painter.samples) {
      final visible = sample.curve.segments
          .expand((segment) => segment)
          .any(
            (point) => painter.viewport.containsData(
              painter.viewport.toData(point, canvasSize),
            ),
          );
      expect(visible, isTrue, reason: sample.function.expression);
    }
    expect(find.textContaining('已添加示例'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('绘图页：导出对话框可打开并切换格式', (tester) async {
    await pumpApp(tester, const Size(1200, 800));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('导出图片（PNG / SVG / WebP）'));
    await tester.pumpAndSettle();

    expect(find.text('导出图片'), findsOneWidget);
    for (final format in ['PNG', 'WebP', 'SVG']) {
      expect(find.text(format), findsWidgets);
    }
    // 默认 PNG：位图尺寸按 2 倍图显示
    expect(find.textContaining('2 倍图'), findsOneWidget);

    await tester.tap(find.text('SVG'));
    await tester.pumpAndSettle();
    expect(find.textContaining('可无限缩放'), findsOneWidget);

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('导出图片'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('导出对话框：选 WebP 后保存，结果交给保存器', (tester) async {
    final controller = PlotController(engine: MathEngine());
    controller.reportCanvasSize(const Size(200, 150));
    PlotExportFile? captured;
    SavedPlotFile? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  saved = await showDialog<SavedPlotFile>(
                    context: context,
                    builder: (_) => PlotExportDialog(
                      controller: controller,
                      // 渲染位图依赖引擎线程，Widget 测试里换成固定字节
                      exporter: const _FakeExporter(),
                      saver: (file) async {
                        captured = file;
                        return SavedPlotFile(
                          location: '/tmp/${file.fileName}',
                          fileName: file.fileName,
                        );
                      },
                    ),
                  );
                },
                child: const Text('打开'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('WebP'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(captured, isNotNull);
    expect(captured!.fileName, endsWith('.webp'));
    expect(captured!.mimeType, 'image/webp');
    expect(String.fromCharCodes(captured!.bytes.sublist(0, 4)), 'RIFF');
    expect(saved?.fileName, captured!.fileName);
    expect(find.text('导出图片'), findsNothing);
  });

  testWidgets('手机尺寸：示例面板可滚动且不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('示例曲线'));
    await tester.pumpAndSettle();
    expect(find.text('心形 · 极坐标'), findsOneWidget);

    // 列表可滚动到末尾，底部来源信息可见
    await tester.drag(find.byType(ListView).last, const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.textContaining('zhuanlan.zhihu.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机横屏：绘图页使用左右布局且不溢出', (tester) async {
    await pumpApp(tester, const Size(844, 390));
    await tester.tap(find.text('绘图'));
    await tester.pumpAndSettle();
    expect(find.byType(PlotCanvas), findsOneWidget);

    // 画布应占据左侧大部分宽度
    final canvas = tester.getSize(find.byType(PlotCanvas));
    expect(canvas.width, greaterThan(400));
    expect(canvas.height, greaterThan(240));
    expect(tester.takeException(), isNull);
  });

  group('复制为 LaTeX', () {
    String? clipboard;

    setUp(() {
      clipboard = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              clipboard = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('显示屏：复制公式为 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, 'sin');
      await tapKey(tester, '3');
      await tapKey(tester, '0');
      await tapKey(tester, ')');

      await tester.tap(find.byTooltip('复制'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, r'\sin\left(30\right)');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });

    testWidgets('显示屏：复制公式与结果', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, 'sin');
      await tapKey(tester, '3');
      await tapKey(tester, '0');
      await tapKey(tester, ')');

      await tester.tap(find.byTooltip('复制'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式与结果（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, r'\sin\left(30\right) = 0.5');
    });

    testWidgets('绘图页：复制曲线 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tester.tap(find.text('绘图'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('复制 LaTeX').first);
      await tester.pumpAndSettle();

      expect(clipboard, r'y = \sin\left(x\right)');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });

    testWidgets('历史记录：复制 LaTeX', (tester) async {
      await pumpApp(tester, const Size(1440, 900));

      await tapKey(tester, '1');
      await tapKey(tester, '+');
      await tapKey(tester, '2');
      await tapKey(tester, '=');

      await tester.tap(find.byTooltip('复制这条记录').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('复制公式（LaTeX）'));
      await tester.pumpAndSettle();

      expect(clipboard, '1 + 2');
      expect(find.text('LaTeX 已复制'), findsOneWidget);
    });
  });

  testWidgets('方向键翻阅历史记录', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tapKey(tester, '1');
    await tapKey(tester, '+');
    await tapKey(tester, '2');
    await tapKey(tester, '=');
    await tapKey(tester, 'AC');

    final field = find.descendant(
      of: find.byType(CalcDisplay),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(field).controller!.text, isEmpty);

    await tester.tap(field);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(field).controller!.text, '1+2');
  });
}

/// 固定内容的导出器：避免 Widget 测试等待引擎渲染位图。
class _FakeExporter extends PlotExporter {
  const _FakeExporter();

  @override
  Future<PlotExportFile> export({
    required PlotController controller,
    required Size size,
    required PlotImageFormat format,
    String name = 'plot',
    DateTime? now,
  }) async {
    return PlotExportFile(
      fileName: plotExportFileName(format, name: name, now: now),
      bytes: Uint8List.fromList(<int>[
        ...'RIFF'.codeUnits,
        0,
        0,
        0,
        0,
        ...'WEBP'.codeUnits,
      ]),
      mimeType: format.mimeType,
    );
  }
}

/// 取绘图画布当前使用的绘制器。
PlotPainter _plotPainter(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((widget) => widget.painter)
    .whereType<PlotPainter>()
    .single;
