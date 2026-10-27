import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'pension_page.dart';

Widget _builder(BuildContext context) => const PensionPage();

/// 「养老金计算器」的工具卡片元数据。
const ToolInfo pensionTool = ToolInfo(
  id: 'pension',
  name: '养老金计算器',
  tagline: '现在缴多少，退休领多少',
  description: '按国发〔2005〕38 号口径测算基础养老金与个人账户养老金，给出替代率与账户构成。',
  icon: Icons.elderly_rounded,
  color: AppColors.tertiary,
  builder: _builder,
);
