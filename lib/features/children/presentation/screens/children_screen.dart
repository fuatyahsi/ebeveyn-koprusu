import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class ChildrenScreen extends StatelessWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Çocuk Bilgileri',
      eyebrow: 'Profil',
      moduleKey: 'children',
      icon: Icons.child_care_outlined,
      usage:
          'Çocuk profilini buradan açarsın. İsim, okul/sağlık/servis notları ve ihtiyaç bilgileri aile kapsamındaki canlı kayda yazılır; daha sonra diğer modüller bu çocuk kaydını kullanır.',
      emptyText: 'Henüz çocuk kaydı yok. Sağ üstteki + ile ilk profili ekle.',
      addTitle: 'Çocuk kaydı',
      addDetailLabel: 'Okul, sağlık, servis veya ihtiyaç notu',
    );
  }
}
