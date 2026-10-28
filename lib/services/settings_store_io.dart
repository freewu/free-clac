import 'dart:convert';
import 'dart:io';

/// 桌面 / Android 上的设置存储：把键值对写进用户配置目录的 JSON 文件。
///
/// - Windows：`%APPDATA%\free-clac\settings.json`
/// - 其他平台：`$XDG_CONFIG_HOME/free-clac/settings.json`（缺省 `~/.config`）
/// - 都取不到时退到系统临时目录（Android 上即应用私有缓存目录）
///
/// 读写失败一律静默降级：设置读不到就用默认值，写不进去也不影响使用。
class SettingsStore {
  const SettingsStore();

  File get _file {
    final env = Platform.environment;
    final base = Platform.isWindows
        ? env['APPDATA'] ?? env['LOCALAPPDATA']
        : env['XDG_CONFIG_HOME'] ??
              (env['HOME'] == null ? null : '${env['HOME']}/.config');
    final root = base ?? Directory.systemTemp.absolute.path;
    return File(
      '$root${Platform.pathSeparator}free-clac'
      '${Platform.pathSeparator}settings.json',
    );
  }

  /// 读出全部键值对；文件不存在或损坏时返回空表。
  Future<Map<String, String>> readAll() async {
    try {
      final file = _file;
      if (!file.existsSync()) return const <String, String>{};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return const <String, String>{};
      return <String, String>{
        for (final entry in decoded.entries)
          if (entry.key is String && entry.value is String)
            entry.key as String: entry.value as String,
      };
    } on Object {
      return const <String, String>{};
    }
  }

  /// 写入一项设置（读改写，保留其他键）。
  Future<void> write(String key, String value) async {
    try {
      final file = _file;
      final values = <String, String>{...await readAll(), key: value};
      await file.parent.create(recursive: true);
      await file.writeAsString(jsonEncode(values));
    } on Object {
      // 只读文件系统或权限受限时忽略，设置仅本次会话生效。
    }
  }
}
