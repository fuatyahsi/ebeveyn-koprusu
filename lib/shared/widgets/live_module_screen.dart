import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LiveModuleScreen extends StatefulWidget {
  const LiveModuleScreen({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.moduleKey,
    required this.usage,
    required this.emptyText,
    required this.addTitle,
    required this.addDetailLabel,
    this.icon = Icons.data_object_outlined,
    this.showBack = true,
    this.primaryStatus,
    this.primaryStatusLabel,
    this.secondaryStatus,
    this.secondaryStatusLabel,
    this.readOnly = false,
  });

  final String title;
  final String eyebrow;
  final String moduleKey;
  final String usage;
  final String emptyText;
  final String addTitle;
  final String addDetailLabel;
  final IconData icon;
  final bool showBack;
  final String? primaryStatus;
  final String? primaryStatusLabel;
  final String? secondaryStatus;
  final String? secondaryStatusLabel;
  final bool readOnly;

  @override
  State<LiveModuleScreen> createState() => _LiveModuleScreenState();
}

class _LiveModuleScreenState extends State<LiveModuleScreen> {
  bool _loading = false;
  List<LiveRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final records = await AppDataService.fetchLiveRecords(widget.moduleKey);
      if (!mounted) return;
      setState(() => _records = records);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final draft = await showModalBottomSheet<_RecordDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RecordSheet(
        title: widget.addTitle,
        detailLabel: widget.addDetailLabel,
      ),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      final record = await AppDataService.addLiveRecord(
        moduleKey: widget.moduleKey,
        title: draft.title,
        detail: draft.detail,
      );
      if (!mounted) return;
      setState(() => _records = [record, ..._records]);
      _showMessage('Kayıt eklendi.');
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit(LiveRecord record) async {
    final draft = await showModalBottomSheet<_RecordDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _RecordSheet(
        title: 'Kaydı güncelle',
        detailLabel: widget.addDetailLabel,
        initialTitle: record.title,
        initialDetail: record.subtitle,
      ),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      await AppDataService.updateLiveRecord(
        moduleKey: widget.moduleKey,
        id: record.id,
        title: draft.title,
        detail: draft.detail,
      );
      await _load();
      _showMessage('Kayıt güncellendi.');
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(LiveRecord record, String status) async {
    setState(() => _loading = true);
    try {
      await AppDataService.setLiveRecordStatus(
        moduleKey: widget.moduleKey,
        id: record.id,
        status: status,
      );
      await _load();
      _showMessage('Durum güncellendi.');
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

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
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
              eyebrow: widget.eyebrow,
              title: widget.title,
              showBack: widget.showBack,
              trailing: widget.readOnly
                  ? null
                  : _AddButton(onTap: _loading ? null : _add),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ModuleUsageTip(text: widget.usage, icon: widget.icon),
                  const SizedBox(height: 14),
                  SectionLabel(label: 'Canlı kayıtlar'),
                  if (_records.isEmpty)
                    AppCard(
                      child: Text(
                        widget.emptyText,
                        style: AppTypography.ui(
                          size: 13,
                          weight: FontWeight.w400,
                          color: AppColors.inkMute,
                        ),
                      ),
                    )
                  else
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (var i = 0; i < _records.length; i++) ...[
                            _RecordRow(
                              record: _records[i],
                              icon: widget.icon,
                              readOnly: widget.readOnly,
                              onEdit: () => _edit(_records[i]),
                              primaryLabel: widget.primaryStatusLabel,
                              onPrimary: widget.primaryStatus == null
                                  ? null
                                  : () => _setStatus(
                                      _records[i],
                                      widget.primaryStatus!,
                                    ),
                              secondaryLabel: widget.secondaryStatusLabel,
                              onSecondary: widget.secondaryStatus == null
                                  ? null
                                  : () => _setStatus(
                                      _records[i],
                                      widget.secondaryStatus!,
                                    ),
                            ),
                            if (i < _records.length - 1)
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

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Kayıt ekle',
      child: Material(
        color: AppColors.ink,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 38,
            child: Icon(Icons.add, size: 19, color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.record,
    required this.icon,
    required this.readOnly,
    required this.onEdit,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  final LiveRecord record;
  final IconData icon;
  final bool readOnly;
  final VoidCallback onEdit;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM HH:mm', 'tr_TR').format(record.createdAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.sageSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: AppColors.sage),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title,
                      style: AppTypography.ui(
                        size: 13.5,
                        weight: FontWeight.w700,
                      ),
                    ),
                    if (record.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        record.subtitle,
                        style: AppTypography.ui(
                          size: 11.5,
                          weight: FontWeight.w400,
                          color: AppColors.inkMute,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Text(
                      date,
                      style: AppTypography.mono(
                        size: 9.5,
                        letter: 0.6,
                        color: AppColors.inkMute,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppPill(label: record.status, tone: PillTone.sage),
                  if (!readOnly)
                    IconButton(
                      tooltip: 'Düzenle',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                ],
              ),
            ],
          ),
          if (onPrimary != null || onSecondary != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (onPrimary != null)
                  Expanded(
                    child: FilledButton(
                      onPressed: onPrimary,
                      child: Text(primaryLabel ?? 'Onayla'),
                    ),
                  ),
                if (onPrimary != null && onSecondary != null)
                  const SizedBox(width: 8),
                if (onSecondary != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      child: Text(secondaryLabel ?? 'Kapat'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RecordSheet extends StatefulWidget {
  const _RecordSheet({
    required this.title,
    required this.detailLabel,
    this.initialTitle,
    this.initialDetail,
  });

  final String title;
  final String detailLabel;
  final String? initialTitle;
  final String? initialDetail;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _detailController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle ?? '');
    _detailController = TextEditingController(text: widget.initialDetail ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
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
            Text(widget.title, style: AppTypography.display(size: 30)),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Başlık'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Başlık zorunlu.';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _detailController,
              decoration: InputDecoration(labelText: widget.detailLabel),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _RecordDraft(
        title: _titleController.text,
        detail: _detailController.text,
      ),
    );
  }
}

class _RecordDraft {
  const _RecordDraft({required this.title, required this.detail});

  final String title;
  final String detail;
}
