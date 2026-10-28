import 'package:flutter/material.dart';

import 'volume.dart';
import '../widgets/unit_convert_page.dart';

/// 容量换算页：数据在 `lib/tools/volume.dart`，界面用通用的换算页。
class VolumePage extends StatelessWidget {
  const VolumePage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kVolumeCatalog,
    title: '容量换算',
    icon: Icons.water_drop_outlined,
  );
}
