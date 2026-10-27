import 'bmi/defined.dart';
import 'compound/defined.dart';
import 'interest/defined.dart';
import 'loan/defined.dart';
import 'tool_info.dart';

export 'tool_info.dart';

/// 全部内置工具，顺序即工具页展示顺序。
///
/// 每项元数据都在各自目录的 `defined.dart` 里声明，这里只负责汇总。
final List<ToolInfo> kTools = List.unmodifiable(<ToolInfo>[
  bmiTool,
  compoundTool,
  interestTool,
  loanTool,
]);

/// 按 id 查找工具，找不到返回 null。
ToolInfo? toolById(String id) {
  for (final tool in kTools) {
    if (tool.id == id) return tool;
  }
  return null;
}
