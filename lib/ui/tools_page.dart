import 'package:flutter/material.dart';

import '../l10n/app_i18n.dart';
import '../state/app_appearance.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';
import 'tools/tool_catalog.dart';

/// 「工具」页：以应用商店的风格列出内置小工具，点开即可使用。
///
/// 卡片右上角的图钉可以把工具置顶，置顶的工具排在页面上方；
/// 最多能置顶几个由设置页的「置顶数量」决定（2 ~ 5，默认 3）。
class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 工具页在工具 tab 的内嵌 Navigator 里，外层 setState 不会重跑路由 builder，
    // 所以自己监听设置：置顶数量、置顶项变了要立刻刷新列表。
    return ListenableBuilder(
      listenable: currentSettings ?? appAppearanceRevision,
      // 不能返回 const：语言 / 配色切换后要真的重建，否则文案不会跟着变
      builder: (context, _) => _ToolsBody(),
    );
  }
}

class _ToolsBody extends StatelessWidget {
  const _ToolsBody();

  Future<void> _togglePin(BuildContext context, ToolInfo tool) async {
    final settings = currentSettings;
    if (settings == null) return;
    final ok = await settings.togglePinned(tool.id);
    if (ok || !context.mounted) return;
    // 顶满了：提示上限，顺便告诉用户去哪里改
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.toolPinLimit(settings.pinnedLimit)),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final settings = currentSettings;
    final pinnedIds = settings?.pinnedTools ?? const <String>[];
    final limit =
        settings?.pinnedLimit ?? SettingsController.defaultPinnedTools;

    // 置顶项与其余工具都保持工具表里的顺序，置顶不会打乱原有相对次序
    final pinned = <ToolInfo>[];
    final others = <ToolInfo>[];
    for (final tool in visibleTools) {
      (pinnedIds.contains(tool.id) ? pinned : others).add(tool);
    }

    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: CustomScrollView(
            slivers: [
              if (pinned.isNotEmpty) ...[
                _sectionHeader(
                  icon: Icons.push_pin_rounded,
                  title: t.toolsPinned,
                  trailing: t.pinnedCount(pinned.length, limit),
                ),
                _grid(pinned, pinned: true, onTogglePin: _togglePin),
                _sectionHeader(
                  icon: Icons.widgets_outlined,
                  title: t.toolsOthers,
                  trailing: t.toolsCount(others.length),
                ),
              ],
              _grid(others, pinned: false, onTogglePin: _togglePin),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _grid(
    List<ToolInfo> tools, {
    required bool pinned,
    required Future<void> Function(BuildContext, ToolInfo) onTogglePin,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid.builder(
        // 1440 宽时排 3 列（3 + 2），比 4 列留一张卡片在新一行更整齐
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          mainAxisExtent: 132,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          return _ToolCard(
            tool: tool,
            pinned: pinned,
            onTogglePin: () => onTogglePin(context, tool),
          );
        },
      ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required String title,
    required String trailing,
  }) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              trailing,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: Row(
        children: [
          Icon(Icons.apps_rounded, size: 19, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            t.toolsTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              t.toolsCount(visibleTools.length),
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              t.toolsOffline,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 商店风格的应用卡片。
class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.tool,
    required this.pinned,
    required this.onTogglePin,
  });

  final ToolInfo tool;

  /// 是否已置顶，决定图钉的样式与提示文案。
  final bool pinned;

  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tool.color.withValues(alpha: 0.14),
            AppColors.surface,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tool.color.withValues(alpha: pinned ? 0.55 : 0.28),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.of(
                  context,
                ).push(MaterialPageRoute<void>(builder: tool.pageBuilder)),
                child: Padding(
                  // 右上角留给图钉，文字别顶到它下面
                  padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              tool.color.withValues(alpha: 0.9),
                              tool.color.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                        child: Icon(
                          tool.icon,
                          size: 25,
                          color: AppColors.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 22),
                              child: Text(
                                tool.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              tool.tagline,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tool.color,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              tool.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: _PinButton(
              key: Key('tool-pin-${tool.id}'),
              pinned: pinned,
              tooltip: pinned ? t.toolUnpin : t.toolPin,
              onPressed: onTogglePin,
            ),
          ),
        ],
      ),
    );
  }
}

/// 卡片右上角的图钉：点一下置顶，再点一下取消。
class _PinButton extends StatelessWidget {
  const _PinButton({
    super.key,
    required this.pinned,
    required this.tooltip,
    required this.onPressed,
  });

  final bool pinned;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = pinned ? AppColors.primary : AppColors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: pinned
            ? AppColors.primary.withValues(alpha: 0.14)
            : Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              pinned ? Icons.push_pin : Icons.push_pin_outlined,
              size: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
