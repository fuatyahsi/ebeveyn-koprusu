import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Admin',
      eyebrow: 'Operasyon',
      moduleKey: 'admin',
      icon: Icons.admin_panel_settings_outlined,
      usage:
          'Bu ekran aileye ait audit kayıtlarını maskeli şekilde okur. Destek ve doğrulama için hash zincirinin son aksiyonlarını görür; yeni aile içeriği oluşturmaz.',
      emptyText: 'Henüz audit kaydı yok.',
      addTitle: 'Admin kaydı',
      addDetailLabel: 'Not',
      readOnly: true,
    );
  }
}
