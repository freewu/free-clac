import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// 输入框内的小单位选择器（如 BMI 的 `ft ▾`、贷款期限的 `年 ▾`）。
///
/// 放在 [ToolNumberField.trailing] 里，和 `suffixText` 共用同一条水平线。
class ToolUnitPicker<T> extends StatelessWidget {
  const ToolUnitPicker({
    super.key,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onSelected,
    this.menuLabelOf,
    this.tooltip,
  });

  /// 当前选中的单位。
  final T value;

  /// 可选单位，顺序即菜单顺序。
  final List<T> items;

  /// 输入框里显示的短标签（如 `ft`、`年`）。
  final String Function(T value) labelOf;

  /// 菜单项文案，默认与 [labelOf] 相同。
  final String Function(T value)? menuLabelOf;

  final ValueChanged<T> onSelected;

  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final menuLabel = menuLabelOf ?? labelOf;
    return PopupMenuButton<T>(
      tooltip: tooltip ?? '切换单位',
      padding: EdgeInsets.zero,
      position: PopupMenuPosition.under,
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final item in items)
          PopupMenuItem(
            value: item,
            height: 38,
            child: Text(
              menuLabel(item),
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelOf(value),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.arrow_drop_down_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
