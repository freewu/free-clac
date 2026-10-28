import 'package:flutter/material.dart';

import '../../l10n/app_i18n.dart';
import '../../l10n/app_language.dart';
import '../../state/app_appearance.dart';

/// 一张工具卡片的三段文案：名称、卖点、说明。
@immutable
class ToolText {
  const ToolText(this.name, this.tagline, this.description);

  final String name;

  /// 一句话卖点，显示在卡片标题下方。
  final String tagline;

  /// 更长的说明，卡片里最多两行。
  final String description;
}

/// 工具页里一张「应用卡片」的元数据。
///
/// 每个工具在自己的 `defined.dart` 里声明一份（如 `bmi/defined.dart`），
/// 多语言文案放在同目录的 `lang/<tool>_lang.dart`，由 `tool_catalog.dart`
/// 汇总成 [kTools]。新增工具只需三处改动：新建 `defined.dart`、
/// 新建 `lang/` 语言包，再在 `kTools` 里追加一行。
class ToolInfo {
  const ToolInfo({
    required this.id,
    required this.lang,
    required this.icon,
    required this.color,
    required this.builder,
  });

  /// 深链参数（`?tool=bmi`），同时是语言包与测试的稳定标识。
  final String id;

  /// 多语言文案，缺某语言时回落简体中文。
  final Map<AppLanguage, ToolText> lang;

  final IconData icon;
  final Color color;

  /// 打开工具页面的构造器。
  final WidgetBuilder builder;

  /// 当前语言下的文案。
  ToolText get text => toolText(lang);

  String get name => text.name;
  String get tagline => text.tagline;
  String get description => text.description;

  /// 打开工具页面：外面包一层 [ListenableBuilder] 监听
  /// [appAppearanceRevision]，切主题 / 语言时已压栈的页面也会重建。
  WidgetBuilder get pageBuilder =>
      (context) => ListenableBuilder(
        listenable: appAppearanceRevision,
        builder: (context, _) => builder(context),
      );
}
