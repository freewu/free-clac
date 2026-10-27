import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../tool_info.dart';
import 'loan_page.dart';

Widget _builder(BuildContext context) => const LoanPage();

/// 「贷款计算器」的工具卡片元数据。
const ToolInfo loanTool = ToolInfo(
  id: 'loan',
  name: '贷款计算器',
  tagline: '月供本金利息一眼拆开',
  description: '等额本息 / 等额本金，逐期列出本金与利息并用双色条对比，还给出总利息与总还款。',
  icon: Icons.request_quote_outlined,
  color: AppColors.primary,
  builder: _builder,
);
