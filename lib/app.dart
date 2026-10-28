import 'package:flutter/material.dart';

import 'l10n/app_i18n.dart';
import 'l10n/app_language.dart';
import 'state/app_appearance.dart';
import 'state/settings_controller.dart';
import 'theme/app_theme.dart';
import 'ui/home_page.dart';

class FreeCalcApp extends StatefulWidget {
  const FreeCalcApp({
    super.key,
    this.initialTab = 0,
    this.initialPreset,
    this.initialTool,
    this.settings,
  });

  /// 启动时展示的页面（Web 端可通过 ?page=plot 直达绘图页）。
  final int initialTab;

  /// 启动时载入的示例曲线下标（Web 端 ?preset=0）。
  final int? initialPreset;

  /// 启动时直接打开的工具 id（Web 端 ?tool=bmi），由工具页内嵌的
  /// Navigator 打开，外层导航菜单仍然保留。
  final String? initialTool;

  /// 测试可注入自定义设置（内存存储、固定主题）；为空时自建并读本地配置。
  final SettingsController? settings;

  @override
  State<FreeCalcApp> createState() => _FreeCalcAppState();
}

class _FreeCalcAppState extends State<FreeCalcApp> with WidgetsBindingObserver {
  late final SettingsController _settings =
      widget.settings ?? SettingsController();
  late final bool _ownsSettings = widget.settings == null;

  /// 上次真正应用到全局入口的配色与语言，用来判断是否需要通知其他页面。
  Brightness? _appliedBrightness;
  AppLanguage? _appliedLanguage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _settings.addListener(_onSettingsChanged);
    // 本地设置是异步读的：读完再重建一次即可，首帧用默认值。
    _settings.load();
    _syncGlobals();
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    if (_ownsSettings) _settings.dispose();
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // 「跟随系统」时系统换了明暗要跟着换配色。
    if (_settings.themeMode == AppThemeMode.system) _refresh();
  }

  void _onSettingsChanged() => _refresh();

  /// 全局入口（[AppColors] / [t]）已经换成新值，通知已压栈的页面重建。
  ///
  /// 必须在重建自身之前自增，避免在 build 里改 notifier。
  void _refresh() {
    final palette = _settings.paletteFor(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    if (palette.brightness != _appliedBrightness ||
        _settings.language != _appliedLanguage) {
      _appliedBrightness = palette.brightness;
      _appliedLanguage = _settings.language;
      AppColors.apply(palette);
      applyAppLanguage(_settings.language);
      appAppearanceRevision.value++;
    }
    if (mounted) setState(() {});
  }

  /// 首帧（以及未变化时）只切全局入口，不自增版本号。
  void _syncGlobals() {
    final palette = _settings.paletteFor(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    _appliedBrightness = palette.brightness;
    _appliedLanguage = _settings.language;
    AppColors.apply(palette);
    applyAppLanguage(_settings.language);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _settings.paletteFor(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
    // 全应用的颜色与文案都从这两个全局入口读，重建前先切好。
    AppColors.apply(palette);
    applyAppLanguage(_settings.language);

    return MaterialApp(
      title: t.appTitle,
      debugShowCheckedModeBanner: false,
      locale: _settings.language.locale,
      theme: AppTheme.of(palette),
      home: HomePage(
        settings: _settings,
        initialTab: widget.initialTab,
        initialPreset: widget.initialPreset,
        initialTool: widget.initialTool,
      ),
    );
  }
}
