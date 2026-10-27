import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'compound_page.dart';

Widget _builder(BuildContext context) => const CompoundPage();

/// 「复利计算」的工具卡片元数据。
const ToolInfo compoundTool = ToolInfo(
  id: 'compound',
  name: '复利计算',
  tagline: '让时间替你赚钱',
  description: '支持任意复利频率与定期追加投入，输出本息、有效年利率与逐年增长表。',
  icon: Icons.savings_outlined,
  color: AppColors.warning,
  builder: _builder,
);
