import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/models/app_module.dart';
import 'package:ebeveyn_koprusu/core/providers/mock_data_provider.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModuleDetailScreen extends ConsumerWidget {
  const ModuleDetailScreen({
    required this.title,
    required this.route,
    this.children = const [],
    super.key,
  });

  final String title;
  final String route;
  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final module = ref
        .watch(appModulesProvider)
        .where((item) => item.route == route)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            ScreenHeader(title: title, eyebrow: 'Modül', showBack: true),
            if (module != null) _ModuleHeader(module: module),
            if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module});

  final AppModule module;

  @override
  Widget build(BuildContext context) {
    final status = switch (module.status) {
      ModuleStatus.scaffolded => ('Hazir', PillTone.sage),
      ModuleStatus.mock => ('Demo', PillTone.ochre),
      ModuleStatus.needsCredentials => ('Ayar gerekli', PillTone.terra),
    };

    return AppCard(
      tint: CardTint.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(module.icon, size: 28, color: AppColors.paper),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  module.title,
                  style: AppTypography.display(
                    size: 28,
                    color: AppColors.paper,
                  ),
                ),
              ),
              AppPill(label: status.$1, tone: status.$2),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            module.summary,
            style: AppTypography.ui(
              color: AppColors.paper,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            module.acceptance,
            style: AppTypography.ui(
              color: AppColors.paper.withValues(alpha: 0.72),
              weight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
