import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'temperature_lang.dart';
import 'temperature_page.dart';

Widget _builder(BuildContext context) => TemperaturePage();

/// 「温度换算」的工具卡片元数据。
final ToolInfo temperatureTool = ToolInfo(
  id: 'temperature',
  lang: kTemperatureLang,
  icon: Icons.thermostat_rounded,
  color: AppColors.error,
  builder: _builder,
);
