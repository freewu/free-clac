import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'bmi_page.dart';

Widget _builder(BuildContext context) => const BmiPage();

/// 「BMI 计算」的工具卡片元数据。
const ToolInfo bmiTool = ToolInfo(
  id: 'bmi',
  name: 'BMI 计算',
  tagline: '身高体重，一眼看体型',
  description: '按中国成人标准给出分级、标准体重区间与建议，支持米制与厘米输入。',
  icon: Icons.monitor_weight_outlined,
  color: AppColors.tertiary,
  builder: _builder,
);
