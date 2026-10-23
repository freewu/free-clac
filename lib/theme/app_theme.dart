import 'package:flutter/material.dart';

/// 应用配色：深色科学计算器风格。
abstract final class AppColors {
  static const Color background = Color(0xFF0A0E14);
  static const Color surface = Color(0xFF121821);
  static const Color surfaceHigh = Color(0xFF1A2230);
  static const Color surfaceHigher = Color(0xFF222C3C);
  static const Color outline = Color(0xFF2E3A4C);

  static const Color primary = Color(0xFF4F9CFF);
  static const Color secondary = Color(0xFF22D3EE);
  static const Color tertiary = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFF6B6B);

  static const Color textPrimary = Color(0xFFE9F0FA);
  static const Color textSecondary = Color(0xFF93A4BB);

  /// 曲线调色板。
  static const List<Color> curvePalette = <Color>[
    Color(0xFF4F9CFF),
    Color(0xFFFF7A59),
    Color(0xFF34D399),
    Color(0xFFC084FC),
    Color(0xFFFBBF24),
    Color(0xFF22D3EE),
    Color(0xFFF472B6),
    Color(0xFFA3E635),
  ];
}

abstract final class AppTheme {
  static ThemeData dark() {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Color(0xFF04101F),
      primaryContainer: Color(0xFF1B3A5C),
      onPrimaryContainer: AppColors.textPrimary,
      secondary: AppColors.secondary,
      onSecondary: Color(0xFF041318),
      tertiary: AppColors.tertiary,
      onTertiary: Color(0xFF04170F),
      error: AppColors.error,
      onError: Color(0xFF22080A),
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceHigher,
      outline: AppColors.outline,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          )
          .copyWith(
            bodySmall: const TextStyle(color: AppColors.textSecondary),
            labelSmall: const TextStyle(color: AppColors.textSecondary),
          ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceHigh,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigher,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceHigher,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
