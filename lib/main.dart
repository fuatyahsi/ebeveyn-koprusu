import 'package:ebeveyn_koprusu/app/app.dart';
import 'package:ebeveyn_koprusu/core/config/app_config.dart';
import 'package:ebeveyn_koprusu/core/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const config = AppConfig.fromEnvironment();
  await initializeDateFormatting('tr_TR');
  await SupabaseService.initializeIfConfigured(config);

  runApp(
    ProviderScope(
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: EbeveynKoprusuApp(),
    ),
  );
}
