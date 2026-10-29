import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../widgets/unit_convert_page.dart';
import 'pressure.dart';
import 'pressure_lang.dart';

/// 压力换算页：数据在 `pressure.dart`，界面用通用的换算页。
class PressurePage extends StatelessWidget {
  const PressurePage({super.key});

  @override
  Widget build(BuildContext context) => UnitConvertPage(
    catalog: kPressureCatalog,
    // 标题取工具卡片的名称，跟着界面语言走；这里不能写 const，
    // 否则重建时 Flutter 会判定「同一实例」而跳过更新。
    title: toolText(kPressureLang).name,
    icon: Icons.compress_rounded,
  );
}
