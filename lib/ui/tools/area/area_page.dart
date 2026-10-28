import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../widgets/unit_convert_page.dart';
import 'area.dart';
import 'area_lang.dart';

/// 面积换算页：数据在 `lib/tools/area.dart`，界面用通用的换算页。
class AreaPage extends StatelessWidget {
  const AreaPage({super.key});

  @override
  Widget build(BuildContext context) => UnitConvertPage(
    catalog: kAreaCatalog,
    // 标题取工具卡片的名称，跟着界面语言走；这里不能写 const，
    // 否则重建时 Flutter 会判定「同一实例」而跳过更新。
    title: toolText(kAreaLang).name,
    icon: Icons.crop_square_rounded,
  );
}
