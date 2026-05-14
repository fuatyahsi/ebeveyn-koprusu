import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/status_pill.dart';
import 'package:flutter/material.dart';

class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDetailScreen(
      title: 'Uyuşmazlıklar',
      route: '/disputes',
      children: [
        SectionCard(
          title: 'Açık dosyalar',
          icon: Icons.gavel_outlined,
          child: Column(
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Teslim gecikmesi'),
                subtitle: Text('Takvim etkinliği ile bağlantılı'),
                trailing: StatusPill(label: 'Açık', color: AppColors.amber),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
