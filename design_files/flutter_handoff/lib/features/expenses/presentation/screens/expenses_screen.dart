import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          ScreenHeader(
            eyebrow: 'Mayıs · Bu ay',
            title: 'Masraflar',
            trailing: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.ink,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: AppColors.paper),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const _SummaryCard(),
                const SizedBox(height: 12),
                _FilterChips(
                  selected: _filter,
                  onChanged: (i) => setState(() => _filter = i),
                ),
                const SizedBox(height: 14),
                const _ExpenseList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BU AY SENİN PAYIN',
            style: AppTypography.mono(
                letter: 1.8, color: AppColors.paper.withValues(alpha: 0.55)),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('2.525',
                  style: AppTypography.display(
                      size: 44, color: AppColors.paper, height: 1)),
              const SizedBox(width: 6),
              Text('₺',
                  style: AppTypography.ui(
                      size: 18,
                      color: AppColors.paper.withValues(alpha: 0.55))),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(flex: 42, child: Container(color: AppColors.ochre)),
                  Expanded(flex: 30, child: Container(color: AppColors.sage)),
                  Expanded(flex: 18, child: Container(color: AppColors.terra)),
                  Expanded(
                    flex: 10,
                    child: Container(
                        color: AppColors.paper.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _LegendDot(c: AppColors.ochre, label: 'Bekliyor 1.600'),
              _LegendDot(c: AppColors.sage, label: 'Kabul 925'),
              _LegendDot(c: AppColors.terra, label: 'İtiraz —'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.c, required this.label});
  final Color c;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('●', style: TextStyle(color: c, fontSize: 10)),
        const SizedBox(width: 5),
        Text(label,
            style: AppTypography.ui(
                size: 11, color: AppColors.paper.withValues(alpha: 0.7))),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onChanged});
  final int selected;
  final ValueChanged<int> onChanged;

  static const _items = <(String, int)>[
    ('Tümü', 3),
    ('Bekliyor', 1),
    ('Kabul', 1),
    ('Ödendi', 0),
    ('İtiraz', 0),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _FilterChip(
              label: _items[i].$1,
              count: _items[i].$2,
              active: i == selected,
              onTap: () => onChanged(i),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.paperWhite,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: active ? Colors.transparent : AppColors.line),
        ),
        child: Row(
          children: [
            Text(label,
                style: AppTypography.ui(
                  size: 11.5,
                  weight: FontWeight.w500,
                  color: active ? AppColors.paper : AppColors.inkSoft,
                )),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.paper.withValues(alpha: 0.18)
                      : AppColors.ink.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: AppTypography.mono(
                    color: active
                        ? AppColors.paper.withValues(alpha: 0.7)
                        : AppColors.inkMute,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList();

  static const _items = <(String, String, String, String, PillTone, String, IconData)>[
    ('Okul servis ücreti', 'Servis · 13 May', '3.200', '1.600', PillTone.ochre,
        'Bekliyor', Icons.directions_bus_outlined),
    ('Doktor kontrolü', 'Sağlık · 7 May', '1.850', '925', PillTone.sage,
        'Kabul', Icons.health_and_safety_outlined),
    ('Yaz kampı kaydı', 'Eğitim · 4 May', '4.800', '2.400', PillTone.terra,
        'İtiraz', Icons.cottage_outlined),
    ('Diş tedavisi', 'Sağlık · 28 Nis', '2.100', '1.050', PillTone.mute,
        'Ödendi', Icons.medical_services_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            _ExpenseRow(
              title: _items[i].$1,
              sub: _items[i].$2,
              amount: _items[i].$3,
              share: _items[i].$4,
              tone: _items[i].$5,
              label: _items[i].$6,
              icon: _items[i].$7,
            ),
            if (i < _items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.title,
    required this.sub,
    required this.amount,
    required this.share,
    required this.tone,
    required this.label,
    required this.icon,
  });
  final String title;
  final String sub;
  final String amount;
  final String share;
  final PillTone tone;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final iconBg = switch (tone) {
      PillTone.ochre => AppColors.ochreSoft,
      PillTone.sage => AppColors.sageSoft,
      PillTone.terra => AppColors.terra.withValues(alpha: 0.1),
      _ => AppColors.ink.withValues(alpha: 0.05),
    };
    final iconFg = switch (tone) {
      PillTone.ochre => const Color(0xFF7B5B33),
      PillTone.sage => AppColors.sage,
      PillTone.terra => AppColors.terra,
      _ => AppColors.inkSoft,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: iconFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.ui(
                        size: 13.5, weight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text('$sub · talep $share ₺',
                    style: AppTypography.ui(
                        size: 11, color: AppColors.inkMute)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$amount ₺',
                  style: AppTypography.display(size: 17, height: 1)),
              const SizedBox(height: 5),
              AppPill(label: label, tone: tone),
            ],
          ),
        ],
      ),
    );
  }
}
