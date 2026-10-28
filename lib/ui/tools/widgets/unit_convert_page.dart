import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/number_format.dart';
import '../../../theme/app_theme.dart';
import '../unit_catalog.dart';
import 'tool_field.dart';
import 'tool_select.dart';

/// 通用单位换算页：长度 / 面积 / 重量 / 容量 / 温度 / 速度共用一套界面。
///
/// 顶部是可折叠的「常见 XX」参照物，下面「计量体系 / 单位 / 数值」输入；
/// 结果按体系分成 tab（温度只有公制与英制两个），切 tab 不改变输入，
/// 点任意一行即可复制。
class UnitConvertPage extends StatefulWidget {
  const UnitConvertPage({
    super.key,
    required this.catalog,
    required this.title,
    required this.icon,
  });

  /// 单位表与参照物。
  final MeasureCatalog catalog;

  /// 页面标题，如「长度换算」。
  final String title;

  /// 空状态图标，沿用工具卡片的图标。
  final IconData icon;

  @override
  State<UnitConvertPage> createState() => _UnitConvertPageState();
}

class _UnitConvertPageState extends State<UnitConvertPage>
    with SingleTickerProviderStateMixin {
  /// 输入单位，取单位表里配置的默认单位。
  late MeasureUnit _from = widget.catalog.defaultUnit;

  final TextEditingController _value = TextEditingController(text: '1');

  /// 「常见 XX」默认展开，点标题行可折叠起来省空间。
  bool _samplesExpanded = true;

  /// 结果 tab，跟输入单位所在体系联动。
  late final TabController _tabs = TabController(
    length: widget.catalog.systems.length,
    vsync: this,
  )..addListener(_onTabChanged);

  @override
  void dispose() {
    _tabs
      ..removeListener(_onTabChanged)
      ..dispose();
    _value.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // 指示器动画期间也要重绘内容，避免 tab 已切换但列表还停在上一组
    if (mounted) setState(() {});
  }

  MeasureCatalog get _catalog => widget.catalog;

  double? get _amount {
    final value = double.tryParse(_value.text);
    if (value == null || !value.isFinite) return null;
    return value;
  }

  /// 当前单位所在体系。
  MeasureSystem get _system => _from.system;

  /// 当前展示的结果体系（由 tab 决定）。
  MeasureSystem get _tabSystem => _catalog.systems[_tabs.index];

  /// 把体系切到 [system] 对应的 tab。
  int _tabIndexOf(MeasureSystem system) {
    final index = _catalog.systems.indexOf(system);
    return index < 0 ? 0 : index;
  }

  void _switchSystem(MeasureSystem system) {
    if (system == _system) return;
    // 切体系时落到该体系的第一个单位；数值保持不变，配合参照物更快
    setState(() {
      _from = _catalog.unitsOf(system).first;
      _tabs.index = _tabIndexOf(system);
    });
  }

  void _selectUnit(MeasureUnit unit) {
    setState(() {
      _from = unit;
      _tabs.index = _tabIndexOf(unit.system);
    });
  }

  /// 点击参照物：把数值与单位一起代入。
  void _applySample(MeasureSample sample) {
    final unit = _catalog.unitOfSample(sample);
    if (unit == null) return;
    setState(() {
      _from = unit;
      _value.text = _trim(sample.value);
      _tabs.index = _tabIndexOf(unit.system);
    });
  }

  Future<void> _copy(MeasureUnit unit, String text) async {
    await Clipboard.setData(ClipboardData(text: '$text ${unit.label}'));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已复制 $text ${unit.label}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = _amount;
    final systems = _catalog.systems;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 660),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_catalog.samples.isNotEmpty) ...[
                  _SamplesCard(
                    catalog: _catalog,
                    expanded: _samplesExpanded,
                    onToggle: () =>
                        setState(() => _samplesExpanded = !_samplesExpanded),
                    onPick: _applySample,
                  ),
                  const SizedBox(height: 12),
                ],
                ToolSection(
                  title: '输入',
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ToolSelect<MeasureSystem>(
                              key: Key('${_catalog.id}-system'),
                              label: '计量体系',
                              value: _system,
                              items: systems,
                              labelOf: (system) => system.label,
                              onChanged: _switchSystem,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: ToolSelect<MeasureUnit>(
                              key: Key('${_catalog.id}-unit'),
                              label: '单位',
                              value: _from,
                              items: _catalog.unitsOf(_system),
                              labelOf: _unitLabel,
                              onChanged: _selectUnit,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ToolNumberField(
                        label: '数值',
                        suffix: _from.symbol,
                        controller: _value,
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_from.note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _from.note,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (amount == null)
                  ToolSection(child: _EmptyHint(icon: widget.icon))
                else
                  ToolSection(
                    title: '换算结果',
                    icon: Icons.swap_horiz_rounded,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${formatNumber(amount, significantDigits: 10)} '
                          '${_from.label}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 24,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 6),
                        _SystemTabs(controller: _tabs, systems: systems),
                        const SizedBox(height: 2),
                        for (final unit in _catalog.unitsOf(_tabSystem))
                          _ResultRow(
                            unit: unit,
                            text: _format(
                              _catalog.convert(amount, from: _from, to: unit),
                            ),
                            highlighted: unit == _from,
                            onTap: () => _copy(
                              unit,
                              _format(
                                _catalog.convert(amount, from: _from, to: unit),
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          '点任意一行即可复制 · 统一以${_catalog.baseName}为基准',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 下拉项文案：中文名后带符号，符号与名称相同时（市制单位）只显示名称。
  static String _unitLabel(MeasureUnit unit) =>
      unit.symbol == unit.label ? unit.label : '${unit.label}（${unit.symbol}）';

  static String _format(double? value) =>
      value == null ? '—' : formatNumber(value, significantDigits: 10);
}

/// 去掉整数末尾的 `.0`，用于把参照物数值回填到输入框。
String _trim(double value) {
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toStringAsFixed(0);
  }
  return value.toString();
}

/// 常见参照物：默认展开，点标题行折叠 / 展开。
class _SamplesCard extends StatelessWidget {
  const _SamplesCard({
    required this.catalog,
    required this.expanded,
    required this.onToggle,
    required this.onPick,
  });

  final MeasureCatalog catalog;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<MeasureSample> onPick;

  @override
  Widget build(BuildContext context) {
    return ToolSection(
      key: Key('${catalog.id}-samples'),
      title: '常见${catalog.name}',
      icon: Icons.lightbulb_outline_rounded,
      onHeaderTap: onToggle,
      padding: EdgeInsets.fromLTRB(14, 12, 14, expanded ? 14 : 12),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            expanded ? '收起' : '展开',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
          ),
          Icon(
            expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
        ],
      ),
      child: expanded
          ? Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final sample in catalog.samples)
                  ActionChip(
                    label: Text(
                      sample.label,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    visualDensity: VisualDensity.compact,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    onPressed: () => onPick(sample),
                  ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

/// 结果区的体系 tab：公制 / 英制 / 市制（温度只有前两个）。
class _SystemTabs extends StatelessWidget {
  const _SystemTabs({required this.controller, required this.systems});

  final TabController controller;
  final List<MeasureSystem> systems;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.primary,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 2,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelPadding: EdgeInsets.zero,
      tabs: [for (final system in systems) Tab(height: 34, text: system.label)],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.unit,
    required this.text,
    required this.highlighted,
    required this.onTap,
  });

  final MeasureUnit unit;
  final String text;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                unit.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: highlighted
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: highlighted
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontSize: 13.5,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: 32,
              child: Text(
                unit.symbol,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Column(
        children: [
          Icon(icon, size: 30, color: AppColors.outline),
          const SizedBox(height: 10),
          Text(
            '填入数值并选好单位后自动换算',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
