import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/core/angle_mode.dart';
import 'package:free_clac/core/math_engine.dart';
import 'package:free_clac/core/number_format.dart';

void main() {
  late MathEngine engine;

  setUp(() => engine = MathEngine(angleMode: AngleMode.degrees));

  double value(String source) {
    final result = engine.evaluate(source);
    expect(result.isError, isFalse, reason: '${result.error} <- $source');
    return result.value!;
  }

  group('优先级与基本运算', () {
    test('四则运算', () {
      expect(value('1+2*3'), 7);
      expect(value('(1+2)*3'), 9);
      expect(value('10-4/2'), 8);
      expect(value('2^3^2'), 512, reason: '幂右结合');
      expect(value('-2^2'), -4, reason: '一元负号低于幂');
      expect(value('2^-2'), 0.25);
    });

    test('隐式乘法', () {
      expect(value('2(3+4)'), 14);
      expect(value('(1+1)(2+2)'), 8);
      expect(value('3sin(30)'), closeTo(1.5, 1e-12));
      expect(value('2pi'), closeTo(2 * math.pi, 1e-12));
    });

    test('阶乘与百分号', () {
      expect(value('5!'), 120);
      expect(value('0!'), 1);
      expect(value('50%'), 0.5);
      expect(value('200*10%'), 20);
      expect(value('10%3'), 1, reason: '后接操作数时按取模处理');
    });

    test('Unicode 与上标', () {
      expect(value('2×3'), 6);
      expect(value('6÷3'), 2);
      expect(value('2²'), 4);
      expect(value('π'), closeTo(math.pi, 1e-12));
    });
  });

  group('函数', () {
    test('三角（角度制）', () {
      expect(value('sin(30)'), closeTo(0.5, 1e-12));
      expect(value('cos(60)'), closeTo(0.5, 1e-12));
      expect(value('asin(0.5)'), closeTo(30, 1e-9));
      expect(value('tan(45)'), closeTo(1, 1e-12));
    });

    test('弧度制', () {
      engine.angleMode = AngleMode.radians;
      expect(value('sin(pi/2)'), closeTo(1, 1e-12));
      expect(value('atan(1)*4'), closeTo(math.pi, 1e-12));
    });

    test('对数与幂', () {
      expect(value('ln(e)'), closeTo(1, 1e-12));
      expect(value('log(1000)'), closeTo(3, 1e-12));
      expect(value('log(8,2)'), closeTo(3, 1e-12));
      expect(value('sqrt(16)'), 4);
      expect(value('cbrt(-27)'), closeTo(-3, 1e-12));
      expect(value('root(32,5)'), closeTo(2, 1e-12));
    });

    test('组合与取整', () {
      expect(value('ncr(5,2)'), 10);
      expect(value('npr(5,2)'), 20);
      expect(value('gcd(12,18)'), 6);
      expect(value('lcm(4,6)'), 12);
      expect(value('round(2.345,2)'), closeTo(2.35, 1e-12));
      expect(value('floor(-1.2)'), -2);
      expect(value('abs(-3)+sign(-3)'), 2);
    });

    test('无需括号的一元函数', () {
      expect(value('sin 30'), closeTo(0.5, 1e-12));
      expect(value('ln e'), closeTo(1, 1e-12));
    });
  });

  group('高级：求和 / 积分 / 求导', () {
    test('sum 与 prod', () {
      expect(value('sum(k^2, k, 1, 10)'), 385);
      expect(value('prod(k, k, 1, 5)'), 120);
      expect(
        value('sum(1/k^2, k, 1, 100)'),
        closeTo(math.pi * math.pi / 6, 1e-2),
      );
    });

    test('integrate', () {
      expect(value('integrate(x^2, x, 0, 3)'), closeTo(9, 1e-6));
      expect(value('integrate(1/x, x, 1, e)'), closeTo(1, 1e-6));
      // 角度制下 sin 的自变量按度解释，结果为 2 * 180/π
      expect(
        value('integrate(sin(x), x, 0, 180)'),
        closeTo(360 / math.pi, 1e-6),
      );
      engine.angleMode = AngleMode.radians;
      expect(value('integrate(sin(x), x, 0, pi)'), closeTo(2, 1e-6));
    });

    test('diff', () {
      expect(value('diff(x^3, x, 2)'), closeTo(12, 1e-4));
      engine.angleMode = AngleMode.radians;
      expect(value('diff(sin(x), x, 0)'), closeTo(1, 1e-4));
      expect(value('diff(ln(x), x, 1)'), closeTo(1, 1e-4));
    });
  });

  group('错误处理', () {
    test('非法表达式给出错误信息', () {
      for (final source in ['1+', '(1+2', '1.2.3', 'foo(1)', '2 @ 3', '']) {
        final result = engine.evaluate(source);
        expect(result.isError, isTrue, reason: '应当报错：$source');
        expect(result.error, isNotEmpty);
      }
    });

    test('未定义变量', () {
      expect(engine.evaluate('x+1').isError, isTrue);
      expect(engine.evaluate('x^2', variables: {'x': 3}).value, 9);
    });
  });

  group('数字格式化', () {
    test('去除浮点噪声', () {
      expect(formatNumber(0.1 + 0.2), '0.3');
      expect(formatNumber(1 / 3), '0.333333333333');
      expect(formatNumber(2), '2');
      expect(formatNumber(-0.0), '0');
    });

    test('科学计数法', () {
      expect(formatNumber(1.5e20), '1.5e20');
      expect(formatNumber(1.2e-12), '1.2e-12');
      expect(formatNumber(double.infinity), '∞');
      expect(formatNumber(double.nan), 'NaN');
    });

    test('自动闭包求值（绘图用）', () {
      final curve = engine.compileCurve('x^2');
      expect(curve(3), 9);
      expect(curve.dependsOnVariable(), isTrue);
    });

    test('二元闭包求值（隐式方程用）', () {
      final surface = engine.compileSurface('(x^2+y^2-1)^3-x^2y^3');
      // 隐式爱心上的两个点：(1, 0) 与 (0, 1)
      expect(surface(1, 0), closeTo(0, 1e-12));
      expect(surface(0, 1), closeTo(0, 1e-12));
      expect(surface(0, 0), closeTo(-1, 1e-12));
      expect(engine.compileSurface('x+y')(2, 3), 5);
      // 变量表在多次调用之间复用，不会串值
      expect(surface(0, 0), closeTo(-1, 1e-12));
    });
  });
}
