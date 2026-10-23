/// 保存导出图片：Web 走下载，其它平台写磁盘。
///
/// 通过条件导入隔离 `dart:io` 与 `package:web`，Web 构建不会引入文件系统代码。
library;

export 'plot_file_saver_io.dart'
    if (dart.library.js_interop) 'plot_file_saver_web.dart';
