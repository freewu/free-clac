import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_i18n.dart';
import '../l10n/app_language.dart';
import '../state/settings_controller.dart';
import '../theme/app_theme.dart';
import 'tools/widgets/tool_select.dart';

/// 仓库地址，设置页「关于」里展示与复制。
const String kRepositoryUrl = 'https://github.com/freewu/free-clac';

/// 应用版本号，与 pubspec.yaml 的 version 保持一致。
const String kAppVersion = '1.0.0';

/// 「设置」页：主题模式（跟随系统 / 浅色 / 深色）与界面语言。
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.controller});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(),
                const SizedBox(height: 14),
                _Card(
                  icon: Icons.palette_outlined,
                  title: t.settingsAppearance,
                  child: Row(
                    children: [
                      for (final mode in AppThemeMode.values) ...[
                        if (mode != AppThemeMode.values.first)
                          const SizedBox(width: 8),
                        Expanded(
                          child: _ModeTile(
                            mode: mode,
                            selected: controller.themeMode == mode,
                            onTap: () => controller.setThemeMode(mode),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  icon: Icons.translate_rounded,
                  title: t.settingsLanguage,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolSelect<AppLanguage>(
                        key: const Key('settings-language'),
                        value: controller.language,
                        items: AppLanguage.values,
                        labelOf: (language) =>
                            '${language.nativeLabel} · ${language.englishLabel}',
                        onChanged: controller.setLanguage,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.settingsLanguageHint,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10.5,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _Card(
                  icon: Icons.info_outline_rounded,
                  title: t.settingsAbout,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        t.aboutDescription,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _InfoRow(label: t.aboutVersion, value: kAppVersion),
                      const SizedBox(height: 6),
                      _InfoRow(label: t.aboutRepo, value: kRepositoryUrl),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(text: kRepositoryUrl),
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t.aboutLinkCopied)),
                            );
                          },
                          icon: const Icon(Icons.link_rounded, size: 16),
                          label: Text(t.aboutRepoAction),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  t.settingsFootnote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.settings_rounded, size: 19, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          t.settingsTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            t.settingsSubtitle,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.icon, required this.title, required this.child});

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
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
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (mode) {
      AppThemeMode.system => (Icons.brightness_auto_rounded, t.themeSystem),
      AppThemeMode.light => (Icons.light_mode_rounded, t.themeLight),
      AppThemeMode.dark => (Icons.dark_mode_rounded, t.themeDark),
    };
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        key: Key('settings-theme-${mode.code}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.outline,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                  fontSize: 11.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 68,
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(color: AppColors.textPrimary, fontSize: 11.5),
          ),
        ),
      ],
    );
  }
}
