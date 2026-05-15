import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class HandoverScreen extends StatelessWidget {
  const HandoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Teslim',
      eyebrow: 'Zaman damgası',
      moduleKey: 'handover',
      icon: Icons.handshake_outlined,
      usage:
          'Teslim anındaki “yola çıktım”, “teslim noktasındayım”, “çocuk teslim edildi” veya gecikme notlarını buradan kaydet. Her işlem zaman damgasıyla canlı teslim loguna yazılır.',
      emptyText: 'Henüz teslim logu yok. + ile ilk teslim aksiyonunu kaydet.',
      addTitle: 'Teslim aksiyonu',
      addDetailLabel: 'Konum, gecikme veya kısa açıklama',
    );
  }
}
