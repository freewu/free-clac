import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../tools/bmi.dart';

/// 各 BMI 分级对应的颜色。
Color bmiCategoryColor(BmiCategory category) => switch (category) {
  BmiCategory.underweight => AppColors.warning,
  BmiCategory.normal => AppColors.tertiary,
  BmiCategory.overweight => const Color(0xFFFF9F43),
  BmiCategory.obese => AppColors.error,
};

/// BMI 数值条：按 14~34 的刻度分为四段，并在对应位置标出当前值。
class BmiGauge extends StatelessWidget {
  const BmiGauge({super.key, required this.bmi});

  /// 当前 BMI，null 表示尚未计算。
  final double? bmi;

  static const double _min = 14;
  static const double _max = 34;

  static const List<(double, double, BmiCategory)> _segments = [
    (_min, bmiUnderweightMax, BmiCategory.underweight),
    (bmiUnderweightMax, bmiNormalMax, BmiCategory.normal),
    (bmiNormalMax, bmiOverweightMax, BmiCategory.overweight),
    (bmiOverweightMax, _max, BmiCategory.obese),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double x(double value) =>
            ((value - _min) / (_max - _min)).clamp(0.0, 1.0) * width;
        final marker = bmi;
        final markerX = marker == null ? null : x(marker);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Row(
                      children: [
                        for (final (start, end, category) in _segments)
                          Expanded(
                            flex: ((end - start) * 100).round(),
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 1,
                              ),
                              decoration: BoxDecoration(
                                color: bmiCategoryColor(
                                  category,
                                ).withValues(alpha: 0.75),
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(
                                    category == BmiCategory.underweight ? 6 : 2,
                                  ),
                                  right: Radius.circular(
                                    category == BmiCategory.obese ? 6 : 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (markerX != null)
                    Positioned(
                      left: markerX - 1.5,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: const [
                            BoxShadow(color: Color(0x99000000), blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 14,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (final boundary in const [
                    bmiUnderweightMax,
                    bmiNormalMax,
                    bmiOverweightMax,
                  ])
                    Positioned(
                      left: x(boundary) - 14,
                      width: 28,
                      child: Text(
                        boundary == bmiUnderweightMax
                            ? '18.5'
                            : '${boundary.toInt()}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 9.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final (_, _, category) in _segments)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: bmiCategoryColor(category),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            category.label,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
