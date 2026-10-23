/// 计算历史记录。
class HistoryEntry {
  HistoryEntry({
    required this.expression,
    required this.display,
    this.value,
    this.isError = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String expression;
  final String display;
  final double? value;
  final bool isError;
  final DateTime createdAt;
}
