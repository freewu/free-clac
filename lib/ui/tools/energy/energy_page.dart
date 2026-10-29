import 'package:flutter/material.dart';

import '../../../l10n/app_i18n.dart';
import '../widgets/unit_convert_page.dart';
import 'energy.dart';
import 'energy_lang.dart';

/// 热量换算页：数据在 `energy.dart`，界面用通用的换算页。
class EnergyPage extends StatelessWidget {
  const EnergyPage({super.key});

  @override
  Widget build(BuildContext context) => UnitConvertPage(
    catalog: kEnergyCatalog,
    // 标题取工具卡片的名称，跟着界面语言走；这里不能写 const，
    // 否则重建时 Flutter 会判定「同一实例」而跳过更新。
    title: toolText(kEnergyLang).name,
    icon: Icons.local_fire_department_rounded,
  );
}
