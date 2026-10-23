import 'dart:math' as math;

import '../core/angle_mode.dart';
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
    required this.curves,
    required this.viewport,
    this.angleMode,
  });

  final String name;
  final String description;
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
    curves: <PresetCurve>[
      PresetCurve(PlotMode.polar, 'abs(tan(t))^(1/abs(tan(t)))'),
    ],
    viewport: PlotViewport(minX: -1, maxX: 1, minY: -0.15, maxY: 1.55),
  ),
  PlotPreset(
    name: '无限爱心',
    description: 'y = √|sin x| ± √|cos x|，向两侧无限延伸',
    curves: <PresetCurve>[
      PresetCurve(PlotMode.cartesian, 'sqrt(abs(sin(x)))+sqrt(abs(cos(x)))'),
      PresetCurve(PlotMode.cartesian, 'sqrt(abs(sin(x)))-sqrt(abs(cos(x)))'),
    ],
    viewport: PlotViewport(minX: -6.4, maxX: 6.4, minY: -1.7, maxY: 1.9),
  ),
  PlotPreset(
    name: '填充爱心',
    description: 'y = |x|^(2/3) + (4/5)√(9/10 − x²)·sin(aπx)，a=1000 时密线填充',
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
    curves: <PresetCurve>[
      PresetCurve(PlotMode.polar, '(4+sin(10))/sqrt(1-abs(cos(t))sin(t))'),
      PresetCurve(PlotMode.polar, '(4+sin(-10))/sqrt(1-abs(cos(t))sin(t))'),
    ],
    viewport: PlotViewport(minX: -5.6, maxX: 5.6, minY: -5.2, maxY: 5.6),
  ),
  PlotPreset(
    name: '心形 · 隐式方程',
    description: '(x²+y²−1)³ − x²y³ = 0，用等值线画出的爱心',
    curves: <PresetCurve>[
      PresetCurve(PlotMode.implicit, '(x^2+y^2-1)^3-x^2y^3'),
    ],
    viewport: PlotViewport(minX: -1.55, maxX: 1.55, minY: -1.45, maxY: 1.65),
  ),
  PlotPreset(
    name: '玫瑰线',
    description: 'r = 4cos(3t)，三瓣玫瑰；改系数可画四瓣、五瓣',
    curves: <PresetCurve>[PresetCurve(PlotMode.polar, '4cos(3t)')],
    viewport: PlotViewport(minX: -4.6, maxX: 4.6, minY: -4.6, maxY: 4.6),
  ),
  PlotPreset(
    name: '李萨如曲线',
    description: 'x = 4sin(3t)，y = 4sin(4t)，两个频率之比决定花纹',
    curves: <PresetCurve>[
      PresetCurve(PlotMode.parametric, '4sin(3t)', '4sin(4t)'),
    ],
    viewport: PlotViewport(minX: -4.6, maxX: 4.6, minY: -4.6, maxY: 4.6),
  ),
  PlotPreset(
    name: '正弦与抛物线',
    description: 'y = sin x 与 y = 0.12x² − 2 的交点演示',
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
