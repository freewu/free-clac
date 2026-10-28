import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/latex.dart';
import '../../core/number_format.dart';
import '../../l10n/calc_strings.dart';
import '../../models/history_entry.dart';
import '../../state/calculator_controller.dart';
import '../../theme/app_theme.dart';

/// 历史记录列表。
class HistoryPanel extends StatelessWidget {
  const HistoryPanel({
    super.key,
    required this.controller,
    this.showClearButton = true,
  });

  final CalculatorController controller;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final history = controller.history;
        return Container(
          color: AppColors.surface.withValues(alpha: 0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      calcStrings.historyTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    if (showClearButton && history.isNotEmpty)
                      TextButton.icon(
                        onPressed: controller.clearHistory,
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: Text(
                          calcStrings.clear,
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            calcStrings.historyEmpty,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.6,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: history.length,
                        itemBuilder: (context, index) => _HistoryTile(
                          entry: history[index],
                          onTap: () => controller.useHistory(history[index]),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onTap});

  final HistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 9, 4, 9),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    entry.expression,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.display,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: entry.isError
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontSize: entry.isError ? 12 : 16,
                      fontWeight: entry.isError
                          ? FontWeight.w400
                          : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<_EntryAction>(
              tooltip: calcStrings.copyEntryTooltip,
              icon: const Icon(Icons.copy_rounded, size: 16),
              color: AppColors.surface,
              iconColor: AppColors.textSecondary,
              iconSize: 16,
              padding: EdgeInsets.zero,
              onSelected: (action) => _copy(context, action),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _EntryAction.latex,
                  enabled: tryExpressionToLatex(entry.expression) != null,
                  child: Text(calcStrings.copyLatex),
                ),
                PopupMenuItem(
                  value: _EntryAction.value,
                  enabled: !entry.isError,
                  child: Text(calcStrings.copyResult),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copy(BuildContext context, _EntryAction action) {
    final String? text;
    final String message;
    switch (action) {
      case _EntryAction.latex:
        text = tryExpressionToLatex(entry.expression);
        message = calcStrings.latexCopied;
      case _EntryAction.value:
        final value = entry.value;
        text = value == null
            ? null
            : formatNumber(value, significantDigits: 15);
        message = calcStrings.resultCopied;
    }
    if (text == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(calcStrings.latexFailed)));
      return;
    }

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

/// 历史记录「复制」菜单里的动作。
enum _EntryAction { latex, value }
