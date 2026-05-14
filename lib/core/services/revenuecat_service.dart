import 'package:flutter_riverpod/flutter_riverpod.dart';

final revenueCatServiceProvider = Provider<RevenueCatService>(
  (ref) => const RevenueCatService(),
);

class EntitlementSnapshot {
  const EntitlementSnapshot({
    required this.plan,
    required this.canUseToneAssistant,
    required this.canGenerateVerifiedReports,
    required this.canInviteExperts,
    required this.maxChildren,
    required this.storageLimitGb,
  });

  final String plan;
  final bool canUseToneAssistant;
  final bool canGenerateVerifiedReports;
  final bool canInviteExperts;
  final int maxChildren;
  final int storageLimitGb;
}

class RevenueCatService {
  const RevenueCatService();

  EntitlementSnapshot mockEntitlement(String entitlement) {
    return switch (entitlement) {
      'professional_access' => const EntitlementSnapshot(
        plan: 'Professional',
        canUseToneAssistant: true,
        canGenerateVerifiedReports: true,
        canInviteExperts: true,
        maxChildren: 10,
        storageLimitGb: 50,
      ),
      'premium_access' => const EntitlementSnapshot(
        plan: 'Premium',
        canUseToneAssistant: true,
        canGenerateVerifiedReports: true,
        canInviteExperts: true,
        maxChildren: 5,
        storageLimitGb: 10,
      ),
      _ => const EntitlementSnapshot(
        plan: 'Plus',
        canUseToneAssistant: false,
        canGenerateVerifiedReports: false,
        canInviteExperts: false,
        maxChildren: 1,
        storageLimitGb: 2,
      ),
    };
  }
}
