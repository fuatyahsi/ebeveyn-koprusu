import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Acil Durum',
      eyebrow: 'Bildirim',
      moduleKey: 'emergency',
      icon: Icons.emergency_outlined,
      usage:
          'Sağlık, okul, servis veya teslim anındaki acil konuları burada aç. Kayıt aileyle paylaşılacak biçimde canlıya yazılır; olay bittiğinde kapatabilirsin.',
      emptyText: 'Açık acil durum yok. + ile acil kayıt oluştur.',
      addTitle: 'Acil bildirim',
      addDetailLabel: 'Kısa, sakin ve gerekli bilgi',
      primaryStatus: 'closed',
      primaryStatusLabel: 'Kapat',
    );
  }
}
