import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'weight_lang.dart';
import 'weight_page.dart';

Widget _builder(BuildContext context) => WeightPage();

/// 「重量换算」的工具卡片元数据。
final ToolInfo weightTool = ToolInfo(
  id: 'weight',
  lang: kWeightLang,
  icon: Icons.scale_outlined,
  color: AppColors.warning,
  builder: _builder,
);
