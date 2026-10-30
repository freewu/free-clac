import 'package:flutter/material.dart';

import '../../l10n/app_i18n.dart';
import '../../state/settings_controller.dart';
import '../../theme/app_theme.dart';
import '../widgets/settings_card.dart';
import 'widgets/tool_select.dart';

/// 工具页的置顶设置：最多能置顶几个工具（2 ~ 5，默认 3）。
///
/// 置顶动作本身在工具页卡片的右上角（那枚图钉），这里只调上限，
/// 顺带显示当前已经置顶几个，方便对照。
class ToolsSetting extends StatelessWidget {
  const ToolsSetting({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      icon: Icons.push_pin_outlined,
      title: t.settingsPinned,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ToolSelect<int>(
            key: const Key('settings-pinned-limit'),
            label: t.settingsPinnedLimit,
            value: controller.pinnedLimit,
            items: SettingsController.pinnedLimitOptions,
            labelOf: (limit) => '$limit',
            onChanged: controller.setPinnedLimit,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.push_pin_rounded,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  t.pinnedCount(
                    controller.pinnedTools.length,
                    controller.pinnedLimit,
                  ),
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.settingsPinnedHint,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
