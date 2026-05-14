import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleDetailScreen(
      title: 'Admin',
      route: '/admin',
      children: [
        SectionCard(
          title: 'Operasyon panosu',
          icon: Icons.admin_panel_settings_outlined,
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.report_problem_outlined),
                title: Text('Abuse/risk flag listesi'),
                subtitle: Text('Hassas aile içeriği maskeli görünür.'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.verified_outlined),
                title: Text('Rapor doğrulama kayıtları'),
                subtitle: Text('Token ve hash sonuçları üzerinden izlenir.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
