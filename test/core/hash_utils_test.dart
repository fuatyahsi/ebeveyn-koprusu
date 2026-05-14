import 'package:ebeveyn_koprusu/core/utils/hash_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sha256 returns deterministic hash', () {
    final first = HashUtils.sha256('ebeveyn-koprusu');
    final second = HashUtils.sha256('ebeveyn-koprusu');

    expect(first, second);
    expect(first.length, 64);
  });
}
