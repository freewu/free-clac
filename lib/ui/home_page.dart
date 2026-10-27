import 'package:flutter/material.dart';

import '../core/math_engine.dart';
import '../state/calculator_controller.dart';
import '../state/plot_controller.dart';
import '../theme/app_theme.dart';
import '../plot/plot_presets.dart';
import 'calculator_page.dart';
import 'plot_page.dart';
import 'tools/tools_tab.dart';

/// 应用主框架：计算器 / 绘图 / 工具三个页面，共享同一个计算引擎。
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.initialTab = 0,
    this.initialPreset,
    this.initialTool,
  });

  /// 初始页面：0 计算器，1 绘图，2 工具。
  final int initialTab;

  /// 启动时载入的示例曲线下标，越界时忽略。
  final int? initialPreset;

  /// 启动时直接打开的工具 id（Web 端 `?tool=bmi`）。
  final String? initialTool;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MathEngine _engine = MathEngine();
  late final CalculatorController _calculator = CalculatorController(
    engine: _engine,
  );
  late final PlotController _plot = PlotController(engine: _engine);

  late int _index = widget.initialTab.clamp(0, 2);

  @override
  void initState() {
    super.initState();
    final preset = widget.initialPreset;
    if (preset != null && preset >= 0 && preset < kPlotPresets.length) {
      // 深链启动时只显示该示例，不叠加默认曲线
      _plot.applyPreset(kPlotPresets[preset], replaceAll: true);
    }
  }

  @override
  void dispose() {
    _calculator.dispose();
    _plot.dispose();
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 940;
        final body = IndexedStack(
          index: _index,
          children: [
            CalculatorPage(controller: _calculator),
            PlotPage(controller: _plot),
            ToolsTab(initialTool: widget.initialTool, active: _index == 2),
          ],
        );

        if (wide) {
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  NavigationRail(
                    backgroundColor: AppColors.surface,
                    selectedIndex: _index,
                    onDestinationSelected: (index) =>
                        setState(() => _index = index),
                    labelType: NavigationRailLabelType.all,
                    selectedIconTheme: const IconThemeData(
                      color: AppColors.primary,
                    ),
                    unselectedIconTheme: const IconThemeData(
                      color: AppColors.textSecondary,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    indicatorColor: AppColors.primary.withValues(alpha: 0.15),
                    leading: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: _Logo(),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.calculate_outlined),
                        selectedIcon: Icon(Icons.calculate),
                        label: Text('计算'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.insights_outlined),
                        selectedIcon: Icon(Icons.insights),
                        label: Text('绘图'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.apps_outlined),
                        selectedIcon: Icon(Icons.apps),
                        label: Text('工具'),
                      ),
                    ],
                  ),
                  Container(width: 1, color: AppColors.outline),
                  Expanded(child: body),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          body: SafeArea(child: body),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            height: 62,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.calculate_outlined),
                selectedIcon: Icon(Icons.calculate),
                label: '计算',
              ),
              NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights),
                label: '绘图',
              ),
              NavigationDestination(
                icon: Icon(Icons.apps_outlined),
                selectedIcon: Icon(Icons.apps),
                label: '工具',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: const Icon(Icons.functions, size: 20, color: Color(0xFF04101F)),
    );
  }
}
