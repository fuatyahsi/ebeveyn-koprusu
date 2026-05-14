import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

class HashUtils {
  const HashUtils._();

  static String sha256(String input) {
    return sha256Digest(utf8.encode(input));
  }

  static String sha256Digest(List<int> bytes) {
    return crypto.sha256.convert(bytes).toString();
  }
}
