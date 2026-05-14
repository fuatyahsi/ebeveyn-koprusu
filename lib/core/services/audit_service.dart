import 'dart:convert';

import 'package:ebeveyn_koprusu/core/utils/hash_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final auditServiceProvider = Provider<AuditService>(
  (ref) => const AuditService(),
);

class AuditService {
  const AuditService();

  String createHash({
    required String previousHash,
    required String actorId,
    required String action,
    required Map<String, Object?> payload,
  }) {
    final canonical = jsonEncode({
      'previous_hash': previousHash,
      'actor_id': actorId,
      'action': action,
      'payload': payload,
    });
    return HashUtils.sha256(canonical);
  }
}
