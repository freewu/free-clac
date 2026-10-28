import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_i18n.dart';
import '../../l10n/plot_strings.dart';
import '../../plot/plot_export.dart';
import '../../services/plot_file_saver.dart';
import '../../state/plot_controller.dart';
import '../../theme/app_theme.dart';

/// 保存回调：默认写磁盘 / 下载，测试时可替换。
typedef PlotExportSaver = Future<SavedPlotFile> Function(PlotExportFile file);

/// 打开导出对话框，成功保存后用 SnackBar 告知文件位置。
Future<void> showPlotExportDialog(
  BuildContext context,
  PlotController controller, {
  PlotExportSaver? saver,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final saved = await showDialog<SavedPlotFile>(
    context: context,
    builder: (_) => PlotExportDialog(controller: controller, saver: saver),
  );
  if (saved == null) return;
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(fill(plotStrings.saved, [saved.fullPath])),
        duration: const Duration(seconds: 4),
        action: saved.canReveal
            ? SnackBarAction(
                label: plotStrings.openFolder,
                onPressed: () => revealSavedPlotFile(saved),
              )
            : null,
      ),
    );
}

/// 导出图片对话框：选择 PNG / SVG / WebP，按当前视口重新渲染。
class PlotExportDialog extends StatefulWidget {
  const PlotExportDialog({
    super.key,
    required this.controller,
    this.saver,
    this.exporter = const PlotExporter(),
  });

  final PlotController controller;
  final PlotExportSaver? saver;

  /// 渲染器：决定位图倍率与 WebP 质量（测试时可替换）。
  final PlotExporter exporter;

  @override
  State<PlotExportDialog> createState() => _PlotExportDialogState();
}

class _PlotExportDialogState extends State<PlotExportDialog> {
  PlotImageFormat _format = PlotImageFormat.png;
  bool _busy = false;
  String? _error;

  Size get _size => widget.controller.canvasSize;

  /// 倍率文本：2 显示为 `2`，1.5 保留小数。
  String get _ratioText {
    final ratio = widget.exporter.pixelRatio;
    return ratio == ratio.roundToDouble()
        ? ratio.round().toString()
        : ratio.toString();
  }

  /// 格式按钮上的短名称（PNG / SVG / WebP 本身不翻译）。
  String _formatLabel(PlotImageFormat format) => format.label;

  /// 格式下面的一行说明。
  String _formatNote(PlotImageFormat format) => switch (format) {
    PlotImageFormat.png => plotStrings.notePng,
    PlotImageFormat.webp => plotStrings.noteWebp,
    PlotImageFormat.svg => plotStrings.noteSvg,
  };

  String get _pixelText {
    final width = (_size.width * widget.exporter.pixelRatio).round();
    final height = (_size.height * widget.exporter.pixelRatio).round();
    return '$width × $height';
  }

  Future<void> _save() async {
    final navigator = Navigator.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final file = await widget.exporter.export(
        controller: widget.controller,
        size: _size,
        format: _format,
        title: plotStrings.svgTitle,
      );
      final save = widget.saver ?? savePlotExportFile;
      final saved = await save(file);
      if (!mounted) return;
      navigator.pop(saved);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = fill(plotStrings.exportFailed, [error]);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final samples = widget.controller.buildSamples(_size);
    final expressions = describeSamples(
      samples,
      empty: plotStrings.noVisibleCurves,
    );
    final viewportText = describeViewport(widget.controller.viewport);
    return AlertDialog(
      backgroundColor: AppColors.surface,
      titlePadding: const EdgeInsets.fromLTRB(22, 20, 16, 0),
      contentPadding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
      actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      title: Row(
        children: [
          Icon(Icons.image_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              plotStrings.exportTitle,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            tooltip: plotStrings.close,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, size: 18),
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<PlotImageFormat>(
              segments: [
                for (final format in PlotImageFormat.values)
                  ButtonSegment(
                    value: format,
                    label: Text(_formatLabel(format)),
                  ),
              ],
              selected: {_format},
              showSelectedIcon: false,
              onSelectionChanged: _busy
                  ? null
                  : (selection) => setState(() => _format = selection.first),
            ),
            const SizedBox(height: 12),
            Text(
              _formatNote(_format),
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.aspect_ratio_rounded,
              label: _format.isVector
                  ? plotStrings.vectorSize
                  : plotStrings.imageSize,
              value: _format.isVector
                  ? fill(plotStrings.vectorSizeValue, [
                      _size.width.round(),
                      _size.height.round(),
                    ])
                  : fill(plotStrings.rasterSizeValue, [_pixelText, _ratioText]),
            ),
            _InfoRow(
              icon: Icons.grid_4x4_rounded,
              label: plotStrings.viewportLabel,
              value: viewportText,
            ),
            _InfoRow(
              icon: Icons.show_chart_rounded,
              label: plotStrings.curvesLabel,
              value: expressions,
            ),
            _InfoRow(
              icon: Icons.folder_open_rounded,
              label: plotStrings.saveLocation,
              value: plotSaveLocationNote(),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(plotStrings.cancel),
        ),
        FilledButton.icon(
          onPressed: _busy ? null : _save,
          icon: _busy
              ? const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(kIsWeb ? plotStrings.download : plotStrings.save),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
