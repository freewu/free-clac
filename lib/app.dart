import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'ui/home_page.dart';

class FreeCalcApp extends StatelessWidget {
  const FreeCalcApp({super.key, this.initialTab = 0, this.initialPreset});

  /// 启动时展示的页面（Web 端可通过 ?page=plot 直达绘图页）。
  final int initialTab;

  /// 启动时载入的示例曲线下标（Web 端 ?preset=0）。
  final int? initialPreset;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '科学计算器',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: HomePage(initialTab: initialTab, initialPreset: initialPreset),
    );
  }
}
