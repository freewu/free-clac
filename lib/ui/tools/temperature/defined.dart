import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'temperature_page.dart';

Widget _builder(BuildContext context) => const TemperaturePage();

/// 「温度换算」的工具卡片元数据。
const ToolInfo temperatureTool = ToolInfo(
  id: 'temperature',
  name: '温度换算',
  tagline: '摄氏华氏，连同体感',
  description: '摄氏度 / 华氏度 / 开尔文 / 兰氏度互转，按零点偏移精确换算，附常见温度参照物。',
  icon: Icons.thermostat_rounded,
  color: AppColors.error,
  builder: _builder,
);
