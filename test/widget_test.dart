import 'package:ebeveyn_koprusu/app/app.dart';
import 'package:ebeveyn_koprusu/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('tr_TR');
  });

  testWidgets('opens the operational dashboard', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig.fromEnvironment(),
          ),
        ],
        child: const EbeveynKoprusuApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Deniz, 8 yaş'), findsOneWidget);
    expect(find.text('SIRADAKİ TESLİM'), findsOneWidget);
    expect(find.text('Hızlı teslim'), findsOneWidget);
  });
}
