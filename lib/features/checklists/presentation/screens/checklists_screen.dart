import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';

class ChecklistsScreen extends StatefulWidget {
  const ChecklistsScreen({super.key});

  @override
  State<ChecklistsScreen> createState() => _ChecklistsScreenState();
}

class _ChecklistsScreenState extends State<ChecklistsScreen> {
  bool _loading = false;
  List<LiveRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final items = await AppDataService.fetchChecklistItems();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _ChecklistItemSheet(),
    );
    if (!mounted || title == null || title.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      final item = await AppDataService.addChecklistItem(title);
      if (!mounted) return;
      setState(() => _items = [..._items, item]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Checklist maddesi eklendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggle(LiveRecord item, bool value) async {
    setState(() => _loading = true);
    try {
      await AppDataService.setChecklistItemChecked(
        id: item.id,
        isChecked: value,
      );
      await _load();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppDataService.friendlyError(error)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ScreenHeader(
              eyebrow: 'Teslim hazırlığı',
              title: 'Checklist',
              showBack: true,
              trailing: IconButton.filled(
                onPressed: _loading ? null : _add,
                icon: const Icon(Icons.add),
              ),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ModuleUsageTip(
                    icon: Icons.checklist_outlined,
                    text:
                        'Teslim çantası, ilaç, kimlik, kıyafet gibi maddeleri canlı checklist olarak takip et. İşaretlediğin her madde Supabase’de saklanır ve tekrar açıldığında aynı durumda gelir.',
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Maddeler'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: _items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Henüz madde yok. + ile ilk maddeyi ekle.',
                              style: AppTypography.ui(
                                size: 13,
                                color: AppColors.inkMute,
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              for (var i = 0; i < _items.length; i++) ...[
                                CheckboxListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  value: _items[i].status == 'done',
                                  onChanged: (value) =>
                                      _toggle(_items[i], value ?? false),
                                  title: Text(_items[i].title),
                                  subtitle: Text(_items[i].subtitle),
                                ),
                                if (i < _items.length - 1)
                                  const Divider(height: 1),
                              ],
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChecklistItemSheet extends StatefulWidget {
  const _ChecklistItemSheet();

  @override
  State<_ChecklistItemSheet> createState() => _ChecklistItemSheetState();
}

class _ChecklistItemSheetState extends State<_ChecklistItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Checklist maddesi', style: AppTypography.display(size: 30)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Madde adı'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Madde adı zorunlu.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add),
              label: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_controller.text.trim());
  }
}
