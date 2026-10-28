import 'package:flutter/material.dart';

import 'app.dart';
import 'l10n/app_language.dart';
import 'state/settings_controller.dart';

void main() {
  // 要在读平台语言之前初始化绑定，否则 Web 上拿不到 platformDispatcher。
  WidgetsFlutterBinding.ensureInitialized();
  // Web 端支持 ?page=plot|tools|settings 直接打开对应页面，
  // ?preset=0 载入第 1 个示例曲线，?tool=bmi 直接打开 BMI 计算。
  final query = Uri.base.queryParameters;
  final page = query['page'];
  // 首次启动跟随系统语言，之后以设置页里存的为准。
  final language = AppLanguage.fromLocale(
    WidgetsBinding.instance.platformDispatcher.locale,
  );
  runApp(
    FreeCalcApp(
      settings: SettingsController(language: language),
      initialTab: switch (page) {
        'plot' => 1,
        'tools' => 2,
        'settings' => 3,
        // 只带 ?tool=xxx 时也直接停在工具页
        _ when query['tool'] != null => 2,
        _ => 0,
      },
      initialPreset: int.tryParse(query['preset'] ?? ''),
      initialTool: query['tool'],
    ),
  );
}
