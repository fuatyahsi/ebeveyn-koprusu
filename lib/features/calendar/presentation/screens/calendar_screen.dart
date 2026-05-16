import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/models/domain_models.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _view = 0; // 0 = month, 1 = list
  bool _loading = false;
  List<CustodyEvent> _events = const [];
  late final DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final events = await AppDataService.fetchCustodyEvents();
      if (!mounted) return;
      setState(() => _events = events);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addEvent({DateTime? initialDate}) async {
    final draft = await showModalBottomSheet<_EventDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AddEventSheet(initialDate: initialDate),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      final event = await AppDataService.addCustodyEvent(
        title: draft.title,
        startAt: draft.startAt,
        endAt: draft.endAt,
        location: draft.location,
      );
      if (!mounted) return;
      setState(() {
        _events = [..._events, event]
          ..sort((a, b) => a.startAt.compareTo(b.startAt));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Takvim kaydi eklendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppDataService.friendlyError(error)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScreenHeader(
            eyebrow: 'Velayet takvimi',
            title: _calendarMonthTitle(_visibleMonth),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _AddButton(onTap: _loading ? null : () => _addEvent()),
                const SizedBox(width: 8),
                _MemoryButton(
                  onTap: () => context.push('/visionary/holiday-memory'),
                ),
                const SizedBox(width: 8),
                _ViewSwitcher(
                  index: _view,
                  onChanged: (v) => setState(() => _view = v),
                ),
              ],
            ),
          ),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const ModuleUsageTip(
                  icon: Icons.calendar_month_outlined,
                  text:
                      'Teslim, görüşme, okul veya özel günleri + ile ya da doğrudan takvimde güne dokunarak ekle. Gün takası gibi mutabık kalınan akışlar da takvime otomatik kayıt düşer.',
                ),
                const SizedBox(height: 12),
                const _Legend(),
                const SizedBox(height: 6),
                AppCard(
                  padding: const EdgeInsets.all(12),
                  child: _MonthGrid(
                    month: _visibleMonth,
                    onDayTap: (date) => _addEvent(initialDate: date),
                  ),
                ),
                const SizedBox(height: 14),
                const SectionLabel(label: 'Yaklasan kayitlar'),
                _UpcomingList(events: _events),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _calendarMonthTitle(DateTime month) {
  final label = DateFormat('MMMM y', 'tr_TR').format(month);
  return label.isEmpty ? '' : '${label[0].toUpperCase()}${label.substring(1)}';
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Takvime ekle',
      child: Material(
        color: AppColors.ink,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 36,
            child: Icon(Icons.add, size: 18, color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}

class _MemoryButton extends StatelessWidget {
  const _MemoryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sıra hafızası',
      child: Material(
        color: AppColors.paperWhite,
        shape: CircleBorder(side: BorderSide(color: AppColors.line)),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 36,
            child: Icon(
              Icons.history_edu_outlined,
              size: 18,
              color: AppColors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewSwitcher extends StatelessWidget {
  const _ViewSwitcher({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 2; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          _SwitchChip(
            label: i == 0 ? 'Ay' : 'Liste',
            active: i == index,
            onTap: () => onChanged(i),
          ),
        ],
      ],
    );
  }
}

class _SwitchChip extends StatelessWidget {
  const _SwitchChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? Colors.transparent : AppColors.line,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.ui(
            size: 11.5,
            weight: FontWeight.w500,
            color: active ? AppColors.paper : AppColors.inkMute,
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget dot(Color c, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: c,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTypography.ui(size: 11, color: AppColors.inkMute),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 6, 4, 14),
      child: Row(
        children: [
          dot(AppColors.sage, 'Anne'),
          const SizedBox(width: 14),
          dot(AppColors.ochre, 'Baba'),
          const SizedBox(width: 14),
          dot(AppColors.ink, 'Teslim'),
          const Spacer(),
          Text(
            '1. VE 3. HAFTA SONU',
            style: AppTypography.mono(letter: 1.4, color: AppColors.inkMute),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({required this.month, required this.onDayTap});

  final DateTime month;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    const weekHeaders = ['P', 'S', 'C', 'P', 'C', 'C', 'P'];
    final firstDay = DateTime(month.year, month.month);
    final leadingDays = firstDay.weekday - 1;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final cells = [
      for (var i = 0; i < cellCount; i++)
        firstDay.add(Duration(days: i - leadingDays)),
    ];

    return Column(
      children: [
        Row(
          children: [
            for (final h in weekHeaders)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style: AppTypography.mono(
                      letter: 1,
                      color: AppColors.inkMute,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          children: [
            for (var i = 0; i < cells.length; i++)
              _DayBox(
                index: i,
                date: cells[i],
                month: month,
                onDayTap: onDayTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({
    required this.index,
    required this.date,
    required this.month,
    required this.onDayTap,
  });
  final int index;
  final DateTime date;
  final DateTime month;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final inMonth = date.year == month.year && date.month == month.month;
    final day = date.day;
    final dow = index % 7;
    final week = index ~/ 7;
    final weekend = dow >= 5;
    final isDad = inMonth && weekend && (week == 0 || week == 2);
    final isToday = inMonth && DateUtils.isSameDay(date, DateTime.now());
    final isHandover = inMonth && [2, 4, 16, 18].contains(day);

    final bg = !inMonth
        ? Colors.transparent
        : isToday
        ? AppColors.ink
        : isDad
        ? AppColors.ochreSoft
        : AppColors.sageSoft;
    final fg = !inMonth
        ? AppColors.ink.withValues(alpha: 0.25)
        : isToday
        ? AppColors.paper
        : isDad
        ? const Color(0xFF7B5B33)
        : AppColors.sage;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        onTap: inMonth ? () => onDayTap(date) : null,
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: AppTypography.ui(
                size: 13,
                color: fg,
                weight: isToday ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isHandover)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? AppColors.paper : AppColors.ink,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList({required this.events});

  final List<CustodyEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return AppCard(
        child: Text(
          'Henüz kayıt yok. Sağ üstteki + ile ilk teslim, görüşme veya okul kaydını ekleyebilirsin.',
          style: AppTypography.ui(size: 13, color: AppColors.inkMute),
        ),
      );
    }

    final visibleEvents = events.take(6).toList();
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < visibleEvents.length; i++) ...[
            _UpcomingRow(event: visibleEvents[i]),
            if (i < visibleEvents.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.event});

  final CustodyEvent event;

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('EEE', 'tr_TR').format(event.startAt);
    final timeLabel = DateFormat('HH:mm', 'tr_TR').format(event.startAt);
    final days = event.startAt.difference(DateTime.now()).inDays;
    final pill = days <= 0 ? 'bugün' : '$days gün';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: AppTypography.display(size: 18, height: 1),
                ),
                const SizedBox(height: 2),
                Text(
                  timeLabel,
                  style: AppTypography.mono(
                    color: AppColors.inkMute,
                    letter: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 1,
            height: 36,
            color: AppColors.line,
            margin: const EdgeInsets.symmetric(horizontal: 14),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  event.location.isEmpty
                      ? event.assignedParent
                      : event.location,
                  style: AppTypography.ui(size: 11.5, color: AppColors.inkMute),
                ),
              ],
            ),
          ),
          AppPill(label: pill, tone: PillTone.ochre),
        ],
      ),
    );
  }
}

class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet({this.initialDate});

  final DateTime? initialDate;

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Teslim kaydı');
  final _locationController = TextEditingController();
  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Takvime ekle', style: AppTypography.display(size: 30)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Baslik'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Baslik zorunlu.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Konum / not'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text(DateFormat('d MMM', 'tr_TR').format(_date)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text(_time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add),
              label: const Text('Kaydi ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('tr'),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final startAt = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    Navigator.of(context).pop(
      _EventDraft(
        title: _titleController.text,
        location: _locationController.text,
        startAt: startAt,
        endAt: startAt.add(const Duration(hours: 1)),
      ),
    );
  }
}

class _EventDraft {
  const _EventDraft({
    required this.title,
    required this.location,
    required this.startAt,
    required this.endAt,
  });

  final String title;
  final String location;
  final DateTime startAt;
  final DateTime endAt;
}
