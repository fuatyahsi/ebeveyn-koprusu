import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/status_pill.dart';
import 'package:flutter/material.dart';

class DecisionsScreen extends StatelessWidget {
  const DecisionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDetailScreen(
      title: 'Onaylar',
      route: '/decisions',
      children: [
        SectionCard(
          title: 'Bekleyen kararlar',
          icon: Icons.fact_check_outlined,
          child: Column(
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Şehir dışı seyahat'),
                subtitle: Text('Son yanıt: 18 Mayıs 2026'),
                trailing: StatusPill(label: 'Yanıt bekliyor'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Servis değişikliği'),
                subtitle: Text('Ek belge istendi'),
                trailing: StatusPill(label: 'Ek bilgi'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
