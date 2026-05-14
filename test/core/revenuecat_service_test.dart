import 'package:ebeveyn_koprusu/core/services/revenuecat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps premium entitlement to feature gates', () {
    const service = RevenueCatService();

    final premium = service.mockEntitlement('premium_access');

    expect(premium.plan, 'Premium');
    expect(premium.canUseToneAssistant, isTrue);
    expect(premium.canGenerateVerifiedReports, isTrue);
    expect(premium.storageLimitGb, 10);
  });
}
