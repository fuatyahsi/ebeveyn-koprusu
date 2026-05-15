import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Raporlar',
      eyebrow: 'Hash kayıt',
      moduleKey: 'reports',
      icon: Icons.picture_as_pdf_outlined,
      usage:
          'Rapor üret dediğinde son 30 gün için canlı reports kaydı, doğrulama tokenı ve SHA-256 özet değeri oluşturulur. PDF üretim servisi bağlandığında aynı kayıt dosya yoluyla eşleşir.',
      emptyText: 'Henüz rapor yok. + ile test raporu üret.',
      addTitle: 'Rapor üret',
      addDetailLabel: 'Bu alan test raporunda opsiyoneldir',
    );
  }
}
