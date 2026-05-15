import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class PersonalJournalScreen extends StatelessWidget {
  const PersonalJournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Kişisel Defter',
      eyebrow: 'Gizli alan',
      moduleKey: 'journal',
      icon: Icons.note_alt_outlined,
      usage:
          'Bu alan yalnızca senin kayıtlarını gösterir. Günlük not, olay yorumu veya hatırlatmayı yaz; gerektiğinde “rapora al” diyerek rapor kapsamına dahil edebilirsin.',
      emptyText: 'Defter boş. + ile kişisel bir not ekle.',
      addTitle: 'Defter notu',
      addDetailLabel: 'Not içeriği',
      primaryStatus: 'raporda',
      primaryStatusLabel: 'Rapora al',
      secondaryStatus: 'gizli',
      secondaryStatusLabel: 'Gizli tut',
    );
  }
}
