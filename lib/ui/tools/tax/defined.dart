import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'tax_page.dart';

Widget _builder(BuildContext context) => const TaxPage();

/// 「个人所得税」的工具卡片元数据。
const ToolInfo taxTool = ToolInfo(
  id: 'tax',
  name: '个人所得税',
  tagline: '月薪扣完还剩多少',
  description: '按累计预扣法算个税，五险一金比例与缴费基数都能改，逐月列出个税与到手工资。',
  icon: Icons.receipt_long_outlined,
  color: AppColors.error,
  builder: _builder,
);
