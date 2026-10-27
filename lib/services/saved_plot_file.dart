/// 一次图片保存的结果：保存位置、文件名、是否走浏览器下载。
class SavedPlotFile {
  const SavedPlotFile({
    required this.location,
    required this.fileName,
    this.inBrowser = false,
    this.displayPath,
    this.canReveal = false,
  });

  /// 落盘位置：桌面端是绝对路径，保存到相册时是 MediaStore 的 content:// URI；
  /// 浏览器下载时为空。
  final String location;

  final String fileName;

  /// 浏览器环境下由下载管理器接管，落盘位置由浏览器设置决定。
  final bool inBrowser;

  /// 更友好的位置描述（如相册里的相对路径 `Pictures/free-clac/plot.png`）。
  /// 为空时退回 [location]。
  final String? displayPath;

  /// 能否在文件管理器中定位到该文件（相册、浏览器下载都不支持）。
  final bool canReveal;

  /// 展示用的位置描述。
  String get displayLocation => inBrowser ? '浏览器默认下载目录' : fullPath;

  /// 完整文件路径（浏览器环境只有文件名）。
  String get fullPath => inBrowser ? fileName : (displayPath ?? location);
}
