import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Okul', Icons.school_outlined, 'Veli toplantısı, sınav, etkinlik'),
      ('Sağlık', Icons.health_and_safety_outlined, 'Rapor, reçete, kontrol'),
      ('Servis', Icons.directions_bus_outlined, 'Sözleşme, güzergah'),
      ('Masraf', Icons.receipt_outlined, 'Fatura, dekont, fiş'),
      ('Hukuki', Icons.balance_outlined, 'Protokol, karar, yazışma'),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Belge kategorileri',
          icon: Icons.folder_outlined,
          trailing: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload_file_outlined),
            label: const Text('Yükle'),
          ),
          child: Column(
            children: [
              for (final category in categories)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(category.$2),
                  title: Text(category.$1),
                  subtitle: Text(category.$3),
                  trailing: const Icon(Icons.chevron_right),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionCard(
          title: 'Storage politikası',
          icon: Icons.lock_outline,
          child: Text(
            'Dosyalar private bucket içinde family_id, child_id ve entity id içeren yolla saklanır. Sağlık belgeleri hassas kategori olarak ayrılır.',
          ),
        ),
      ],
    );
  }
}
