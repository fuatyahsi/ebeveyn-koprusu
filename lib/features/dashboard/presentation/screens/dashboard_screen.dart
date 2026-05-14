import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        children: [
          ScreenHeader(
            eyebrow: 'Salı · 14 Mayıs',
            title: 'Bugün',
            trailing: _RoundIconButton(
              icon: Icons.add,
              bg: AppColors.sageSoft,
              fg: AppColors.sage,
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const _ChildHero(),
                const SizedBox(height: 12),
                _NextHandoverCard(onDetail: () => context.push('/handover')),
                const SizedBox(height: 16),
                const SectionLabel(label: 'Bugün için'),
                const _QuickActions(),
                const SizedBox(height: 12),
                const SectionLabel(label: 'Bekleyen'),
                const _PendingList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.onTap,
  });
  final IconData icon;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(icon, size: 16, color: fg),
      ),
    );
  }
}

class _ChildHero extends StatelessWidget {
  const _ChildHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.sageSoft, AppColors.ochreSoft],
                  ),
                ),
                alignment: Alignment.center,
                child: Text('D', style: AppTypography.display(size: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deniz, 8 yaş',
                      style: AppTypography.display(size: 24, height: 1),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Atatürk İlkokulu · 3-B',
                      style: AppTypography.ui(
                        size: 12,
                        color: AppColors.inkMute,
                      ),
                    ),
                  ],
                ),
              ),
              const AppPill(label: 'Şu an anne', tone: PillTone.sage),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'BU HAFTA',
            style: AppTypography.mono(letter: 1.6, color: AppColors.inkMute),
          ),
          const SizedBox(height: 8),
          const _WeekStrip(),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();

  static const _days = <(String, String, String)>[
    ('Pzt', 'A', 'sage'),
    ('Sal', 'A', 'today'),
    ('Çar', 'A', 'sage'),
    ('Per', 'A', 'sage'),
    ('Cum', '→B', 'ochre'),
    ('Cmt', 'B', 'ochre'),
    ('Paz', 'B', 'ochre'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _days.length; i++) ...[
          Expanded(
            child: _DayCell(
              day: _days[i].$1,
              who: _days[i].$2,
              tone: _days[i].$3,
            ),
          ),
          if (i < _days.length - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.who, required this.tone});
  final String day;
  final String who;
  final String tone;

  @override
  Widget build(BuildContext context) {
    final isToday = tone == 'today';
    final isOchre = tone == 'ochre';
    final bg = isToday
        ? AppColors.ink
        : isOchre
        ? AppColors.ochreSoft
        : AppColors.sageSoft;
    final fg = isToday
        ? AppColors.paper
        : isOchre
        ? const Color(0xFF7B5B33)
        : AppColors.sage;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: AppTypography.ui(
              size: 9.5,
              color: fg,
              weight: FontWeight.w500,
              letter: 0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            who,
            style: AppTypography.ui(
              size: 13,
              color: fg,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextHandoverCard extends StatelessWidget {
  const _NextHandoverCard({required this.onDetail});
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      clip: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIRADAKİ TESLİM',
                        style: AppTypography.mono(
                          letter: 1.8,
                          color: AppColors.paper.withValues(alpha: 0.55),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cuma · 17:00',
                        style: AppTypography.display(
                          size: 26,
                          color: AppColors.paper,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Okul çıkışı · Anne → Baba',
                        style: AppTypography.ui(
                          size: 12.5,
                          color: AppColors.paper.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const AppPill(label: '3 gün', tone: PillTone.ochre),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: AppColors.paper.withValues(alpha: 0.1)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.paper,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      'Hazır mı?',
                      style: AppTypography.ui(
                        size: 12.5,
                        weight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDetail,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.paper,
                      side: BorderSide(
                        color: AppColors.paper.withValues(alpha: 0.25),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(0, 0),
                    ),
                    child: Text(
                      'Detay',
                      style: AppTypography.ui(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: AppColors.paper,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const _actions = <(_QA,)>[
    (
      _QA(
        'Hızlı teslim',
        Icons.handshake_outlined,
        AppColors.sage,
        AppColors.sageSoft,
      ),
    ),
    (
      _QA(
        'Acil bildirim',
        Icons.priority_high,
        AppColors.terra,
        Color(0x1FB65F46),
      ),
    ),
    (
      _QA(
        'Masraf ekle',
        Icons.receipt_long_outlined,
        AppColors.ochre,
        AppColors.ochreSoft,
      ),
    ),
    (
      _QA(
        'Rapor üret',
        Icons.picture_as_pdf_outlined,
        AppColors.ink,
        AppColors.paperWhite,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.45,
      children: [
        for (final a in _actions)
          Material(
            color: a.$1.bg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.paperWhite,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Icon(a.$1.icon, size: 16, color: a.$1.fg),
                    ),
                    const Spacer(),
                    Text(
                      a.$1.label,
                      style: AppTypography.ui(
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _QA {
  const _QA(this.label, this.icon, this.fg, this.bg);
  final String label;
  final IconData icon;
  final Color fg;
  final Color bg;
}

class _PendingList extends StatelessWidget {
  const _PendingList();

  static const _items = <(String, String, PillTone, String)>[
    (
      'Servis ücreti — 1.600 ₺',
      'Onayını bekliyor · 2 gün kaldı',
      PillTone.ochre,
      'Bekliyor',
    ),
    (
      'Doktor randevusu onayı',
      'Karar talebi · Baba gönderdi',
      PillTone.sage,
      'Karar',
    ),
    ('Yaz tatili planı', 'İtiraz açık · 4 gün önce', PillTone.terra, 'İtiraz'),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _items[i].$1,
                          style: AppTypography.ui(
                            size: 13.5,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _items[i].$2,
                          style: AppTypography.ui(
                            size: 11.5,
                            color: AppColors.inkMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppPill(label: _items[i].$4, tone: _items[i].$3),
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
