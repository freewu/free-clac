import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/builtins.dart';
import '../../core/latex.dart';
import '../../core/number_format.dart';
import '../../state/calculator_controller.dart';
import '../../theme/app_theme.dart';

/// 顶部显示屏：角度模式、表达式输入、实时结果预览。
class CalcDisplay extends StatelessWidget {
  const CalcDisplay({super.key, required this.controller, this.onOpenHistory});

  final CalculatorController controller;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131B26), Color(0xFF0E141D)],
        ),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildToolbar(context),
          const SizedBox(height: 6),
          Expanded(child: _buildInput()),
          const SizedBox(height: 4),
          _buildResult(context),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    final mode = controller.angleMode;
    final latex = tryExpressionToLatex(controller.expression);
    final value = controller.previewValue;
    return Row(
      children: [
        _Chip(
          label: mode.shortLabel,
          tooltip: '切换角度单位（当前：${mode.label}）',
          color: AppColors.secondary,
          onTap: controller.toggleAngleMode,
        ),
        const SizedBox(width: 6),
        if (controller.memoryActive)
          _Chip(
            label: 'M ${formatNumber(controller.memory, significantDigits: 6)}',
            tooltip: '清除内存（M+ / M− 可在函数库中调用）',
            color: AppColors.warning,
            onTap: controller.memoryClear,
          ),
        if (controller.memoryActive) const SizedBox(width: 6),
        if (controller.answer != null)
          _Chip(
            label:
                'ans ${formatNumber(controller.answer!, significantDigits: 6)}',
            color: AppColors.tertiary,
            onTap: () => controller.insert('ans'),
            tooltip: '插入上一次结果',
          ),
        const Spacer(),
        IconButton(
          onPressed: () => _showFunctionSheet(context),
          icon: const Icon(Icons.functions, size: 20),
          tooltip: '函数库',
          visualDensity: VisualDensity.compact,
          color: AppColors.textSecondary,
        ),
        PopupMenuButton<_CopyAction>(
          tooltip: '复制',
          icon: const Icon(Icons.copy_rounded, size: 19),
          color: AppColors.surface,
          position: PopupMenuPosition.under,
          iconColor: AppColors.textSecondary,
          onSelected: (action) => _copy(context, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _CopyAction.value,
              enabled: value != null,
              child: const _CopyMenuItem(
                icon: Icons.numbers_rounded,
                label: '复制结果',
              ),
            ),
            PopupMenuItem(
              value: _CopyAction.latex,
              enabled: latex != null,
              child: const _CopyMenuItem(
                icon: Icons.functions,
                label: '复制公式（LaTeX）',
              ),
            ),
            PopupMenuItem(
              value: _CopyAction.latexWithResult,
              enabled: latex != null && value != null,
              child: const _CopyMenuItem(
                icon: Icons.drag_handle_rounded,
                label: '复制公式与结果（LaTeX）',
              ),
            ),
          ],
        ),
        if (onOpenHistory != null)
          IconButton(
            onPressed: onOpenHistory,
            icon: const Icon(Icons.history_rounded, size: 20),
            tooltip: '历史记录',
            visualDensity: VisualDensity.compact,
            color: AppColors.textSecondary,
          ),
      ],
    );
  }

  void _copy(BuildContext context, _CopyAction action) {
    final value = controller.previewValue;
    final latex = tryExpressionToLatex(controller.expression);
    final result = value == null
        ? null
        : formatNumber(value, significantDigits: 15);

    final String? text;
    final String message;
    switch (action) {
      case _CopyAction.value:
        text = result;
        message = '结果已复制';
      case _CopyAction.latex:
        text = latex;
        message = 'LaTeX 已复制';
      case _CopyAction.latexWithResult:
        text = latex == null || result == null ? null : '$latex = $result';
        message = 'LaTeX 与结果已复制';
    }
    if (text == null) return;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showFunctionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => FunctionsSheet(controller: controller),
    );
  }

  Widget _buildInput() {
    return Align(
      alignment: Alignment.topRight,
      child: TextField(
        controller: controller.input,
        maxLines: 4,
        textAlign: TextAlign.right,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => controller.evaluate(),
        style: const TextStyle(
          fontSize: 26,
          height: 1.25,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
        decoration: InputDecoration(
          isCollapsed: false,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: '输入表达式，例如 sin(30) + 2^3',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final error = controller.previewError;
    final value = controller.previewValue;

    if (error != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2, right: 6),
            child: Icon(Icons.error_outline, color: AppColors.error, size: 16),
          ),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      );
    }

    if (value == null) {
      return Text(
        '实时预览结果会显示在这里，按 = 记录到历史',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }

    final text = formatNumber(value, significantDigits: 14);
    return InkWell(
      onTap: controller.appendResult,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text(
              '=',
              style: TextStyle(
                color: AppColors.secondary.withValues(alpha: 0.8),
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.north_west_rounded,
              size: 15,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示屏「复制」菜单里的动作。
enum _CopyAction { value, latex, latexWithResult }

class _CopyMenuItem extends StatelessWidget {
  const _CopyMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 13.5)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    this.onTap,
    this.tooltip,
  });

  final String label;
  final Color color;
  final VoidCallback? onTap;
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
    if (tooltip == null) return chip;
    return Tooltip(message: tooltip!, child: chip);
  }
}

/// 函数库：按类别列出所有内置函数，点击插入模板。
class FunctionsSheet extends StatelessWidget {
  const FunctionsSheet({super.key, required this.controller});

  final CalculatorController controller;

  static const Map<String, String> _categories = {
    '三角': 'sin cos tan csc sec cot asin acos atan atan2',
    '双曲': 'sinh cosh tanh asinh acosh atanh',
    '指数对数': 'exp ln log lg log2 expm1',
    '幂与根': 'sqrt cbrt root hypot',
    '取整符号': 'abs sign floor ceil round trunc frac mod',
    '组合统计': 'fact gamma ncr npr gcd lcm min max avg',
    '微积分': 'sum prod integrate diff',
    '其它': 'deg rad sinc rand randint',
  };

  static const Map<String, String> _templates = {
    'sum': 'sum(, k, 1, 10)',
    'prod': 'prod(, k, 1, 10)',
    'integrate': 'integrate(, x, 0, 1)',
    'diff': 'diff(, x, 0)',
  };

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.75,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '函数库',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              '点击即可插入，支持隐式乘法（2x、3sin(x)）与 ans / mem 变量',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final entry in _categories.entries)
                    _buildCategory(context, entry.key, entry.value.split(' ')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategory(
    BuildContext context,
    String title,
    List<String> names,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final name in names)
              if (_exists(name))
                Tooltip(
                  message: _description(name),
                  child: ActionChip(
                    backgroundColor: AppColors.surfaceHigh,
                    side: BorderSide(
                      color: AppColors.outline.withValues(alpha: 0.6),
                    ),
                    label: Text(name, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _insert(name);
                      Navigator.of(context).maybePop();
                    },
                  ),
                ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  void _insert(String name) {
    final template = _templates[name] ?? '$name(';
    final open = template.indexOf('(');
    final caret = open < 0 ? template.length : open + 1;
    controller.insert(template, cursorOffset: caret - template.length);
  }
}

bool _exists(String name) =>
    builtinFunctions.containsKey(name) || specialFormNames.contains(name);

String _description(String name) {
  final function = builtinFunctions[name];
  if (function != null) {
    return '${function.signature} — ${function.description}';
  }
  switch (name) {
    case 'sum':
      return 'sum(f(k), k, a, b) — 求和 Σ';
    case 'prod':
      return 'prod(f(k), k, a, b) — 连乘 Π';
    case 'integrate':
      return 'integrate(f(x), x, a, b) — 自适应 Simpson 数值积分';
    case 'diff':
      return 'diff(f(x), x, a) — 数值导数';
  }
  return name;
}
