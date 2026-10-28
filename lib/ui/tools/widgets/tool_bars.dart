import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// 条里的一段：权重 + 颜色。
class RatioSegment {
  const RatioSegment({required this.value, required this.color});

  /// 相对权重，会按所有段之和归一化。
  final double value;

  final Color color;
}

/// 多段比例条：按各段 value 的比例分满整条宽度（蓝色本金 + 黄色利息就是两段）。
class SegmentedBar extends StatelessWidget {
  const SegmentedBar({
    super.key,
    required this.segments,
    this.height = 6,
    this.radius = 3,
  });

  final List<RatioSegment> segments;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(
      0,
      (sum, segment) => sum + _weightOf(segment),
    );
    return SizedBox(
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (total <= 0) {
              return ColoredBox(color: AppColors.outline);
            }
            var left = 0.0;
            final bars = <Widget>[];
            for (final segment in segments) {
              final width = constraints.maxWidth * _weightOf(segment) / total;
              bars.add(
                Positioned(
                  left: left,
                  top: 0,
                  bottom: 0,
                  width: width,
                  child: ColoredBox(color: segment.color),
                ),
              );
              left += width;
            }
            return Stack(children: bars);
          },
        ),
      ),
    );
  }

  static double _weightOf(RatioSegment segment) =>
      segment.value.isFinite && segment.value > 0 ? segment.value : 0;
}

/// 金额对比条：条长按 [ratio] 缩放，右侧显示金额。
///
/// 三行放在一起就能按金额比出长短（贷款总额 / 总利息 / 总还款），
/// 传多段 [segments] 时画成双色 / 多色构成条。
class AmountBar extends StatelessWidget {
  const AmountBar({
    super.key,
    required this.label,
    required this.value,
    required this.ratio,
    required this.segments,
    this.labelWidth = 56,
    this.valueWidth = 92,
    this.height = 8,
  });

  /// 左侧标签。
  final String label;

  /// 右侧金额文本。
  final String value;

  /// 条长占比（0~1）。
  final double ratio;

  /// 构成条的分段；单段就是纯色条。
  final List<RatioSegment> segments;

  final double labelWidth;
  final double valueWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: labelWidth,
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: ratio.clamp(0.0, 1.0),
              child: SizedBox(
                height: height,
                child: SegmentedBar(
                  segments: segments,
                  height: height,
                  radius: height / 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: valueWidth,
          child: Text(
            value,
            maxLines: 1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
