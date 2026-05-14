import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Bölüm başlığı — mono caps + opsiyonel aksiyon.
class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.label, this.action});

  final String label;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.mono(letter: 1.8, color: AppColors.inkMute),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Premium kart — varsayılan beyaz kağıt, opsiyonel "ink" varyantı.
enum CardTint { paper, ink, sage }

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.tint = CardTint.paper,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final CardTint tint;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final bg = switch (tint) {
      CardTint.paper => AppColors.paperWhite,
      CardTint.ink => AppColors.ink,
      CardTint.sage => AppColors.sageSoft,
    };
    final box = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
        boxShadow: tint == CardTint.ink
            ? [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: clip
          ? ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: child,
            )
          : Padding(padding: padding, child: child),
    );
    return clip ? box : box;
  }
}
