import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

class ModuleUsageTip extends StatelessWidget {
  const ModuleUsageTip({
    super.key,
    required this.text,
    this.icon = Icons.tips_and_updates_outlined,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.sage,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.sage),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.ui(
                size: 12.5,
                weight: FontWeight.w400,
                color: AppColors.inkSoft,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
