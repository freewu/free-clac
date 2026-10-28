import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'lang/volume_lang.dart';
import 'volume_page.dart';

Widget _builder(BuildContext context) => VolumePage();

/// 「容量换算」的工具卡片元数据。
final ToolInfo volumeTool = ToolInfo(
  id: 'volume',
  lang: kVolumeLang,
  icon: Icons.water_drop_outlined,
  color: AppColors.secondary,
  builder: _builder,
);
