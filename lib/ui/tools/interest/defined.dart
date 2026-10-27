import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'interest_page.dart';

Widget _builder(BuildContext context) => const InterestPage();

/// 「利率计算」的工具卡片元数据。
const ToolInfo interestTool = ToolInfo(
  id: 'interest',
  name: '利率计算',
  tagline: '日付月付，一眼换年化',
  description: '本金配日付 / 月付 / 年付反推年化率，也能由年化率算出三种周期收益。',
  icon: Icons.percent_rounded,
  color: AppColors.secondary,
  builder: _builder,
);
