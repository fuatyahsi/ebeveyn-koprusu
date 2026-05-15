import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class VisionaryFeaturesScreen extends StatelessWidget {
  const VisionaryFeaturesScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ScreenHeader(
              eyebrow: 'Canlıya hazırlık',
              title: 'Vizyon',
              showBack: showBack,
              trailing: IconButton.filled(
                tooltip: 'Yayın kontrolü',
                onPressed: () => context.push('/reports'),
                icon: const Icon(Icons.verified_outlined),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const _VisionHero(),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Canlı özellikler'),
                  for (final feature in visionaryFeatureSpecs) ...[
                    _FeatureEntryCard(feature: feature),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VisionFeatureScreen extends StatefulWidget {
  const VisionFeatureScreen({
    super.key,
    required this.featureKey,
    this.showBack = true,
  });

  final String featureKey;
  final bool showBack;

  @override
  State<VisionFeatureScreen> createState() => _VisionFeatureScreenState();
}

class _VisionFeatureScreenState extends State<VisionFeatureScreen> {
  late final VisionFeatureSpec _feature = visionFeatureByKey(widget.featureKey);
  bool _loading = false;
  bool _saving = false;
  List<VisionFeatureRecord> _records = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final records = await AppDataService.fetchVisionFeatureRecords(
        _feature.key,
      );
      if (!mounted) return;
      setState(() => _records = records);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addRecord() async {
    final draft = await showModalBottomSheet<_VisionRecordDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _AddVisionRecordSheet(feature: _feature),
    );
    if (draft == null) return;

    setState(() => _saving = true);
    try {
      final record = await AppDataService.createVisionFeatureRecord(
        featureKey: _feature.key,
        title: draft.title,
        detail: draft.detail,
        status: draft.status,
        payload: {
          'feature_title': _feature.title,
          'surface': _feature.surface,
          'created_from': 'vision_feature_screen',
        },
      );
      if (!mounted) return;
      setState(() => _records = [record, ..._records]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_feature.shortTitle} kaydı eklendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _setStatus(VisionFeatureRecord record, String status) async {
    setState(() => _saving = true);
    try {
      await AppDataService.updateVisionFeatureRecordStatus(
        id: record.id,
        status: status,
      );
      await _load();
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _saving = false);
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
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ScreenHeader(
              eyebrow: _feature.kicker,
              title: _feature.shortTitle,
              showBack: widget.showBack,
              trailing: _HeaderAddButton(
                tooltip: _feature.primaryActionLabel,
                onTap: _saving ? null : _addRecord,
              ),
            ),
            if (_loading || _saving)
              const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _FeatureHero(feature: _feature),
                  const SizedBox(height: 12),
                  _HowToUseCard(feature: _feature),
                  const SizedBox(height: 14),
                  SectionLabel(
                    label: 'Canlı kayıtlar',
                    action: TextButton.icon(
                      onPressed: _saving ? null : _addRecord,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Ekle'),
                    ),
                  ),
                  _RecordList(
                    feature: _feature,
                    records: _records,
                    onStatus: _setStatus,
                    busy: _saving,
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Canlı servis hazırlığı'),
                  _ExternalServicesCard(feature: _feature),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisionHero extends StatelessWidget {
  const _VisionHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.paper.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.paper,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Çalışır kayıt, net ekran, hazır servis',
                  style: AppTypography.display(
                    size: 27,
                    color: AppColors.paper,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bu alan artık mock değil: her özellik kendi ekranında Supabase kaydı açar, durum değiştirir ve canlıya çıkmadan önce gereken dış servis bilgisini gösterir.',
            style: AppTypography.ui(
              size: 12.5,
              color: AppColors.paper.withValues(alpha: 0.74),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroChip(label: 'Ebeveyn asistanı kaldırıldı'),
              _HeroChip(label: 'RLS + audit'),
              _HeroChip(label: 'Canlı kayıt'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.paper.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: AppTypography.ui(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.paper,
        ),
      ),
    );
  }
}

class _FeatureEntryCard extends StatelessWidget {
  const _FeatureEntryCard({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paperWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(feature.route),
        borderRadius: BorderRadius.circular(14),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _FeatureIcon(feature: feature),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            feature.title,
                            style: AppTypography.ui(
                              size: 13.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AppPill(label: feature.badge, tone: feature.pillTone),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feature.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.ui(
                        size: 11.5,
                        color: AppColors.inkMute,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureHero extends StatelessWidget {
  const _FeatureHero({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.paper.withValues(alpha: 0.14),
                  ),
                ),
                child: Icon(feature.icon, color: AppColors.paper),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppPill(label: feature.badge, tone: feature.pillTone),
                    const SizedBox(height: 6),
                    Text(
                      feature.title,
                      style: AppTypography.display(
                        size: 30,
                        color: AppColors.paper,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            feature.usageTip,
            style: AppTypography.ui(
              size: 12.5,
              color: AppColors.paper.withValues(alpha: 0.74),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: feature.tone,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(feature.icon, color: AppColors.ink, size: 21),
    );
  }
}

class _HowToUseCard extends StatelessWidget {
  const _HowToUseCard({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: feature.iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Nasıl kullanılır?',
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < feature.steps.length; i++) ...[
            _StepRow(index: i + 1, text: feature.steps[i]),
            if (i < feature.steps.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.sageSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$index',
            style: AppTypography.mono(
              size: 10,
              color: AppColors.sage,
              letter: 0,
            ),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: AppTypography.ui(
              size: 12.5,
              color: AppColors.inkSoft,
              height: 1.32,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.feature,
    required this.records,
    required this.onStatus,
    required this.busy,
  });

  final VisionFeatureSpec feature;
  final List<VisionFeatureRecord> records;
  final Future<void> Function(VisionFeatureRecord record, String status)
  onStatus;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return AppCard(
        child: Text(
          feature.emptyText,
          style: AppTypography.ui(size: 13, color: AppColors.inkMute),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < records.length; i++) ...[
          _RecordCard(
            feature: feature,
            record: records[i],
            busy: busy,
            onStatus: onStatus,
          ),
          if (i < records.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.feature,
    required this.record,
    required this.busy,
    required this.onStatus,
  });

  final VisionFeatureSpec feature;
  final VisionFeatureRecord record;
  final bool busy;
  final Future<void> Function(VisionFeatureRecord record, String status)
  onStatus;

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd MMM HH:mm', 'tr');
    final isDone = record.status == feature.doneStatus;
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FeatureIcon(feature: feature),
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
                    const SizedBox(height: 3),
                    Text(
                      formatter.format(record.createdAt),
                      style: AppTypography.mono(size: 9.5),
                    ),
                  ],
                ),
              ),
              AppPill(
                label: feature.statusLabel(record.status),
                tone: isDone ? PillTone.sage : PillTone.ochre,
              ),
            ],
          ),
          if (record.detail.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              record.detail,
              style: AppTypography.ui(
                size: 12.5,
                color: AppColors.inkSoft,
                height: 1.32,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: feature.statuses.containsKey(record.status)
                      ? record.status
                      : feature.defaultStatus,
                  decoration: const InputDecoration(
                    labelText: 'Durum',
                    isDense: true,
                  ),
                  items: [
                    for (final entry in feature.statuses.entries)
                      DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                  ],
                  onChanged: busy || isDone
                      ? null
                      : (value) {
                          if (value != null) onStatus(record, value);
                        },
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: busy || isDone
                    ? null
                    : () => onStatus(record, feature.doneStatus),
                icon: const Icon(Icons.check, size: 17),
                label: Text(isDone ? 'Tamam' : 'Tamamla'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExternalServicesCard extends StatelessWidget {
  const _ExternalServicesCard({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (feature.services.isEmpty)
            _ServiceRow(
              icon: Icons.check_circle_outline,
              title: 'Ek dış üyelik gerekmiyor',
              detail:
                  'Bu ekran Supabase verisi ve cihaz içi izinlerle çalışır. Canlıya çıkışta sadece genel uygulama yayın adımları gerekir.',
              env: const [],
            )
          else
            for (var i = 0; i < feature.services.length; i++) ...[
              _ServiceRow(
                icon: feature.services[i].icon,
                title: feature.services[i].title,
                detail: feature.services[i].detail,
                env: feature.services[i].env,
              ),
              if (i < feature.services.length - 1) const Divider(height: 18),
            ],
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.env,
  });

  final IconData icon;
  final String title;
  final String detail;
  final List<String> env;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.sageSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.sage),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.ui(weight: FontWeight.w700)),
              const SizedBox(height: 3),
              Text(
                detail,
                style: AppTypography.ui(
                  size: 12,
                  color: AppColors.inkSoft,
                  height: 1.32,
                ),
              ),
              if (env.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final key in env)
                      AppPill(label: key, tone: PillTone.mute),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _HeaderAddButton extends StatelessWidget {
  const _HeaderAddButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.ink,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 36,
            child: Icon(Icons.add, size: 18, color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}

class _AddVisionRecordSheet extends StatefulWidget {
  const _AddVisionRecordSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddVisionRecordSheet> createState() => _AddVisionRecordSheetState();
}

class _AddVisionRecordSheetState extends State<_AddVisionRecordSheet> {
  late final TextEditingController _titleController = TextEditingController(
    text: widget.feature.defaultTitle,
  );
  late final TextEditingController _detailController = TextEditingController(
    text: widget.feature.defaultDetail,
  );
  late String _status = widget.feature.defaultStatus;

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: title,
        detail: _detailController.text.trim(),
        status: _status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _FeatureIcon(feature: widget.feature),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.feature.primaryActionLabel,
                        style: AppTypography.display(size: 28, height: 1),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.feature.kicker,
                        style: AppTypography.mono(letter: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: widget.feature.titleFieldLabel,
                prefixIcon: Icon(widget.feature.icon),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _detailController,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: widget.feature.detailFieldLabel,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Başlangıç durumu'),
              items: [
                for (final entry in widget.feature.statuses.entries)
                  DropdownMenuItem(value: entry.key, child: Text(entry.value)),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Kaydı oluştur'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Vazgeç'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisionRecordDraft {
  const _VisionRecordDraft({
    required this.title,
    required this.detail,
    required this.status,
  });

  final String title;
  final String detail;
  final String status;
}

class VisionFeatureSpec {
  const VisionFeatureSpec({
    required this.key,
    required this.title,
    required this.shortTitle,
    required this.kicker,
    required this.summary,
    required this.usageTip,
    required this.steps,
    required this.icon,
    required this.tone,
    required this.badge,
    required this.pillTone,
    required this.primaryActionLabel,
    required this.defaultTitle,
    required this.defaultDetail,
    required this.emptyText,
    required this.statuses,
    required this.defaultStatus,
    required this.doneStatus,
    required this.services,
    required this.surface,
    this.titleFieldLabel = 'Başlık',
    this.detailFieldLabel = 'Detay',
  });

  final String key;
  final String title;
  final String shortTitle;
  final String kicker;
  final String summary;
  final String usageTip;
  final List<String> steps;
  final IconData icon;
  final Color tone;
  final String badge;
  final PillTone pillTone;
  final String primaryActionLabel;
  final String defaultTitle;
  final String defaultDetail;
  final String emptyText;
  final Map<String, String> statuses;
  final String defaultStatus;
  final String doneStatus;
  final List<VisionExternalService> services;
  final String surface;
  final String titleFieldLabel;
  final String detailFieldLabel;

  String get route => '/visionary/$key';

  Color get iconColor => switch (pillTone) {
    PillTone.ochre => AppColors.ochre,
    PillTone.terra => AppColors.terra,
    _ => AppColors.sage,
  };

  String statusLabel(String status) => statuses[status] ?? status;
}

class VisionExternalService {
  const VisionExternalService({
    required this.title,
    required this.detail,
    required this.icon,
    this.env = const [],
  });

  final String title;
  final String detail;
  final IconData icon;
  final List<String> env;
}

VisionFeatureSpec visionFeatureByKey(String key) {
  for (final feature in visionaryFeatureSpecs) {
    if (feature.key == key) return feature;
  }
  return visionaryFeatureSpecs.first;
}

const _approvalStatuses = <String, String>{
  'draft': 'Taslak',
  'pending': 'Onay bekliyor',
  'approved': 'Onaylandı',
  'completed': 'Tamamlandı',
};

const _simpleStatuses = <String, String>{
  'draft': 'Taslak',
  'active': 'Aktif',
  'completed': 'Tamamlandı',
};

const visionaryFeatureSpecs = <VisionFeatureSpec>[
  VisionFeatureSpec(
    key: 'swap',
    title: 'Akıllı takvim ve gün takası',
    shortTitle: 'Gün takası',
    kicker: 'Smart swap',
    summary: 'Mahkeme takvimindeki günü karşılık günle takas talebine çevirir.',
    usageTip:
        'Takas talebi karşı tarafa açık onayla gider; sistem otomatik karar vermez. Her talep audit izine düşer ve onaylanınca takvimle ilişkilendirilir.',
    steps: [
      'Asıl günü ve önerilen karşılık günü yaz.',
      'Gerekçeyi kısa ve nötr biçimde ekle.',
      'Karşı taraf onaylayınca durumu Onaylandı veya Tamamlandı yap.',
    ],
    icon: Icons.swap_horiz_rounded,
    tone: AppColors.sageSoft,
    badge: 'Alt bar',
    pillTone: PillTone.sage,
    primaryActionLabel: 'Takas talebi oluştur',
    defaultTitle: 'Cuma teslimini pazar karşılığıyla takas',
    defaultDetail: 'Asıl gün: Cuma 17:00. Öneri: Pazar 12:00-18:00.',
    emptyText: 'Henüz takas talebi yok. + ile ilk canlı talebi oluştur.',
    statuses: _approvalStatuses,
    defaultStatus: 'pending',
    doneStatus: 'completed',
    services: [],
    surface: 'bottom',
    titleFieldLabel: 'Takas başlığı',
    detailFieldLabel: 'Asıl gün, karşılık gün ve gerekçe',
  ),
  VisionFeatureSpec(
    key: 'geofence',
    title: 'Cihaz içi teslim hatırlatıcı',
    shortTitle: 'Teslim sınırı',
    kicker: 'Geofence',
    summary: 'Okul veya teslim noktasına yaklaşınca lokal bildirim üretir.',
    usageTip:
        'Konum cihaz içinde değerlendirilir. Canlı konum Supabase’e yazılmaz; sadece hatırlatıcı tercihi ve izin durumu kayıtlanır.',
    steps: [
      'Teslim noktası adını ve hatırlatma aralığını gir.',
      'Telefonda konum ve lokal bildirim iznini aç.',
      'Teslim günü hatırlatıcıyı Aktif olarak takip et.',
    ],
    icon: Icons.location_searching_outlined,
    tone: AppColors.sageSoft,
    badge: 'Cihaz',
    pillTone: PillTone.sage,
    primaryActionLabel: 'Hatırlatıcı kur',
    defaultTitle: 'Okul çıkışı teslim hatırlatıcısı',
    defaultDetail: 'Atatürk İlkokulu çevresinde 100 metre, Cuma 16:45.',
    emptyText: 'Henüz teslim hatırlatıcısı yok.',
    statuses: {
      'draft': 'Taslak',
      'permission_needed': 'İzin gerekli',
      'active': 'Aktif',
      'completed': 'Tamamlandı',
    },
    defaultStatus: 'permission_needed',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Android/iOS izinleri',
        detail:
            'Konum ve lokal bildirim izinleri mağaza açıklamasıyla uyumlu olmalı. Sunucuya canlı konum gönderilmeyecek.',
        icon: Icons.phonelink_lock_outlined,
        env: ['ANDROID_FINE_LOCATION', 'IOS_LOCATION_WHEN_IN_USE'],
      ),
    ],
    surface: 'sidebar',
    titleFieldLabel: 'Hatırlatıcı adı',
    detailFieldLabel: 'Konum, zaman ve uyarı notu',
  ),
  VisionFeatureSpec(
    key: 'banking',
    title: 'Açık bankacılık masraf taslağı',
    shortTitle: 'Banka taslağı',
    kicker: 'Open banking',
    summary: 'Seçili banka işlemini masraf talebine dönüştürür.',
    usageTip:
        'Kullanıcı OAuth ile bağlanır ve sadece seçtiği tekil işlemi masraf taslağına çevirir. Banka şifresi veya tam ekstre uygulamada tutulmaz.',
    steps: [
      'Açık bankacılık sağlayıcısından uygulama ve redirect URL oluştur.',
      'Kullanıcının seçtiği işlemi masraf taslağı olarak kaydet.',
      'Taslağı masraf ekranında onaya gönder.',
    ],
    icon: Icons.account_balance_outlined,
    tone: AppColors.ochreSoft,
    badge: 'API',
    pillTone: PillTone.ochre,
    primaryActionLabel: 'Masraf taslağı aç',
    defaultTitle: 'Banka işleminden servis ücreti',
    defaultDetail:
        'İşlem seçildiğinde tutar, tarih ve açıklama buraya düşecek.',
    emptyText: 'Henüz banka masraf taslağı yok.',
    statuses: {
      'draft': 'Taslak',
      'provider_needed': 'Sağlayıcı gerekli',
      'ready': 'Hazır',
      'completed': 'Masrafa dönüştü',
    },
    defaultStatus: 'provider_needed',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Lisanslı açık bankacılık sağlayıcısı',
        detail:
            'Canlı bağlantı için sağlayıcı hesabı, client ID, secret ve redirect URL gerekli. Türkiye’de yetkili sağlayıcıyla ilerlenmeli.',
        icon: Icons.account_balance_wallet_outlined,
        env: [
          'OPEN_BANKING_PROVIDER',
          'OPEN_BANKING_CLIENT_ID',
          'OPEN_BANKING_CLIENT_SECRET',
        ],
      ),
    ],
    surface: 'home',
    titleFieldLabel: 'Taslak başlığı',
    detailFieldLabel: 'İşlem açıklaması veya banka notu',
  ),
  VisionFeatureSpec(
    key: 'harmony',
    title: 'Pozitif iletişim skoru',
    shortTitle: 'Uyum skoru',
    kicker: 'Harmony score',
    summary: 'Ailenin ortak uyumunu motivasyonel dille takip eder.',
    usageTip:
        'Skor kişileri puanlamak için değil, aile akışının toplam sakinliğini göstermek için kullanılır. Rapor dili suçlayıcı olmaz.',
    steps: [
      'Aylık teslim, mesaj, masraf ve itiraz sinyallerini özetle.',
      'Kişi bazlı değil aile bazlı skor kaydı üret.',
      'Skoru ana sayfada ve raporda motivasyonel dille göster.',
    ],
    icon: Icons.favorite_border_rounded,
    tone: AppColors.sageSoft,
    badge: 'Ana sayfa',
    pillTone: PillTone.sage,
    primaryActionLabel: 'Uyum özeti oluştur',
    defaultTitle: 'Mayıs aile uyum özeti',
    defaultDetail:
        'Zamanında teslim, itirazsız masraf ve sakin mesaj sinyalleri.',
    emptyText: 'Henüz uyum skoru kaydı yok.',
    statuses: _simpleStatuses,
    defaultStatus: 'draft',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Supabase zamanlanmış hesaplama',
        detail:
            'Canlıda edge function veya cron ile aylık skor kaydı üretilecek. Şimdiki ekran manuel canlı kayıt açar.',
        icon: Icons.schedule_outlined,
        env: ['SUPABASE_SERVICE_ROLE_KEY'],
      ),
    ],
    surface: 'home',
    titleFieldLabel: 'Skor dönemi',
    detailFieldLabel: 'Skoru etkileyen sinyaller',
  ),
  VisionFeatureSpec(
    key: 'teen',
    title: 'Teen modu',
    shortTitle: 'Teen modu',
    kicker: '13+ salt okunur',
    summary: 'Ergen çocuk için sınırlı takvim ve talep ekranı.',
    usageTip:
        'Teen modu açık ebeveyn rızasıyla çalışır. Çocuk sadece kendi takvimini görür ve talep bırakır; mesaj, masraf ve belge erişimi kapalıdır.',
    steps: [
      'Ebeveyn rızasını ve yaş uygunluğunu kayıt altına al.',
      'Çocuğa salt okunur takvim erişimi ver.',
      'Çocuğun taleplerini ebeveyn onayına düşür.',
    ],
    icon: Icons.school_outlined,
    tone: AppColors.paperWhite,
    badge: 'Rıza',
    pillTone: PillTone.mute,
    primaryActionLabel: 'Teen erişimi aç',
    defaultTitle: 'Deniz için salt okunur takvim',
    defaultDetail:
        'Erişim kapsamı: Takvimim ve Talep Ekle. Mesaj/masraf kapalı.',
    emptyText: 'Henüz teen modu kaydı yok.',
    statuses: _approvalStatuses,
    defaultStatus: 'pending',
    doneStatus: 'completed',
    services: [],
    surface: 'sidebar',
    titleFieldLabel: 'Erişim başlığı',
    detailFieldLabel: 'Yaş, kapsam ve rıza notu',
  ),
  VisionFeatureSpec(
    key: 'wardrobe',
    title: 'Beden kartı ve ihtiyaç vitrini',
    shortTitle: 'Beden kartı',
    kicker: 'Kids wardrobe',
    summary: 'Boy, ayakkabı, kıyafet ve ihtiyaç takibini ortaklaştırır.',
    usageTip:
        'Bu ekran sağlık verisi tutmaz; pratik beden ölçüsü ve ihtiyaç bilgisini iki ebeveynin aynı yerden güncellemesi için kullanılır.',
    steps: [
      'Güncel beden veya ihtiyaç bilgisini yaz.',
      'Alınacak, alındı veya güncellendi durumunu seç.',
      'İhtiyaç kapanınca Tamamlandı olarak işaretle.',
    ],
    icon: Icons.child_friendly_outlined,
    tone: AppColors.sageSoft,
    badge: 'Ana sayfa',
    pillTone: PillTone.sage,
    primaryActionLabel: 'Beden/ ihtiyaç ekle',
    defaultTitle: 'Ayakkabı 32 numara güncellendi',
    defaultDetail: 'Spor ayakkabı ihtiyacı var. Mevsimlik mont tamam.',
    emptyText: 'Henüz beden veya ihtiyaç kaydı yok.',
    statuses: {
      'draft': 'Taslak',
      'needed': 'İhtiyaç',
      'bought': 'Alındı',
      'completed': 'Güncellendi',
    },
    defaultStatus: 'needed',
    doneStatus: 'completed',
    services: [],
    surface: 'home',
    titleFieldLabel: 'Beden veya ihtiyaç',
    detailFieldLabel: 'Ölçü, adet, mevsim veya not',
  ),
  VisionFeatureSpec(
    key: 'printouts',
    title: 'Görsel çocuk takvimi',
    shortTitle: 'Çıktı',
    kicker: 'Print out',
    summary: 'Çocuğun odasına asılabilecek ikonlu PDF hazırlığı.',
    usageTip:
        'Takvim verisi cihaz içinde PDF’e dönüşür. Çocuğun okuyacağı sade ikonlar ve renkler kullanılır; dış servise çocuk takvimi gönderilmez.',
    steps: [
      'Ay ve görünüm tipini seç.',
      'PDF önizleme kaydını oluştur.',
      'Hazır olunca yazdırma veya paylaşma akışına geç.',
    ],
    icon: Icons.print_outlined,
    tone: AppColors.ochreSoft,
    badge: 'PDF',
    pillTone: PillTone.ochre,
    primaryActionLabel: 'PDF çıktısı hazırla',
    defaultTitle: 'Mayıs çocuk takvimi',
    defaultDetail: 'İkonlu teslim günleri, okul ve özel günler dahil.',
    emptyText: 'Henüz çocuk takvimi çıktısı yok.',
    statuses: {'draft': 'Taslak', 'preview': 'Önizleme', 'completed': 'Hazır'},
    defaultStatus: 'preview',
    doneStatus: 'completed',
    services: [],
    surface: 'sidebar',
    titleFieldLabel: 'Çıktı başlığı',
    detailFieldLabel: 'Ay, görünüm ve dahil edilecek bilgiler',
  ),
  VisionFeatureSpec(
    key: 'quiet-hours',
    title: 'Sessiz zaman',
    shortTitle: 'Sessiz zaman',
    kicker: 'Quiet hours',
    summary: 'Gece mesajlarını acil değilse sabaha erteler.',
    usageTip:
        'Sessiz zaman karşı tarafı susturmaz; acil olmayan mesajı saygılı biçimde erteler. Acil işareti audit izine girer.',
    steps: [
      'Sessiz saat aralığını belirle.',
      'Acil istisnasını hangi koşulda kullanacağını yaz.',
      'Kuralı Aktif yap ve mesaj ekranında uygula.',
    ],
    icon: Icons.nightlight_round_outlined,
    tone: AppColors.paperWhite,
    badge: 'Alt bar',
    pillTone: PillTone.mute,
    primaryActionLabel: 'Sessiz saat kuralı ekle',
    defaultTitle: '21:00-08:00 sessiz zaman',
    defaultDetail: 'Acil olmayan mesajlar sabah bildirimine ertelensin.',
    emptyText: 'Henüz sessiz zaman kuralı yok.',
    statuses: _simpleStatuses,
    defaultStatus: 'active',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Push bildirim planı',
        detail:
            'Canlıda FCM ile acil/ertelenmiş bildirim ayrımı yapılacak. Kullanıcı tercihleri Supabase’de tutulur.',
        icon: Icons.notifications_active_outlined,
        env: ['FCM_SERVER_KEY', 'SUPABASE_SERVICE_ROLE_KEY'],
      ),
    ],
    surface: 'bottom',
    titleFieldLabel: 'Kural adı',
    detailFieldLabel: 'Saat aralığı ve acil istisnası',
  ),
  VisionFeatureSpec(
    key: 'dropbox',
    title: 'Tek yönlü evrak köprüsü',
    shortTitle: 'Evrak köprüsü',
    kicker: 'Third-party dropbox',
    summary: 'Öğretmen veya doktor süreli linkle belge bırakır.',
    usageTip:
        'Üçüncü kişi uygulamaya üye olmadan süreli ve tek yönlü linkle belge yükler. Yüklenen belge iki ebeveyn için şeffaf kayıt olur.',
    steps: [
      'Kişi, kategori ve link süresini gir.',
      'Linki öğretmen, doktor veya danışmana gönder.',
      'Belge gelince kaydı Tamamlandı yap.',
    ],
    icon: Icons.forward_to_inbox_outlined,
    tone: AppColors.sageSoft,
    badge: 'Link',
    pillTone: PillTone.sage,
    primaryActionLabel: 'Evrak linki hazırla',
    defaultTitle: 'Öğretmen için 48 saatlik link',
    defaultDetail: 'Kategori: Okul evrakı. Yükleme tek yönlü ve süreli.',
    emptyText: 'Henüz evrak köprüsü linki yok.',
    statuses: {
      'draft': 'Taslak',
      'link_ready': 'Link hazır',
      'uploaded': 'Belge geldi',
      'completed': 'Tamamlandı',
    },
    defaultStatus: 'draft',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Supabase Storage + Edge Function',
        detail:
            'Süreli upload token üreten function ve özel storage bucket gerekir. Link herkese açık kalıcı URL olmayacak.',
        icon: Icons.cloud_upload_outlined,
        env: ['DOCUMENTS_BUCKET', 'SUPABASE_SERVICE_ROLE_KEY'],
      ),
    ],
    surface: 'home',
    titleFieldLabel: 'Link başlığı',
    detailFieldLabel: 'Kişi, süre, kategori ve paylaşım notu',
  ),
  VisionFeatureSpec(
    key: 'calls',
    title: 'Uygulama içi arama',
    shortTitle: 'Arama',
    kicker: 'VoIP metadata',
    summary: 'Telefon numarası gizli kalır, sadece arama metası kayıtlanır.',
    usageTip:
        'Ses veya görüntü kaydı tutulmaz. Canlıda Agora ya da Twilio token üretimi gerekir; uygulama yalnızca saat, süre ve cevap durumunu saklar.',
    steps: [
      'VoIP sağlayıcısı hesabı ve uygulama anahtarlarını oluştur.',
      'Arama tokenını edge function üzerinden üret.',
      'Arama bitince sadece meta kaydı ekle.',
    ],
    icon: Icons.call_outlined,
    tone: AppColors.ochreSoft,
    badge: 'API',
    pillTone: PillTone.ochre,
    primaryActionLabel: 'Arama kaydı aç',
    defaultTitle: 'Uygulama içi arama denemesi',
    defaultDetail: 'Ses kaydı yok. Meta: başladı, süre, cevaplandı/cevapsız.',
    emptyText: 'Henüz arama meta kaydı yok.',
    statuses: {
      'draft': 'Taslak',
      'token_needed': 'Token gerekli',
      'completed': 'Tamamlandı',
    },
    defaultStatus: 'token_needed',
    doneStatus: 'completed',
    services: [
      VisionExternalService(
        title: 'Agora veya Twilio',
        detail:
            'Canlı arama için RTC app, token üretimi ve mağaza gizlilik açıklaması gerekir.',
        icon: Icons.vpn_key_outlined,
        env: ['RTC_PROVIDER', 'AGORA_APP_ID', 'TWILIO_ACCOUNT_SID'],
      ),
    ],
    surface: 'sidebar',
    titleFieldLabel: 'Arama başlığı',
    detailFieldLabel: 'Arama amacı, durum ve meta notu',
  ),
  VisionFeatureSpec(
    key: 'holiday-memory',
    title: 'Sıra kimde hafızası',
    shortTitle: 'Sıra hafızası',
    kicker: 'Holiday tracker',
    summary: 'Geçmiş bayram ve yılbaşı teslimlerini sakin dille özetler.',
    usageTip:
        'Bu özellik hukuki emir üretmez; sadece geçmiş takvim kayıtlarına bakarak sıra hafızası çıkarır ve öneri dilini yumuşak tutar.',
    steps: [
      'Bayram, yılbaşı veya özel gün etiketini seç.',
      'Geçmiş yılları not olarak özetle.',
      'Öneriyi takvim veya rapor ekranında kullan.',
    ],
    icon: Icons.history_edu_outlined,
    tone: AppColors.paperWhite,
    badge: 'Takvim',
    pillTone: PillTone.mute,
    primaryActionLabel: 'Hafıza kaydı üret',
    defaultTitle: 'Ramazan Bayramı sıra hafızası',
    defaultDetail: 'Son üç yılın teslim özeti ve bu yıl için nötr öneri.',
    emptyText: 'Henüz sıra hafızası kaydı yok.',
    statuses: _simpleStatuses,
    defaultStatus: 'draft',
    doneStatus: 'completed',
    services: [],
    surface: 'sidebar',
    titleFieldLabel: 'Özel gün',
    detailFieldLabel: 'Geçmiş yıllar ve öneri notu',
  ),
];
