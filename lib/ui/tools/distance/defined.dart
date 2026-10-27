import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'distance_page.dart';

Widget _builder(BuildContext context) => const DistancePage();

/// 「长度换算」的工具卡片元数据。
const ToolInfo distanceTool = ToolInfo(
  id: 'distance',
  name: '长度换算',
  tagline: '公制英制，一屏换算',
  description: '公制 / 英制 / 市制共 25 个单位互转，输入即算，附常见长度参照物。',
  icon: Icons.straighten_rounded,
  color: AppColors.tertiary,
  builder: _builder,
);
