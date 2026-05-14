import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModuleDetailScreen(
      title: 'Yakınlar',
      route: '/contacts',
      children: [
        SectionCard(
          title: 'Teslim yetkilileri',
          icon: Icons.contact_phone_outlined,
          child: Column(
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.verified_user_outlined),
                title: Text('Ayşe Demir'),
                subtitle: Text('Anneanne • sürekli teslim yetkisi'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.local_hospital_outlined),
                title: Text('Dr. Kemal Arı'),
                subtitle: Text('Doktor • acil durumda aranabilir'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
