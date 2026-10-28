import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'interest_lang.dart';
import 'interest_page.dart';

Widget _builder(BuildContext context) => InterestPage();

/// 「利率计算」的工具卡片元数据。
final ToolInfo interestTool = ToolInfo(
  id: 'interest',
  lang: kInterestLang,
  icon: Icons.percent_rounded,
  color: AppColors.secondary,
  builder: _builder,
);
