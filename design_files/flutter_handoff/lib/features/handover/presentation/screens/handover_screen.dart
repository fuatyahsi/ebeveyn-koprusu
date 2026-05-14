import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  bool _includeLocation = true;
  int _selectedAction = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const ScreenHeader(
              eyebrow: 'Teslim · #2026-05-16',
              title: 'Cuma teslimi',
              trailing: AppPill(label: 'Canlı', tone: PillTone.ochre, size: PillSize.lg),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _StatusHero(),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Hızlı işlem'),
                  _ActionGrid(
                    selected: _selectedAction,
                    onTap: (i) => setState(() => _selectedAction = i),
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Zaman damgaları'),
                  const _Timeline(),
                  const SizedBox(height: 14),
                  _LocationConsent(
                    value: _includeLocation,
                    onChanged: (v) => setState(() => _includeLocation = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ŞU AN',
              style: AppTypography.mono(
                  letter: 1.8, color: AppColors.paper.withValues(alpha: 0.55))),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: AppTypography.display(
                  size: 32, color: AppColors.paper, height: 1.05),
              children: const [
                TextSpan(text: 'Anne teslim noktasında. '),
                TextSpan(
                  text: 'Baba yolda.',
                  style: TextStyle(color: AppColors.ochre),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '16:42 · ETA 17:00 · OKUL ÇIKIŞI',
            style: AppTypography.mono(
              letter: 1.6,
              color: AppColors.paper.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  static const _actions = <(String, IconData, Color)>[
    ('Yola çıktım', Icons.directions_car_outlined, AppColors.sage),
    ('Teslim noktasındayım', Icons.location_on_outlined, AppColors.ochre),
    ('Çocuk teslim edildi', Icons.check_circle_outline, AppColors.sage),
    ('Gecikme bildir', Icons.schedule, AppColors.terra),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.3,
      children: [
        for (var i = 0; i < _actions.length; i++)
          _ActionChip(
            label: _actions[i].$1,
            icon: _actions[i].$2,
            accent: _actions[i].$3,
            active: i == selected,
            onTap: () => onTap(i),
          ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.active,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color accent;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.ink : AppColors.paperWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: active ? Colors.transparent : AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.paper.withValues(alpha: 0.12)
                      : (accent == AppColors.terra
                          ? AppColors.terra.withValues(alpha: 0.1)
                          : AppColors.sageSoft),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: active ? AppColors.paper : accent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.ui(
                    size: 12.5,
                    weight: FontWeight.w500,
                    color: active ? AppColors.paper : AppColors.ink,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  static const _items = <(String, String, String, String, bool)>[
    ('16:42', 'Şu an', 'Anne teslim noktasında', 'ochre', true),
    ('16:30', '12 dk önce', 'Baba yola çıktı', 'sage', false),
    ('09:14', 'Bu sabah', 'Teslim hatırlatması gönderildi', 'mute', false),
    ('Dün 21:02', '', 'Çanta kontrol listesi tamamlandı (6/6)', 'sage', false),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++)
            _TimelineRow(
              time: _items[i].$1,
              sub: _items[i].$2,
              desc: _items[i].$3,
              tone: _items[i].$4,
              pulse: _items[i].$5,
              isLast: i == _items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.time,
    required this.sub,
    required this.desc,
    required this.tone,
    required this.pulse,
    required this.isLast,
  });
  final String time;
  final String sub;
  final String desc;
  final String tone;
  final bool pulse;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dotColor = tone == 'ochre'
        ? AppColors.ochre
        : tone == 'sage'
            ? AppColors.sage
            : AppColors.line;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 0),
            child: Column(
              children: [
                const SizedBox(height: 18),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    boxShadow: pulse
                        ? [
                            BoxShadow(
                              color: AppColors.ochre.withValues(alpha: 0.25),
                              blurRadius: 0,
                              spreadRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: AppColors.line),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 16, isLast ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(time,
                          style: AppTypography.mono(
                              size: 11,
                              color: AppColors.ink,
                              letter: 0.4,
                              weight: FontWeight.w500)),
                      if (sub.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(sub,
                            style: AppTypography.ui(
                                size: 10.5, color: AppColors.inkMute)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(desc, style: AppTypography.ui(size: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationConsent extends StatelessWidget {
  const _LocationConsent({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.sage,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.sage),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bu işlem için konum eklensin mi?',
                    style: AppTypography.display(size: 17, height: 1.15)),
                const SizedBox(height: 3),
                Text(
                  'Canlı takip yapılmaz. Sadece bu teslim anına özel, açık rıza ile.',
                  style: AppTypography.ui(
                      size: 11.5, color: AppColors.inkSoft, height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
