import 'package:flutter/material.dart';

import '../../state/calculator_controller.dart';
import '../../theme/app_theme.dart';

enum _KeyKind { digit, operator, function, action, accent, toggle }

class _Key {
  const _Key(
    this.label, {
    this.secondaryLabel,
    this.insert,
    this.secondaryInsert,
    this.kind = _KeyKind.function,
  });

  final String label;
  final String? secondaryLabel;
  final String? insert;
  final String? secondaryInsert;
  final _KeyKind kind;
}

/// 科学计算器键盘。
class Keypad extends StatelessWidget {
  const Keypad({super.key, required this.controller});

  final CalculatorController controller;

  static const List<List<_Key>> _rows = [
    [
      _Key('2nd', kind: _KeyKind.toggle, secondaryLabel: '2nd'),
      _Key(
        'sin',
        secondaryLabel: 'sin⁻¹',
        insert: 'sin(',
        secondaryInsert: 'asin(',
      ),
      _Key(
        'cos',
        secondaryLabel: 'cos⁻¹',
        insert: 'cos(',
        secondaryInsert: 'acos(',
      ),
      _Key(
        'tan',
        secondaryLabel: 'tan⁻¹',
        insert: 'tan(',
        secondaryInsert: 'atan(',
      ),
      _Key('AC', kind: _KeyKind.action),
      _Key('⌫', kind: _KeyKind.action),
    ],
    [
      _Key(
        'x²',
        secondaryLabel: 'x³',
        insert: '^2',
        secondaryInsert: '^3',
        kind: _KeyKind.operator,
      ),
      _Key(
        'xʸ',
        secondaryLabel: 'ʸ√x',
        insert: '^',
        secondaryInsert: 'root(',
        kind: _KeyKind.operator,
      ),
      _Key(
        '√',
        secondaryLabel: '∛',
        insert: 'sqrt(',
        secondaryInsert: 'cbrt(',
        kind: _KeyKind.operator,
      ),
      _Key('ln', secondaryLabel: 'eˣ', insert: 'ln(', secondaryInsert: 'exp('),
      _Key(
        'log',
        secondaryLabel: '10ˣ',
        insert: 'log(',
        secondaryInsert: '10^',
      ),
      _Key('÷', insert: '/', kind: _KeyKind.operator),
    ],
    [
      _Key('(', insert: '('),
      _Key(')', insert: ')'),
      _Key(
        'π',
        secondaryLabel: 'τ',
        insert: 'pi',
        secondaryInsert: 'tau',
        kind: _KeyKind.operator,
      ),
      _Key(
        'e',
        secondaryLabel: 'φ',
        insert: 'e',
        secondaryInsert: 'phi',
        kind: _KeyKind.operator,
      ),
      _Key(
        'x',
        secondaryLabel: 't',
        insert: 'x',
        secondaryInsert: 't',
        kind: _KeyKind.operator,
      ),
      _Key('*', insert: '*', kind: _KeyKind.operator),
    ],
    [
      _Key('7', insert: '7', kind: _KeyKind.digit),
      _Key('8', insert: '8', kind: _KeyKind.digit),
      _Key('9', insert: '9', kind: _KeyKind.digit),
      _Key(
        '1/x',
        secondaryLabel: '|x|',
        insert: '1/(',
        secondaryInsert: 'abs(',
      ),
      _Key(
        '%',
        secondaryLabel: 'x!',
        insert: '%',
        secondaryInsert: '!',
        kind: _KeyKind.operator,
      ),
      _Key('−', insert: '-', kind: _KeyKind.operator),
    ],
    [
      _Key('4', insert: '4', kind: _KeyKind.digit),
      _Key('5', insert: '5', kind: _KeyKind.digit),
      _Key('6', insert: '6', kind: _KeyKind.digit),
      _Key('ans', secondaryLabel: 'mem', insert: 'ans', secondaryInsert: 'mem'),
      _Key(',', secondaryLabel: 'nCr', insert: ',', secondaryInsert: 'ncr('),
      _Key('+', insert: '+', kind: _KeyKind.operator),
    ],
    [
      _Key('1', insert: '1', kind: _KeyKind.digit),
      _Key('2', insert: '2', kind: _KeyKind.digit),
      _Key('3', insert: '3', kind: _KeyKind.digit),
      _Key('0', insert: '0', kind: _KeyKind.digit),
      _Key('.', insert: '.', kind: _KeyKind.digit),
      _Key('=', kind: _KeyKind.accent),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final second = controller.secondActive;
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = _rows;
        final rowHeight = constraints.maxHeight / rows.length;
        final fontSize = (rowHeight * 0.34).clamp(13.0, 22.0);
        return Column(
          children: [
            for (var i = 0; i < rows.length; i++)
              Expanded(
                child: Row(
                  children: [
                    for (var j = 0; j < rows[i].length; j++)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(3),
                          child: _buildKey(
                            context,
                            rows[i][j],
                            second,
                            fontSize,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildKey(
    BuildContext context,
    _Key key,
    bool second,
    double fontSize,
  ) {
    final useSecondary = second && key.secondaryLabel != null;
    final label = useSecondary ? key.secondaryLabel! : key.label;
    final insert = useSecondary ? key.secondaryInsert : key.insert;

    VoidCallback onTap;
    if (key.kind == _KeyKind.toggle) {
      onTap = controller.toggleSecond;
    } else if (key.label == 'AC') {
      onTap = controller.clear;
    } else if (key.label == '⌫') {
      onTap = controller.backspace;
    } else if (key.label == '=') {
      onTap = controller.evaluate;
    } else {
      onTap = () {
        if (insert != null) controller.insert(insert);
      };
    }

    final activeToggle = key.kind == _KeyKind.toggle && controller.secondActive;
    return _KeyButton(
      label: label,
      kind: key.kind,
      fontSize: fontSize,
      active: activeToggle,
      onTap: onTap,
    );
  }
}

class _KeyButton extends StatefulWidget {
  const _KeyButton({
    required this.label,
    required this.kind,
    required this.fontSize,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final _KeyKind kind;
  final double fontSize;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_KeyButton> createState() => _KeyButtonState();
}

class _KeyButtonState extends State<_KeyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = _colors();
    return AnimatedScale(
      scale: _pressed ? 0.95 : 1,
      duration: const Duration(milliseconds: 90),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: widget.kind == _KeyKind.accent
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.secondary],
                )
              : null,
          color: widget.kind == _KeyKind.accent ? null : background,
          border: Border.all(
            color: widget.active
                ? AppColors.primary
                : AppColors.outline.withValues(alpha: 0.55),
            width: widget.active ? 1.4 : 1,
          ),
          boxShadow: widget.kind == _KeyKind.accent
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: widget.fontSize,
                      fontWeight: widget.kind == _KeyKind.digit
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: widget.active
                          ? AppColors.primary
                          : (widget.kind == _KeyKind.accent
                                ? const Color(0xFF04101F)
                                : foreground),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _colors() {
    switch (widget.kind) {
      case _KeyKind.digit:
        return (AppColors.surfaceHigh, AppColors.textPrimary);
      case _KeyKind.operator:
        return (const Color(0xFF1D2839), AppColors.primary);
      case _KeyKind.function:
        return (AppColors.surface, AppColors.textSecondary);
      case _KeyKind.action:
        return (AppColors.surfaceHigher, AppColors.textPrimary);
      case _KeyKind.accent:
        return (AppColors.primary, const Color(0xFF04101F));
      case _KeyKind.toggle:
        return (AppColors.surfaceHigh, AppColors.secondary);
    }
  }
}
