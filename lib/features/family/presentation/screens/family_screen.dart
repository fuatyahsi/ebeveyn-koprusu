import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDetailScreen(
      title: 'Aile',
      route: '/family',
      children: [
        SectionCard(
          title: 'Üyelik durumu',
          icon: Icons.groups_2_outlined,
          child: Column(
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline),
                title: Text('Anne'),
                subtitle: Text('full erişim • active'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.mail_outline),
                title: Text('Baba daveti'),
                subtitle: Text('pending • 7 gün içinde yanıt bekleniyor'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
