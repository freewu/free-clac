import 'package:flutter/material.dart';

import 'area.dart';
import '../widgets/unit_convert_page.dart';

/// 面积换算页：数据在 `lib/tools/area.dart`，界面用通用的换算页。
class AreaPage extends StatelessWidget {
  const AreaPage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kAreaCatalog,
    title: '面积换算',
    icon: Icons.crop_square_rounded,
  );
}
