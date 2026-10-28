import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../core/angle_mode.dart';
import '../core/builtins.dart';
import '../core/calc_error.dart';
import '../core/math_engine.dart';
import '../core/number_format.dart';
import '../l10n/calc_errors.dart';
import '../models/history_entry.dart';

/// 计算器状态：输入、预览、历史、内存、角度模式。
class CalculatorController extends ChangeNotifier {
  CalculatorController({MathEngine? engine})
    : engine = engine ?? MathEngine(),
      input = TextEditingController() {
    this.engine.addListener(_onEngineChanged);
    input.addListener(_onInputChanged);
    _refreshPreview();
  }

  final MathEngine engine;
  final TextEditingController input;

  final List<HistoryEntry> _history = <HistoryEntry>[];
  List<HistoryEntry> get history => List.unmodifiable(_history);

  bool _secondActive = false;
  bool get secondActive => _secondActive;

  CalcException? _previewException;
  String? _previewRawError;

  /// 预览错误按当前语言现算，切换语言后已显示的报错也会跟着换。
  String? get previewError {
    final exception = _previewException;
    if (exception != null) return calcErrorMessage(exception);
    return _previewRawError;
  }

  double? _previewValue;
  double? get previewValue => _previewValue;

  double? _answer;
  double? get answer => _answer;

  double _memory = 0;
  bool _memoryActive = false;
  double get memory => _memory;
  bool get memoryActive => _memoryActive;

  AngleMode get angleMode => engine.angleMode;

  int _historyCursor = -1;

  // ---------------------------------------------------------------- 输入管理

  String get expression => input.text;

  void _onInputChanged() {
    _refreshPreview();
    notifyListeners();
  }

  void _onEngineChanged() {
    _refreshPreview();
    notifyListeners();
  }

  void _refreshPreview() {
    final text = input.text.trim();
    if (text.isEmpty) {
      _previewValue = null;
      _previewException = null;
      _previewRawError = null;
      return;
    }
    final result = engine.evaluate(text, variables: _variables());
    _previewValue = result.value;
    _previewException = result.exception;
    _previewRawError = result.error;
  }

  Map<String, double> _variables() {
    final variables = <String, double>{'ans': _answer ?? 0};
    if (_memoryActive) variables['mem'] = _memory;
    return variables;
  }

  /// 在光标处插入文本；[cursorOffset] 可指定插入后光标相对末尾的偏移。
  void insert(String text, {int cursorOffset = 0}) {
    final value = input.value;
    final selection = _normalizedSelection(value);
    final before = value.text.substring(0, selection.start);
    final after = value.text.substring(selection.end);
    final caret = before.length + text.length + cursorOffset;
    final next = '$before$text$after';
    input.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(
        offset: caret < 0 ? 0 : (caret > next.length ? next.length : caret),
      ),
    );
    HapticFeedback.selectionClick();
  }

  /// 智能退格：整体删除函数名与括号等“符号单元”。
  void backspace() {
    final value = input.value;
    if (value.selection.isValid && !value.selection.isCollapsed) {
      final selection = _normalizedSelection(value);
      final next = value.text.replaceRange(selection.start, selection.end, '');
      input.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: selection.start),
      );
      return;
    }
    final caret = value.selection.isValid
        ? value.selection.baseOffset
        : value.text.length;
    if (caret <= 0) return;
    final prefix = value.text.substring(0, caret);
    final token = _deleteUnitFor(prefix);
    final cut = token?.length ?? 1;
    final next = value.text.replaceRange(caret - cut, caret, '');
    input.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: caret - cut),
    );
    HapticFeedback.selectionClick();
  }

  static String? _deleteUnitFor(String prefix) {
    final lower = prefix.toLowerCase();
    final candidates = <String>[
      ...builtinFunctions.keys.map((name) => '$name('),
      'sum(',
      'prod(',
      'integrate(',
      'diff(',
      'sqrt(',
      'pi',
      'tau',
      'phi',
    ]..sort((a, b) => b.length.compareTo(a.length));
    for (final candidate in candidates) {
      if (lower.endsWith(candidate)) {
        return prefix.substring(prefix.length - candidate.length);
      }
    }
    return null;
  }

  void clear() {
    input.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(offset: 0),
    );
    _historyCursor = -1;
  }

  void setExpression(String text) {
    input.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void appendResult() {
    if (_previewValue != null && !_previewValue!.isNaN) {
      insert(formatInput(_previewValue!));
    }
  }

  void toggleSecond() {
    _secondActive = !_secondActive;
    notifyListeners();
  }

  void toggleAngleMode() {
    engine.angleMode = engine.angleMode.toggled;
  }

  // ---------------------------------------------------------------- 求值

  /// 计算并写入历史记录。返回计算是否成功。
  bool evaluate() {
    final text = input.text.trim();
    if (text.isEmpty) return false;
    final result = engine.evaluate(text, variables: _variables());
    if (result.isError) {
      _history.insert(
        0,
        HistoryEntry(
          expression: text,
          display: result.error!,
          exception: result.exception,
          isError: true,
        ),
      );
      _historyCursor = -1;
      notifyListeners();
      HapticFeedback.heavyImpact();
      return false;
    }
    final value = result.value!;
    final display = formatNumber(value);
    _answer = value.isFinite ? value : _answer;
    _history.insert(
      0,
      HistoryEntry(expression: text, display: display, value: value),
    );
    if (_history.length > 100) _history.removeLast();
    _historyCursor = -1;
    _previewValue = value;
    _previewException = null;
    _previewRawError = null;
    notifyListeners();
    HapticFeedback.mediumImpact();
    return true;
  }

  /// 用历史记录中的结果替换当前输入。
  void useHistory(HistoryEntry entry) {
    setExpression(entry.isError ? entry.expression : entry.display);
  }

  void clearHistory() {
    _history.clear();
    _historyCursor = -1;
    notifyListeners();
  }

  /// 方向键上下翻阅历史。
  void recallHistory({required bool older}) {
    if (_history.isEmpty) return;
    if (_historyCursor == -1) {
      _historyCursor = older ? 0 : -1;
    } else {
      final next = _historyCursor + (older ? 1 : -1);
      _historyCursor = next < -1
          ? -1
          : (next >= _history.length ? _history.length - 1 : next);
    }
    if (_historyCursor == -1) {
      clear();
      return;
    }
    setExpression(_history[_historyCursor].expression);
  }

  // ---------------------------------------------------------------- 内存

  void memoryAdd() {
    final value = _previewValue ?? _answer;
    if (value == null) return;
    _memory += value;
    _memoryActive = true;
    notifyListeners();
  }

  void memorySubtract() {
    final value = _previewValue ?? _answer;
    if (value == null) return;
    _memory -= value;
    _memoryActive = true;
    notifyListeners();
  }

  void memoryRecall() {
    if (!_memoryActive) return;
    insert(formatInput(_memory));
  }

  void memoryClear() {
    _memory = 0;
    _memoryActive = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------- 工具

  TextSelection _normalizedSelection(TextEditingValue value) {
    final selection = value.selection;
    if (!selection.isValid || selection.start < 0) {
      return TextSelection.collapsed(offset: value.text.length);
    }
    final start = selection.start.clamp(0, value.text.length);
    final end = selection.end.clamp(0, value.text.length);
    return TextSelection(baseOffset: start, extentOffset: end);
  }

  @override
  void dispose() {
    engine.removeListener(_onEngineChanged);
    input.removeListener(_onInputChanged);
    input.dispose();
    super.dispose();
  }
}
