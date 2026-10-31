import 'package:flutter/material.dart';

import '../../../core/number_format.dart';
import '../../../l10n/app_i18n.dart';
import '../../../l10n/money.dart';
import '../../../state/settings_controller.dart';
import '../../../state/app_appearance.dart';
import '../../../theme/app_theme.dart';
import '../tool_draft.dart';
import '../widgets/tool_field.dart';
import 'hourly.dart';
import 'hourly_strings.dart';

/// 时薪计算页：月薪 ÷ (工作天数 × 每日工作时长)，结果可存进历史与当前对比。
class HourlyPage extends StatefulWidget {
  const HourlyPage({super.key});

  @override
  State<HourlyPage> createState() => _HourlyPageState();
}

class _HourlyPageState extends State<HourlyPage> with AppAppearanceAware {
  /// 上次填的月薪、每日工作时长与工作日制度。
  final ToolDraft _draft = ToolDraft('hourly');

  late final TextEditingController _salary = _draft.controller(
    'salary',
    '10000',
  );
  late final TextEditingController _hours = _draft.controller('hours', '8');

  late WorkSchedule _schedule =
      _draft.enumOf('schedule', WorkSchedule.values) ?? WorkSchedule.standard;

  /// 历史记录，最近的在前；持久化交给 `SettingsController.toolHistory`。
  late List<HourlyRecord> _records = _loadRecords();

  @override
  void dispose() {
    _salary.dispose();
    _hours.dispose();
    super.dispose();
  }

  List<HourlyRecord> _loadRecords() {
    final raw = currentSettings?.toolHistoryOf('hourly') ?? const <String>[];
    return <HourlyRecord>[for (final line in raw) ?HourlyRecord.decode(line)];
  }

  double _parse(TextEditingController controller) =>
      double.tryParse(controller.text) ?? 0;

  HourlyResult? get _result => calculateHourly(
    monthlySalary: _parse(_salary),
    schedule: _schedule,
    hoursPerDay: _parse(_hours),
  );

  void _toast(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _save(HourlyResult result) async {
    final s = hourlyStrings;
    final record = HourlyRecord.fromResult(result);
    if (_records.isNotEmpty && _records.first.sameInputAs(record)) {
      _toast(s.alreadySaved);
      return;
    }
    final settings = currentSettings;
    if (settings == null) {
      setState(() {
        _records = <HourlyRecord>[
          record,
          ..._records,
        ].take(hourlyHistoryLimit).toList();
      });
    } else {
      await settings.addToolHistory(
        'hourly',
        record.encode(),
        limit: hourlyHistoryLimit,
      );
      if (!mounted) return;
      setState(() => _records = _loadRecords());
    }
    _toast(s.savedHint);
  }

  Future<void> _removeRecord(int index) async {
    final settings = currentSettings;
    if (settings == null) {
      setState(() => _records = <HourlyRecord>[..._records]..removeAt(index));
      return;
    }
    await settings.removeToolHistory('hourly', index);
    if (!mounted) return;
    setState(() => _records = _loadRecords());
  }

  Future<void> _clearRecords() async {
    final s = hourlyStrings;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceHigher,
        title: Text(s.clearConfirmTitle, style: const TextStyle(fontSize: 16)),
        content: Text(
          s.clearConfirmBody,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            key: const Key('hourly-clear-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              s.clearConfirmAction,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _records = const <HourlyRecord>[]);
    await currentSettings?.clearToolHistory('hourly');
  }

  /// 把一条历史记录填回输入框，方便在当前结果上继续微调。
  void _restoreRecord(HourlyRecord record) {
    setState(() {
      _salary.text = formatNumber(record.monthlySalary, significantDigits: 12);
      _hours.text = formatNumber(record.hoursPerDay, significantDigits: 12);
      _schedule = record.schedule;
    });
    _draft.setEnum('schedule', record.schedule);
    _toast(hourlyStrings.restoredHint);
  }

  @override
  Widget build(BuildContext context) {
    final s = hourlyStrings;
    final result = _result;
    return Scaffold(
      appBar: AppBar(
        title: Text(s.title),
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
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ToolSection(
                  title: s.sectionInput,
                  icon: Icons.schedule_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ToolNumberField(
                        key: const Key('hourly-salary'),
                        label: s.salary,
                        suffix: currencySymbol,
                        controller: _salary,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      ToolNumberField(
                        key: const Key('hourly-hours'),
                        label: s.hoursPerDay,
                        suffix: s.hoursPerDaySuffix,
                        controller: _hours,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.schedule,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final schedule in WorkSchedule.values)
                            ChoiceChip(
                              key: Key('hourly-schedule-${schedule.code}'),
                              label: Text(
                                fill(s.scheduleOption, [
                                  s.scheduleLabel(schedule),
                                  formatNumber(
                                    schedule.daysPerMonth,
                                    significantDigits: 4,
                                  ),
                                ]),
                                style: const TextStyle(fontSize: 11.5),
                              ),
                              selected: _schedule == schedule,
                              onSelected: (_) {
                                _draft.setEnum('schedule', schedule);
                                setState(() => _schedule = schedule);
                              },
                              visualDensity: VisualDensity.compact,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  key: const Key('hourly-result'),
                  child: result == null
                      ? const _EmptyHint()
                      : _ResultBody(
                          result: result,
                          onSave: () => _save(result),
                        ),
                ),
                const SizedBox(height: 12),
                ToolSection(
                  key: const Key('hourly-history'),
                  title: s.sectionHistory,
                  icon: Icons.history_rounded,
                  trailing: _records.isEmpty
                      ? null
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              fill(s.historyCount, [_records.length]),
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              key: const Key('hourly-clear'),
                              onPressed: _clearRecords,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 30),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                foregroundColor: AppColors.textSecondary,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                s.clearAll,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ],
                        ),
                  child: _records.isEmpty
                      ? const _HistoryEmpty()
                      : _RecordList(
                          records: _records,
                          current: result,
                          onRestore: _restoreRecord,
                          onDelete: _removeRecord,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(Icons.payments_outlined, size: 30, color: AppColors.outline),
          const SizedBox(height: 10),
          Text(
            hourlyStrings.emptyHint,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmpty extends StatelessWidget {
  const _HistoryEmpty();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        hourlyStrings.historyEmpty,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          height: 1.6,
        ),
      ),
    );
  }
}

/// 结果卡片：时薪大头数字 + 月工时 / 日薪 + 记一笔按钮 + 公式说明。
class _ResultBody extends StatelessWidget {
  const _ResultBody({required this.result, required this.onSave});

  final HourlyResult result;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final s = hourlyStrings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          s.hourlyLabel,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: Text(
                money(result.hourly),
                key: const Key('hourly-value'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 30,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 5),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                s.hourlySuffix,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          fill(s.breakdown, [
            money(result.monthlySalary, decimals: 0),
            formatNumber(result.workDays, significantDigits: 4),
            formatNumber(result.hoursPerDay, significantDigits: 4),
            formatNumber(result.monthlyHours, significantDigits: 6),
          ]),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: s.monthlyHours,
                value: fill(s.hoursValue, [
                  formatNumber(result.monthlyHours, significantDigits: 6),
                ]),
              ),
            ),
            Expanded(
              child: _Stat(label: s.dailyWage, value: money(result.dailyWage)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          key: const Key('hourly-save'),
          onPressed: onSave,
          icon: const Icon(Icons.bookmark_add_outlined, size: 18),
          label: Text(s.save),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 42),
            textStyle: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          s.formulaNote,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 10.5,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// 历史记录列表：每行一条，右侧的角标标出与当前时薪的差距。
class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.records,
    required this.current,
    required this.onRestore,
    required this.onDelete,
  });

  final List<HourlyRecord> records;

  /// 当前输入算出的结果，为空时不显示对比角标。
  final HourlyResult? current;

  final ValueChanged<HourlyRecord> onRestore;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < records.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _RecordRow(
            key: Key('hourly-record-$i'),
            index: i,
            record: records[i],
            current: current,
            onTap: () => onRestore(records[i]),
            onDelete: () => onDelete(i),
          ),
        ],
      ],
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    super.key,
    required this.index,
    required this.record,
    required this.current,
    required this.onTap,
    required this.onDelete,
  });

  final int index;
  final HourlyRecord record;
  final HourlyResult? current;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final s = hourlyStrings;
    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 9, 4, 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            money(record.hourly),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          s.hourlySuffix,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (current != null)
                          _DeltaBadge(
                            key: Key('hourly-delta-$index'),
                            delta: record.hourly - current!.hourly,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fill(s.recordMeta, [
                        money(record.monthlySalary, decimals: 0),
                        s.scheduleLabel(record.schedule),
                        formatNumber(record.hoursPerDay, significantDigits: 4),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTime(record.savedAt),
                      style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                key: Key('hourly-delete-$index'),
                onPressed: onDelete,
                tooltip: s.deleteTooltip,
                icon: const Icon(Icons.close_rounded, size: 16),
                color: AppColors.textSecondary,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 「比当前高 / 低多少」的角标。
class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({super.key, required this.delta});

  /// 记录时薪 − 当前时薪。
  final double delta;

  @override
  Widget build(BuildContext context) {
    final s = hourlyStrings;
    final (text, color) = switch (delta) {
      > 0.004 => (fill(s.compareHigher, [money(delta)]), AppColors.tertiary),
      < -0.004 => (fill(s.compareLower, [money(-delta)]), AppColors.error),
      _ => (s.compareSame, AppColors.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// `10/30 09:12` 这样的时间戳（按本地时区，各语言都用数字）。
String _formatTime(DateTime at) {
  String two(int value) => value < 10 ? '0$value' : '$value';
  return '${at.month}/${at.day} ${two(at.hour)}:${two(at.minute)}';
}
