import 'package:flutter/widgets.dart';

/// 配色与界面语言的版本号，每次切换自增。
///
/// 全应用的颜色（`AppColors`）与文案（`t`）都是全局静态入口，切换时不改
/// widget 树，只让整棵树重建。但已经压栈的页面其 route 只会构建一次 widget，
/// `const XxxPage()` 更是同一实例、连 rebuild 都不会触发，于是切完主题 /
/// 语言回到那个页面还是旧样子。用 [appAppearanceRevision] 包一层
/// `ListenableBuilder`，就能在不丢页面状态的前提下把这些变化推进去。
final ValueNotifier<int> appAppearanceRevision = ValueNotifier<int>(0);

/// 让页面在切主题 / 语言后真正重建一次。
///
/// 工具页活在内嵌 [Navigator] 的路由里，`ToolInfo.pageBuilder` 交下来的页面
/// 大多是 `const XxxPage()`：`ListenableBuilder` 重建时拿到的还是同一个实例，
/// Flutter 判定「无需更新」，跳过了 `State.build`，页面里读到的 `t` / `AppColors`
/// 就停在旧的一套。页面自己的 State 监听版本号，才能保证文案与配色都刷新。
mixin AppAppearanceAware<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    appAppearanceRevision.addListener(_onAppearanceChanged);
  }

  void _onAppearanceChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    appAppearanceRevision.removeListener(_onAppearanceChanged);
    super.dispose();
  }
}
