import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'volume_page.dart';

Widget _builder(BuildContext context) => const VolumePage();

/// 「容量换算」的工具卡片元数据。
const ToolInfo volumeTool = ToolInfo(
  id: 'volume',
  name: '容量换算',
  tagline: '升与加仑，厨房能用',
  description: '公制 / 英制 / 市制共 17 个单位互转，含毫升、英制加仑与石斗升，附常见容量参照物。',
  icon: Icons.water_drop_outlined,
  color: AppColors.secondary,
  builder: _builder,
);
