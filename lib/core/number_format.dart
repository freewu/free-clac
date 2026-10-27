/// 数字格式化工具：把 double 转成适合显示的字符串。
library;

const double _defaultLarge = 1e13;
const double _defaultSmall = 1e-9;

/// 通用数字显示：
/// * 自动在定点 / 科学计数法之间切换
/// * 去除浮点误差带来的多余尾数（0.1 + 0.2 → 0.3）
String formatNumber(double value, {int significantDigits = 12}) {
  if (value.isNaN) return 'NaN';
  if (value.isInfinite) return value > 0 ? '∞' : '-∞';
  if (value == 0) return '0';

  final magnitude = value.abs();
  final String text;
  if (magnitude >= _defaultLarge || magnitude < _defaultSmall) {
    text = _trimExponential(value.toStringAsExponential(significantDigits - 3));
  } else {
    text = _trimFixed(value.toStringAsPrecision(significantDigits));
  }
  return text == '-0' ? '0' : text;
}

/// 坐标轴刻度用的紧凑格式。
String formatTick(double value, {int significantDigits = 5}) {
  if (value.isNaN || value.isInfinite) return '';
  if (value == 0) return '0';
  final magnitude = value.abs();
  if (magnitude >= 1e6 || magnitude < 1e-4) {
    return _trimExponential(value.toStringAsExponential(significantDigits - 1));
  }
  return _trimFixed(value.toStringAsPrecision(significantDigits));
}

/// 输入框中的实时显示：保留更多精度，去掉无意义的 0。
String formatInput(double value) => formatNumber(value, significantDigits: 15);

/// 金额格式：千分位分组 + 固定小数位（默认两位），用于工具页展示。
///
/// ```dart
/// formatMoney(1234567.891); // 1,234,567.89
/// formatMoney(-88, decimals: 0); // -88
/// ```
String formatMoney(double value, {int decimals = 2}) {
  if (value.isNaN || value.isInfinite) return formatNumber(value);
  final negative = value < 0;
  final text = value.abs().toStringAsFixed(decimals);
  final dot = text.indexOf('.');
  final integer = dot < 0 ? text : text.substring(0, dot);
  final decimalsPart = dot < 0 ? '' : text.substring(dot);
  final buffer = StringBuffer();
  for (var i = 0; i < integer.length; i++) {
    if (i > 0 && (integer.length - i) % 3 == 0) buffer.write(',');
    buffer.write(integer[i]);
  }
  final result = '$buffer$decimalsPart';
  final isZero = double.tryParse(result) == 0;
  return negative && !isZero ? '-$result' : result;
}

/// 把数字转成上标字符串，用于指数显示（如 1.5×10³）。
String formatSuperscriptExponent(int exponent) {
  const digits = {
    '0': '⁰',
    '1': '¹',
    '2': '²',
    '3': '³',
    '4': '⁴',
    '5': '⁵',
    '6': '⁶',
    '7': '⁷',
    '8': '⁸',
    '9': '⁹',
    '-': '⁻',
  };
  return exponent
      .toString()
      .split('')
      .map((char) => digits[char] ?? char)
      .join();
}

String _trimExponential(String text) {
  final index = text.indexOf('e');
  if (index < 0) return _trimFixed(text);
  var mantissa = text.substring(0, index);
  var exponent = text.substring(index + 1);
  mantissa = _trimFixed(mantissa);
  if (mantissa.endsWith('.')) {
    mantissa = mantissa.substring(0, mantissa.length - 1);
  }
  if (exponent.startsWith('+')) {
    exponent = exponent.substring(1);
  }
  if (exponent.startsWith('-')) {
    final digits = exponent.substring(1).replaceFirst(RegExp(r'^0+(?=\d)'), '');
    exponent = '-$digits';
  } else {
    exponent = exponent.replaceFirst(RegExp(r'^0+(?=\d)'), '');
  }
  return '${mantissa}e$exponent';
}

String _trimFixed(String text) {
  if (!text.contains('.')) return text;
  var result = text;
  while (result.endsWith('0')) {
    result = result.substring(0, result.length - 1);
  }
  if (result.endsWith('.')) {
    result = result.substring(0, result.length - 1);
  }
  if (result.isEmpty || result == '-') return '0';
  return result;
}
