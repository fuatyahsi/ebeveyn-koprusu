import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class PersonalJournalScreen extends StatelessWidget {
  const PersonalJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleDetailScreen(
      title: 'Kişisel Defter',
      route: '/journal',
      children: [
        SectionCard(
          title: 'Gizli kayıt alanı',
          icon: Icons.note_alt_outlined,
          child: Text(
            'Bu bölümdeki kayıtlar varsayılan olarak yalnızca oluşturan kullanıcı tarafından görüntülenir. Rapora dahil etme açık kullanıcı işlemiyle yapılır.',
          ),
        ),
      ],
    );
  }
}
