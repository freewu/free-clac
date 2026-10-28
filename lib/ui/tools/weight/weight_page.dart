import 'package:flutter/material.dart';

import 'weight.dart';
import '../widgets/unit_convert_page.dart';

/// 重量换算页：数据在 `lib/tools/weight.dart`，界面用通用的换算页。
class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kWeightCatalog,
    title: '重量换算',
    icon: Icons.scale_outlined,
  );
}
