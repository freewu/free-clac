import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../state/plot_controller.dart';
import 'plot_painter.dart';
import 'plot_svg.dart';
import 'plot_viewport.dart';

/// 导出图片的格式。
enum PlotImageFormat {
  png('PNG', 'png', 'image/png'),
  webp('WebP', 'webp', 'image/webp'),
  svg('SVG', 'svg', 'image/svg+xml');

  const PlotImageFormat(this.label, this.extension, this.mimeType);

  final String label;
  final String extension;
  final String mimeType;

  bool get isVector => this == PlotImageFormat.svg;
}

/// 一份待保存的导出文件。
class PlotExportFile {
  const PlotExportFile({
    required this.fileName,
    required this.bytes,
    required this.mimeType,
  });

  final String fileName;
  final Uint8List bytes;
  final String mimeType;

  int get byteLength => bytes.lengthInBytes;

  /// 便于界面展示的可读体积，例如 `128 KB`。
  String get readableSize {
    final kb = byteLength / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }
}

/// 导出内容：按当前视口重新采样后再渲染，与画面保持一致。
class PlotExporter {
  const PlotExporter({this.pixelRatio = 2, this.webpQuality = 90});

  /// 位图的倍率（1 = 与画布等尺寸，2 = 高清两倍图）。
  final double pixelRatio;

  /// WebP 有损压缩质量（0~100）。
  final int webpQuality;

  /// 按 [format] 渲染 [controller] 当前画面。
  ///
  /// [size] 为逻辑尺寸（与画布一致），[name] 为不含扩展名的文件名。
  Future<PlotExportFile> export({
    required PlotController controller,
    required Size size,
    required PlotImageFormat format,
    String name = 'plot',
    String title = 'free-clac 函数绘图',
    DateTime? now,
  }) async {
    final safeSize = Size(
      size.width < 1 ? 900 : size.width,
      size.height < 1 ? 600 : size.height,
    );
    final fileName = plotExportFileName(format, name: name, now: now);
    final samples = controller.buildSamples(safeSize);

    if (format.isVector) {
      final svg = buildPlotSvg(
        viewport: controller.viewport,
        samples: samples,
        size: safeSize,
        showGrid: controller.showGrid,
        title: title,
      );
      return PlotExportFile(
        fileName: fileName,
        bytes: Uint8List.fromList(utf8Encode(svg)),
        mimeType: format.mimeType,
      );
    }

    final painter = PlotPainter(
      viewport: controller.viewport,
      samples: samples,
      showGrid: controller.showGrid,
    );
    final image = await renderPlotImage(
      painter: painter,
      size: safeSize,
      pixelRatio: pixelRatio,
    );
    try {
      final bytes = switch (format) {
        PlotImageFormat.png => await encodePng(image),
        PlotImageFormat.webp => await encodeWebP(image, quality: webpQuality),
        PlotImageFormat.svg => throw StateError('SVG 不走位图分支'),
      };
      return PlotExportFile(
        fileName: fileName,
        bytes: bytes,
        mimeType: format.mimeType,
      );
    } finally {
      image.dispose();
    }
  }
}

/// 用 [PlotPainter] 把画面渲染成 [ui.Image]。
Future<ui.Image> renderPlotImage({
  required PlotPainter painter,
  required Size size,
  double pixelRatio = 2,
}) async {
  final ratio = pixelRatio < 0.1 ? 1.0 : pixelRatio;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  if (ratio != 1) canvas.scale(ratio);
  painter.paint(canvas, size);
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(
      (size.width * ratio).round(),
      (size.height * ratio).round(),
    );
  } finally {
    picture.dispose();
  }
}

/// PNG 编码（Flutter 引擎内置编码器）。
Future<Uint8List> encodePng(ui.Image image) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  if (data == null) throw StateError('PNG 编码失败');
  return data.buffer.asUint8List();
}

/// WebP 编码：Flutter 引擎不提供该格式，这里用纯 Dart 编码器转换 RGBA 数据。
Future<Uint8List> encodeWebP(ui.Image image, {int quality = 90}) async {
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (data == null) throw StateError('WebP 编码失败：无法读取像素');
  final rgba = img.Image.fromBytes(
    width: image.width,
    height: image.height,
    bytes: data.buffer,
    numChannels: 4,
    order: img.ChannelOrder.rgba,
  );
  final bytes = img.encodeWebP(
    rgba,
    lossless: false,
    quality: quality.clamp(0, 100),
  );
  if (bytes.isEmpty) throw StateError('WebP 编码失败');
  return bytes;
}

/// 生成导出文件名：`plot-20250101-1200.png`。
String plotExportFileName(
  PlotImageFormat format, {
  String name = 'plot',
  DateTime? now,
}) {
  final time = now ?? DateTime.now();
  String two(int value) => value.toString().padLeft(2, '0');
  final stamp =
      '${time.year}${two(time.month)}${two(time.day)}'
      '-${two(time.hour)}${two(time.minute)}${two(time.second)}';
  final base = name.trim().isEmpty ? 'plot' : name.trim();
  return '$base-$stamp.${format.extension}';
}

/// UTF-8 编码（避免为一次转换引入更多依赖）。
Uint8List utf8Encode(String text) {
  final buffer = BytesBuilder(copy: false);
  for (final rune in text.runes) {
    if (rune < 0x80) {
      buffer.addByte(rune);
    } else if (rune < 0x800) {
      buffer
        ..addByte(0xC0 | (rune >> 6))
        ..addByte(0x80 | (rune & 0x3F));
    } else if (rune < 0x10000) {
      buffer
        ..addByte(0xE0 | (rune >> 12))
        ..addByte(0x80 | ((rune >> 6) & 0x3F))
        ..addByte(0x80 | (rune & 0x3F));
    } else {
      buffer
        ..addByte(0xF0 | (rune >> 18))
        ..addByte(0x80 | ((rune >> 12) & 0x3F))
        ..addByte(0x80 | ((rune >> 6) & 0x3F))
        ..addByte(0x80 | (rune & 0x3F));
    }
  }
  return buffer.takeBytes();
}

/// 把曲线列表转成便于展示的说明（供 SVG 标题 / 对话框使用）。
String describeSamples(List<PlotSample> samples, {String empty = '暂无可见曲线'}) {
  final visible = samples
      .where((sample) => sample.function.visible && !sample.curve.isEmpty)
      .toList();
  if (visible.isEmpty) return empty;
  return visible
      .map((sample) => sample.function.expression)
      .where((expression) => expression.isNotEmpty)
      .join('   ');
}

/// 视口信息文本：`x ∈ [−10, 10]　y ∈ [−6, 6]`。
String describeViewport(PlotViewport viewport) {
  String format(double value) {
    final rounded = value.abs() < 1e-9 ? 0.0 : value;
    if (rounded == rounded.roundToDouble() && rounded.abs() < 1e6) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(2);
  }

  return 'x ∈ [${format(viewport.minX)}, ${format(viewport.maxX)}]'
      '　y ∈ [${format(viewport.minY)}, ${format(viewport.maxY)}]';
}
