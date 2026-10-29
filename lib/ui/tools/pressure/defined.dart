import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'pressure_lang.dart';
import 'pressure_page.dart';

Widget _builder(BuildContext context) => PressurePage();

/// 「压力换算」的工具卡片元数据。
ToolInfo get pressureTool => ToolInfo(
  id: 'pressure',
  lang: kPressureLang,
  icon: Icons.compress_rounded,
  color: AppColors.secondary,
  builder: _builder,
);
