import 'package:flutter/material.dart';

import '../../plot/plot_presets.dart';
import '../../state/plot_controller.dart';
import '../../theme/app_theme.dart';

/// 弹出示例曲线面板；选中后载入绘图页。
Future<void> showPlotPresetSheet(
  BuildContext context,
  PlotController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => PlotPresetSheet(controller: controller),
  );
}

/// 示例曲线列表：一键把文章中的心形函数放进画布。
class PlotPresetSheet extends StatelessWidget {
  const PlotPresetSheet({super.key, required this.controller});

  final PlotController controller;

  void _apply(BuildContext context, PlotPreset preset) {
    final messenger = ScaffoldMessenger.of(context);
    final added = controller.applyPreset(preset);
    Navigator.of(context).pop();
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added == 0
                ? '「${preset.name}」已在图中'
                : '已添加示例：${preset.name}（+$added 条）',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.78;
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '示例曲线',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${kPlotPresets.length}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '示例会追加到当前画布，视口自动扩展以容纳已有图形；重复载入不会叠加相同曲线。',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.outline),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: kPlotPresets.length,
              separatorBuilder: (_, _) => Divider(
                height: 1,
                indent: 64,
                endIndent: 16,
                color: AppColors.outline,
              ),
              itemBuilder: (context, index) {
                final preset = kPlotPresets[index];
                return ListTile(
                  onTap: () => _apply(context, preset),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Icon(
                      preset.modes.first.icon,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  title: Text(
                    preset.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      preset.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (preset.angleMode != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            preset.angleMode!.shortLabel,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      if (preset.curves.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '${preset.curves.length} 条',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      Icon(
                        Icons.add_circle_outline,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(18, 8, 18, 10),
              child: Text(
                '来源：知乎《绘制出令人怦然心动的7种心形函数》\n$kPlotPresetSource',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
