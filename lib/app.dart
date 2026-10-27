import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/home_page.dart';
import 'ui/tools/tool_catalog.dart';

class FreeCalcApp extends StatelessWidget {
  const FreeCalcApp({
    super.key,
    this.initialTab = 0,
    this.initialPreset,
    this.initialTool,
  });

  /// 启动时展示的页面（Web 端可通过 ?page=plot 直达绘图页）。
  final int initialTab;

  /// 启动时载入的示例曲线下标（Web 端 ?preset=0）。
  final int? initialPreset;

  /// 启动时直接打开的工具（Web 端 ?tool=bmi）。
  final String? initialTool;

  @override
  Widget build(BuildContext context) {
    final home = HomePage(initialTab: initialTab, initialPreset: initialPreset);
    final tool = initialTool == null ? null : toolById(initialTool!);
    if (tool == null) {
      return MaterialApp(
        title: '科学计算器',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: home,
      );
    }

    // 深链打开工具：初始路由为 [首页, 工具页]，返回键回到首页。
    // 用初始路由而不是首帧后再 push，保证截图与首帧就位（`home` 不能与
    // onGenerateInitialRoutes 同时出现，所以这条分支不传 home）。
    return MaterialApp(
      title: '科学计算器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      initialRoute: '/',
      // 兜底路由：满足 WidgetsApp「至少要有一个路由来源」的断言。
      onGenerateRoute: (settings) =>
          MaterialPageRoute<void>(builder: (_) => home),
      onGenerateInitialRoutes: (route) => [
        MaterialPageRoute<void>(builder: (_) => home),
        MaterialPageRoute<void>(builder: tool.builder),
      ],
    );
  }
}
