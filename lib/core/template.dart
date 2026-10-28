/// 用位置占位符填充模板：`fill('{0} 年 {1} 个月', [y, m])`。
///
/// 多语言的语序不同（如日语把数量放在名词前），所以界面文案一律用模板
/// 而不是在代码里拼字符串。放在 core 里是为了让计算错误（`CalcError`）
/// 也能复用，不必让 `lib/core/` 依赖 `lib/l10n/`。
String fill(String template, [List<Object?> args = const <Object?>[]]) {
  if (args.isEmpty) return template;
  var text = template;
  for (var i = 0; i < args.length; i++) {
    text = text.replaceAll('{$i}', '${args[i]}');
  }
  return text;
}
