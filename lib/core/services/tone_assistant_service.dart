import 'package:flutter_riverpod/flutter_riverpod.dart';

final toneAssistantServiceProvider = Provider<ToneAssistantService>(
  (ref) => const ToneAssistantService(),
);

class ToneAssistantResult {
  const ToneAssistantResult({
    required this.riskScore,
    required this.categories,
    required this.suggestion,
  });

  final int riskScore;
  final List<String> categories;
  final String suggestion;
}

class ToneAssistantService {
  const ToneAssistantService();

  ToneAssistantResult analyze(String input) {
    final lower = input.toLowerCase();
    final riskyWords = ['yine', 'hiçbir', 'asla', 'suç', 'sorumsuz'];
    final hits = riskyWords.where(lower.contains).toList();
    final riskScore = (hits.length * 22).clamp(0, 95);

    final suggestion = input.trim().isEmpty
        ? 'Mesajınızı yazdığınızda daha nötr bir öneri burada görünür.'
        : 'Bugünkü konu hakkında kısa bir not paylaşmak istiyorum. Çocuğun düzeni için belirlenen saat ve bilgilere birlikte uymamızı rica ederim.';

    return ToneAssistantResult(
      riskScore: riskScore,
      categories: hits.isEmpty ? ['nötr'] : ['suçlayıcı dil', 'genelleme'],
      suggestion: suggestion,
    );
  }
}
