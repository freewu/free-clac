import 'package:flutter/foundation.dart';

/// 配色与界面语言的版本号，每次切换自增。
///
/// 全应用的颜色（`AppColors`）与文案（`t`）都是全局静态入口，切换时不改
/// widget 树，只让整棵树重建。但已经压栈的页面其 route 只会构建一次 widget，
/// `const XxxPage()` 更是同一实例、连 rebuild 都不会触发，于是切完主题 /
/// 语言回到那个页面还是旧样子。用 [appAppearanceRevision] 包一层
/// `ListenableBuilder`，就能在不丢页面状态的前提下把这些变化推进去。
final ValueNotifier<int> appAppearanceRevision = ValueNotifier<int>(0);
