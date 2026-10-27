import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'area_page.dart';

Widget _builder(BuildContext context) => const AreaPage();

/// 「面积换算」的工具卡片元数据。
const ToolInfo areaTool = ToolInfo(
  id: 'area',
  name: '面积换算',
  tagline: '平方米到亩，一键换算',
  description: '公制 / 英制 / 市制共 19 个单位互转，含公顷、英亩与市亩，附常见面积参照物。',
  icon: Icons.crop_square_rounded,
  color: AppColors.violet,
  builder: _builder,
);
