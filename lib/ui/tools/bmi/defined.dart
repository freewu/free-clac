import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'lang/bmi_lang.dart';
import 'bmi_page.dart';

Widget _builder(BuildContext context) => BmiPage();

/// 「BMI 计算」的工具卡片元数据。
final ToolInfo bmiTool = ToolInfo(
  id: 'bmi',
  lang: kBmiLang,
  icon: Icons.monitor_weight_outlined,
  color: AppColors.tertiary,
  builder: _builder,
);
