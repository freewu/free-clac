import 'package:flutter/material.dart';

import '../state/plot_controller.dart';
import '../theme/app_theme.dart';
import 'widgets/plot_canvas.dart';
import 'widgets/plot_export_dialog.dart';
import 'widgets/plot_function_panel.dart';

/// 函数绘图页面。
class PlotPage extends StatelessWidget {
  const PlotPage({super.key, required this.controller});

  final PlotController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 宽屏，或横屏但高度有限的场景，改用左右布局，避免画布被压扁。
        final wide =
            constraints.maxWidth >= 1080 ||
            (constraints.maxWidth >= 640 && constraints.maxHeight < 560);
        return Column(
          children: [
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) => _buildHeader(context),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) =>
                                  PlotCanvas(controller: controller),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 360,
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) =>
                                  PlotFunctionPanel(controller: controller),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) =>
                                  PlotCanvas(controller: controller),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 240,
                            child: AnimatedBuilder(
                              animation: controller,
                              builder: (context, _) =>
                                  PlotFunctionPanel(controller: controller),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final mode = controller.angleMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 4),
      child: Row(
        children: [
          const Icon(
            Icons.insights_rounded,
            size: 19,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          const Text(
            '函数绘图',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          _HeaderChip(
            label: mode.shortLabel,
            color: AppColors.secondary,
            tooltip: '角度单位（${mode.label}），点击切换',
            onTap: () => controller.engine.angleMode = mode.toggled,
          ),
          const Spacer(),
          _HeaderAction(
            icon: controller.showGrid ? Icons.grid_on : Icons.grid_off,
            tooltip: controller.showGrid ? '隐藏网格' : '显示网格',
            active: controller.showGrid,
            onTap: () => controller.setShowGrid(!controller.showGrid),
          ),
          _HeaderAction(
            icon: controller.traceEnabled
                ? Icons.gps_fixed
                : Icons.gps_not_fixed,
            tooltip: controller.traceEnabled ? '关闭触摸追踪' : '开启触摸追踪（拖动查看数值）',
            active: controller.traceEnabled,
            onTap: () => controller.setTraceEnabled(!controller.traceEnabled),
          ),
          _HeaderAction(
            icon: Icons.image_outlined,
            tooltip: '导出图片（PNG / SVG / WebP）',
            onTap: () => showPlotExportDialog(context, controller),
          ),
        ],
      ),
    );
  }
}

class _HeaderChip extends StatelessWidget {
  const _HeaderChip({
    required this.label,
    required this.color,
    required this.onTap,
    this.tooltip,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final chip = Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return chip;
    return Tooltip(message: tooltip!, child: chip);
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        visualDensity: VisualDensity.compact,
        color: active ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }
}
