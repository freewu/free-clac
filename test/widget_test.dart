import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/app.dart';
import 'package:free_clac/core/math_engine.dart';
import 'package:free_clac/plot/plot_export.dart';
import 'package:free_clac/l10n/app_language.dart';
import 'package:free_clac/services/plot_file_saver.dart';
import 'package:free_clac/services/settings_store.dart';
import 'package:free_clac/state/plot_controller.dart';
import 'package:free_clac/state/settings_controller.dart';
import 'package:free_clac/theme/app_theme.dart';
import 'package:free_clac/ui/settings_page.dart';
import 'package:free_clac/ui/tools/tool_catalog.dart';
import 'package:free_clac/ui/tools/bmi/bmi.dart';
import 'package:free_clac/ui/tools/loan/loan.dart';
import 'package:free_clac/ui/widgets/calc_display.dart';
import 'package:free_clac/ui/widgets/plot_export_dialog.dart';
import 'package:free_clac/ui/tools/area/area_page.dart';
import 'package:free_clac/ui/tools/bmi/bmi_page.dart';
import 'package:free_clac/ui/tools/compound/compound_page.dart';
import 'package:free_clac/ui/tools/distance/distance_page.dart';
import 'package:free_clac/ui/tools/interest/interest_page.dart';
import 'package:free_clac/ui/tools/loan/loan_page.dart';
import 'package:free_clac/ui/tools/pension/pension_page.dart';
import 'package:free_clac/ui/tools/retirement/retirement_page.dart';
import 'package:free_clac/ui/tools/speed/speed_page.dart';
import 'package:free_clac/ui/tools/tax/tax_page.dart';
import 'package:free_clac/ui/tools/temperature/temperature_page.dart';
import 'package:free_clac/ui/tools/volume/volume_page.dart';
import 'package:free_clac/ui/tools/weight/weight_page.dart';
import 'package:free_clac/ui/tools/widgets/tool_bars.dart';
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
    expect(find.text('利率计算'), findsOneWidget);
    expect(find.text('贷款计算器'), findsOneWidget);
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
    // 单位不能把输入区挤没（曾经 suffixIcon 里的 Center 撑满整行，
    // 导致输入框里的数值完全看不见）
    final fields = find.byType(TextField);
    expect(
      tester.getSize(find.byType(EditableText).at(0)).width,
      greaterThan(120),
    );
    expect(
      tester.getSize(find.byType(EditableText).at(1)).width,
      greaterThan(120),
    );
    // 单位各自贴在自己输入框的右侧
    final heightRight = tester.getRect(fields.at(0)).right;
    final weightRight = tester.getRect(fields.at(1)).right;
    expect(
      tester.getRect(find.text('ft')).right,
      greaterThan(heightRight - 60),
    );
    expect(
      tester.getRect(find.text('lb')).right,
      greaterThan(weightRight - 60),
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

  testWidgets('复利计算：本金 / 利率 / 年限按 2 : 1 : 1 排一行', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('复利计算'));
    await tester.pumpAndSettle();

    final principal = tester.getSize(find.byType(TextField).at(0)).width;
    final rate = tester.getSize(find.byType(TextField).at(1)).width;
    final years = tester.getSize(find.byType(TextField).at(2)).width;
    // 本金占两份宽度，利率与年限各一份
    expect(principal, closeTo(rate * 2, 1.5));
    expect(years, closeTo(rate, 0.5));
    // 三个输入框仍在同一行
    expect(
      tester.getTopLeft(find.byType(TextField).at(0)).dy,
      closeTo(tester.getTopLeft(find.byType(TextField).at(2)).dy, 0.5),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：退休年龄计算器按出生年月测算退休时间', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'retirement'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RetirementPage), findsOneWidget);
    // 默认 1985 年 6 月出生男职工：延迟拉满 63 岁，2048 年 6 月退休
    expect(find.text('2048 年 6 月'), findsOneWidget);
    expect(find.text('63 岁'), findsOneWidget);
    expect(find.text('20 年（2048 年退休）'), findsOneWidget);
    expect(find.text('2045 年 6 月 · 60 岁'), findsOneWidget);
    expect(find.text('2051 年 6 月 · 66 岁'), findsOneWidget);

    // 换成原 50 岁的女职工：55 岁退休，时间提前 8 年
    await tester.tap(find.byKey(const Key('retirement-group')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('女职工（工人）· 原 50 岁').last);
    await tester.pumpAndSettle();
    expect(find.text('2040 年 6 月'), findsOneWidget);
    expect(find.text('55 岁'), findsOneWidget);

    // 改出生年份：1990 年出生的男职工退休时间整体后移 5 年
    await tester.tap(find.byKey(const Key('retirement-group')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('男职工 · 原 60 岁').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('retirement-birth-year')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1990 年').last);
    await tester.pumpAndSettle();
    expect(find.text('2053 年 6 月'), findsOneWidget);
    expect(find.textContaining('已到 63 岁的改革目标'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：养老金计算器测算基础与个人账户养老金', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'pension'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PensionPage), findsOneWidget);
    expect(find.text('预计每月养老金'), findsOneWidget);
    expect(find.textContaining('计发 139 个月'), findsWidgets);
    // 增长假设默认收起
    expect(find.text('展开'), findsOneWidget);

    // 把增长率与记账利率归零，用「本金 + 8% 缴费」的简单口径核对
    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(5), '0');
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(6), '0');
    await tester.pumpAndSettle();

    // 30 岁缴到 60 岁：账户 5 万 + 360 个月 × 800 = 33.8 万 ÷ 139
    expect(find.text('¥ 5,581.65'), findsOneWidget);
    expect(find.text('¥ 3,150.00'), findsOneWidget);
    expect(find.text('¥ 2,431.65'), findsOneWidget);
    expect(find.textContaining('替代率 55.8%'), findsOneWidget);
    expect(find.textContaining('已缴 5 年 + 续缴 30 年 = 35 年'), findsOneWidget);

    // 改成 50 岁退休：计发月数变 195，个人账户养老金变少
    await tester.tap(find.byKey(const Key('pension-retire-age')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('50 岁 · 计发 195 个月').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('计发 195 个月'), findsWidgets);
    expect(find.text('¥ 5,581.65'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：养老金计算器输入框改多行且不溢出', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'pension'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PensionPage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      expect(
        tester.getSize(find.byType(EditableText).at(i)).width,
        greaterThanOrEqualTo(90),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('设置页：深链打开、切浅色主题后配色与保存都变了', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 3));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('外观'), findsOneWidget);
    expect(find.text('语言'), findsOneWidget);
    expect(find.text('跟随系统'), findsOneWidget);
    // 语言是一个下拉框，默认显示当前语言
    expect(find.byKey(const Key('settings-language')), findsOneWidget);
    expect(find.text('简体中文 · Chinese (Simplified)'), findsOneWidget);
    // 默认跟随系统（测试里系统是浅色）
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).theme?.brightness,
      Brightness.light,
    );

    await tester.tap(find.byKey(const Key('settings-theme-dark')));
    await tester.pumpAndSettle();
    expect(settings.themeMode, AppThemeMode.dark);
    expect(store.values['theme_mode'], 'dark');
    final themed = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(themed.theme?.brightness, Brightness.dark);
    expect(themed.theme?.scaffoldBackgroundColor, const Color(0xFF0A0E14));
  });

  testWidgets('浅色模式：计算器按键、显示屏与工具卡片都跟着变浅', (tester) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(store: _MemoryStore());
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-theme-light')));
    await tester.pumpAndSettle();

    // 切回计算器看按键：运算符键、强调键都不该再用深色配色的写死颜色
    await tester.tap(find.text('计算').last);
    await tester.pumpAndSettle();
    expect(AppColors.keyOperator, kLightPalette.keyOperator);

    DecoratedBox decoOf(String label) => tester.widget<DecoratedBox>(
      find
          .ancestor(of: find.text(label), matching: find.byType(DecoratedBox))
          .first,
    );

    final operatorKey = decoOf('÷').decoration as BoxDecoration;
    expect(operatorKey.color, kLightPalette.keyOperator);
    expect(operatorKey.color, isNot(kDarkPalette.keyOperator));

    final accentKey = decoOf('=').decoration as BoxDecoration;
    expect(accentKey.color, isNull);
    expect(
      (accentKey.gradient! as LinearGradient).colors.first,
      kLightPalette.primary,
    );

    // 显示屏渐变也不再是写死的深色
    final display = tester.widget<Container>(
      find.byKey(const Key('calc-display')),
    );
    final gradient = (display.decoration! as BoxDecoration).gradient!;
    expect((gradient as LinearGradient).colors, [
      kLightPalette.surface,
      kLightPalette.background,
    ]);

    // 工具卡片配色同样按当前主题取
    await tester.tap(find.text('工具').last);
    await tester.pumpAndSettle();
    expect(kTools.first.color, kLightPalette.tertiary);
    expect(kTools.first.color, isNot(kDarkPalette.tertiary));
  });

  testWidgets('设置页：换算默认体系与结果 tab 生效且各工具互不影响', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 3));
    await tester.pumpAndSettle();

    // 六个换算工具各有独立的一张卡片，各两项设置
    expect(find.text('单位换算默认值'), findsOneWidget);
    for (final id in [
      'distance',
      'area',
      'volume',
      'weight',
      'temperature',
      'speed',
    ]) {
      expect(find.byKey(Key('settings-convert-$id-system')), findsOneWidget);
      expect(find.byKey(Key('settings-convert-$id-tab')), findsOneWidget);
    }
    expect(find.text('默认体系'), findsNWidgets(6));
    expect(find.text('长度换算'), findsOneWidget);
    expect(find.text('容量换算'), findsOneWidget);
    expect(find.text('温度换算'), findsOneWidget);

    // 长度换算：默认体系切市制、结果 tab 切英制
    await tester.tap(find.byKey(const Key('settings-convert-distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-convert-distance-tab')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(store.values['convert.distance.system'], 'chinese');
    expect(store.values['convert.distance.tab'], 'imperial');

    // 打开长度换算：体系是市制，结果 tab 停在英制
    // （换 key 让 HomePage 重新初始化，否则会沿用上一次的 tab 状态）
    await tester.pumpWidget(
      FreeCalcApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 2,
        initialTool: 'distance',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.text('市制'), findsWidgets);
    final tabBar = tester.widget<TabBar>(find.byType(TabBar).last);
    expect(tabBar.controller?.index, 1);

    // 面积换算没设置过，仍是公制
    await tester.pumpWidget(
      FreeCalcApp(
        key: UniqueKey(),
        settings: settings,
        initialTab: 2,
        initialTool: 'area',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AreaPage), findsOneWidget);
    final areaTabs = tester.widget<TabBar>(find.byType(TabBar).last);
    expect(areaTabs.controller?.index, 0);
  });

  testWidgets('设置页：BMI 默认单位改成英制后 BMI 页按英制打开', (tester) async {
    tester.view.physicalSize = const Size(1440, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 3));
    await tester.pumpAndSettle();

    expect(find.text('BMI 默认单位'), findsOneWidget);
    expect(find.text('公制（cm / kg）'), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-bmi-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制（ft·in / lb）').last);
    await tester.pumpAndSettle();
    expect(settings.bmiUnit, BmiUnitSystem.imperial);
    expect(store.values['bmi_unit'], 'imperial');

    // 打开 BMI 工具：单位已经是英制，数值也换算成 ft / lb
    await tester.tap(find.text('工具').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('BMI 计算'));
    await tester.pumpAndSettle();
    expect(find.byType(BmiPage), findsOneWidget);
    expect(find.text('lb'), findsWidgets);
    expect(find.text('kg'), findsNothing);
    final height = tester
        .widget<EditableText>(find.byType(EditableText).first)
        .controller
        .text;
    // 170 cm ≈ 5.58 ft
    expect(double.parse(height), closeTo(5.58, 0.01));
  });

  testWidgets('设置页：切到日语后导航与工具卡片跟着变', (tester) async {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final store = _MemoryStore();
    final settings = SettingsController(store: store);
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 3));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語 · Japanese').last);
    await tester.pumpAndSettle();
    expect(settings.language, AppLanguage.ja);
    expect(store.values['language'], 'ja');
    // 导航栏文案换成日语
    expect(find.text('設定'), findsWidgets);
    expect(find.text('計算'), findsWidgets);
    expect(find.text('设置'), findsNothing);

    // 工具页卡片名称也换成日语
    await tester.tap(find.text('ツール').last);
    await tester.pumpAndSettle();
    expect(find.text('複利計算'), findsOneWidget);
    expect(find.text('ローン計算'), findsOneWidget);
    expect(find.text('复利计算'), findsNothing);
    // 养老金与个税只服务中国社保 / 税法，日语界面不展示
    expect(find.text('年金計算'), findsNothing);
    expect(find.text('所得税'), findsNothing);
    expect(find.text('10 個のアプリ'), findsOneWidget);
  });

  testWidgets('工具页：切回简体中文后养老金、个税与退休年龄又出现了', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(FreeCalcApp(settings: settings, initialTab: 2));
    await tester.pumpAndSettle();
    // 英文界面只有 10 个工具
    expect(find.text('10 apps'), findsOneWidget);
    expect(find.text('Pension calculator'), findsNothing);
    expect(find.text('Income tax'), findsNothing);

    // 切到设置页改成简体中文
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('settings-language')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('简体中文 · Chinese (Simplified)').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('工具').last);
    await tester.pumpAndSettle();
    expect(find.text('13 个应用'), findsOneWidget);
    expect(find.text('养老金计算器'), findsOneWidget);
    expect(find.text('退休年龄计算器'), findsOneWidget);
    expect(find.text('个人所得税'), findsOneWidget);
  });

  testWidgets('设置页：切换语言后工具卡片的深链 id 不变', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = SettingsController(
      store: _MemoryStore(),
      language: AppLanguage.en,
    );
    await tester.pumpWidget(
      FreeCalcApp(settings: settings, initialTab: 2, initialTool: 'bmi'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(BmiPage), findsOneWidget);
    expect(find.text('BMI'), findsWidgets);
    // 卡片文案已是英文，id 仍用于深链
    expect(
      kTools.map((tool) => tool.id),
      containsAll(<String>['bmi', 'loan', 'pension']),
    );
  });

  testWidgets('手机尺寸：复利计算利率 / 年限改两行且不溢出', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'compound'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CompoundPage), findsOneWidget);
    // 本金独占一行，利率与年限在下一行
    final principalY = tester.getTopLeft(find.byType(TextField).at(0)).dy;
    final rateY = tester.getTopLeft(find.byType(TextField).at(1)).dy;
    expect(rateY, greaterThan(principalY));
    expect(
      tester.getTopLeft(find.byType(TextField).at(2)).dy,
      closeTo(rateY, 0.5),
    );
    for (var i = 0; i < 3; i++) {
      expect(
        tester.getSize(find.byType(EditableText).at(i)).width,
        greaterThanOrEqualTo(60),
      );
    }
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

  testWidgets('利率计算：期付 ⇄ 年化双向换算', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('利率计算'));
    await tester.pumpAndSettle();
    expect(find.byType(InterestPage), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);

    // 输入框文案不能重复「每」：每天收益 / 每月收益 / 每年收益
    expect(find.text('每天收益'), findsOneWidget);
    expect(find.text('每每天收益'), findsNothing);
    expect(find.text('元 / 每天'), findsOneWidget);

    // 默认：本金 10000 元、日付 1 元 → 年化 3.65%
    expect(find.text('3.65%'), findsWidgets);
    expect(find.text('¥ 30.42'), findsWidgets);
    expect(find.text('¥ 365.00'), findsWidgets);

    // 换成月付，金额按当前年化率换算成 30.42 元，年化率不变
    // 周期选项在结果区也有同名标签，这里点第一个（选项按钮）
    await tester.tap(find.text('月付').first);
    await tester.pumpAndSettle();
    expect(find.text('30.42'), findsOneWidget);
    expect(find.text('每月收益'), findsOneWidget);
    expect(find.text('每每月收益'), findsNothing);
    expect(find.text('3.65%'), findsWidgets);

    // 月付改成 50 元 → 年化 6%
    await tester.enterText(find.byType(TextField).at(1), '50');
    await tester.pumpAndSettle();
    expect(find.text('6.00%'), findsWidgets);

    // 切到「由年化算期付」，年化率沿用 6%，月付 50 元
    await tester.tap(find.text('由年化算期付'));
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('¥ 50.00'), findsWidgets);

    // 年化率改 12% → 月付 100 元、日付 3.29 元
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.pumpAndSettle();
    expect(find.text('¥ 100.00'), findsWidgets);
    expect(find.text('¥ 3.29'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  test('贷款计算器：深链解析还款方式，无效值回落等额本息', () {
    expect(
      loanMethodFromQuery(const {'method': 'equalPrincipal'}),
      LoanMethod.equalPrincipal,
    );
    expect(
      loanMethodFromQuery(const {'method': 'equalInstallment'}),
      LoanMethod.equalInstallment,
    );
    expect(loanMethodFromQuery(const {}), LoanMethod.equalInstallment);
    expect(
      loanMethodFromQuery(const {'method': '乱写'}),
      LoanMethod.equalInstallment,
    );
  });

  testWidgets('贷款计算器：月供拆分与双色条', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('贷款计算器'));
    await tester.pumpAndSettle();
    expect(find.byType(LoanPage), findsOneWidget);

    // 默认：100 万、4.9%、30 年、等额本息 → 月供 5307.27
    // 等额本息每期金额相同，明细里也会出现同样的数字
    expect(find.text('¥ 5,307.27'), findsWidgets);
    expect(find.textContaining('总利息'), findsOneWidget);
    expect(find.text('¥ 910,616'), findsOneWidget);
    // 汇总条 + 每期明细条都画出来
    expect(find.byType(SegmentedBar), findsWidgets);
    // 等额本息每期还款额相同，不做倒梯形缩放
    expect(find.text('条长按当期还款额缩放：首期 100%，末期 60%'), findsNothing);

    // 三行金额条按金额区分长度：总还款 > 贷款总额 > 总利息
    expect(find.byType(AmountBar), findsNWidgets(3));
    double barWidth(String label) => tester
        .getSize(
          find.descendant(
            of: find.byKey(ValueKey('loan-bar-$label')),
            matching: find.byType(FractionallySizedBox),
          ),
        )
        .width;
    expect(barWidth('总还款'), greaterThan(barWidth('贷款总额')));
    expect(barWidth('贷款总额'), greaterThan(barWidth('总利息')));
    // 长度比 ≈ 金额比（1910616 / 910616 ≈ 2.1）
    expect(
      barWidth('总还款') / barWidth('总利息'),
      closeTo(1910616.19 / 910616.19, 0.05),
    );

    // 明细里第一期利息多于本金（等额本息前期特征）
    expect(find.text('本金 ¥ 1,224'), findsWidgets);
    expect(find.text('利息 ¥ 4,083'), findsWidgets);

    // 切等额本金：首月 6861.11，月供逐月递减
    await tester.tap(find.text('等额本金'));
    await tester.pumpAndSettle();
    expect(find.text('¥ 6,861.11'), findsWidgets);
    expect(find.textContaining('月供逐月递减'), findsOneWidget);
    expect(find.text('条长按当期还款额缩放：首期 100%，末期 60%'), findsOneWidget);

    // 明细条长逐期收窄，整体拼成倒梯形
    double periodBar(int index) =>
        tester.getSize(find.byKey(ValueKey('loan-period-bar-$index'))).width;
    expect(periodBar(1), greaterThan(periodBar(2)));
    expect(periodBar(2), greaterThan(periodBar(3)));

    // 按年汇总：30 行
    await tester.tap(find.text('按年'));
    await tester.pumpAndSettle();
    expect(find.text('第 1 年'), findsOneWidget);
    expect(find.text('当年还款'), findsOneWidget);

    // 期限单位 年 → 月 自动换算
    await tester.tap(find.text('年').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('月').last);
    await tester.pumpAndSettle();
    expect(find.text('360'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('工具页：长度换算用下拉框选体系单位，结果分三个 tab', (tester) async {
    // 结果行点击会写剪贴板，测试环境下不 mock 的话 Future 不会完成
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await pumpApp(tester, const Size(1440, 1600));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.byType(NavigationRail), findsOneWidget);

    // 「常见长度」在最上方，默认展开，点标题行可折叠隐藏
    final samplesY = tester
        .getTopLeft(find.byKey(const Key('distance-samples')))
        .dy;
    final inputY = tester.getTopLeft(find.text('输入')).dy;
    expect(samplesY, lessThan(inputY));
    expect(find.text('A4 纸厚'), findsOneWidget);
    expect(find.text('收起'), findsOneWidget);
    await tester.tap(find.text('收起'));
    await tester.pumpAndSettle();
    expect(find.text('A4 纸厚'), findsNothing);
    expect(find.text('展开'), findsOneWidget);
    // 折叠后输入区仍在原位（不因隐藏参照物而消失）
    expect(find.byKey(const Key('distance-system')), findsOneWidget);
    await tester.tap(find.text('展开'));
    await tester.pumpAndSettle();
    expect(find.text('A4 纸厚'), findsOneWidget);

    // 计量体系 / 单位都是下拉框，放在数值上方
    expect(find.byKey(const Key('distance-system')), findsOneWidget);
    expect(find.byKey(const Key('distance-unit')), findsOneWidget);
    final systemY = tester
        .getTopLeft(find.byKey(const Key('distance-system')))
        .dy;
    final fieldY = tester.getTopLeft(find.byType(TextField).first).dy;
    expect(systemY, lessThan(fieldY));

    // 默认 1 米：公制 tab 只列公制单位
    expect(find.text('1 米'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget); // 毫米
    expect(find.widgetWithText(Tab, '公制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '英制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '市制'), findsOneWidget);
    expect(find.text('英尺'), findsNothing);

    // 体系下拉切到英制：单位落到英寸，tab 跟着切到英制
    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(find.text('英寸（in）'), findsOneWidget);
    expect(find.text('英尺'), findsOneWidget);
    expect(find.text('毫米'), findsNothing);

    // 单位下拉选英尺：1 英尺 = 12 英寸
    await tester.tap(find.byKey(const Key('distance-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英尺（ft）').last);
    await tester.pumpAndSettle();
    expect(find.text('1 英尺'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);

    // 5280 英尺 = 1 英里
    await tester.enterText(find.byType(TextField).first, '5280');
    await tester.pumpAndSettle();
    expect(find.text('5280 英尺'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // 点参照物「马拉松」代入 42.195 千米，tab 回到公制
    await tester.ensureVisible(find.text('马拉松'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('马拉松'));
    await tester.pumpAndSettle();
    expect(find.text('42.195 千米'), findsOneWidget);
    expect(find.text('42195'), findsOneWidget); // 米

    // 先只看市制 tab：输入仍是 42.195 千米，tab 一换就能看到市制结果
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(find.text('42.195 千米'), findsOneWidget);
    expect(find.text('126585'), findsOneWidget); // 42.195 千米 = 126585 尺
    expect(find.text('1 里 = 150 丈 = 500 米'), findsNothing);

    // 体系下拉切到市制：单位落到里，说明文案跟着变
    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    expect(find.text('42.195 里'), findsOneWidget);
    expect(find.text('63292.5'), findsOneWidget); // 尺
    expect(find.text('1 里 = 150 丈 = 500 米'), findsOneWidget);

    // 单位下拉里选「尺」
    await tester.tap(find.byKey(const Key('distance-unit')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('尺').last);
    await tester.pumpAndSettle();
    expect(find.text('42.195 尺'), findsOneWidget);
    expect(find.text('1 尺 = 1/3 米 ≈ 33.33 厘米'), findsOneWidget);

    // 点结果行复制到剪贴板：42.195 尺 = 421.95 寸
    await tester.tap(find.text('421.95'));
    await tester.pumpAndSettle();
    expect(clipboard, '421.95 寸');
    expect(find.text('已复制 421.95 寸'), findsOneWidget);

    // 清空数值显示空状态
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pumpAndSettle();
    expect(find.text('填入数值并选好单位后自动换算'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  // (深链 id, 页面类型, 默认换算的标题, 结果里必须出现的一行)
  const convertCases = <(String, Type, String, String)>[
    ('area', AreaPage, '1 平方米', '10000'),
    ('volume', VolumePage, '1 升', '1000'),
    ('weight', WeightPage, '1 千克', '1000'),
  ];
  for (final (id, type, headline, row) in convertCases) {
    testWidgets('工具页：$id 深链打开并换算', (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(FreeCalcApp(initialTab: 2, initialTool: id));
      await tester.pumpAndSettle();

      expect(find.byType(type), findsOneWidget);
      expect(find.byKey(Key('$id-system')), findsOneWidget);
      expect(find.byKey(Key('$id-unit')), findsOneWidget);
      expect(find.byKey(Key('$id-samples')), findsOneWidget);
      expect(find.text(headline), findsOneWidget);
      expect(find.text(row), findsOneWidget);
      // 结果区三个体系 tab 齐全
      expect(find.widgetWithText(Tab, '公制'), findsOneWidget);
      expect(find.widgetWithText(Tab, '英制'), findsOneWidget);
      expect(find.widgetWithText(Tab, '市制'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('重量换算：切市制 tab、点参照物与复制整行', (tester) async {
    String? clipboard;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard = (call.arguments as Map)['text'] as String?;
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'weight'),
    );
    await tester.pumpAndSettle();

    // 默认 1 千克：公制 tab 只有公制单位
    expect(find.text('克'), findsOneWidget);
    expect(find.text('斤'), findsNothing);

    // 点参照物「一袋大米」代入 10 千克
    await tester.ensureVisible(find.text('一袋大米'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('一袋大米'));
    await tester.pumpAndSettle();
    expect(find.text('10 千克'), findsOneWidget);

    // 切到市制 tab 才会出现斤两钱，输入不变
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(find.text('斤'), findsWidgets);
    expect(find.text('20'), findsOneWidget); // 10 千克 = 20 斤
    expect(find.text('克'), findsNothing);

    // 点「斤」那一行复制（结果区里最后一个「斤」）
    await tester.tap(find.text('斤').last);
    await tester.pumpAndSettle();
    expect(clipboard, '20 斤');
    expect(find.text('已复制 20 斤'), findsOneWidget);

    // 体系下拉切市制：单位落到该体系第一个（担），数值保持不变
    await tester.tap(find.byKey(const Key('weight-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('市制').last);
    await tester.pumpAndSettle();
    expect(find.text('10 担'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget); // 10 担 = 1000 斤
    expect(tester.takeException(), isNull);
  });

  testWidgets('温度换算：只有公制与英制两个 tab，仿射换算正确', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'temperature'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TemperaturePage), findsOneWidget);
    // 1 °C = 33.8 °F = 274.15 K
    expect(find.text('1 摄氏度'), findsOneWidget);
    expect(find.text('274.15'), findsOneWidget); // 开尔文

    // 华氏度在英制 tab 里
    await tester.tap(find.widgetWithText(Tab, '英制'));
    await tester.pumpAndSettle();
    expect(find.text('33.8'), findsOneWidget);
    // 温度没有市制，tab 只有两个
    expect(find.widgetWithText(Tab, '公制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '英制'), findsOneWidget);
    expect(find.widgetWithText(Tab, '市制'), findsNothing);
    expect(find.text('25'), findsNothing);
    expect(find.text('千米'), findsNothing);

    // 体系下拉也只有两项：公制 / 英制
    await tester.tap(find.byKey(const Key('temperature-system')));
    await tester.pumpAndSettle();
    expect(find.text('市制'), findsNothing);
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(find.text('华氏度（°F）'), findsOneWidget);

    // 1 °F = −17.22 °C
    await tester.enterText(find.byType(TextField).first, '32');
    await tester.pumpAndSettle();
    expect(find.text('32 华氏度'), findsOneWidget);
    await tester.tap(find.widgetWithText(Tab, '公制'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsWidgets); // 32 °F = 0 °C
    expect(tester.takeException(), isNull);
  });

  testWidgets('速度换算：千米每小时与米每秒互转', (tester) async {
    tester.view.physicalSize = const Size(1440, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const FreeCalcApp(initialTab: 2, initialTool: 'speed'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SpeedPage), findsOneWidget);
    // 默认 1 千米/小时 ≈ 0.2778 米/秒
    expect(find.text('1 千米/小时'), findsOneWidget);
    expect(find.text('0.2777777778'), findsOneWidget);

    // 输入 36 千米/小时 = 10 米/秒
    await tester.enterText(find.byType(TextField).first, '36');
    await tester.pumpAndSettle();
    expect(find.text('36 千米/小时'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：新换算工具页不溢出', (tester) async {
    for (final id in <String>[
      'area',
      'volume',
      'weight',
      'temperature',
      'speed',
    ]) {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(FreeCalcApp(initialTab: 2, initialTool: id));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget, reason: id);
      expect(find.widgetWithText(Tab, '公制'), findsOneWidget, reason: id);
      expect(tester.takeException(), isNull, reason: id);
    }
  });

  testWidgets('工具页：手机尺寸下长度换算不溢出', (tester) async {
    await pumpApp(tester, const Size(390, 844));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('长度换算'));
    await tester.pumpAndSettle();
    expect(find.byType(DistancePage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    // 两个下拉框并排、三个 tab 平分宽度，窄屏下都不能溢出
    await tester.tap(find.widgetWithText(Tab, '市制'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const Key('distance-system')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('英制').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：贷款计算器三栏改两行且不溢出', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FreeCalcApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    // 工具变多后手机上贷款计算器要滚动才看得到
    await tester.dragUntilVisible(
      find.text('贷款计算器'),
      find.byType(GridView),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('贷款计算器'));
    await tester.pumpAndSettle();

    expect(find.byType(LoanPage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
    // 每个输入框都要留出足够的输入区，不能只剩单位
    for (var i = 0; i < 3; i++) {
      expect(
        tester.getSize(find.byType(EditableText).at(i)).width,
        greaterThanOrEqualTo(90),
      );
    }
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
    // 「保存位置」要写真实落盘目录，不能只写笼统的「图片 / 下载」
    expect(find.text(plotSaveLocationNote()), findsOneWidget);

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
  testWidgets('个人所得税：五险一金比例与累计预扣', (tester) async {
    await pumpApp(tester, const Size(1440, 900));

    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('个人所得税'));
    await tester.pumpAndSettle();
    expect(find.byType(TaxPage), findsOneWidget);

    // 默认：2 万月薪、基数同月薪、比例 8 / 2 / 0.5 / 12 → 合计 22.5%
    expect(find.text('合计 22.5%'), findsOneWidget);
    expect(find.text('¥ 15,185.00'), findsWidgets);
    expect(
      find.text('税前 ¥ 20,000 − 五险一金 ¥ 4,500 − 个税 ¥ 315.00'),
      findsOneWidget,
    );
    // 全年个税 10,080、全年到手 175,920、边际税率 10%
    expect(find.text('¥ 10,080'), findsOneWidget);
    expect(find.text('¥ 175,920'), findsOneWidget);
    expect(find.text('10%'), findsOneWidget);
    // 五险一金构成：养老 1600 / 医疗 400 / 失业 100 / 公积金 2400
    expect(find.text('养老 ¥ 1,600.00'), findsOneWidget);
    expect(find.text('医疗 ¥ 400.00'), findsOneWidget);
    expect(find.text('失业 ¥ 100.00'), findsOneWidget);
    expect(find.text('公积金 ¥ 2,400.00'), findsOneWidget);
    expect(find.byType(SegmentedBar), findsWidgets);

    // 逐月明细 12 行：前 3 个月 315，第 4 月补档 735，之后 1050
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith('tax-month-'),
      ),
      findsNWidgets(12),
    );
    expect(find.text('第 1 月'), findsOneWidget);
    expect(find.text('第 12 月'), findsOneWidget);
    expect(find.text('315.00'), findsNWidgets(3));
    expect(find.text('735.00'), findsOneWidget);
    expect(find.text('1,050.00'), findsNWidgets(8));

    // 月薪改 5 万 → 首月到手 37,737.50、全年个税 69,330、边际税率 25%
    await tester.enterText(find.byType(TextField).at(0), '50000');
    await tester.pumpAndSettle();
    expect(find.text('¥ 37,737.50'), findsWidgets);
    expect(find.text('¥ 69,330'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);

    // 缴费基数单独填 10000 → 五险一金 2250、个税变多
    await tester.enterText(find.byType(TextField).at(1), '10000');
    await tester.pumpAndSettle();
    expect(find.text('按基数 ¥ 10,000 计算，每月个人缴纳 ¥ 2,250.00'), findsOneWidget);

    // 公积金比例改成 5% → 合计 15.5%、每月 5500（基数 1 万）
    await tester.enterText(find.byType(TextField).at(6), '5');
    await tester.pumpAndSettle();
    expect(find.text('合计 15.5%'), findsOneWidget);

    // 月薪清空 → 提示占位，不出结果
    await tester.enterText(find.byType(TextField).at(0), '');
    await tester.pumpAndSettle();
    expect(find.text('填写税前月薪与缴纳比例后自动计算'), findsOneWidget);
    expect(find.text('月度明细'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('手机尺寸：个人所得税输入框改多行且不溢出', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const FreeCalcApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('工具'));
    await tester.pumpAndSettle();
    // 手机上卡片一列排布，第 6 张（个税）要滚动才看得到
    await tester.dragUntilVisible(
      find.text('个人所得税'),
      find.byType(GridView),
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('个人所得税'));
    await tester.pumpAndSettle();

    expect(find.byType(TaxPage), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    // 3 个金额输入 + 4 个比例输入
    expect(find.byType(TextField), findsNWidgets(7));
    for (var i = 0; i < 7; i++) {
      expect(
        tester.getSize(find.byType(EditableText).at(i)).width,
        greaterThanOrEqualTo(60),
      );
    }
    // 窄屏时三栏金额拆成「月薪 + 两栏」两行
    final salaryTop = tester.getTopLeft(find.byType(TextField).at(0)).dy;
    final baseTop = tester.getTopLeft(find.byType(TextField).at(1)).dy;
    final specialTop = tester.getTopLeft(find.byType(TextField).at(2)).dy;
    expect(baseTop, greaterThan(salaryTop));
    expect(specialTop, baseTop);
    expect(tester.takeException(), isNull);
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

/// 内存版设置存储，Widget 测试里替代文件 / localStorage。
class _MemoryStore implements SettingsStore {
  final Map<String, String> values = <String, String>{};

  @override
  Future<Map<String, String>> readAll() async => Map<String, String>.of(values);

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
