import 'dart:io';

import 'package:flutter/services.dart';

import '../plot/plot_export.dart';
import 'saved_plot_file.dart';

export 'saved_plot_file.dart';

/// 相册 / 下载目录的平台通道（实现在 `android/.../MainActivity.kt`）。
const MethodChannel _mediaStoreChannel = MethodChannel('free_clac/media_store');

/// 界面「保存位置」一行的文案。
///
/// 必须和实际落盘位置一致：Android 走 MediaStore（相册 / 下载），
/// 桌面端写 [defaultPlotDirectory] 解析出来的真实目录。
String plotSaveLocationNote() {
  if (Platform.isAndroid) {
    return '系统相册「Pictures/free-clac」（SVG 存到「Download/free-clac」）';
  }
  if (Platform.isIOS) return '应用沙盒临时目录';
  return defaultPlotDirectory();
}

/// 桌面 / 移动端：写入系统目录。
///
/// * Android 交给 MediaStore，位图进相册、SVG 进下载目录，用户在系统里能找到；
///   平台通道不可用时退回应用缓存目录（老版本行为）。
/// * 其它平台优先取「图片」再取「下载」，都没有时退回用户主目录。
Future<SavedPlotFile> savePlotExportFile(
  PlotExportFile file, {
  String? directory,
}) async {
  if (directory == null && Platform.isAndroid) {
    final gallery = await _saveToSystemGallery(file);
    if (gallery != null) return gallery;
  }
  final dir = Directory(directory ?? defaultPlotDirectory());
  await dir.create(recursive: true);
  final target = _uniqueFile(dir, file.fileName);
  await target.writeAsBytes(file.bytes, flush: true);
  return SavedPlotFile(
    location: target.path,
    fileName: fileNameFor(target),
    canReveal: !Platform.isAndroid && !Platform.isIOS,
  );
}

/// 通过平台通道把文件写进相册 / 下载目录；失败返回 null 交给调用方兜底。
Future<SavedPlotFile?> _saveToSystemGallery(PlotExportFile file) async {
  final Map<String, String>? result;
  try {
    result = await _mediaStoreChannel.invokeMapMethod<String, String>(
      'saveImage',
      <String, Object>{
        'bytes': file.bytes,
        'fileName': file.fileName,
        'mimeType': file.mimeType,
      },
    );
  } on MissingPluginException {
    return null;
  } on PlatformException {
    // 没有写相册的权限或被系统拒绝：退回应用目录，至少文件还在。
    return null;
  }
  final location = result?['location'];
  if (location == null || location.isEmpty) return null;
  return SavedPlotFile(
    location: location,
    fileName: file.fileName,
    displayPath: result!['displayPath'],
  );
}

/// 默认保存目录（Android / iOS 仅在平台通道不可用时作兜底）。
String defaultPlotDirectory() {
  if (Platform.isAndroid || Platform.isIOS) {
    return Directory.systemTemp.path;
  }
  final env = Platform.environment;
  final home = env['USERPROFILE'] ?? env['HOME'] ?? '';
  if (home.isEmpty) return Directory.systemTemp.path;
  final candidates = <String>[
    joinPath(home, 'Pictures'),
    joinPath(home, 'Downloads'),
    joinPath(home, '下载'),
    home,
  ];
  for (final candidate in candidates) {
    if (Directory(candidate).existsSync()) return candidate;
  }
  return Directory.systemTemp.path;
}

/// 在文件管理器中定位刚保存的文件。
Future<void> revealSavedPlotFile(SavedPlotFile file) async {
  if (!file.canReveal || file.location.isEmpty) return;
  try {
    if (Platform.isWindows) {
      await Process.run('explorer.exe', ['/select,${file.location}']);
    } else if (Platform.isMacOS) {
      await Process.run('open', ['-R', file.location]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [File(file.location).parent.path]);
    }
  } catch (_) {
    // 打不开文件管理器不影响保存结果，忽略即可。
  }
}

/// 拼接路径（不引入 path 依赖）。
String joinPath(String dir, String name) {
  final separator = Platform.pathSeparator;
  final trimmed = dir.endsWith(separator)
      ? dir.substring(0, dir.length - separator.length)
      : dir;
  return '$trimmed$separator$name';
}

/// 重名时追加序号：`plot-1.png` → `plot-1 (1).png`。
File _uniqueFile(Directory dir, String fileName) {
  final dot = fileName.lastIndexOf('.');
  final base = dot <= 0 ? fileName : fileName.substring(0, dot);
  final extension = dot <= 0 ? '' : fileName.substring(dot);
  var candidate = File(joinPath(dir.path, fileName));
  var index = 1;
  while (candidate.existsSync()) {
    candidate = File(joinPath(dir.path, '$base ($index)$extension'));
    index++;
  }
  return candidate;
}

/// 从 [File] 取文件名。
String fileNameFor(File file) => file.uri.pathSegments.last;

/// 便于测试：直接写入指定目录并返回文件字节内容。
Future<Uint8List> readSavedFile(String path) => File(path).readAsBytes();
