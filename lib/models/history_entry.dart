import '../core/calc_error.dart';

/// 计算历史记录。
class HistoryEntry {
  HistoryEntry({
    required this.expression,
    required this.display,
    this.exception,
    this.value,
    this.isError = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String expression;

  /// 落库时的展示文案（错误项由 [exception] 重新本地化）。
  final String display;

  /// 出错时的结构化错误，界面用 `calcErrorMessage()` 按当前语言显示。
  final CalcException? exception;
  final double? value;
  final bool isError;
  final DateTime createdAt;
}
