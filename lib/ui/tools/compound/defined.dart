import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'compound_lang.dart';
import 'compound_page.dart';

Widget _builder(BuildContext context) => CompoundPage();

/// 「复利计算」的工具卡片元数据。
ToolInfo get compoundTool => ToolInfo(
  id: 'compound',
  lang: kCompoundLang,
  icon: Icons.savings_outlined,
  color: AppColors.warning,
  builder: _builder,
);
