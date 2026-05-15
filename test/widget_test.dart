import 'package:ebeveyn_koprusu/app/theme/app_theme.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: const AppShell(),
          locale: const Locale('tr'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Deniz, 8 yaş'), findsOneWidget);
    expect(find.text('SIRADAKİ TESLİM'), findsOneWidget);
    expect(find.text('Gün takası'), findsOneWidget);
  });
}
