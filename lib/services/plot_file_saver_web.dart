import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../l10n/plot_strings.dart';
import '../plot/plot_export.dart';
import 'saved_plot_file.dart';

export 'saved_plot_file.dart';

/// 界面「保存位置」一行的文案：浏览器下载目录由浏览器设置决定。
String plotSaveLocationNote() => plotStrings.saveLocationWeb;

/// Web：交给浏览器下载（Blob + a[download]），落盘位置由浏览器设置决定。
Future<SavedPlotFile> savePlotExportFile(
  PlotExportFile file, {
  String? directory,
}) async {
  final blob = web.Blob(
    <web.BlobPart>[file.bytes.toJS].toJS,
    web.BlobPropertyBag(type: file.mimeType),
  );
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = file.fileName;
  web.document.body?.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
  return SavedPlotFile(location: '', fileName: file.fileName, inBrowser: true);
}

/// 浏览器无法定位本地文件，留空实现。
Future<void> revealSavedPlotFile(SavedPlotFile file) async {}
