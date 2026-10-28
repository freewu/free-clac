import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/plot_function.dart';
import '../../state/plot_controller.dart';
import '../../theme/app_theme.dart';
import 'plot_preset_sheet.dart';

/// 函数列表面板：添加 / 编辑 / 隐藏 / 删除曲线。
class PlotFunctionPanel extends StatelessWidget {
  const PlotFunctionPanel({super.key, required this.controller});

  final PlotController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 8),
            child: Row(
              children: [
                Icon(
                  Icons.show_chart,
                  size: 17,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '曲线',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '${controller.functions.length}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: '示例曲线',
                  visualDensity: VisualDensity.compact,
                  iconSize: 19,
                  color: AppColors.secondary,
                  onPressed: () => showPlotPresetSheet(context, controller),
                  icon: const Icon(Icons.auto_awesome_outlined),
                ),
                if (controller.functions.isNotEmpty)
                  IconButton(
                    tooltip: '清空全部',
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    color: AppColors.textSecondary,
                    onPressed: controller.clearFunctions,
                    icon: const Icon(Icons.delete_sweep_outlined),
                  ),
                PopupMenuButton<PlotMode>(
                  tooltip: '添加曲线',
                  icon: Icon(
                    Icons.add_circle_outline,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  onSelected: (mode) => controller.addFunction(mode: mode),
                  itemBuilder: (context) => [
                    for (final mode in PlotMode.values)
                      PopupMenuItem<PlotMode>(
                        value: mode,
                        child: Row(
                          children: [
                            Icon(mode.icon, size: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                switch (mode) {
                                  PlotMode.cartesian => '直角坐标 y = f(x)',
                                  PlotMode.polar => '极坐标 r = f(t)',
                                  PlotMode.parametric => '参数方程',
                                  PlotMode.implicit => '隐式方程 f(x, y) = 0',
                                },
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: controller.functions.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        '点击 + 添加曲线\n例如 sin(x)、x^2/4、1/x\n隐式方程：x^2 + y^2 - 1',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          height: 1.6,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: controller.functions.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final function = controller.functions[index];
                      return _FunctionTile(
                        key: ValueKey<String>(function.id),
                        controller: controller,
                        function: function,
                      );
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
            child: Text(
              '提示：滚轮 / 双指缩放，拖拽平移，悬停或长按查看数值',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.75),
                fontSize: 10.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunctionTile extends StatefulWidget {
  const _FunctionTile({
    super.key,
    required this.controller,
    required this.function,
  });

  final PlotController controller;
  final PlotFunction function;

  @override
  State<_FunctionTile> createState() => _FunctionTileState();
}

class _FunctionTileState extends State<_FunctionTile> {
  late final TextEditingController _expression;
  late final TextEditingController _second;

  @override
  void initState() {
    super.initState();
    _expression = TextEditingController(text: widget.function.expression);
    _second = TextEditingController(text: widget.function.secondExpression);
  }

  @override
  void didUpdateWidget(covariant _FunctionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.function.expression != _expression.text) {
      _expression.text = widget.function.expression;
    }
    if (widget.function.secondExpression != _second.text) {
      _second.text = widget.function.secondExpression;
    }
  }

  @override
  void dispose() {
    _expression.dispose();
    _second.dispose();
    super.dispose();
  }

  void _copyLatex(BuildContext context, PlotFunction function) {
    final latex = function.toLatex();
    final messenger = ScaffoldMessenger.of(context);
    if (latex == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('表达式不完整，无法转换为 LaTeX')),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: latex));
    messenger.showSnackBar(const SnackBar(content: Text('LaTeX 已复制')));
  }

  @override
  Widget build(BuildContext context) {
    final function = widget.function;
    final error = widget.controller.validate(function);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Tooltip(
                message: '点击切换颜色',
                child: InkWell(
                  onTap: () => widget.controller.cycleColor(function.id),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: function.color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: function.color.withValues(alpha: 0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<PlotMode>(
                tooltip: '切换曲线类型',
                padding: EdgeInsets.zero,
                onSelected: (mode) =>
                    widget.controller.updateExpression(function.id, mode: mode),
                itemBuilder: (context) => [
                  for (final mode in PlotMode.values)
                    PopupMenuItem<PlotMode>(
                      value: mode,
                      child: Text(mode.label),
                    ),
                ],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      function.mode.label,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: function.visible ? '隐藏曲线' : '显示曲线',
                visualDensity: VisualDensity.compact,
                iconSize: 17,
                color: function.visible
                    ? AppColors.textSecondary
                    : AppColors.outline,
                onPressed: () =>
                    widget.controller.toggleVisibility(function.id),
                icon: Icon(
                  function.visible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
              IconButton(
                tooltip: '复制 LaTeX',
                visualDensity: VisualDensity.compact,
                iconSize: 17,
                color: AppColors.textSecondary,
                onPressed: () => _copyLatex(context, function),
                icon: const Icon(Icons.copy_rounded),
              ),
              IconButton(
                tooltip: '删除',
                visualDensity: VisualDensity.compact,
                iconSize: 17,
                color: AppColors.textSecondary,
                onPressed: () => widget.controller.removeFunction(function.id),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 2),
          _buildField(
            controller: _expression,
            prefix: switch (function.mode) {
              PlotMode.cartesian => 'y =',
              PlotMode.polar => 'r =',
              PlotMode.parametric => 'x =',
              PlotMode.implicit => '0 =',
            },
            hint: function.mode.hint,
            onChanged: (value) => widget.controller.updateExpression(
              function.id,
              expression: value,
            ),
            enabled: function.visible,
            accent: function.color,
          ),
          if (function.mode.needsSecondExpression) ...[
            const SizedBox(height: 6),
            _buildField(
              controller: _second,
              prefix: 'y =',
              hint: 'y(t)',
              onChanged: (value) => widget.controller.updateExpression(
                function.id,
                secondExpression: value,
              ),
              enabled: function.visible,
              accent: function.color,
            ),
          ],
          if (error != null && function.visible)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 2),
              child: Text(
                error,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: AppColors.error, fontSize: 10.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String prefix,
    required String hint,
    required ValueChanged<String> onChanged,
    required bool enabled,
    required Color accent,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      style: TextStyle(
        fontSize: 13,
        fontFamily: 'monospace',
        color: enabled ? AppColors.textPrimary : AppColors.outline,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceHigh.withValues(alpha: 0.7),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 8, right: 4),
          child: Center(
            widthFactor: 1,
            child: Text(
              prefix,
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.outline,
          fontSize: 12,
          fontFamily: 'monospace',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
