import 'package:flutter/material.dart';

import 'speed.dart';
import '../widgets/unit_convert_page.dart';

/// 速度换算页：数据在 `lib/tools/speed.dart`，界面用通用的换算页。
class SpeedPage extends StatelessWidget {
  const SpeedPage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kSpeedCatalog,
    title: '速度换算',
    icon: Icons.speed_rounded,
  );
}
