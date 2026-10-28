import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'distance_lang.dart';
import 'distance_page.dart';

Widget _builder(BuildContext context) => DistancePage();

/// 「长度换算」的工具卡片元数据。
final ToolInfo distanceTool = ToolInfo(
  id: 'distance',
  lang: kDistanceLang,
  icon: Icons.straighten_rounded,
  color: AppColors.tertiary,
  builder: _builder,
);
