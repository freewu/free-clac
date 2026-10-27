import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:free_clac/core/latex.dart';
import 'package:free_clac/models/plot_function.dart';

void main() {
  String latex(String source) {
    final result = tryExpressionToLatex(source);
    expect(result, isNotNull, reason: '无法解析：$source');
    return result!;
  }

  group('LaTeX：基础运算', () {
    test('四则运算与优先级', () {
      expect(latex('1+2*3'), r'1 + 2 \cdot 3');
      expect(latex('(1+2)*3'), r'\left(1 + 2\right) \cdot 3');
      expect(latex('1/2'), r'\frac{1}{2}');
      expect(latex('1/(2+3)'), r'\frac{1}{2 + 3}');
      expect(latex('2^3'), '2^{3}');
      expect(latex('2^3^2'), '2^{3^{2}}', reason: '幂右结合');
      expect(latex('x^(n+1)'), 'x^{n + 1}');
      expect(latex('-2^2'), '-2^{2}');
      expect(latex('2^-3'), '2^{-3}');
      expect(latex('-(x+1)'), r'-\left(x + 1\right)');
    });

    test('阶乘、百分号与取模', () {
      expect(latex('5!'), '5!');
      expect(latex('50%'), r'\frac{50}{100}');
      expect(latex('x % 3'), r'x \bmod 3');
      expect(latex('mod(10, 3)'), r'10 \bmod 3');
    });

    test('数字与变量的写法', () {
      expect(latex('3.5'), '3.5');
      expect(latex('2pi'), r'2 \cdot \pi');
      expect(latex('e^x'), 'e^{x}', reason: 'e 按常量直接写成 e');
      expect(latex('ans + 1'), r'\mathrm{ans} + 1');
      expect(latex('alpha1'), r'\mathrm{alpha1}', reason: '多字母标识符用 \\mathrm');
    });
  });

  group('LaTeX：函数', () {
    test('三角与对数', () {
      expect(latex('sin(30)'), r'\sin\left(30\right)');
      expect(latex('asin(x)'), r'\arcsin\left(x\right)');
      expect(latex('ln(x)'), r'\ln\left(x\right)');
      expect(latex('log(8, 2)'), r'\log_{2}\left(8\right)');
      expect(latex('log2(8)'), r'\log_{2}\left(8\right)');
      expect(latex('lg(x)'), r'\log_{10}\left(x\right)');
      expect(latex('atan2(1, 1)'), r'\operatorname{atan2}\left(1, 1\right)');
    });

    test('根式、绝对值与取整', () {
      expect(latex('sqrt(2)'), r'\sqrt{2}');
      expect(latex('cbrt(x)'), r'\sqrt[3]{x}');
      expect(latex('root(8, 3)'), r'\sqrt[3]{8}');
      expect(latex('abs(-3)'), r'\left|-3\right|');
      expect(latex('floor(x)'), r'\left\lfloor x \right\rfloor');
      expect(latex('ceil(x)'), r'\left\lceil x \right\rceil');
      expect(latex('gamma(4)'), r'\Gamma\left(4\right)');
    });

    test('组合数与自定义函数名', () {
      expect(latex('ncr(5, 2)'), r'\binom{5}{2}');
      expect(latex('gcd(12, 18)'), r'\operatorname{gcd}\left(12, 18\right)');
    });

    test('特殊形式：求和 / 连乘 / 积分 / 求导', () {
      expect(latex('sum(x^2, x, 1, 10)'), r'\sum_{x=1}^{10} x^{2}');
      expect(latex('prod(1/x, x, 1, 5)'), r'\prod_{x=1}^{5} \frac{1}{x}');
      expect(latex('integrate(x^2, x, 0, 1)'), r'\int_{0}^{1} x^{2}\,dx');
      expect(
        latex('diff(x^2, x, 3)'),
        r'\left.\frac{d}{dx}\left(x^{2}\right)\right|_{x=3}',
      );
    });
  });

  group('LaTeX：异常输入', () {
    test('空表达式与语法错误返回 null', () {
      expect(tryExpressionToLatex(''), isNull);
      expect(tryExpressionToLatex('   '), isNull);
      expect(tryExpressionToLatex('1+'), isNull);
      expect(tryExpressionToLatex('sin('), isNull);
    });
  });

  group('LaTeX：绘图曲线', () {
    PlotFunction make(
      String expression, {
      PlotMode mode = PlotMode.cartesian,
      String secondExpression = '',
    }) => PlotFunction(
      id: 'f1',
      color: const Color(0xFF66CCFF),
      mode: mode,
      expression: expression,
      secondExpression: secondExpression,
    );

    test('直角坐标 / 极坐标 / 隐式方程', () {
      expect(make('x^2').toLatex(), r'y = x^{2}');
      expect(
        make('1-cos(t)', mode: PlotMode.polar).toLatex(),
        r'r = 1 - \cos\left(t\right)',
      );
      expect(
        make('x^2+y^2-1', mode: PlotMode.implicit).toLatex(),
        r'0 = x^{2} + y^{2} - 1',
      );
    });

    test('参数方程用 cases 环境', () {
      expect(
        make(
          'cos(t)',
          mode: PlotMode.parametric,
          secondExpression: 'sin(t)',
        ).toLatex(),
        r'\begin{cases} x = \cos\left(t\right) \\ y = \sin\left(t\right) \end{cases}',
      );
    });

    test('表达式不完整时返回 null', () {
      expect(make('').toLatex(), isNull);
      expect(make('1+').toLatex(), isNull);
      expect(make('cos(t)', mode: PlotMode.parametric).toLatex(), isNull);
    });
  });
}
