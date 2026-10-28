import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'lang/pension_lang.dart';
import 'pension_page.dart';

Widget _builder(BuildContext context) => PensionPage();

/// 「养老金计算器」的工具卡片元数据。
final ToolInfo pensionTool = ToolInfo(
  id: 'pension',
  lang: kPensionLang,
  icon: Icons.elderly_rounded,
  color: AppColors.tertiary,
  builder: _builder,
);
