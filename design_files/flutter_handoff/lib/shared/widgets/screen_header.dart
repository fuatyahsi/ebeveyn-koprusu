import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Ekran başlığı — mono "eyebrow" + büyük italik serif başlık + opsiyonel
/// sağ aksiyon. Default AppBar yerine ekran içine yerleştirilir.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.trailing,
    this.dark = false,
    this.padding =
        const EdgeInsets.fromLTRB(20, 12, 20, 14),
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;
  final bool dark;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.paper : AppColors.ink;
    final muted = dark
        ? AppColors.paper.withValues(alpha: 0.55)
        : AppColors.inkMute;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (eyebrow != null) ...[
                  Text(
                    eyebrow!.toUpperCase(),
                    style: AppTypography.mono(
                      size: 9.5,
                      color: muted,
                      letter: 1.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  title,
                  style: AppTypography.display(size: 30, color: fg),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
