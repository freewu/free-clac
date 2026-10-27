import 'package:flutter/material.dart';

import '../tools_page.dart';
import 'tool_catalog.dart';

/// 「工具」tab：用一个内嵌 [Navigator] 承载「工具列表 → 具体工具」的跳转，
/// 这样打开某个工具后，外层的导航菜单（侧边栏 / 底部栏）仍然保留。
class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key, this.initialTool, this.active = true});

  /// 深链参数（Web 端 `?tool=bmi`），启动时直接打开对应工具。
  final String? initialTool;

  /// 当前是否停留在工具 tab；只有停在工具 tab 时才接管系统返回键，
  /// 否则隐藏的 tab 会抢走返回事件。
  final bool active;

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final ToolInfo? _initialTool = widget.initialTool == null
      ? null
      : toolById(widget.initialTool!);

  @override
  Widget build(BuildContext context) {
    return NavigatorPopHandler<Object?>(
      enabled: widget.active,
      onPopWithResult: (_) => _navigatorKey.currentState?.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ToolsPage(),
        ),
        // 深链时首帧就是「列表 + 工具」两层路由，返回键回到列表。
        onGenerateInitialRoutes: (_, _) => [
          MaterialPageRoute<void>(builder: (_) => const ToolsPage()),
          if (_initialTool != null)
            MaterialPageRoute<void>(builder: _initialTool.builder),
        ],
      ),
    );
  }
}
