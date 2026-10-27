import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'speed_page.dart';

Widget _builder(BuildContext context) => const SpeedPage();

/// 「速度换算」的工具卡片元数据。
const ToolInfo speedTool = ToolInfo(
  id: 'speed',
  name: '速度换算',
  tagline: '车速航速，一节就懂',
  description: '公制 / 英制 / 市制共 11 个单位互转，含千米每小时、英里每小时、节与马赫。',
  icon: Icons.speed_rounded,
  color: AppColors.orange,
  builder: _builder,
);
