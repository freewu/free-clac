import 'package:web/web.dart' as web;

/// Web 端的设置存储：直接写进 `localStorage`。
class SettingsStore {
  const SettingsStore();

  static const String _prefix = 'free-clac.';

  /// 读出全部键值对；localStorage 被禁用时返回空表。
  Future<Map<String, String>> readAll() async {
    try {
      final storage = web.window.localStorage;
      final values = <String, String>{};
      for (var i = 0; i < storage.length; i++) {
        final key = storage.key(i);
        if (key == null || !key.startsWith(_prefix)) continue;
        final value = storage.getItem(key);
        if (value != null) values[key.substring(_prefix.length)] = value;
      }
      return values;
    } on Object {
      return const <String, String>{};
    }
  }

  /// 写入一项设置。
  Future<void> write(String key, String value) async {
    try {
      web.window.localStorage.setItem('$_prefix$key', value);
    } on Object {
      // 隐私模式或容量不足时忽略，设置仅本次会话生效。
    }
  }
}
