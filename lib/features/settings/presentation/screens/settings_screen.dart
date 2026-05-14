import 'package:ebeveyn_koprusu/core/config/app_config.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Ortam',
            icon: Icons.settings_applications_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Env: ${config.appEnv}'),
                Text('Locale: ${config.defaultLocale}'),
                Text('Timezone: ${config.timezone}'),
                Text(
                  'Supabase: ${config.isSupabaseConfigured ? 'Bağlı' : 'Yapılandırılmadı'}',
                ),
                Text(
                  'RevenueCat: ${config.isRevenueCatConfigured ? 'Bağlı' : 'Yapılandırılmadı'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'KVKK ve hesap',
            icon: Icons.privacy_tip_outlined,
            child: Column(
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.download_outlined),
                  title: Text('Verilerimi indir'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.delete_outline),
                  title: Text('Hesap silme talebi'),
                ),
                if (AppDataService.hasSession)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout),
                    title: const Text('Çıkış yap'),
                    onTap: () async {
                      await AppDataService.signOut();
                      if (context.mounted) context.go('/auth');
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
