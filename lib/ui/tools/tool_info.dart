import 'package:flutter/material.dart';

/// 工具页里一张「应用卡片」的元数据。
///
/// 每个工具在自己的 `defined.dart` 里声明一份（如 `bmi/defined.dart`），
/// 由 `tool_catalog.dart` 汇总成 [kTools]。新增工具只需两处改动：
/// 新建 `defined.dart`，再在 `kTools` 里追加一行。
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
