import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'area_lang.dart';
import 'area_page.dart';

Widget _builder(BuildContext context) => AreaPage();

/// 「面积换算」的工具卡片元数据。
ToolInfo get areaTool => ToolInfo(
  id: 'area',
  lang: kAreaLang,
  icon: Icons.crop_square_rounded,
  color: AppColors.violet,
  builder: _builder,
);
