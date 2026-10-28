import 'package:flutter/material.dart';

/// 一套完整配色。深色是默认风格，浅色用于「浅色模式」。
///
/// 所有界面都通过 [AppColors] 取色，切换时只换 [AppPalette] 实例，
/// 不必在每个组件里判断 `Theme.of(context).brightness`。
@immutable
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.surfaceHigher,
    required this.outline,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.tertiary,
    required this.onTertiary,
    required this.warning,
    required this.error,
    required this.onError,
    required this.violet,
    required this.orange,
    required this.textPrimary,
    required this.textSecondary,
    required this.curvePalette,
  });

  /// 该配色对应的明暗，用来生成 [ThemeData] 与状态栏样式。
  final Brightness brightness;

  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color surfaceHigher;
  final Color outline;

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color tertiary;
  final Color onTertiary;
  final Color warning;
  final Color error;
  final Color onError;

  /// 工具卡片的补充配色（紫 / 橙）。
  final Color violet;
  final Color orange;

  final Color textPrimary;
  final Color textSecondary;

  /// 曲线调色板。
  final List<Color> curvePalette;

  bool get isDark => brightness == Brightness.dark;
}

/// 深色配色：深色科学计算器风格（默认）。
const AppPalette kDarkPalette = AppPalette(
  brightness: Brightness.dark,
  background: Color(0xFF0A0E14),
  surface: Color(0xFF121821),
  surfaceHigh: Color(0xFF1A2230),
  surfaceHigher: Color(0xFF222C3C),
  outline: Color(0xFF2E3A4C),
  primary: Color(0xFF4F9CFF),
  onPrimary: Color(0xFF04101F),
  primaryContainer: Color(0xFF1B3A5C),
  secondary: Color(0xFF22D3EE),
  onSecondary: Color(0xFF041318),
  tertiary: Color(0xFF34D399),
  onTertiary: Color(0xFF04170F),
  warning: Color(0xFFFBBF24),
  error: Color(0xFFFF6B6B),
  onError: Color(0xFF22080A),
  violet: Color(0xFFC084FC),
  orange: Color(0xFFFF7A59),
  textPrimary: Color(0xFFE9F0FA),
  textSecondary: Color(0xFF93A4BB),
  curvePalette: <Color>[
    Color(0xFF4F9CFF),
    Color(0xFFFF7A59),
    Color(0xFF34D399),
    Color(0xFFC084FC),
    Color(0xFFFBBF24),
    Color(0xFF22D3EE),
    Color(0xFFF472B6),
    Color(0xFFA3E635),
  ],
);

/// 浅色配色：同一套色相压暗到白底可读，曲线调色板换成深色版本。
const AppPalette kLightPalette = AppPalette(
  brightness: Brightness.light,
  background: Color(0xFFF4F6FA),
  surface: Color(0xFFFFFFFF),
  surfaceHigh: Color(0xFFEDF1F7),
  surfaceHigher: Color(0xFFE2E8F1),
  outline: Color(0xFFD2DAE5),
  primary: Color(0xFF1F6FEB),
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: Color(0xFFD6E4FF),
  secondary: Color(0xFF0E7490),
  onSecondary: Color(0xFFFFFFFF),
  tertiary: Color(0xFF0F9D74),
  onTertiary: Color(0xFFFFFFFF),
  warning: Color(0xFFB45309),
  error: Color(0xFFD92D20),
  onError: Color(0xFFFFFFFF),
  violet: Color(0xFF7C3AED),
  orange: Color(0xFFDC6320),
  textPrimary: Color(0xFF101B2D),
  textSecondary: Color(0xFF5A6B83),
  curvePalette: <Color>[
    Color(0xFF1F6FEB),
    Color(0xFFDC6320),
    Color(0xFF0F9D74),
    Color(0xFF7C3AED),
    Color(0xFFB45309),
    Color(0xFF0E7490),
    Color(0xFFDB2777),
    Color(0xFF4D7C0F),
  ],
);

/// 全局取色入口：所有颜色都读这里当前生效的 [AppPalette]。
///
/// 这样即便在 `static` 方法、`CustomPainter`、`const` 之外的工具函数里，
/// 也能拿到当前主题的颜色，无需层层传 `BuildContext`。
/// 切换配色由 `FreeCalcApp` 在构建 `MaterialApp` 之前调用 [apply]，
/// 随后整棵树重建即可。
abstract final class AppColors {
  static AppPalette _active = kDarkPalette;

  /// 当前生效的配色。
  static AppPalette get active => _active;

  /// 切换全局配色（只改数据，重建由调用方负责）。
  static void apply(AppPalette palette) => _active = palette;

  static Color get background => _active.background;
  static Color get surface => _active.surface;
  static Color get surfaceHigh => _active.surfaceHigh;
  static Color get surfaceHigher => _active.surfaceHigher;
  static Color get outline => _active.outline;

  static Color get primary => _active.primary;
  static Color get onPrimary => _active.onPrimary;
  static Color get primaryContainer => _active.primaryContainer;
  static Color get secondary => _active.secondary;
  static Color get onSecondary => _active.onSecondary;
  static Color get tertiary => _active.tertiary;
  static Color get onTertiary => _active.onTertiary;
  static Color get warning => _active.warning;
  static Color get error => _active.error;
  static Color get onError => _active.onError;

  static Color get violet => _active.violet;
  static Color get orange => _active.orange;

  static Color get textPrimary => _active.textPrimary;
  static Color get textSecondary => _active.textSecondary;

  static List<Color> get curvePalette => _active.curvePalette;
}

abstract final class AppTheme {
  /// 依据配色生成主题；浅色与深色共用同一份排版尺度。
  static ThemeData of(AppPalette palette) {
    final isDark = palette.isDark;
    final colorScheme = ColorScheme(
      brightness: palette.brightness,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.textPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      tertiary: palette.tertiary,
      onTertiary: palette.onTertiary,
      error: palette.error,
      onError: palette.onError,
      surface: palette.surface,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.surfaceHigher,
      outline: palette.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      canvasColor: palette.background,
      splashFactory: isDark
          ? InkSparkle.splashFactory
          : InkRipple.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          )
          .copyWith(
            bodySmall: TextStyle(color: palette.textSecondary),
            labelSmall: TextStyle(color: palette.textSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surfaceHigh,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 1.4),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.outline,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: palette.surfaceHigher,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceHigher,
        contentTextStyle: TextStyle(color: palette.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? palette.primary
                : palette.textSecondary,
          ),
        ),
      ),
    );
  }

  /// 深色主题（默认）。
  static ThemeData dark() => of(kDarkPalette);

  /// 浅色主题。
  static ThemeData light() => of(kLightPalette);
}
