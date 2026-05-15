import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class DecisionsScreen extends StatelessWidget {
  const DecisionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Onaylar',
      eyebrow: 'Karar',
      moduleKey: 'decisions',
      icon: Icons.fact_check_outlined,
      usage:
          'Okul, sağlık, seyahat, servis veya masraf gibi karşı taraftan karar bekleyen konuları buradan talep et. Her talep canlı kayda düşer; onayla veya reddet aksiyonları durumunu günceller.',
      emptyText: 'Bekleyen karar yok. + ile yeni bir onay talebi oluştur.',
      addTitle: 'Onay talebi',
      addDetailLabel: 'Talep açıklaması ve son yanıt tarihi notu',
      primaryStatus: 'accepted',
      primaryStatusLabel: 'Onayla',
      secondaryStatus: 'rejected',
      secondaryStatusLabel: 'Reddet',
    );
  }
}
