import 'dart:math' as math;

import '../core/angle_mode.dart';
import '../l10n/app_language.dart';
import '../models/plot_function.dart';
import 'plot_viewport.dart';

/// 示例中的一条曲线。
class PresetCurve {
  const PresetCurve(this.mode, this.expression, [this.secondExpression = '']);

  final PlotMode mode;
  final String expression;

  /// 参数方程的 y(t)。
  final String secondExpression;
}

/// 一组示例曲线：曲线定义 + 建议视口，可一键载入绘图页。
class PlotPreset {
  const PlotPreset({
    required this.name,
    required this.description,
    required this.names,
    required this.descriptions,
    required this.curves,
    required this.viewport,
    this.angleMode,
  });

  /// 简体中文名称（[names] 缺少该语言时的回落值）。
  final String name;

  /// 简体中文说明。
  final String description;

  /// 其它语言的名称（zhHans 与 zhHant 都可用简体原文）。
  final Map<AppLanguage, String> names;

  /// 其它语言的说明。
  final Map<AppLanguage, String> descriptions;

  /// 按语言取名称；`zhHant` 有繁体就用繁体，否则回落简体原文。
  String nameIn(AppLanguage language) => names[language] ?? name;

  /// 按语言取说明。
  String descriptionIn(AppLanguage language) =>
      descriptions[language] ?? description;
  final List<PresetCurve> curves;
  final PlotViewport viewport;

  /// 需要特定角度模式才能得到原文效果时指定（例如密线填充依赖 sin 的周期）。
  final AngleMode? angleMode;

  Set<PlotMode> get modes => curves.map((curve) => curve.mode).toSet();
}

/// 示例来源：知乎《绘制出令人怦然心动的 7 种心形函数》。
const String kPlotPresetSource = 'https://zhuanlan.zhihu.com/p/662309066';

/// 示例曲目。
///
/// 前 6 组来自上述文章（其中隐式爱心用等值线绘制），
/// 其余为常见的“数学之美”曲线。
const List<PlotPreset> kPlotPresets = <PlotPreset>[
  PlotPreset(
    name: '心形 · 参数方程',
    description: 'x = 16sin³t，y = 13cos t − 5cos 2t − 2cos 3t − cos 4t',
    names: {
      AppLanguage.zhHant: '心形 · 參數方程',
      AppLanguage.en: 'Heart · parametric',
      AppLanguage.ja: 'ハート · 媒介変数',
      AppLanguage.es: 'Corazón · paramétrica',
    },
    descriptions: {
      AppLanguage.zhHant:
          'x = 16sin³t，y = 13cos t − 5cos 2t − 2cos 3t − cos 4t',
      AppLanguage.en: 'x = 16sin³t, y = 13cos t − 5cos 2t − 2cos 3t − cos 4t',
      AppLanguage.ja: 'x = 16sin³t、y = 13cos t − 5cos 2t − 2cos 3t − cos 4t',
      AppLanguage.es: 'x = 16sin³t, y = 13cos t − 5cos 2t − 2cos 3t − cos 4t',
    },
    curves: <PresetCurve>[
      PresetCurve(
        PlotMode.parametric,
        '16sin(t)^3',
        '13cos(t)-5cos(2t)-2cos(3t)-cos(4t)',
      ),
    ],
    viewport: PlotViewport(minX: -18, maxX: 18, minY: -19, maxY: 14),
  ),
  PlotPreset(
    name: '心形 · 极坐标',
    description: 'r = 2 − 2sin t + sin t·√|cos t| / (sin t + 1.4)',
    names: {
      AppLanguage.zhHant: '心形 · 極座標',
      AppLanguage.en: 'Heart · polar',
      AppLanguage.ja: 'ハート · 極座標',
      AppLanguage.es: 'Corazón · polar',
    },
    descriptions: {
      AppLanguage.zhHant: 'r = 2 − 2sin t + sin t·√|cos t| / (sin t + 1.4)',
      AppLanguage.en: 'r = 2 − 2sin t + sin t·√|cos t| / (sin t + 1.4)',
      AppLanguage.ja: 'r = 2 − 2sin t + sin t·√|cos t| / (sin t + 1.4)',
      AppLanguage.es: 'r = 2 − 2sin t + sin t·√|cos t| / (sin t + 1.4)',
    },
    curves: <PresetCurve>[
      PresetCurve(
        PlotMode.polar,
        '2-2sin(t)+sin(t)sqrt(abs(cos(t)))/(sin(t)+1.4)',
      ),
    ],
    viewport: PlotViewport(minX: -2.6, maxX: 2.6, minY: -4.4, maxY: 1.2),
  ),
  PlotPreset(
    name: '心形 · 正切幂',
    description: 'r = |tan t|^(1/|tan t|)，原点上方的一枚小爱心',
    names: {
      AppLanguage.zhHant: '心形 · 正切冪',
      AppLanguage.en: 'Heart · tangent power',
      AppLanguage.ja: 'ハート · 正接の累乗',
      AppLanguage.es: 'Corazón · potencia de tangente',
    },
    descriptions: {
      AppLanguage.zhHant: 'r = |tan t|^(1/|tan t|)，原點上方的一枚小愛心',
      AppLanguage.en:
          'r = |tan t|^(1/|tan t|) — a small heart just above the origin',
      AppLanguage.ja: 'r = |tan t|^(1/|tan t|)、原点のすぐ上に小さなハート',
      AppLanguage.es:
          'r = |tan t|^(1/|tan t|), un pequeño corazón sobre el origen',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.polar, 'abs(tan(t))^(1/abs(tan(t)))'),
    ],
    viewport: PlotViewport(minX: -1, maxX: 1, minY: -0.15, maxY: 1.55),
  ),
  PlotPreset(
    name: '无限爱心',
    description: 'y = √|sin x| ± √|cos x|，向两侧无限延伸',
    names: {
      AppLanguage.zhHant: '無限愛心',
      AppLanguage.en: 'Endless hearts',
      AppLanguage.ja: '無限ハート',
      AppLanguage.es: 'Corazones infinitos',
    },
    descriptions: {
      AppLanguage.zhHant: 'y = √|sin x| ± √|cos x|，向兩側無限延伸',
      AppLanguage.en:
          'y = √|sin x| ± √|cos x| — repeats forever in both directions',
      AppLanguage.ja: 'y = √|sin x| ± √|cos x|、左右に無限に続く',
      AppLanguage.es:
          'y = √|sin x| ± √|cos x|, se repite sin fin hacia ambos lados',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.cartesian, 'sqrt(abs(sin(x)))+sqrt(abs(cos(x)))'),
      PresetCurve(PlotMode.cartesian, 'sqrt(abs(sin(x)))-sqrt(abs(cos(x)))'),
    ],
    viewport: PlotViewport(minX: -6.4, maxX: 6.4, minY: -1.7, maxY: 1.9),
  ),
  PlotPreset(
    name: '填充爱心',
    description: 'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx)，a=1000 时密线填充',
    names: {
      AppLanguage.zhHant: '填充愛心',
      AppLanguage.en: 'Filled heart',
      AppLanguage.ja: '塗りつぶしハート',
      AppLanguage.es: 'Corazón relleno',
    },
    descriptions: {
      AppLanguage.zhHant:
          'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx)，a=1000 時密線填充',
      AppLanguage.en:
          'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx); a = 1000 fills it with dense lines',
      AppLanguage.ja:
          'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx)、a=1000 で密な線の塗り',
      AppLanguage.es:
          'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx); con a = 1000 se rellena de líneas',
    },
    curves: <PresetCurve>[
      PresetCurve(
        PlotMode.cartesian,
        'abs(x)^(2/3)+0.8sqrt(0.9-x^2)sin(1000pi*x)',
      ),
    ],
    viewport: PlotViewport(minX: -1.05, maxX: 1.05, minY: -1, maxY: 1.45),
    angleMode: AngleMode.radians,
  ),
  PlotPreset(
    name: '跳动爱心',
    description: 'r = (4 + sin t)/√(1 − |cos t|·sin t)，t 取 ±10 时缩放跳动',
    names: {
      AppLanguage.zhHant: '跳動愛心',
      AppLanguage.en: 'Beating heart',
      AppLanguage.ja: '鼓動するハート',
      AppLanguage.es: 'Corazón que late',
    },
    descriptions: {
      AppLanguage.zhHant: 'r = (4 + sin t)/√(1 − |cos t|·sin t)，t 取 ±10 時縮放跳動',
      AppLanguage.en:
          'r = (4 + sin t)/√(1 − |cos t|·sin t) — t up to ±10 makes it pulse',
      AppLanguage.ja: 'r = (4 + sin t)/√(1 − |cos t|·sin t)、t を ±10 にすると脈打つ',
      AppLanguage.es:
          'r = (4 + sin t)/√(1 − |cos t|·sin t); con t hasta ±10 late',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.polar, '(4+sin(10))/sqrt(1-abs(cos(t))sin(t))'),
      PresetCurve(PlotMode.polar, '(4+sin(-10))/sqrt(1-abs(cos(t))sin(t))'),
    ],
    viewport: PlotViewport(minX: -5.6, maxX: 5.6, minY: -5.2, maxY: 5.6),
  ),
  PlotPreset(
    name: '心形 · 隐式方程',
    description: '(x²+y²−1)³ − x²y³ = 0，用等值线画出的爱心',
    names: {
      AppLanguage.zhHant: '心形 · 隱式方程',
      AppLanguage.en: 'Heart · implicit',
      AppLanguage.ja: 'ハート · 陰関数',
      AppLanguage.es: 'Corazón · implícita',
    },
    descriptions: {
      AppLanguage.zhHant: '(x²+y²−1)³ − x²y³ = 0，用等值線畫出的愛心',
      AppLanguage.en: '(x²+y²−1)³ − x²y³ = 0 — drawn as a contour line',
      AppLanguage.ja: '(x²+y²−1)³ − x²y³ = 0、等高線として描くハート',
      AppLanguage.es: '(x²+y²−1)³ − x²y³ = 0, dibujado como línea de nivel',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.implicit, '(x^2+y^2-1)^3-x^2y^3'),
    ],
    viewport: PlotViewport(minX: -1.55, maxX: 1.55, minY: -1.45, maxY: 1.65),
  ),
  PlotPreset(
    name: '玫瑰线',
    description: 'r = 4cos(3t)，三瓣玫瑰；改系数可画四瓣、五瓣',
    names: {
      AppLanguage.zhHant: '玫瑰線',
      AppLanguage.en: 'Rose curve',
      AppLanguage.ja: 'バラ曲線',
      AppLanguage.es: 'Rosa polar',
    },
    descriptions: {
      AppLanguage.zhHant: 'r = 4cos(3t)，三瓣玫瑰；改係數可畫四瓣、五瓣',
      AppLanguage.en:
          'r = 4cos(3t) — three petals; change the factor for four or five',
      AppLanguage.ja: 'r = 4cos(3t)、3 枚の花びら。係数を変えれば 4 枚・5 枚にも',
      AppLanguage.es:
          'r = 4cos(3t), tres pétalos; cambia el factor para cuatro o cinco',
    },
    curves: <PresetCurve>[PresetCurve(PlotMode.polar, '4cos(3t)')],
    viewport: PlotViewport(minX: -4.6, maxX: 4.6, minY: -4.6, maxY: 4.6),
  ),
  PlotPreset(
    name: '李萨如曲线',
    description: 'x = 4sin(3t)，y = 4sin(4t)，两个频率之比决定花纹',
    names: {
      AppLanguage.zhHant: '李薩如曲線',
      AppLanguage.en: 'Lissajous curve',
      AppLanguage.ja: 'リサージュ曲線',
      AppLanguage.es: 'Curva de Lissajous',
    },
    descriptions: {
      AppLanguage.zhHant: 'x = 4sin(3t)，y = 4sin(4t)，兩個頻率之比決定花紋',
      AppLanguage.en:
          'x = 4sin(3t), y = 4sin(4t) — the frequency ratio shapes the pattern',
      AppLanguage.ja: 'x = 4sin(3t)、y = 4sin(4t)、2 つの周波数の比が模様を決める',
      AppLanguage.es:
          'x = 4sin(3t), y = 4sin(4t); la razón de frecuencias define el dibujo',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.parametric, '4sin(3t)', '4sin(4t)'),
    ],
    viewport: PlotViewport(minX: -4.6, maxX: 4.6, minY: -4.6, maxY: 4.6),
  ),
  PlotPreset(
    name: '正弦与抛物线',
    description: 'y = sin x 与 y = 0.12x² − 2 的交点演示',
    names: {
      AppLanguage.zhHant: '正弦與拋物線',
      AppLanguage.en: 'Sine and parabola',
      AppLanguage.ja: 'サインと放物線',
      AppLanguage.es: 'Seno y parábola',
    },
    descriptions: {
      AppLanguage.zhHant: 'y = sin x 與 y = 0.12x² − 2 的交點演示',
      AppLanguage.en: 'y = sin x meeting y = 0.12x² − 2',
      AppLanguage.ja: 'y = sin x と y = 0.12x² − 2 の交点',
      AppLanguage.es: 'y = sin x frente a y = 0.12x² − 2',
    },
    curves: <PresetCurve>[
      PresetCurve(PlotMode.cartesian, 'sin(x)'),
      PresetCurve(PlotMode.cartesian, '0.12x^2-2'),
    ],
    viewport: PlotViewport(minX: -10, maxX: 10, minY: -6, maxY: 6),
  ),
];

/// 极坐标 / 参数方程的默认参数区间（跟随角度模式）。
(double, double) defaultParameterDomain({required bool degrees}) =>
    degrees ? (0, 360) : (0, 2 * math.pi);
