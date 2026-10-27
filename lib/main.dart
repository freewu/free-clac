import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Web 端支持 ?page=plot / ?page=tools 直接打开对应页面，
  // ?preset=0 载入第 1 个示例曲线，?tool=bmi 直接打开 BMI 计算。
  final query = Uri.base.queryParameters;
  final page = query['page'];
  runApp(
    FreeCalcApp(
      initialTab: switch (page) {
        'plot' => 1,
        'tools' => 2,
        // 只带 ?tool=xxx 时也直接停在工具页
        _ when query['tool'] != null => 2,
        _ => 0,
      },
      initialPreset: int.tryParse(query['preset'] ?? ''),
      initialTool: query['tool'],
    ),
  );
}
