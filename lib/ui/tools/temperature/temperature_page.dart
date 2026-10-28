import 'package:flutter/material.dart';

import 'temperature.dart';
import '../widgets/unit_convert_page.dart';

/// 温度换算页：数据在 `lib/tools/temperature.dart`，界面用通用的换算页。
class TemperaturePage extends StatelessWidget {
  const TemperaturePage({super.key});

  @override
  Widget build(BuildContext context) => const UnitConvertPage(
    catalog: kTemperatureCatalog,
    title: '温度换算',
    icon: Icons.thermostat_rounded,
  );
}
