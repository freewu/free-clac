import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../theme/app_theme.dart';

/// 工具页通用的数字输入框（带单位后缀）。
class ToolNumberField extends StatelessWidget {
  const ToolNumberField({
    super.key,
    this.label,
    required this.controller,
    this.suffix = '',
    this.trailing,
    this.onChanged,
    this.hint,
    this.allowNegative = false,
  });

  /// 输入框上方的标题；组合输入（如 ft + in）时由外层统一提供，可传 null。
  final String? label;
  final TextEditingController controller;
  final String suffix;

  /// 输入框右侧的附加控件（如 ft / in 单位选择），会比 suffix 更靠右。
  final Widget? trailing;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final bool allowNegative;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 5),
        ],
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(allowNegative ? r'[0-9.\-]' : r'[0-9.]'),
            ),
          ],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixIcon: trailing == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 8),
                    // suffixIcon 槽位是 48 高的紧约束，居中后才能和
                    // 其它字段的 suffixText 保持同一水平线
                    child: Center(child: trailing),
                  ),
            suffixStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

/// 工具页通用卡片容器。
class ToolSection extends StatelessWidget {
  const ToolSection({
    super.key,
    required this.child,
    this.title,
    this.icon,
    this.trailing,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final String? title;
  final IconData? icon;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                ],
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                ?trailing,
              ],
            ),
            const SizedBox(height: 10),
          ],
          child,
        ],
      ),
    );
  }
}
