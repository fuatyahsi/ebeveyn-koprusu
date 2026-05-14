import 'package:flutter_riverpod/flutter_riverpod.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => const AppConfig.fromEnvironment(),
);

class AppConfig {
  const AppConfig({
    required this.appEnv,
    required this.appName,
    required this.defaultLocale,
    required this.timezone,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.revenueCatIosApiKey,
    required this.revenueCatAndroidApiKey,
    required this.toneAssistantProvider,
  });

  const AppConfig.fromEnvironment()
    : appEnv = const String.fromEnvironment(
        'APP_ENV',
        defaultValue: 'development',
      ),
      appName = const String.fromEnvironment(
        'APP_NAME',
        defaultValue: 'Ebeveyn Köprüsü',
      ),
      defaultLocale = const String.fromEnvironment(
        'APP_DEFAULT_LOCALE',
        defaultValue: 'tr',
      ),
      timezone = const String.fromEnvironment(
        'APP_TIMEZONE',
        defaultValue: 'Europe/Istanbul',
      ),
      supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY'),
      revenueCatIosApiKey = const String.fromEnvironment(
        'REVENUECAT_IOS_API_KEY',
      ),
      revenueCatAndroidApiKey = const String.fromEnvironment(
        'REVENUECAT_ANDROID_API_KEY',
      ),
      toneAssistantProvider = const String.fromEnvironment(
        'TONE_ASSISTANT_PROVIDER',
        defaultValue: 'mock',
      );

  final String appEnv;
  final String appName;
  final String defaultLocale;
  final String timezone;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String revenueCatIosApiKey;
  final String revenueCatAndroidApiKey;
  final String toneAssistantProvider;

  bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get isRevenueCatConfigured =>
      revenueCatIosApiKey.trim().isNotEmpty ||
      revenueCatAndroidApiKey.trim().isNotEmpty;
}
