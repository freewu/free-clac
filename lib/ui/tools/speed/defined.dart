import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'speed_lang.dart';
import 'speed_page.dart';

Widget _builder(BuildContext context) => SpeedPage();

/// 「速度换算」的工具卡片元数据。
final ToolInfo speedTool = ToolInfo(
  id: 'speed',
  lang: kSpeedLang,
  icon: Icons.speed_rounded,
  color: AppColors.orange,
  builder: _builder,
);
