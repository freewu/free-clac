import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/number_format.dart';
import '../../plot/plot_painter.dart';
import '../../plot/plot_viewport.dart';
import '../../state/plot_controller.dart';
import '../../theme/app_theme.dart';

/// 绘图画布：支持拖拽 / 方向键平移、滚轮 / 捏合缩放、悬停追踪。
///
/// 快捷键（画布获得焦点时生效）：← → ↑ ↓ 移动视图，`+` / `-` 缩放，`0` 重置。
class PlotCanvas extends StatefulWidget {
  const PlotCanvas({super.key, required this.controller});

  final PlotController controller;

  @override
  State<PlotCanvas> createState() => _PlotCanvasState();
}

class _PlotCanvasState extends State<PlotCanvas> {
  Size _cachedSize = Size.zero;
  PlotViewport? _cachedViewport;
  int _cachedRevision = -1;
  List<PlotSample> _samples = const <PlotSample>[];

  PlotViewport? _gestureViewport;
  Offset _gestureFocal = Offset.zero;
  bool _initialized = false;

  final FocusNode _focusNode = FocusNode(debugLabel: 'plot-canvas');

  PlotController get controller => widget.controller;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 每次平移 / 缩放移动视图的比例（相对画布宽高）。
  static const double _panStep = 0.22;

  /// [fx] > 0 向左看，[fy] > 0 向上看。
  void _pan(double fx, double fy, Size size) {
    controller.panByFraction(fx, fy, size);
  }

  void _ensureSamples(Size size, PlotViewport viewport) {
    if (size == _cachedSize &&
        viewport == _cachedViewport &&
        controller.revision == _cachedRevision) {
      return;
    }
    _samples = controller.buildSamples(size);
    _cachedSize = size;
    _cachedViewport = viewport;
    _cachedRevision = controller.revision;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        if (!_initialized && size.width > 0) {
          _initialized = true;
          // 载入示例时已给出合适视口，首次布局不要重置。
          if (!controller.consumeViewportPin()) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) controller.resetView(size);
            });
          }
        }

        controller.reportCanvasSize(size);
        final viewport = controller.viewport;
        _ensureSamples(size, viewport);
        final trace = controller.trace;
        final traceValues = trace == null
            ? const <TraceValue>[]
            : controller.traceValues(trace.dx, y: trace.dy);
        final traceDots = <TraceDot>[
          for (final value in traceValues)
            if (value.point != null && viewport.containsData(value.point!))
              TraceDot(position: value.point!, color: value.function.color),
        ];

        final canvas = Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final factor = math.pow(1.0018, -event.scrollDelta.dy).toDouble();
              controller.zoomAtPixel(event.localPosition, factor, size);
            } else if (event is PointerScaleEvent) {
              controller.zoomAtPixel(event.localPosition, event.scale, size);
            }
          },
          onPointerHover: (event) {
            if (controller.traceEnabled) return;
            controller.setTrace(
              controller.viewport.toData(event.localPosition, size),
            );
          },
          child: MouseRegion(
            cursor: controller.traceEnabled
                ? SystemMouseCursors.precise
                : SystemMouseCursors.grab,
            onExit: (_) {
              if (!controller.traceEnabled) controller.setTrace(null);
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) {
                // 让画布拿到键盘焦点，方向键才能平移视图。
                _focusNode.requestFocus();
              },
              onScaleStart: (details) {
                _focusNode.requestFocus();
                _gestureViewport = controller.viewport;
                _gestureFocal = details.localFocalPoint;
              },
              onScaleUpdate: (details) {
                final start = _gestureViewport;
                if (start == null) return;
                if (controller.traceEnabled) {
                  controller.setTrace(
                    start.toData(details.localFocalPoint, size),
                  );
                  return;
                }
                final focus = start.toData(_gestureFocal, size);
                var next = start.zoomedAt(focus, details.scale, size);
                final delta = details.localFocalPoint - _gestureFocal;
                next = next.pannedByPixels(delta, size);
                controller.viewport = next;
              },
              onScaleEnd: (_) => _gestureViewport = null,
              onLongPressStart: (details) {
                controller.setTrace(
                  controller.viewport.toData(details.localPosition, size),
                );
              },
              onLongPressMoveUpdate: (details) {
                controller.setTrace(
                  controller.viewport.toData(details.localPosition, size),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RepaintBoundary(
                        child: CustomPaint(
                          painter: PlotPainter(
                            viewport: viewport,
                            samples: _samples,
                            showGrid: controller.showGrid,
                            trace: trace,
                            traceDots: traceDots,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 10,
                        right: size.width > 520 ? null : 70,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: size.width * 0.66,
                            ),
                            child: _InfoChip(text: _viewportLabel(viewport)),
                          ),
                        ),
                      ),
                      Positioned(right: 10, top: 10, child: _buildAngleChip()),
                      Positioned(
                        right: 10,
                        bottom: 10,
                        child: _buildViewControls(size),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: math.max(80, size.width - 130),
                          ),
                          child: _buildLegend(),
                        ),
                      ),
                      if (trace != null)
                        _buildTraceCard(trace, traceValues, size, viewport),
                      if (controller.functions.isEmpty)
                        const Center(
                          child: Text(
                            '还没有函数，点击右上角“+”添加一条曲线',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        return CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                _pan(_panStep, 0, size),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                _pan(-_panStep, 0, size),
            const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
                _pan(0, _panStep, size),
            const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
                _pan(0, -_panStep, size),
            const SingleActivator(LogicalKeyboardKey.equal): () =>
                controller.zoom(1.4, size),
            const SingleActivator(LogicalKeyboardKey.add): () =>
                controller.zoom(1.4, size),
            const SingleActivator(LogicalKeyboardKey.minus): () =>
                controller.zoom(1 / 1.4, size),
            const SingleActivator(LogicalKeyboardKey.digit0): () =>
                controller.resetView(size),
          },
          child: Focus(focusNode: _focusNode, autofocus: true, child: canvas),
        );
      },
    );
  }

  String _viewportLabel(PlotViewport viewport) {
    return 'x ∈ [${formatTick(viewport.minX, significantDigits: 4)}, '
        '${formatTick(viewport.maxX, significantDigits: 4)}]   '
        'y ∈ [${formatTick(viewport.minY, significantDigits: 4)}, '
        '${formatTick(viewport.maxY, significantDigits: 4)}]';
  }

  Widget _buildAngleChip() {
    final mode = controller.angleMode;
    return _InfoChip(
      text: mode.shortLabel,
      color: AppColors.secondary,
      onTap: () => controller.engine.angleMode = mode.toggled,
    );
  }

  Widget _buildLegend() {
    final entries = _samples
        .where((sample) => sample.function.visible && sample.function.isValid)
        .take(4)
        .toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final sample in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 3,
                decoration: BoxDecoration(
                  color: sample.function.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 5),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Text(
                  sample.function.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// 右下角视图控制：十字方向键移动 + 缩放 / 自适应 / 重置。
  Widget _buildViewControls(Size size) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RoundIconButton(
          icon: Icons.keyboard_arrow_up,
          tooltip: '上移视图（↑）',
          onTap: () => _pan(0, _panStep, size),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundIconButton(
              icon: Icons.keyboard_arrow_left,
              tooltip: '左移视图（←）',
              onTap: () => _pan(_panStep, 0, size),
            ),
            const SizedBox(width: 5),
            _RoundIconButton(
              icon: Icons.restart_alt,
              tooltip: '重置视图（0）',
              onTap: () => controller.resetView(size),
            ),
            const SizedBox(width: 5),
            _RoundIconButton(
              icon: Icons.keyboard_arrow_right,
              tooltip: '右移视图（→）',
              onTap: () => _pan(-_panStep, 0, size),
            ),
          ],
        ),
        _RoundIconButton(
          icon: Icons.keyboard_arrow_down,
          tooltip: '下移视图（↓）',
          onTap: () => _pan(0, -_panStep, size),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundIconButton(
              icon: Icons.add,
              tooltip: '放大（+）',
              onTap: () => controller.zoom(1.4, size),
            ),
            const SizedBox(width: 5),
            _RoundIconButton(
              icon: Icons.remove,
              tooltip: '缩小（-）',
              onTap: () => controller.zoom(1 / 1.4, size),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _RoundIconButton(
          icon: Icons.height,
          tooltip: '纵向自适应',
          onTap: () => controller.fitY(size),
        ),
        const SizedBox(height: 6),
        _RoundIconButton(
          icon: Icons.center_focus_strong,
          tooltip: '显示全部',
          onTap: () => controller.fitAll(size),
        ),
      ],
    );
  }

  Widget _buildTraceCard(
    Offset trace,
    List<TraceValue> values,
    Size size,
    PlotViewport viewport,
  ) {
    final pixel = viewport.toScreen(trace.dx, 0, size);
    final placeLeft = pixel.dx > size.width * 0.55;
    return Positioned(
      top: 46,
      left: placeLeft ? 12 : null,
      right: placeLeft ? null : 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
            boxShadow: const [
              BoxShadow(color: Color(0x66000000), blurRadius: 12),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'x = ${formatNumber(trace.dx, significantDigits: 6)}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              for (final value in values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: value.function.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          value.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textPrimary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text, this.onTap, this.color});

  final String text;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.78),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? AppColors.textSecondary,
              fontSize: 11,
              height: 1.3,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.85),
        shape: const CircleBorder(side: BorderSide(color: AppColors.outline)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: 17, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}
