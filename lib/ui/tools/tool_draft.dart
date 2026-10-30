import 'package:flutter/widgets.dart';

import '../../state/settings_controller.dart';

/// 工具页的输入草稿：记住上次填的值，重新进入该工具时原样填回。
///
/// 用法：页面里建一个 `ToolDraft('<工具 id>')`，输入框用 [controller] 建，
/// 选项（单位、模式等）改了调 [set] / [setEnum]，初值用 [text] / [integer] /
/// [enumOf] 读，读不到再回落到页面默认值（通常来自设置页）。
///
/// 存的是字符串：数字就是输入框里的原文，枚举存 [Enum.name]。
class ToolDraft {
  ToolDraft(this.toolId)
    : _values = <String, String>{...?currentSettings?.toolDraftOf(toolId)};

  /// 工具 id（如 `bmi`、`loan`），决定草稿存在哪一格。
  final String toolId;

  final Map<String, String> _values;

  /// 上次填的原文；没存过时为 null（页面用默认值）。
  String? text(String field) => _values[field];

  /// 上次填的整数；没存过或不是整数时返回 null。
  int? integer(String field) => int.tryParse(_values[field] ?? '');

  /// 上次填的小数；没存过或不是数字时返回 null。
  double? number(String field) => double.tryParse(_values[field] ?? '');

  /// 上次开关的状态；没存过时用 [fallback]。
  bool flag(String field, {bool fallback = false}) {
    final stored = _values[field];
    return stored == null ? fallback : stored == 'true';
  }

  /// 按 [Enum.name] 找回上次选的枚举项；没存过或名字对不上时返回 null。
  T? enumOf<T extends Enum>(String field, List<T> values) {
    final stored = _values[field];
    if (stored == null) return null;
    for (final value in values) {
      if (value.name == stored) return value;
    }
    return null;
  }

  /// 记下一个字段；传 null 或空串表示清掉（下次用默认值）。
  void set(String field, Object? value) {
    final next = value == null ? null : '$value';
    if (_values[field] == next) return;
    if (next == null || next.isEmpty) {
      _values.remove(field);
      currentSettings?.setToolDraftValue(toolId, field, null);
      return;
    }
    _values[field] = next;
    currentSettings?.setToolDraftValue(toolId, field, next);
  }

  /// 记下选中的枚举项（存 [Enum.name]）。
  void setEnum(String field, Enum? value) => set(field, value?.name);

  /// 记下开关状态。
  void setFlag(String field, bool value) =>
      set(field, value ? 'true' : 'false');

  /// 建一个跟草稿双向绑定的输入框控制器：初值取草稿，改动自动记下来。
  TextEditingController controller(String field, String fallback) {
    final controller = TextEditingController(text: _values[field] ?? fallback);
    controller.addListener(() => set(field, controller.text));
    return controller;
  }
}
