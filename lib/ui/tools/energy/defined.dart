import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'energy_lang.dart';
import 'energy_page.dart';

Widget _builder(BuildContext context) => EnergyPage();

/// 「热量换算」的工具卡片元数据。
ToolInfo get energyTool => ToolInfo(
  id: 'energy',
  lang: kEnergyLang,
  icon: Icons.local_fire_department_rounded,
  color: AppColors.warning,
  builder: _builder,
);
