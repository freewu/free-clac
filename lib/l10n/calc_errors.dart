import '../core/calc_error.dart';
import 'app_i18n.dart';
import 'app_language.dart';

/// 计算错误的五种语言模板，键是 [CalcError]。
///
/// 简体中文直接用 [CalcError.template]（`lib/core/` 里那份），
/// 另外四种语言必须在这里翻全——`test/l10n_test.dart` 会逐项检查。
const Map<AppLanguage, Map<CalcError, String>>
kCalcErrorStrings = <AppLanguage, Map<CalcError, String>>{
  AppLanguage.zhHant: <CalcError, String>{
    CalcError.unknownChar: '無法辨識的字元「{0}」',
    CalcError.invalidNumber: '無效的數字「{0}」',
    CalcError.emptyExpression: '運算式不能為空',
    CalcError.trailingInput: '多餘的輸入「{0}」',
    CalcError.missingRParen: '缺少右括號「)」',
    CalcError.extraRParen: '多餘的右括號「)」',
    CalcError.misplacedOperator: '運算子「{0}」位置不正確',
    CalcError.misplacedComma: '逗號位置不正確',
    CalcError.incompleteExpression: '運算式不完整',
    CalcError.unparsable: '無法解析「{0}」',
    CalcError.functionNeedsParens: '函式 {0} 需要括號，例如 {1}',
    CalcError.functionMissingRParen: '函式 {0} 缺少右括號「)」',
    CalcError.functionArgCount: '函式 {0} 的參數個數不正確，用法：{1}',
    CalcError.specialArgCount: '特殊函式 {0} 的參數個數不正確',
    CalcError.nesting: '運算式巢狀層數過多',
    CalcError.undefinedVariable: '未定義的變數「{0}」',
    CalcError.undefinedFunction: '未定義的函式「{0}」',
    CalcError.unknownPostfix: '未知的後置運算子「{0}」',
    CalcError.unknownOperator: '未知的運算子「{0}」',
    CalcError.notEvaluable: '無法求值的運算式',
    CalcError.sumTooMany: '求和／求積的項數過多（上限 1000000）',
    CalcError.integralBounds: '積分上下限必須是有限值',
    CalcError.integralUndefined: '積分區間內函式無定義',
    CalcError.derivativeUndefined: '該點導數不存在或無法計算',
    CalcError.secondArgVariable: '第二個參數必須是變數名，例如 sum(k^2, k, 1, 10)',
    CalcError.logBase: '對數的底數必須大於 0 且不等於 1',
    CalcError.rootDegree: '方根次數不能為 0',
    CalcError.randintRange: 'randint 的區間無效',
    CalcError.generic: '計算失敗：{0}',
  },
  AppLanguage.en: <CalcError, String>{
    CalcError.unknownChar: 'Unrecognized character "{0}"',
    CalcError.invalidNumber: 'Invalid number "{0}"',
    CalcError.emptyExpression: 'Expression is empty',
    CalcError.trailingInput: 'Unexpected input "{0}"',
    CalcError.missingRParen: 'Missing closing ")"',
    CalcError.extraRParen: 'Unmatched ")"',
    CalcError.misplacedOperator: 'Operator "{0}" is in the wrong place',
    CalcError.misplacedComma: 'Comma is in the wrong place',
    CalcError.incompleteExpression: 'Expression is incomplete',
    CalcError.unparsable: 'Cannot parse "{0}"',
    CalcError.functionNeedsParens: 'Function {0} needs parentheses, e.g. {1}',
    CalcError.functionMissingRParen: 'Function {0} is missing a closing ")"',
    CalcError.functionArgCount:
        'Function {0} takes a different number of arguments, usage: {1}',
    CalcError.specialArgCount:
        'Special function {0} takes a different number of arguments',
    CalcError.nesting: 'Expression is nested too deeply',
    CalcError.undefinedVariable: 'Undefined variable "{0}"',
    CalcError.undefinedFunction: 'Undefined function "{0}"',
    CalcError.unknownPostfix: 'Unknown postfix operator "{0}"',
    CalcError.unknownOperator: 'Unknown operator "{0}"',
    CalcError.notEvaluable: 'Expression cannot be evaluated',
    CalcError.sumTooMany: 'Too many terms in sum/product (limit 1000000)',
    CalcError.integralBounds: 'Integration limits must be finite',
    CalcError.integralUndefined:
        'Function is undefined somewhere in the integration range',
    CalcError.derivativeUndefined:
        'Derivative does not exist or cannot be computed here',
    CalcError.secondArgVariable:
        'The second argument must be a variable name, e.g. sum(k^2, k, 1, 10)',
    CalcError.logBase: 'Logarithm base must be greater than 0 and not 1',
    CalcError.rootDegree: 'Root degree cannot be 0',
    CalcError.randintRange: 'Invalid randint range',
    CalcError.generic: 'Calculation failed: {0}',
  },
  AppLanguage.ja: <CalcError, String>{
    CalcError.unknownChar: '認識できない文字「{0}」',
    CalcError.invalidNumber: '無効な数値「{0}」',
    CalcError.emptyExpression: '式が入力されていません',
    CalcError.trailingInput: '余分な入力「{0}」',
    CalcError.missingRParen: '閉じ括弧「)」がありません',
    CalcError.extraRParen: '余分な閉じ括弧「)」',
    CalcError.misplacedOperator: '演算子「{0}」の位置が正しくありません',
    CalcError.misplacedComma: 'カンマの位置が正しくありません',
    CalcError.incompleteExpression: '式が不完全です',
    CalcError.unparsable: '「{0}」を解析できません',
    CalcError.functionNeedsParens: '関数 {0} には括弧が必要です（例：{1}）',
    CalcError.functionMissingRParen: '関数 {0} の閉じ括弧「)」がありません',
    CalcError.functionArgCount: '関数 {0} の引数の個数が正しくありません（書式：{1}）',
    CalcError.specialArgCount: '特殊関数 {0} の引数の個数が正しくありません',
    CalcError.nesting: '式の入れ子が深すぎます',
    CalcError.undefinedVariable: '未定義の変数「{0}」',
    CalcError.undefinedFunction: '未定義の関数「{0}」',
    CalcError.unknownPostfix: '不明な後置演算子「{0}」',
    CalcError.unknownOperator: '不明な演算子「{0}」',
    CalcError.notEvaluable: '計算できない式です',
    CalcError.sumTooMany: '総和／総乗の項数が多すぎます（上限 1000000）',
    CalcError.integralBounds: '積分区間の上下限は有限値である必要があります',
    CalcError.integralUndefined: '積分区間内で関数が定義されていません',
    CalcError.derivativeUndefined: 'この点の導関数は存在しないか計算できません',
    CalcError.secondArgVariable: '2 番目の引数は変数名である必要があります（例：sum(k^2, k, 1, 10)）',
    CalcError.logBase: '対数の底は 0 より大きく 1 以外である必要があります',
    CalcError.rootDegree: '累乗根の次数に 0 は指定できません',
    CalcError.randintRange: 'randint の範囲が無効です',
    CalcError.generic: '計算に失敗しました：{0}',
  },
  AppLanguage.es: <CalcError, String>{
    CalcError.unknownChar: 'Carácter no reconocido «{0}»',
    CalcError.invalidNumber: 'Número no válido «{0}»',
    CalcError.emptyExpression: 'La expresión está vacía',
    CalcError.trailingInput: 'Entrada sobrante «{0}»',
    CalcError.missingRParen: 'Falta el paréntesis de cierre «)»',
    CalcError.extraRParen: 'Paréntesis de cierre «)» sobrante',
    CalcError.misplacedOperator: 'El operador «{0}» está mal colocado',
    CalcError.misplacedComma: 'La coma está mal colocada',
    CalcError.incompleteExpression: 'La expresión está incompleta',
    CalcError.unparsable: 'No se puede analizar «{0}»',
    CalcError.functionNeedsParens:
        'La función {0} necesita paréntesis, p. ej. {1}',
    CalcError.functionMissingRParen:
        'A la función {0} le falta el paréntesis de cierre «)»',
    CalcError.functionArgCount:
        'La función {0} no admite ese número de argumentos, uso: {1}',
    CalcError.specialArgCount:
        'La función especial {0} no admite ese número de argumentos',
    CalcError.nesting: 'La expresión está demasiado anidada',
    CalcError.undefinedVariable: 'Variable no definida «{0}»',
    CalcError.undefinedFunction: 'Función no definida «{0}»',
    CalcError.unknownPostfix: 'Operador postfijo desconocido «{0}»',
    CalcError.unknownOperator: 'Operador desconocido «{0}»',
    CalcError.notEvaluable: 'La expresión no se puede evaluar',
    CalcError.sumTooMany:
        'Demasiados términos en el sumatorio/producto (límite 1000000)',
    CalcError.integralBounds: 'Los límites de integración deben ser finitos',
    CalcError.integralUndefined:
        'La función no está definida en algún punto del intervalo',
    CalcError.derivativeUndefined:
        'La derivada no existe o no se puede calcular en este punto',
    CalcError.secondArgVariable:
        'El segundo argumento debe ser un nombre de variable, p. ej. sum(k^2, k, 1, 10)',
    CalcError.logBase:
        'La base del logaritmo debe ser mayor que 0 y distinta de 1',
    CalcError.rootDegree: 'El grado de la raíz no puede ser 0',
    CalcError.randintRange: 'Rango de randint no válido',
    CalcError.generic: 'El cálculo ha fallado: {0}',
  },
};

/// 出错位置后缀模板。
const Map<AppLanguage, String> kCalcErrorPosition = <AppLanguage, String>{
  AppLanguage.zhHans: '（位置 {0}）',
  AppLanguage.zhHant: '（位置 {0}）',
  AppLanguage.en: ' (position {0})',
  AppLanguage.ja: '（位置 {0}）',
  AppLanguage.es: ' (posición {0})',
};

/// 取当前语言下的错误文案：模板 → 填充参数 → 附上位置。
String calcErrorMessage(CalcException error) {
  final language = appLanguage;
  final localized = kCalcErrorStrings[language]?[error.code];
  var text = fill(localized ?? error.code.template, error.args);
  final position = error.position;
  if (position != null) {
    text += fill(kCalcErrorPosition[language] ?? '（位置 {0}）', [position + 1]);
  }
  return text;
}

/// 把任意异常转成当前语言的错误文案。
String calcErrorText(Object error) =>
    error is CalcException ? calcErrorMessage(error) : '$error';
