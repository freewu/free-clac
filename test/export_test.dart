import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/core/math_engine.dart';
import 'package:free_clac/plot/plot_export.dart';
import 'package:free_clac/plot/plot_presets.dart';
import 'package:free_clac/l10n/app_language.dart';
import 'package:free_clac/l10n/plot_strings.dart';
import 'package:free_clac/plot/plot_svg.dart';
import 'package:free_clac/plot/plot_viewport.dart';
import 'package:free_clac/services/plot_file_saver_io.dart';
import 'package:free_clac/state/plot_controller.dart';
import 'package:image/image.dart' as img;

PlotController _controller({String? expression}) {
  final controller = PlotController(engine: MathEngine());
  controller.clearFunctions();
  if (expression != null) {
    final created = controller.addFunction();
    controller.updateExpression(created.id, expression: expression);
  }
  return controller;
}

void main() {
  const size = Size(800, 500);

  group('导出图片', () {
    test('PNG：带正确文件头且尺寸为 2 倍图', () async {
      final controller = _controller(expression: 'sin(x)');
      final file = await const PlotExporter().export(
        controller: controller,
        size: size,
        format: PlotImageFormat.png,
      );

      expect(file.fileName, endsWith('.png'));
      expect(file.mimeType, 'image/png');
      expect(file.bytes.sublist(0, 8), <int>[
        0x89,
        0x50,
        0x4E,
        0x47,
        0x0D,
        0x0A,
        0x1A,
        0x0A,
      ]);
      final decoded = img.decodePng(file.bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, (size.width * 2).round());
      expect(decoded.height, (size.height * 2).round());
      expect(file.readableSize, isNotEmpty);
    });

    test('WebP：RIFF/WEBP 文件头，可被解码', () async {
      final controller = _controller(expression: 'sin(x)');
      final file = await const PlotExporter(pixelRatio: 1).export(
        controller: controller,
        size: size,
        format: PlotImageFormat.webp,
      );

      expect(file.fileName, endsWith('.webp'));
      expect(String.fromCharCodes(file.bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(file.bytes.sublist(8, 12)), 'WEBP');

      final decoded = img.decodeWebP(file.bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, size.width.round());
      expect(decoded.height, size.height.round());
    });

    test('SVG：矢量输出包含视口、曲线路径与刻度', () async {
      final controller = _controller(expression: 'sin(x)');
      final file = await const PlotExporter().export(
        controller: controller,
        size: size,
        format: PlotImageFormat.svg,
      );

      final svg = String.fromCharCodes(file.bytes);
      expect(file.fileName, endsWith('.svg'));
      expect(file.mimeType, 'image/svg+xml');
      expect(svg, startsWith('<?xml'));
      expect(svg, contains('<svg'));
      expect(svg, contains('viewBox="0 0 800 500"'));
      // 背景渐变、网格与曲线描边都应该在文件里
      expect(svg, contains('url(#bg)'));
      expect(svg, contains('<path d="M '));
      expect(svg, contains('stroke-width="1.8"'));
      expect(svg, endsWith('</svg>\n'));
      expect(svg, isNot(contains('NaN')));
      // 中文默认标题，可由调用方换成当前语言（注意 bytes 是 UTF-8）
      expect(
        utf8.decode(file.bytes),
        contains('<title>free-clac 函数绘图</title>'),
      );
    });

    test('SVG 标题跟随界面语言', () async {
      final controller = _controller(expression: 'sin(x)');
      final file = await const PlotExporter().export(
        controller: controller,
        size: size,
        format: PlotImageFormat.svg,
        title: kPlotStrings[AppLanguage.en]!.svgTitle,
      );
      expect(
        utf8.decode(file.bytes),
        contains('<title>free-clac function plot</title>'),
      );
    });

    test('示例曲线也能导出 SVG，且不随画布尺寸产生 NaN', () async {
      final controller = PlotController(engine: MathEngine())
        ..applyPreset(kPlotPresets.first);
      final file = await const PlotExporter().export(
        controller: controller,
        size: const Size(640, 480),
        format: PlotImageFormat.svg,
      );
      final svg = String.fromCharCodes(file.bytes);
      expect(svg, contains('<path'));
      expect(svg, isNot(contains('NaN')));
      expect(svg, isNot(contains('Infinity')));
    });

    test('文件名带时间戳，格式与内容一致', () {
      final now = DateTime(2025, 3, 4, 5, 6, 7);
      expect(
        plotExportFileName(PlotImageFormat.png, now: now),
        'plot-20250304-050607.png',
      );
      expect(
        plotExportFileName(PlotImageFormat.webp, name: '心形', now: now),
        '心形-20250304-050607.webp',
      );
      // 空名字回退为 plot
      expect(
        plotExportFileName(PlotImageFormat.svg, name: '  ', now: now),
        'plot-20250304-050607.svg',
      );
    });

    test('SVG 网格与刻度的步长跟随视口缩放', () {
      const viewport = PlotViewport(minX: -2, maxX: 2, minY: -1, maxY: 1);
      final svg = buildPlotSvg(
        viewport: viewport,
        samples: const [],
        size: size,
      );
      expect(svg, contains('text-anchor="middle"'));
      expect(svg, contains('dominant-baseline="middle"'));
      // 4 单位宽、800px：步长应为 0.5
      expect(svg, contains('>0.5<'));
    });
  });

  group('保存到磁盘', () {
    test('写入指定目录，重名自动加序号', () async {
      final dir = await Directory.systemTemp.createTemp('free_clac_export');
      addTearDown(() => dir.delete(recursive: true));

      final bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
      final file = PlotExportFile(
        fileName: 'plot.png',
        bytes: bytes,
        mimeType: 'image/png',
      );

      final first = await savePlotExportFile(file, directory: dir.path);
      final second = await savePlotExportFile(file, directory: dir.path);

      expect(first.fileName, 'plot.png');
      expect(second.fileName, 'plot (1).png');
      expect(await readSavedFile(first.location), bytes);
      expect(await readSavedFile(second.location), bytes);
      expect(first.inBrowser, isFalse);
      expect(first.fullPath, first.location);
    });

    test('默认目录存在且可写', () async {
      final directory = Directory(defaultPlotDirectory());
      expect(directory.path, isNotEmpty);
      if (!Platform.isAndroid && !Platform.isIOS) {
        expect(directory.existsSync(), isTrue, reason: directory.path);
      }
    });

    test('展示位置与实际落盘位置一致', () async {
      final dir = await Directory.systemTemp.createTemp('free_clac_export');
      addTearDown(() => dir.delete(recursive: true));
      final saved = await savePlotExportFile(
        PlotExportFile(
          fileName: 'plot.png',
          bytes: Uint8List.fromList(<int>[1, 2, 3]),
          mimeType: 'image/png',
        ),
        directory: dir.path,
      );

      // 直接写盘：展示的就是真实路径，桌面端可以打开所在文件夹
      expect(saved.displayPath, isNull);
      expect(saved.fullPath, saved.location);
      expect(saved.displayLocation, saved.location);
      expect(saved.canReveal, !Platform.isAndroid && !Platform.isIOS);
      // 对话框里的「保存位置」要指向真实目录，不能是笼统的「图片 / 下载」
      final note = plotSaveLocationNote();
      expect(note, isNotEmpty);
      if (!Platform.isAndroid && !Platform.isIOS) {
        expect(note, defaultPlotDirectory());
      }
    });

    test('相册保存：展示相对路径，且不能打开文件夹', () {
      const saved = SavedPlotFile(
        location: 'content://media/external/images/media/42',
        displayPath: 'Pictures/free-clac/plot.png',
        fileName: 'plot.png',
      );

      expect(saved.fullPath, 'Pictures/free-clac/plot.png');
      expect(saved.displayLocation, 'Pictures/free-clac/plot.png');
      expect(saved.canReveal, isFalse);
    });
  });
}
