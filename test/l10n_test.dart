import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/core/angle_mode.dart';
import 'package:free_clac/core/builtins.dart';
import 'package:free_clac/l10n/calc_strings.dart';
import 'package:free_clac/l10n/plot_strings.dart';
import 'package:free_clac/l10n/app_language.dart';
import 'package:free_clac/models/plot_function.dart';
import 'package:free_clac/plot/plot_export.dart';
import 'package:free_clac/plot/plot_presets.dart';
import 'package:free_clac/plot/plot_viewport.dart';
import 'package:free_clac/state/plot_controller.dart';

void main() {
  group('计算器页面文案', () {
    test('五种语言都齐全', () {
      for (final language in AppLanguage.values) {
        expect(
          kCalcStrings.containsKey(language),
          isTrue,
          reason: language.code,
        );
      }
    });

    test('除简体外的语言翻全了 48 个内置函数说明', () {
      // 简体直接用 core/builtins.dart 的中文，其余语言必须自己覆盖
      for (final language in AppLanguage.values) {
        if (language == AppLanguage.zhHans) continue;
        final descriptions = kCalcStrings[language]!.functionDescriptions;
        for (final name in builtinFunctions.keys) {
          expect(
            descriptions.containsKey(name),
            isTrue,
            reason: '${language.code} 缺少 $name 的说明',
          );
          expect(descriptions[name], isNotEmpty);
        }
      }
    });

    test('取不到的说明回落数据层中文', () {
      const strings = CalcStrings(
        keyboardHint: '',
        historyShort: '',
        clear: '',
        historyTitle: '',
        historyEmpty: '',
        copyEntryTooltip: '',
        copyLatex: '',
        copyResult: '',
        latexCopied: '',
        resultCopied: '',
        latexWithResultCopied: '',
        latexFailed: '',
        angleTooltip: '',
        memoryClearTooltip: '',
        insertAnsTooltip: '',
        functionLibrary: '',
        copyTooltip: '',
        copyLatexWithResult: '',
        inputHint: '',
        previewHint: '',
        functionsIntro: '',
        angleDegrees: '',
        angleRadians: '',
        categoryTrig: '',
        categoryHyperbolic: '',
        categoryExpLog: '',
        categoryPowerRoot: '',
        categoryRounding: '',
        categoryCombinatorics: '',
        categoryCalculus: '',
        categoryMisc: '',
        functionDescriptions: <String, String>{'sin': 'sine'},
        sumDescription: '',
        prodDescription: '',
        integrateDescription: '',
        diffDescription: '',
      );
      expect(strings.functionDescription('sin', '正弦'), 'sine');
      expect(strings.functionDescription('cos', '余弦'), '余弦');
    });

    test('角度单位名称跟语言走', () {
      expect(
        kCalcStrings[AppLanguage.en]!.angleLabel(AngleMode.degrees),
        'degrees',
      );
      expect(
        kCalcStrings[AppLanguage.ja]!.angleLabel(AngleMode.radians),
        'ラジアン',
      );
      expect(
        kCalcStrings[AppLanguage.es]!.angleLabel(AngleMode.degrees),
        'grados',
      );
    });
  });

  group('绘图页面文案', () {
    test('五种语言都齐全', () {
      for (final language in AppLanguage.values) {
        expect(
          kPlotStrings.containsKey(language),
          isTrue,
          reason: language.code,
        );
        final strings = kPlotStrings[language]!;
        for (final mode in PlotMode.values) {
          expect(strings.modeLabel(mode), isNotEmpty);
          expect(strings.modeMenu(mode), isNotEmpty);
          expect(strings.modeHint(mode), isNotEmpty);
        }
      }
    });

    test('曲线类型名称按语言区分', () {
      final en = kPlotStrings[AppLanguage.en]!;
      final zh = kPlotStrings[AppLanguage.zhHans]!;
      expect(en.modeLabel(PlotMode.cartesian), 'Cartesian');
      expect(en.modeLabel(PlotMode.implicit), 'Implicit');
      expect(zh.modeLabel(PlotMode.cartesian), '直角坐标');
      expect(en.modeHint(PlotMode.parametric), 'x(t) and y(t)');
      expect(zh.modeHint(PlotMode.parametric), 'x(t) 与 y(t)');
    });

    test('示例曲线的名称与说明翻了四种语言，简体保持原文', () {
      const translated = <AppLanguage>[
        AppLanguage.zhHant,
        AppLanguage.en,
        AppLanguage.ja,
        AppLanguage.es,
      ];
      for (final preset in kPlotPresets) {
        expect(preset.nameIn(AppLanguage.zhHans), preset.name);
        for (final language in translated) {
          expect(
            preset.names.containsKey(language),
            isTrue,
            reason: '${preset.name} 缺少 ${language.code} 名称',
          );
          expect(
            preset.descriptions.containsKey(language),
            isTrue,
            reason: '${preset.name} 缺少 ${language.code} 说明',
          );
          expect(preset.nameIn(language), isNotEmpty);
          expect(preset.descriptionIn(language), isNotEmpty);
        }
      }
      final polar = kPlotPresets.firstWhere(
        (preset) => preset.name == '心形 · 极坐标',
      );
      expect(polar.nameIn(AppLanguage.en), 'Heart · polar');
      expect(polar.nameIn(AppLanguage.zhHant), '心形 · 極座標');
      expect(polar.nameIn(AppLanguage.ja), 'ハート · 極座標');
    });

    test('示例缺项时回落简体原文', () {
      const preset = PlotPreset(
        name: '测试',
        description: '说明',
        names: <AppLanguage, String>{},
        descriptions: <AppLanguage, String>{},
        curves: <PresetCurve>[],
        viewport: PlotViewport(minX: -1, maxX: 1, minY: -1, maxY: 1),
      );
      expect(preset.nameIn(AppLanguage.zhHant), '测试');
      expect(preset.nameIn(AppLanguage.en), '测试');
      expect(preset.descriptionIn(AppLanguage.es), '说明');
    });

    test('导出对话框的空状态文案可替换', () {
      expect(describeSamples(const <PlotSample>[]), '暂无可见曲线');
      expect(
        describeSamples(
          const <PlotSample>[],
          empty: kPlotStrings[AppLanguage.en]!.noVisibleCurves,
        ),
        'No visible curves',
      );
    });
  });
}
