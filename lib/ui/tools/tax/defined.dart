import 'package:flutter/material.dart';

import '../../../l10n/app_language.dart';
import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'lang/tax_lang.dart';
import 'tax_page.dart';

Widget _builder(BuildContext context) => TaxPage();

/// 「个人所得税」的工具卡片元数据。
final ToolInfo taxTool = ToolInfo(
  id: 'tax',
  lang: kTaxLang,
  icon: Icons.receipt_long_outlined,
  color: AppColors.error,
  builder: _builder,
  // 中国社保 / 税法口径，只在中文界面展示。
  availableIn: const {AppLanguage.zhHans, AppLanguage.zhHant},
);
