import 'package:ebeveyn_koprusu/core/services/tone_assistant_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mock tone assistant flags risky wording', () {
    const service = ToneAssistantService();

    final result = service.analyze('Sen yine hiçbir şeyi düzgün yapmadın.');

    expect(result.riskScore, greaterThan(0));
    expect(result.categories, contains('suçlayıcı dil'));
    expect(result.suggestion, isNotEmpty);
  });
}
