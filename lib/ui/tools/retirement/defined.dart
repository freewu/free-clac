import 'package:flutter/material.dart';

import '../../../l10n/app_language.dart';
import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'retirement_lang.dart';
import 'retirement_page.dart';

/// 不能写 `const`：重建时若返回同一个实例，Flutter 会跳过更新，
/// 切主题 / 语言后已打开的页面就不跟着变了。
Widget _builder(BuildContext context) => RetirementPage();

/// 「退休年龄计算器」的工具卡片元数据。
ToolInfo get retirementTool => ToolInfo(
  id: 'retirement',
  lang: kRetirementLang,
  icon: Icons.event_available_rounded,
  color: AppColors.violet,
  builder: _builder,
  // 中国大陆的延迟退休口径，只在中文界面展示。
  availableIn: const {AppLanguage.zhHans, AppLanguage.zhHant},
);
