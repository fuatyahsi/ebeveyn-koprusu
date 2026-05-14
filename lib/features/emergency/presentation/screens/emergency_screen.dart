import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDetailScreen(
      title: 'Acil Durum',
      route: '/emergency',
      children: [
        SectionCard(
          title: 'Acil bildirim',
          icon: Icons.emergency_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Bildirim metni hassas detay göstermeden gönderilir.'),
              const SizedBox(height: 12),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.red),
                onPressed: () {},
                icon: const Icon(Icons.priority_high_outlined),
                label: const Text('Acil bildirim oluştur'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
