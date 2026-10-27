import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'bmi/bmi_page.dart';
import 'compound/compound_page.dart';

/// 工具页里一张「应用卡片」的元数据。
class ToolInfo {
  const ToolInfo({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.icon,
    required this.color,
    required this.builder,
  });

  /// 深链参数（`?tool=bmi`）。
  final String id;

  final String name;

  /// 一句话卖点，显示在卡片标题下方。
  final String tagline;

  /// 更长的说明，卡片里最多两行。
  final String description;

  final IconData icon;
  final Color color;

  /// 打开工具页面的构造器。
  final WidgetBuilder builder;
}

Widget _bmiBuilder(BuildContext context) => const BmiPage();

Widget _compoundBuilder(BuildContext context) => const CompoundPage();

/// 全部内置工具，顺序即工具页展示顺序。
final List<ToolInfo> kTools = List.unmodifiable(<ToolInfo>[
  ToolInfo(
    id: 'bmi',
    name: 'BMI 计算',
    tagline: '身高体重，一眼看体型',
    description: '按中国成人标准给出分级、标准体重区间与建议，支持米制与厘米输入。',
    icon: Icons.monitor_weight_outlined,
    color: AppColors.tertiary,
    builder: _bmiBuilder,
  ),
  ToolInfo(
    id: 'compound',
    name: '复利计算',
    tagline: '让时间替你赚钱',
    description: '支持任意复利频率与定期追加投入，输出本息、有效年利率与逐年增长表。',
    icon: Icons.savings_outlined,
    color: AppColors.warning,
    builder: _compoundBuilder,
  ),
]);

/// 按 id 查找工具，找不到返回 null。
ToolInfo? toolById(String id) {
  for (final tool in kTools) {
    if (tool.id == id) return tool;
  }
  return null;
}
