import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'lang/loan_lang.dart';
import 'loan_page.dart';

Widget _builder(BuildContext context) => LoanPage();

/// 「贷款计算器」的工具卡片元数据。
final ToolInfo loanTool = ToolInfo(
  id: 'loan',
  lang: kLoanLang,
  icon: Icons.request_quote_outlined,
  color: AppColors.primary,
  builder: _builder,
);
