import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/brand_mark.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _range = 0;
  final Set<int> _included = {0, 1, 2};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const ScreenHeader(
              eyebrow: 'Hash-zincirli kayıt',
              title: 'Rapor üret',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _RangePicker(
                    index: _range,
                    onChanged: (i) => setState(() => _range = i),
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Dahil edilecek'),
                  _IncludeList(
                    included: _included,
                    onToggle: (i) => setState(() {
                      if (_included.contains(i)) {
                        _included.remove(i);
                      } else {
                        _included.add(i);
                      }
                    }),
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Önizleme'),
                  const _ReportPreview(),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('PDF olarak üret'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Premium · Aylık 5 rapor hakkın kaldı',
                      style: AppTypography.ui(
                          size: 11, color: AppColors.inkMute),
                    ),
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

class _RangePicker extends StatelessWidget {
  const _RangePicker({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  static const _opts = ['Son 30 gün', 'Bu yıl', 'Özel'];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TARİH ARALIĞI',
              style:
                  AppTypography.mono(letter: 1.6, color: AppColors.inkMute)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (var i = 0; i < _opts.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => onChanged(i),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: i == index
                            ? AppColors.ink
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: i == index
                                ? Colors.transparent
                                : AppColors.line),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _opts[i],
                        style: AppTypography.ui(
                          size: 12,
                          weight: FontWeight.w500,
                          color: i == index
                              ? AppColors.paper
                              : AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _DateBox(label: 'BAŞLANGIÇ', value: '14 Nisan')),
              SizedBox(width: 10),
              Expanded(child: _DateBox(label: 'BİTİŞ', value: '14 Mayıs')),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.mono(letter: 1, color: AppColors.inkMute)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.display(size: 18)),
        ],
      ),
    );
  }
}

class _IncludeList extends StatelessWidget {
  const _IncludeList({required this.included, required this.onToggle});
  final Set<int> included;
  final ValueChanged<int> onToggle;

  static const _items = <(String, String)>[
    ('Teslim kayıtları', '12 işlem'),
    ('Mesaj başlıkları', '4 konu'),
    ('Masraflar', '7 kalem'),
    ('Karar talepleri', '3 onay'),
    ('Kişisel defter', '— Yalnız sahibi'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            InkWell(
              onTap: () => onToggle(i),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_items[i].$1,
                              style: AppTypography.ui(
                                  size: 13.5, weight: FontWeight.w500)),
                          const SizedBox(height: 1),
                          Text(_items[i].$2,
                              style: AppTypography.ui(
                                  size: 11, color: AppColors.inkMute)),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: included.contains(i),
                      onChanged: (_) => onToggle(i),
                    ),
                  ],
                ),
              ),
            ),
            if (i < _items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ReportPreview extends StatelessWidget {
  const _ReportPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Stack(
        children: [
          // Watermark
          Positioned(
            right: -10,
            top: 90,
            child: Transform.rotate(
              angle: -0.38,
              child: Text(
                'Taslak',
                style: AppTypography.display(
                    size: 60, color: AppColors.ink.withValues(alpha: 0.04)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BridgeMark(size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Koordinasyon raporu',
                            style:
                                AppTypography.display(size: 20, height: 1.1)),
                        const SizedBox(height: 2),
                        Text(
                          '14.04.2026 — 14.05.2026 · DENİZ Y.',
                          style: AppTypography.mono(
                              letter: 1.2, color: AppColors.inkMute),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: _Stat(value: '12', label: 'TESLİM')),
                  Expanded(child: _Stat(value: '4', label: 'KONU')),
                  Expanded(child: _Stat(value: '7', label: 'MASRAF')),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Bu rapor 30 günlük süreyi özetler. Tüm kayıtlar zaman damgalı ve hash-zincirinde imzalıdır. Hukuki tavsiye veya kesin delil iddiası taşımaz.',
                style: AppTypography.ui(
                    size: 11, color: AppColors.inkSoft, height: 1.5),
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _QrPlaceholder(size: 54),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SHA-256 İMZA',
                            style: AppTypography.mono(
                                letter: 1.2, color: AppColors.inkMute)),
                        const SizedBox(height: 3),
                        Text(
                          '9f2a·c41d·8e07·4b3f·…·2c8a',
                          style: AppTypography.mono(
                              size: 10.5, color: AppColors.ink, letter: 0.4),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'doğrulama: ekoprusu.app/v/9f2a',
                          style: AppTypography.ui(
                              size: 9.5,
                              color: AppColors.sage,
                              weight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTypography.display(size: 24, height: 1)),
        const SizedBox(height: 2),
        Text(label,
            style: AppTypography.mono(letter: 1.6, color: AppColors.inkMute)),
      ],
    );
  }
}

class _QrPlaceholder extends StatelessWidget {
  const _QrPlaceholder({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.count(
        crossAxisCount: 7,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(49, (i) {
          const corners = {0,1,2,7,8,9,14,15,16, 4,5,6,11,12,13,18,19,20,
                           28,29,30,35,36,37,42,43,44};
          final filled = corners.contains(i) || ((i * 7 + 3) % 5) < 2;
          return Container(color: filled ? AppColors.paper : Colors.transparent);
        }),
      ),
    );
  }
}
