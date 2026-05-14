import 'package:ebeveyn_koprusu/core/providers/mock_data_provider.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChildrenScreen extends ConsumerWidget {
  const ChildrenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(childrenProvider).first;

    return ModuleDetailScreen(
      title: 'Çocuk Bilgileri',
      route: '/children',
      children: [
        SectionCard(
          title: child.fullName,
          icon: Icons.child_care_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${child.ageLabel} • ${child.school}'),
              const SizedBox(height: 12),
              const Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Okul')),
                  Chip(label: Text('Servis')),
                  Chip(label: Text('Sağlık')),
                  Chip(label: Text('Yakınlar')),
                  Chip(label: Text('İhtiyaçlar')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
