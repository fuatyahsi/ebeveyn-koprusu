import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int _view = 0; // 0 = month, 1 = list

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScreenHeader(
            eyebrow: 'Velâyet takvimi',
            title: 'Mayıs 2026',
            trailing: _ViewSwitcher(
              index: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                _Legend(),
                SizedBox(height: 6),
                AppCard(padding: EdgeInsets.all(12), child: _MonthGrid()),
                SizedBox(height: 14),
                SectionLabel(label: 'Yaklaşan kayıtlar'),
                _UpcomingList(),
              ],
            ),
          ),
        ],
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
  const _SwitchChip({required this.label, required this.active, required this.onTap});
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
          border: Border.all(color: active ? Colors.transparent : AppColors.line),
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
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4)),
            ),
            const SizedBox(width: 6),
            Text(label, style: AppTypography.ui(size: 11, color: AppColors.inkMute)),
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
  const _MonthGrid();

  @override
  Widget build(BuildContext context) {
    const weekHeaders = ['P', 'S', 'Ç', 'P', 'C', 'C', 'P'];
    final cells = List<int>.generate(35, (i) => i - 1); // -2..32 (offset 2)

    return Column(
      children: [
        Row(
          children: [
            for (final h in weekHeaders)
              Expanded(
                child: Center(
                  child: Text(
                    h,
                    style:
                        AppTypography.mono(letter: 1, color: AppColors.inkMute),
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
              _DayBox(index: i, raw: cells[i]),
          ],
        ),
      ],
    );
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({required this.index, required this.raw});
  final int index;
  final int raw;

  @override
  Widget build(BuildContext context) {
    final inMonth = raw >= 1 && raw <= 31;
    final day = inMonth ? raw : (raw < 1 ? 30 + raw : raw - 31);
    final dow = index % 7;
    final week = index ~/ 7;
    final weekend = dow >= 5;
    final isDad = inMonth && weekend && (week == 0 || week == 2);
    final isToday = inMonth && raw == 14;
    final isHandover = inMonth && [2, 4, 16, 18].contains(raw);

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

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(7),
      ),
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
    );
  }
}

class _UpcomingList extends StatelessWidget {
  const _UpcomingList();

  static const _items = <(String, String, String, String, PillTone, String)>[
    ('Cuma', '17:00', 'Hafta sonu teslimi', 'Okul çıkışı · Anne → Baba',
        PillTone.ochre, '3 gün'),
    ('Pazar', '18:00', 'Geri teslim', 'Park önü · Baba → Anne', PillTone.sage,
        '5 gün'),
    ('25 May', '', 'Veli toplantısı', '3-B sınıfı · 18:30', PillTone.mute,
        '11 gün'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Column(
                      children: [
                        Text(_items[i].$1,
                            style:
                                AppTypography.display(size: 18, height: 1)),
                        const SizedBox(height: 2),
                        Text(_items[i].$2,
                            style: AppTypography.mono(
                                color: AppColors.inkMute, letter: 0.5)),
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
                        Text(_items[i].$3,
                            style: AppTypography.ui(
                                size: 13.5, weight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(_items[i].$4,
                            style: AppTypography.ui(
                                size: 11.5, color: AppColors.inkMute)),
                      ],
                    ),
                  ),
                  AppPill(label: _items[i].$6, tone: _items[i].$5),
                ],
              ),
            ),
            if (i < _items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}
