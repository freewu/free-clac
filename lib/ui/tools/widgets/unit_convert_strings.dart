import '../../../l10n/app_i18n.dart';
import '../../../l10n/app_language.dart';
import '../unit_catalog.dart';

/// 单位下拉项文案：`名称（符号）`；市制单位的符号就是汉字本身，只显示名称。
String unitOptionLabel(MeasureUnit unit) {
  final label = unit.labelIn(appLanguage);
  if (unit.symbol == unit.label || unit.symbol == label) return label;
  return fill(unitConvertStrings.unitOption, [label, unit.symbol]);
}

/// 六个单位换算工具共用的页面文案。
///
/// 页面外壳（[UnitConvertPage]）是共用的，所以文案也共用一份；每个工具
/// 自己的名称、卖点、说明仍在各自的 `<tool>_lang.dart` 里。
class UnitConvertStrings {
  const UnitConvertStrings({
    required this.input,
    required this.system,
    required this.unit,
    required this.value,
    required this.results,
    required this.copyHint,
    required this.samplesTitle,
    required this.collapse,
    required this.expand,
    required this.emptyHint,
    required this.copied,
    required this.unitOption,
    required this.catalogNames,
    required this.baseNames,
  });

  final String input;
  final String system;
  final String unit;
  final String value;
  final String results;

  /// 「点任意一行即可复制 · 统一以 {0} 为基准」。
  final String copyHint;

  /// 「常见 {0}」，`{0}` 是该工具的量名（长度 / 面积 …）。
  final String samplesTitle;
  final String collapse;
  final String expand;
  final String emptyHint;

  /// 「已复制 {0} {1}」，`{0}` 是数值，`{1}` 是单位名。
  final String copied;

  /// 单位下拉项：`{0}` 是名称、`{1}` 是符号。
  final String unitOption;

  /// 量名（对应 `MeasureCatalog.id`），覆盖 `MeasureCatalog.name` 的中文。
  final Map<String, String> catalogNames;

  /// 基准单位名（对应 `MeasureCatalog.id`），覆盖 `MeasureCatalog.baseName`。
  final Map<String, String> baseNames;

  /// 该工具的量名。
  String catalogName(String id, String fallback) =>
      catalogNames[id] ?? fallback;

  /// 该工具的基准单位名。
  String baseName(String id, String fallback) => baseNames[id] ?? fallback;
}

/// 各语言的换算页文案。
const Map<AppLanguage, UnitConvertStrings> kUnitConvertStrings =
    <AppLanguage, UnitConvertStrings>{
      AppLanguage.zhHans: UnitConvertStrings(
        input: '输入',
        system: '计量体系',
        unit: '单位',
        value: '数值',
        results: '换算结果',
        copyHint: '点任意一行即可复制 · 统一以 {0} 为基准',
        samplesTitle: '常见{0}',
        collapse: '收起',
        expand: '展开',
        emptyHint: '填入数值并选好单位后自动换算',
        copied: '已复制 {0} {1}',
        unitOption: '{0}（{1}）',
        catalogNames: <String, String>{
          'distance': '长度',
          'area': '面积',
          'volume': '容量',
          'weight': '重量',
          'temperature': '温度',
          'energy': '热量',
          'pressure': '压力',
          'speed': '速度',
        },
        baseNames: <String, String>{
          'distance': '米',
          'area': '平方米',
          'volume': '升',
          'weight': '千克',
          'temperature': '摄氏度',
          'energy': '焦耳',
          'pressure': '帕斯卡',
          'speed': '米/秒',
        },
      ),
      AppLanguage.zhHant: UnitConvertStrings(
        input: '輸入',
        system: '計量體系',
        unit: '單位',
        value: '數值',
        results: '換算結果',
        copyHint: '點任意一行即可複製 · 統一以 {0} 為基準',
        samplesTitle: '常見{0}',
        collapse: '收起',
        expand: '展開',
        emptyHint: '填入數值並選好單位後自動換算',
        copied: '已複製 {0} {1}',
        unitOption: '{0}（{1}）',
        catalogNames: <String, String>{
          'distance': '長度',
          'area': '面積',
          'volume': '容量',
          'weight': '重量',
          'temperature': '溫度',
          'energy': '熱量',
          'pressure': '壓力',
          'speed': '速度',
        },
        baseNames: <String, String>{
          'distance': '米',
          'area': '平方米',
          'volume': '升',
          'weight': '千克',
          'temperature': '攝氏度',
          'energy': '焦耳',
          'pressure': '帕斯卡',
          'speed': '米/秒',
        },
      ),
      AppLanguage.en: UnitConvertStrings(
        input: 'Input',
        system: 'Unit system',
        unit: 'Unit',
        value: 'Value',
        results: 'Result',
        copyHint: 'Tap any row to copy · base unit: {0}',
        samplesTitle: 'Common {0}',
        collapse: 'Hide',
        expand: 'Show',
        emptyHint: 'Enter a value and pick units to convert',
        copied: 'Copied {0} {1}',
        unitOption: '{0} ({1})',
        catalogNames: <String, String>{
          'distance': 'lengths',
          'area': 'areas',
          'volume': 'volumes',
          'weight': 'weights',
          'temperature': 'temperatures',
          'energy': 'energy figures',
          'pressure': 'pressures',
          'speed': 'speeds',
        },
        baseNames: <String, String>{
          'distance': 'metre',
          'area': 'square metre',
          'volume': 'litre',
          'weight': 'kilogram',
          'temperature': 'degree Celsius',
          'energy': 'joule',
          'pressure': 'pascal',
          'speed': 'metre per second',
        },
      ),
      AppLanguage.ja: UnitConvertStrings(
        input: '入力',
        system: '単位系',
        unit: '単位',
        value: '値',
        results: '換算結果',
        copyHint: '行をタップするとコピー · {0} を基準',
        samplesTitle: 'よくある{0}',
        collapse: '折りたたむ',
        expand: '展開',
        emptyHint: '値と単位を選ぶと自動で換算します',
        copied: '{0} {1} をコピーしました',
        unitOption: '{0}（{1}）',
        catalogNames: <String, String>{
          'distance': '長さ',
          'area': '面積',
          'volume': '体積',
          'weight': '重さ',
          'temperature': '温度',
          'energy': '熱量',
          'pressure': '圧力',
          'speed': '速さ',
        },
        baseNames: <String, String>{
          'distance': 'メートル',
          'area': '平方メートル',
          'volume': 'リットル',
          'weight': 'キログラム',
          'temperature': '摂氏',
          'energy': 'ジュール',
          'pressure': 'パスカル',
          'speed': 'メートル毎秒',
        },
      ),
      AppLanguage.es: UnitConvertStrings(
        input: 'Datos',
        system: 'Sistema',
        unit: 'Unidad',
        value: 'Valor',
        results: 'Resultado',
        copyHint: 'Toca una fila para copiar · unidad base: {0}',
        samplesTitle: '{0} habituales',
        collapse: 'Ocultar',
        expand: 'Mostrar',
        emptyHint: 'Introduce un valor y elige las unidades',
        copied: 'Copiado {0} {1}',
        unitOption: '{0} ({1})',
        catalogNames: <String, String>{
          'distance': 'longitudes',
          'area': 'áreas',
          'volume': 'volúmenes',
          'weight': 'pesos',
          'temperature': 'temperaturas',
          'energy': 'energías',
          'pressure': 'presiones',
          'speed': 'velocidades',
        },
        baseNames: <String, String>{
          'distance': 'metro',
          'area': 'metro cuadrado',
          'volume': 'litro',
          'weight': 'kilogramo',
          'temperature': 'grado Celsius',
          'energy': 'julio',
          'pressure': 'pascal',
          'speed': 'metro por segundo',
        },
      ),
    };

/// 当前语言的换算页文案。
UnitConvertStrings get unitConvertStrings => toolText(kUnitConvertStrings);
