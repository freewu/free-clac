import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'weight_page.dart';

Widget _builder(BuildContext context) => const WeightPage();

/// 「重量换算」的工具卡片元数据。
const ToolInfo weightTool = ToolInfo(
  id: 'weight',
  name: '重量换算',
  tagline: '斤两磅，随手换',
  description: '公制 / 英制 / 市制共 17 个单位互转，含千克、磅与斤两钱，附常见重量参照物。',
  icon: Icons.scale_outlined,
  color: AppColors.warning,
  builder: _builder,
);
