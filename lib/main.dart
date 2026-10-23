import 'package:flutter/material.dart';

import 'app.dart';

void main() {
  // Web 端支持 ?page=plot 直接打开绘图页，?preset=0 直接载入第 1 个示例。
  final query = Uri.base.queryParameters;
  final page = query['page'];
  runApp(
    FreeCalcApp(
      initialTab: page == 'plot' ? 1 : 0,
      initialPreset: int.tryParse(query['preset'] ?? ''),
    ),
  );
}
