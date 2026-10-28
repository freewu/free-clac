import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// 工具页通用的下拉选择器（如长度换算的「计量体系 / 单位」）。
///
/// 外观与 `ToolNumberField` 一致：上方小标题 + 圆角填充框，
/// 宽度自适应，适合和其它字段并排放在一行里。
class ToolSelect<T> extends StatelessWidget {
  const ToolSelect({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelOf,
    required this.onChanged,
  });

  /// 选择器上方的小标题，如「计量体系」。
  final String label;

  /// 当前选中的值，必须出现在 [items] 里。
  final T value;

  /// 可选项，顺序即菜单顺序。
  final List<T> items;

  /// 选项文案。
  final String Function(T value) labelOf;

  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<T>(
          // 受控：父级换值后 didUpdateWidget 会同步到 FormField
          initialValue: value,
          isDense: true,
          isExpanded: true,
          menuMaxHeight: 340,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: AppColors.surfaceHigher,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          items: [
            for (final item in items)
              DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelOf(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}
