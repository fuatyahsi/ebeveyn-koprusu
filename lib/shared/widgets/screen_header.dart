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
    this.showBack = false,
    this.onBack,
    this.trailing,
    this.dark = false,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 14),
  });

  final String title;
  final String? eyebrow;
  final bool showBack;
  final VoidCallback? onBack;
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
          if (showBack) ...[
            _HeaderBackButton(
              dark: dark,
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
          ],
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
                Text(title, style: AppTypography.display(size: 30, color: fg)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _HeaderBackButton extends StatelessWidget {
  const _HeaderBackButton({required this.dark, required this.onPressed});

  final bool dark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? AppColors.paper : AppColors.ink;
    final bg = dark
        ? AppColors.paper.withValues(alpha: 0.1)
        : AppColors.paperWhite;
    final border = dark
        ? AppColors.paper.withValues(alpha: 0.18)
        : AppColors.line;

    return Tooltip(
      message: 'Geri',
      child: Material(
        color: bg,
        shape: CircleBorder(side: BorderSide(color: border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 38,
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 17, color: fg),
          ),
        ),
      ),
    );
  }
}
