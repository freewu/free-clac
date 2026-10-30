import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'bmr_lang.dart';
import 'bmr_page.dart';

Widget _builder(BuildContext context) => const BmrPage();

/// 「基础代谢 BMR」的工具卡片元数据。
ToolInfo get bmrTool => ToolInfo(
  id: 'bmr',
  lang: kBmrLang,
  icon: Icons.local_fire_department_outlined,
  color: AppColors.orange,
  builder: _builder,
);
