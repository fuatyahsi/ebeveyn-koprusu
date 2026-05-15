import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class DisputesScreen extends StatelessWidget {
  const DisputesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Uyuşmazlıklar',
      eyebrow: 'Dosya',
      moduleKey: 'disputes',
      icon: Icons.gavel_outlined,
      usage:
          'Teslim gecikmesi, masraf itirazı veya belge anlaşmazlığı gibi konuları ayrı dosya olarak aç. Dosya canlı tutulur; çözüldüğünde kapatıp rapor geçmişine dahil edebilirsin.',
      emptyText: 'Açık uyuşmazlık yok. + ile bir dosya aç.',
      addTitle: 'Uyuşmazlık aç',
      addDetailLabel: 'Olay, tarih, kanıt veya beklenen çözüm',
      primaryStatus: 'closed',
      primaryStatusLabel: 'Çözüldü',
    );
  }
}
