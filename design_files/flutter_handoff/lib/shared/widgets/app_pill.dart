import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum PillTone { sage, ochre, ink, paper, mute, terra }

/// Küçük üst-değişken etiket. Genelde mono fontla, "BEKLİYOR", "3 GÜN"
/// gibi durumlar için.
class AppPill extends StatelessWidget {
  const AppPill({
    super.key,
    required this.label,
    this.tone = PillTone.sage,
    this.size = PillSize.sm,
  });

  final String label;
  final PillTone tone;
  final PillSize size;

  @override
  Widget build(BuildContext context) {
    final t = _toneOf(tone);
    final isLg = size == PillSize.lg;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLg ? 10 : 8,
        vertical: isLg ? 6 : 3.5,
      ),
      decoration: BoxDecoration(
        color: t.bg,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.mono(
          size: isLg ? 11 : 9.5,
          color: t.fg,
          letter: 0.9,
        ),
      ),
    );
  }

  _ToneSpec _toneOf(PillTone t) {
    switch (t) {
      case PillTone.sage:
        return _ToneSpec(AppColors.sageSoft, AppColors.sage,
            AppColors.sage.withValues(alpha: 0.25));
      case PillTone.ochre:
        return _ToneSpec(AppColors.ochreSoft, const Color(0xFF7B5B33),
            AppColors.ochre.withValues(alpha: 0.35));
      case PillTone.ink:
        return _ToneSpec(AppColors.ink, AppColors.paper, Colors.transparent);
      case PillTone.paper:
        return _ToneSpec(AppColors.paper, AppColors.ink, AppColors.line);
      case PillTone.mute:
        return _ToneSpec(AppColors.ink.withValues(alpha: 0.05),
            AppColors.inkSoft, AppColors.line);
      case PillTone.terra:
        return _ToneSpec(AppColors.terra.withValues(alpha: 0.12),
            AppColors.terra, AppColors.terra.withValues(alpha: 0.25));
    }
  }
}

enum PillSize { sm, lg }

class _ToneSpec {
  _ToneSpec(this.bg, this.fg, this.border);
  final Color bg;
  final Color fg;
  final Color border;
}
