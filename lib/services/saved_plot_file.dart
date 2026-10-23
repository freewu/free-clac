/// 一次图片保存的结果：保存位置、文件名、是否走浏览器下载。
class SavedPlotFile {
  const SavedPlotFile({
    required this.location,
    required this.fileName,
    this.inBrowser = false,
  });

  /// 磁盘上的绝对路径；浏览器下载时为空。
  final String location;
  final String fileName;

  /// 浏览器环境下由下载管理器接管，落盘位置由浏览器设置决定。
  final bool inBrowser;

  /// 展示用的位置描述。
  String get displayLocation => inBrowser ? '浏览器默认下载目录' : location;

  /// 完整文件路径（浏览器环境只有文件名）。
  String get fullPath => inBrowser ? fileName : location;
}
