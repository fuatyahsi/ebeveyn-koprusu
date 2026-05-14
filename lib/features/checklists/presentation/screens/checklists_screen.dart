import 'package:ebeveyn_koprusu/shared/widgets/module_detail_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  final Set<String> _checked = {'Okul çantası'};

  @override
  Widget build(BuildContext context) {
    const items = ['Okul çantası', 'İlaç', 'Kıyafet', 'Kimlik fotokopisi'];

    return ModuleDetailScreen(
      title: 'Checklist',
      route: '/checklists',
      children: [
        SectionCard(
          title: 'Teslim çantası',
          icon: Icons.checklist_outlined,
          child: Column(
            children: [
              for (final item in items)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _checked.contains(item),
                  onChanged: (value) {
                    setState(() {
                      if (value ?? false) {
                        _checked.add(item);
                      } else {
                        _checked.remove(item);
                      }
                    });
                  },
                  title: Text(item),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
