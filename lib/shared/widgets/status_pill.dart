import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:flutter/material.dart';

class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.color = AppColors.inkSoft,
    super.key,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppPill(label: label, tone: _toneFor(color));
  }

  PillTone _toneFor(Color color) {
    if (color == AppColors.sage || color == AppColors.teal) {
      return PillTone.sage;
    }
    if (color == AppColors.ochre || color == AppColors.amber) {
      return PillTone.ochre;
    }
    if (color == AppColors.terra || color == AppColors.red) {
      return PillTone.terra;
    }
    if (color == AppColors.ink || color == AppColors.navy) {
      return PillTone.ink;
    }
    return PillTone.mute;
  }
}
