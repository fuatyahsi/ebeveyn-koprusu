import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/brand_mark.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';

class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.paper, AppColors.paper, AppColors.sageSoft],
            stops: [0, 0.6, 1],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              ScreenHeader(
                eyebrow: 'Abonelik',
                title: 'Premium',
                trailing: Text(
                  'Yedekle',
                  style: AppTypography.ui(
                      size: 12,
                      color: AppColors.sage,
                      weight: FontWeight.w500),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: const [
                    _PremiumHero(),
                    SizedBox(height: 14),
                    _PlanRow(),
                    SizedBox(height: 14),
                    _FeatureList(),
                    SizedBox(height: 14),
                    _CtaButton(),
                    SizedBox(height: 8),
                    _EntitlementLabel(),
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

class _PremiumHero extends StatelessWidget {
  const _PremiumHero();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF14304B), AppColors.ink, Color(0xFF081A2C)],
          stops: [0, 0.5, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -30,
            top: -10,
            child: Opacity(
              opacity: 0.18,
              child: AppIconWidget(size: 170, radius: 48),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPill(label: 'En çok seçilen', tone: PillTone.ochre),
              const SizedBox(height: 14),
              Text(
                'Köprü,\ntam taşıma kapasitesinde.',
                style: AppTypography.display(
                    size: 36, color: AppColors.paper, height: 1.05),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('149',
                      style: AppTypography.display(
                          size: 40, color: AppColors.paper, height: 1)),
                  const SizedBox(width: 6),
                  Text('₺ / ay',
                      style: AppTypography.ui(
                          size: 14,
                          color: AppColors.paper.withValues(alpha: 0.65))),
                  const SizedBox(width: 8),
                  Text(
                    '199 ₺',
                    style: AppTypography.mono(
                      color: AppColors.paper.withValues(alpha: 0.5),
                      letter: 0.8,
                    ).copyWith(decoration: TextDecoration.lineThrough),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'İlk 7 gün ücretsiz · İstediğin zaman iptal',
                style: AppTypography.ui(
                    size: 11.5, color: AppColors.paper.withValues(alpha: 0.65)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanRow extends StatelessWidget {
  const _PlanRow();
  @override
  Widget build(BuildContext context) {
    const plans = <(String, String, String, bool)>[
      ('Plus', '49', 'Temel', false),
      ('Premium', '149', 'Seçili', true),
      ('Pro', '299', 'Avukat', false),
    ];
    return Row(
      children: [
        for (var i = 0; i < plans.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: plans[i].$4 ? AppColors.paperWhite : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: plans[i].$4 ? AppColors.ink : AppColors.line,
                  width: plans[i].$4 ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Text(plans[i].$1, style: AppTypography.display(size: 18)),
                  const SizedBox(height: 3),
                  Text('${plans[i].$2} ₺/ay',
                      style: AppTypography.ui(
                          size: 11.5, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(
                    plans[i].$3.toUpperCase(),
                    style: AppTypography.mono(
                        letter: 0.8, color: AppColors.inkMute),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();
  @override
  Widget build(BuildContext context) {
    const items = <(String, String, bool)>[
      ('Sınırsız teslim kaydı', 'Tüm planlar', true),
      ('Sakin Dil Asistanı', 'Premium · Pro', true),
      ('Aylık 5 PDF rapor', 'Premium', true),
      ('QR doğrulamalı arşiv', 'Premium · Pro', true),
      ('Avukat paylaşım kanalı', 'Sadece Pro', false),
      ('Mahkeme formatlı çıktı', 'Sadece Pro', false),
    ];

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: items[i].$3
                          ? AppColors.ink
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: items[i].$3
                          ? null
                          : Border.all(color: AppColors.line),
                    ),
                    child: Icon(
                      items[i].$3 ? Icons.check : Icons.remove,
                      size: 14,
                      color: items[i].$3 ? AppColors.paper : AppColors.inkMute,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(items[i].$1,
                            style: AppTypography.ui(
                              size: 13,
                              weight: FontWeight.w500,
                              color: items[i].$3
                                  ? AppColors.ink
                                  : AppColors.inkMute,
                            )),
                        const SizedBox(height: 1),
                        Text(items[i].$2,
                            style: AppTypography.ui(
                                size: 10.5, color: AppColors.inkMute)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  const _CtaButton();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {},
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          '7 gün ücretsiz dene',
          style: AppTypography.ui(
              size: 14.5,
              weight: FontWeight.w600,
              color: AppColors.paper),
        ),
      ),
    );
  }
}

class _EntitlementLabel extends StatelessWidget {
  const _EntitlementLabel();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'ENTITLEMENT · PREMIUM_ACCESS',
        style:
            AppTypography.mono(letter: 1.6, color: AppColors.inkMute),
      ),
    );
  }
}
