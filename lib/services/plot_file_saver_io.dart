import 'dart:io';
import 'dart:typed_data';

import '../plot/plot_export.dart';
import 'saved_plot_file.dart';

export 'saved_plot_file.dart';

/// 桌面 / 移动端：直接写入磁盘。
///
/// 默认目录优先取「图片」再取「下载」，都没有时退回用户主目录；
/// 移动端受沙盒限制，写入应用临时目录（系统不允许直接写共享存储）。
Future<SavedPlotFile> savePlotExportFile(
  PlotExportFile file, {
  String? directory,
}) async {
  final dir = Directory(directory ?? defaultPlotDirectory());
  await dir.create(recursive: true);
  final target = _uniqueFile(dir, file.fileName);
  await target.writeAsBytes(file.bytes, flush: true);
  return SavedPlotFile(location: target.path, fileName: fileNameFor(target));
}

/// 默认保存目录。
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
  if (file.inBrowser || file.location.isEmpty) return;
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
