import 'area/defined.dart';
import 'bmi/defined.dart';
import 'compound/defined.dart';
import 'distance/defined.dart';
import 'interest/defined.dart';
import 'loan/defined.dart';
import 'pension/defined.dart';
import 'retirement/defined.dart';
import 'speed/defined.dart';
import 'tax/defined.dart';
import 'temperature/defined.dart';
import 'volume/defined.dart';
import 'weight/defined.dart';
import 'tool_info.dart';

export 'tool_info.dart';

/// 全部内置工具，顺序即工具页展示顺序。
///
/// 每项元数据都在各自目录的 `defined.dart` 里声明，这里只负责汇总。
///
/// 用 getter 而不是 `final` 变量：卡片配色取自 [AppColors]，而顶层 `final`
/// 只在首次访问时求值，切到浅色主题后颜色就会停在旧配色上。
List<ToolInfo> get kTools => List.unmodifiable(<ToolInfo>[
  bmiTool,
  compoundTool,
  distanceTool,
  areaTool,
  volumeTool,
  weightTool,
  temperatureTool,
  speedTool,
  interestTool,
  loanTool,
  pensionTool,
  retirementTool,
  taxTool,
]);

/// 当前界面语言下应该展示的工具。
///
/// 养老金与个税按中国社保 / 税法口径计算，只在简体、繁体中文界面出现，
/// 换成英 / 日 / 西语时隐藏，避免给出看不懂或不适用的结果。
List<ToolInfo> get visibleTools =>
    List.unmodifiable(kTools.where((tool) => tool.isAvailable));

/// 按 id 查找当前语言下可见的工具，找不到返回 null。
ToolInfo? toolById(String id) {
  for (final tool in visibleTools) {
    if (tool.id == id) return tool;
  }
  return null;
}
