import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'hourly_lang.dart';
import 'hourly_page.dart';

Widget _builder(BuildContext context) => const HourlyPage();

/// 「时薪计算器」的工具卡片元数据。
ToolInfo get hourlyTool => ToolInfo(
  id: 'hourly',
  lang: kHourlyLang,
  icon: Icons.payments_outlined,
  color: AppColors.primary,
  builder: _builder,
);
