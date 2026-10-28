import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/calc_strings.dart';
import '../state/calculator_controller.dart';
import '../theme/app_theme.dart';
import 'widgets/calc_display.dart';
import 'widgets/history_panel.dart';
import 'widgets/keypad.dart';

/// 计算器主页面（宽屏时右侧常驻历史记录）。
class CalculatorPage extends StatelessWidget {
  const CalculatorPage({super.key, required this.controller});

  final CalculatorController controller;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.arrowUp): _RecallHistoryIntent(true),
        SingleActivator(LogicalKeyboardKey.arrowDown): _RecallHistoryIntent(
          false,
        ),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _RecallHistoryIntent: CallbackAction<_RecallHistoryIntent>(
            onInvoke: (intent) {
              controller.recallHistory(older: intent.older);
              return null;
            },
          ),
        },
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 1040;
        final displayHeight = (constraints.maxHeight * 0.28).clamp(
          160.0,
          260.0,
        );

        final main = Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 780),
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Column(
                  children: [
                    SizedBox(
                      height: wide ? displayHeight : displayHeight * 0.9,
                      child: CalcDisplay(
                        controller: controller,
                        onOpenHistory: wide
                            ? null
                            : () => _showHistory(context),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: Keypad(controller: controller)),
                  ],
                ),
              ),
            ),
          ),
        );

        if (!wide) {
          return Column(
            children: [
              Expanded(child: main),
              _buildHintBar(context),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: main),
            Container(width: 1, color: AppColors.outline),
            SizedBox(width: 340, child: HistoryPanel(controller: controller)),
          ],
        );
      },
    );
  }

  Widget _buildHintBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              calcStrings.keyboardHint,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _showHistory(context),
            icon: const Icon(Icons.history_rounded, size: 16),
            label: Text(
              calcStrings.historyShort,
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              visualDensity: VisualDensity.compact,
            ),
          ),
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
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.62,
        child: HistoryPanel(controller: controller),
      ),
    );
  }
}

/// ↑ / ↓ 翻阅历史记录。
class _RecallHistoryIntent extends Intent {
  const _RecallHistoryIntent(this.older);

  final bool older;
}
