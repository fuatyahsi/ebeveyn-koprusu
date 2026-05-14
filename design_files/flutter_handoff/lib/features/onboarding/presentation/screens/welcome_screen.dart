import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.1,
              center: Alignment(0, -1.1),
              colors: [Color(0xFF1B3A57), AppColors.ink, Color(0xFF081A2C)],
              stops: [0, 0.5, 1],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BridgeMark(size: 16, color: AppColors.paper),
                      const SizedBox(width: 8),
                      Text(
                        'EBEVEYN KÖPRÜSÜ',
                        style: AppTypography.mono(
                          color: AppColors.paper.withValues(alpha: 0.7),
                          letter: 2.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'ÇOCUK İÇİN SAKİN KOORDİNASYON',
                    style: AppTypography.mono(
                      color: AppColors.paper.withValues(alpha: 0.55),
                      letter: 2.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RichText(
                    text: TextSpan(
                      style: AppTypography.display(
                        size: 46,
                        color: AppColors.paper,
                        height: 1.05,
                      ),
                      children: const [
                        TextSpan(text: 'İki yakayı,\ntek bir çocuk için '),
                        TextSpan(
                          text: 'birleştirir.',
                          style: TextStyle(color: AppColors.ochre),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 300,
                    child: Text(
                      'Teslimler, takvim, masraflar ve mesajlar — zaman damgalı, çocuk odaklı, kayıtlı.',
                      style: AppTypography.ui(
                        size: 14.5,
                        color: AppColors.paper.withValues(alpha: 0.7),
                        height: 1.55,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const _FeatureGrid(),
                  const SizedBox(height: 18),
                  _PrimaryButton(
                    label: 'Aileyi başlat',
                    onTap: () => context.go('/'),
                  ),
                  const SizedBox(height: 10),
                  _SecondaryButton(
                    label: 'Davet kodum var',
                    onTap: () => context.push('/auth'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  @override
  Widget build(BuildContext context) {
    const items = <(String, String)>[
      ('Kayıtlı', 'Her teslim, mesaj ve karar hash-zincirinde.'),
      ('Sakin dil', 'Mesaj öncesi otomatik ton önerisi.'),
      ('Çocuk odaklı', 'Eş takip değil — düzen.'),
      ('Raporlanabilir', 'QR doğrulamalı PDF çıktısı.'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.05,
      children: [
        for (final it in items)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.paper.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(it.$1,
                    style: AppTypography.display(size: 18, color: AppColors.paper)),
                const SizedBox(height: 1),
                Text(
                  it.$2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(
                    size: 10.5,
                    color: AppColors.paper.withValues(alpha: 0.55),
                    height: 1.4,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.ui(
                    size: 15,
                    weight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward, size: 18, color: AppColors.ink),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.paper.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.ui(
                size: 14,
                weight: FontWeight.w500,
                color: AppColors.paper,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
