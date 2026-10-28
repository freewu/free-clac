import 'package:flutter/material.dart';

import 'distance.dart';
import '../widgets/unit_convert_page.dart';

/// 长度换算页：数据在 `lib/tools/distance.dart`，界面用通用的换算页。
class DistancePage extends StatelessWidget {
  const DistancePage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kLengthCatalog,
    title: '长度换算',
    icon: Icons.straighten_rounded,
  );
}
