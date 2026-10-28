/// 本地设置存储：Web 用 localStorage，桌面 / Android 用配置文件。
library;

export 'settings_store_io.dart'
    if (dart.library.js_interop) 'settings_store_web.dart';
