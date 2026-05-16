import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/core/services/local_notification_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      builder: (context) => _addSheetForFeature(_feature),
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
          ...draft.payload,
        },
      );
      if (draft.calendarStartAt != null && draft.calendarEndAt != null) {
        await AppDataService.addCustodyEvent(
          title: draft.calendarTitle ?? draft.title,
          startAt: draft.calendarStartAt!,
          endAt: draft.calendarEndAt!,
          location: draft.calendarLocation ?? '',
        );
      }
      if (draft.notificationTitle != null && draft.notificationBody != null) {
        await LocalNotificationService.showReminderCreated(
          title: draft.notificationTitle!,
          body: draft.notificationBody!,
        );
      }
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

  Widget _addSheetForFeature(VisionFeatureSpec feature) {
    return switch (feature.key) {
      'swap' => _AddSwapSheet(feature: feature),
      'geofence' => _AddGeofenceSheet(feature: feature),
      'wardrobe' => _AddWardrobeSheet(feature: feature),
      'teen' => _AddTeenSheet(feature: feature),
      'dropbox' => _AddDropboxSheet(feature: feature),
      'printouts' => _AddPrintoutSheet(feature: feature),
      _ => _AddVisionRecordSheet(feature: feature),
    };
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
                  _FeatureExtraPanel(feature: _feature, records: _records),
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

class _FeatureExtraPanel extends StatelessWidget {
  const _FeatureExtraPanel({required this.feature, required this.records});

  final VisionFeatureSpec feature;
  final List<VisionFeatureRecord> records;

  @override
  Widget build(BuildContext context) {
    final latest = records.isEmpty ? null : records.first;
    return switch (feature.key) {
      'wardrobe' => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _WardrobeCurrentCard(record: latest),
      ),
      'printouts' => const Padding(
        padding: EdgeInsets.only(top: 12),
        child: _ChildCalendarPreview(),
      ),
      'dropbox' => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: _DropboxHelperCard(record: latest),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _WardrobeCurrentCard extends StatelessWidget {
  const _WardrobeCurrentCard({required this.record});

  final VisionFeatureRecord? record;

  @override
  Widget build(BuildContext context) {
    final payload = record?.payload ?? const <String, dynamic>{};
    String value(String key, String fallback) {
      final raw = payload[key]?.toString().trim();
      return raw == null || raw.isEmpty ? fallback : raw;
    }

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.straighten_outlined, color: AppColors.sage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Güncel beden kartı',
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w700),
                ),
              ),
              if (record != null)
                AppPill(
                  label: DateFormat(
                    'dd MMM',
                    'tr_TR',
                  ).format(record!.createdAt),
                  tone: PillTone.mute,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: 'Boy', value: value('height', '-')),
              _InfoChip(label: 'Ayakkabı', value: value('shoe', '-')),
              _InfoChip(label: 'Üst', value: value('top_size', '-')),
              _InfoChip(label: 'Alt', value: value('bottom_size', '-')),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value(
              'need',
              'Henüz ihtiyaç notu yok. + ile güncel beden ve ihtiyaç ekle.',
            ),
            style: AppTypography.ui(size: 12.5, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.mono(size: 9.5, letter: 1)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.ui(weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ChildCalendarPreview extends StatelessWidget {
  const _ChildCalendarPreview();

  @override
  Widget build(BuildContext context) {
    const days = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.preview_outlined, color: AppColors.ochre),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Çocuk takvimi ön gösterimi',
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                Expanded(
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: i >= 5 ? AppColors.ochreSoft : AppColors.sageSoft,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          i == 4
                              ? Icons.backpack_outlined
                              : Icons.home_outlined,
                          size: 16,
                          color: AppColors.ink,
                        ),
                        const SizedBox(height: 3),
                        Text(days[i], style: AppTypography.ui(size: 10)),
                      ],
                    ),
                  ),
                ),
                if (i < days.length - 1) const SizedBox(width: 5),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _DropboxHelperCard extends StatelessWidget {
  const _DropboxHelperCard({required this.record});

  final VisionFeatureRecord? record;

  @override
  Widget build(BuildContext context) {
    final link = record?.payload['upload_url']?.toString();
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link_outlined, color: AppColors.sage),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Link nerede?',
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ekle’ye basınca kişi, kanal ve süre seçilir. Uygulama süreli bir yükleme linki oluşturur; link kayıt kartında görünür. Belge gelince durum “Belge geldi”, kontrol edilince “Tamamlandı” yapılır.',
            style: AppTypography.ui(size: 12.5, color: AppColors.inkSoft),
          ),
          if (link != null && link.isNotEmpty) ...[
            const SizedBox(height: 10),
            _UploadLinkActions(link: link),
          ],
        ],
      ),
    );
  }
}

class _UploadLinkActions extends StatelessWidget {
  const _UploadLinkActions({required this.link});

  final String link;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          link,
          style: AppTypography.mono(
            size: 10.5,
            letter: 0,
            color: AppColors.inkSoft,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            OutlinedButton.icon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: link));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Link kopyalandi.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Kopyala'),
            ),
            OutlinedButton.icon(
              onPressed: () => _showUploadLinkPreview(context, link),
              icon: const Icon(Icons.open_in_new_rounded, size: 16),
              label: const Text('Linki dene'),
            ),
          ],
        ),
      ],
    );
  }
}

void _showUploadLinkPreview(BuildContext context, String link) {
  final isHttps = link.startsWith('http://') || link.startsWith('https://');
  showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (context) => Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.forward_to_inbox_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Belge yukleme baglantisi',
                  style: AppTypography.ui(size: 17, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(link, style: AppTypography.mono(size: 11, letter: 0)),
          const SizedBox(height: 12),
          Text(
            isHttps
                ? 'Bu HTTPS linki dis kullanicinin belge yukleme sayfasina gider. Link suresi dolunca kabul edilmez.'
                : 'Bu cihaz ici deneme linkidir. Edge Function PUBLIC_APP_URL ile yayina alindiginda burada HTTPS yukleme sayfasi gorunur.',
            style: AppTypography.ui(
              size: 13,
              height: 1.35,
              color: AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Tamam'),
          ),
        ],
      ),
    ),
  );
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
    final uploadUrl = record.payload['upload_url']?.toString();
    final calendarSynced = record.payload['calendar_synced'] == true;
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
          if (calendarSynced) ...[
            const SizedBox(height: 8),
            const AppPill(label: 'Takvime işlendi', tone: PillTone.sage),
          ],
          if (uploadUrl != null && uploadUrl.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.sageSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paylaşılacak link',
                    style: AppTypography.ui(size: 12, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  _UploadLinkActions(link: uploadUrl),
                ],
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

class _AddSwapSheet extends StatefulWidget {
  const _AddSwapSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddSwapSheet> createState() => _AddSwapSheetState();
}

class _AddSwapSheetState extends State<_AddSwapSheet> {
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController(text: 'Okul çıkışı');
  DateTime _originalDate = DateTime.now().add(const Duration(days: 2));
  DateTime _proposedDate = DateTime.now().add(const Duration(days: 4));
  TimeOfDay _originalTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _proposedTime = const TimeOfDay(hour: 12, minute: 0);
  double _durationHours = 2;

  @override
  void dispose() {
    _reasonController.dispose();
    _locationController.dispose();
    super.dispose();
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
            _SheetTitle(feature: widget.feature),
            const SizedBox(height: 14),
            _DateTimeButtons(
              label: 'Asıl gün',
              date: _originalDate,
              time: _originalTime,
              onDate: () async {
                final picked = await _pickDate(_originalDate);
                if (picked != null) setState(() => _originalDate = picked);
              },
              onTime: () async {
                final picked = await _pickTime(_originalTime);
                if (picked != null) setState(() => _originalTime = picked);
              },
            ),
            const SizedBox(height: 10),
            _DateTimeButtons(
              label: 'Önerilen yeni gün',
              date: _proposedDate,
              time: _proposedTime,
              onDate: () async {
                final picked = await _pickDate(_proposedDate);
                if (picked != null) setState(() => _proposedDate = picked);
              },
              onTime: () async {
                final picked = await _pickTime(_proposedTime);
                if (picked != null) setState(() => _proposedTime = picked);
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Konum / teslim noktası',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _reasonController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Gerekçe',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Yeni takvim kaydı süresi: ${_durationHours.round()} saat',
              style: AppTypography.ui(size: 12.5, color: AppColors.inkMute),
            ),
            Slider(
              value: _durationHours,
              min: 1,
              max: 8,
              divisions: 7,
              label: '${_durationHours.round()} saat',
              onChanged: (value) => setState(() => _durationHours = value),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Takas talebi ve takvim kaydı oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(DateTime initialDate) => showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2035),
    locale: const Locale('tr'),
  );

  Future<TimeOfDay?> _pickTime(TimeOfDay initialTime) =>
      showTimePicker(context: context, initialTime: initialTime);

  void _save() {
    final original = _combine(_originalDate, _originalTime);
    final proposed = _combine(_proposedDate, _proposedTime);
    final title =
        '${DateFormat('d MMM', 'tr_TR').format(original)} yerine ${DateFormat('d MMM', 'tr_TR').format(proposed)}';
    final detail =
        'Asıl gün: ${DateFormat('d MMM HH:mm', 'tr_TR').format(original)}. Öneri: ${DateFormat('d MMM HH:mm', 'tr_TR').format(proposed)}. ${_reasonController.text.trim()}';
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: title,
        detail: detail,
        status: 'pending',
        payload: {
          'original_at': original.toIso8601String(),
          'proposed_at': proposed.toIso8601String(),
          'calendar_synced': true,
        },
        calendarTitle: 'Gün takası: $title',
        calendarStartAt: proposed,
        calendarEndAt: proposed.add(Duration(hours: _durationHours.round())),
        calendarLocation: _locationController.text.trim(),
      ),
    );
  }

  DateTime _combine(DateTime date, TimeOfDay time) =>
      DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _AddGeofenceSheet extends StatefulWidget {
  const _AddGeofenceSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddGeofenceSheet> createState() => _AddGeofenceSheetState();
}

class _AddGeofenceSheetState extends State<_AddGeofenceSheet> {
  final _placeController = TextEditingController(text: 'Atatürk İlkokulu');
  final _noteController = TextEditingController();
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 16, minute: 45);
  double _radius = 100;

  @override
  void dispose() {
    _placeController.dispose();
    _noteController.dispose();
    super.dispose();
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
            _SheetTitle(feature: widget.feature),
            const SizedBox(height: 14),
            TextField(
              controller: _placeController,
              decoration: const InputDecoration(labelText: 'Teslim noktası'),
            ),
            const SizedBox(height: 10),
            _DateTimeButtons(
              label: 'Bildirim zamanı',
              date: _date,
              time: _time,
              onDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                  locale: const Locale('tr'),
                );
                if (picked != null) setState(() => _date = picked);
              },
              onTime: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) setState(() => _time = picked);
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Yaklaşma sınırı: ${_radius.round()} metre',
              style: AppTypography.ui(size: 12.5, color: AppColors.inkMute),
            ),
            Slider(
              value: _radius,
              min: 50,
              max: 500,
              divisions: 9,
              label: '${_radius.round()} m',
              onChanged: (value) => setState(() => _radius = value),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.notifications_active_outlined),
              label: const Text('Hatırlatıcıyı kur ve bildir'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final when = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    final place = _placeController.text.trim();
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: '$place teslim hatırlatıcısı',
        detail:
            '${DateFormat('d MMM HH:mm', 'tr_TR').format(when)} · ${_radius.round()} m. ${_noteController.text.trim()}',
        status: 'active',
        payload: {
          'place': place,
          'remind_at': when.toIso8601String(),
          'radius_meters': _radius.round(),
        },
        notificationTitle: 'Teslim hatırlatıcısı kuruldu',
        notificationBody:
            '$place için ${DateFormat('HH:mm', 'tr_TR').format(when)} hatırlatıcısı hazır.',
      ),
    );
  }
}

class _AddWardrobeSheet extends StatefulWidget {
  const _AddWardrobeSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddWardrobeSheet> createState() => _AddWardrobeSheetState();
}

class _AddWardrobeSheetState extends State<_AddWardrobeSheet> {
  final _heightController = TextEditingController();
  final _shoeController = TextEditingController();
  final _topController = TextEditingController();
  final _bottomController = TextEditingController();
  final _needController = TextEditingController();

  @override
  void dispose() {
    _heightController.dispose();
    _shoeController.dispose();
    _topController.dispose();
    _bottomController.dispose();
    _needController.dispose();
    super.dispose();
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
            _SheetTitle(feature: widget.feature),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _field(_heightController, 'Boy', '132 cm')),
                const SizedBox(width: 10),
                Expanded(child: _field(_shoeController, 'Ayakkabı', '32')),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _field(_topController, 'Üst beden', '8-9 yaş')),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(_bottomController, 'Alt beden', '9 yaş'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _needController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Açık ihtiyaç / not',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: const Text('Beden kartını güncelle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String hint) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  void _save() {
    final payload = {
      'height': _heightController.text.trim(),
      'shoe': _shoeController.text.trim(),
      'top_size': _topController.text.trim(),
      'bottom_size': _bottomController.text.trim(),
      'need': _needController.text.trim(),
    };
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: 'Beden kartı güncellendi',
        detail:
            'Boy ${payload['height']}, ayakkabı ${payload['shoe']}. ${payload['need']}',
        status: 'completed',
        payload: payload,
      ),
    );
  }
}

class _AddTeenSheet extends StatefulWidget {
  const _AddTeenSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddTeenSheet> createState() => _AddTeenSheetState();
}

class _AddTeenSheetState extends State<_AddTeenSheet> {
  bool _calendar = true;
  bool _requests = true;
  bool _handover = false;
  bool _documents = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
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
            _SheetTitle(feature: widget.feature),
            const SizedBox(height: 12),
            _switchTile(
              'Takvimim',
              _calendar,
              (v) => setState(() => _calendar = v),
            ),
            _switchTile(
              'Talep ekle',
              _requests,
              (v) => setState(() => _requests = v),
            ),
            _switchTile(
              'Teslim bilgisi',
              _handover,
              (v) => setState(() => _handover = v),
            ),
            _switchTile(
              'Seçili belgeler',
              _documents,
              (v) => setState(() => _documents = v),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Ebeveyn rıza notu'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Teen erişim talebi oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: AppTypography.ui(weight: FontWeight.w700)),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _save() {
    final enabled = <String>[
      if (_calendar) 'Takvimim',
      if (_requests) 'Talep ekle',
      if (_handover) 'Teslim bilgisi',
      if (_documents) 'Seçili belgeler',
    ];
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: 'Teen modu erişim kapsamı',
        detail:
            'Açık ekranlar: ${enabled.join(', ')}. ${_noteController.text.trim()}',
        status: 'pending',
        payload: {
          'calendar': _calendar,
          'requests': _requests,
          'handover': _handover,
          'documents': _documents,
        },
      ),
    );
  }
}

class _AddDropboxSheet extends StatefulWidget {
  const _AddDropboxSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddDropboxSheet> createState() => _AddDropboxSheetState();
}

class _AddDropboxSheetState extends State<_AddDropboxSheet> {
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String _category = 'Okul';
  int _hours = 48;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
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
            _SheetTitle(feature: widget.feature),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kim yükleyecek?'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactController,
              decoration: const InputDecoration(
                labelText: 'E-posta veya telefon',
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Belge türü'),
              items: const [
                DropdownMenuItem(value: 'Okul', child: Text('Okul')),
                DropdownMenuItem(value: 'Sağlık', child: Text('Sağlık')),
                DropdownMenuItem(value: 'Servis', child: Text('Servis')),
                DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
              ],
              onChanged: (value) => setState(() => _category = value ?? 'Okul'),
            ),
            const SizedBox(height: 10),
            Text(
              'Link süresi: $_hours saat',
              style: AppTypography.ui(size: 12.5, color: AppColors.inkMute),
            ),
            Slider(
              value: _hours.toDouble(),
              min: 1,
              max: 168,
              divisions: 7,
              label: '$_hours saat',
              onChanged: (value) => setState(() => _hours = value.round()),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.link_outlined),
              label: Text(_saving ? 'Link hazirlaniyor...' : 'Link olustur'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Ucuncu kisi'
        : _nameController.text.trim();
    setState(() => _saving = true);
    final link = await AppDataService.createExternalDropboxLink(
      recipientName: name,
      contact: _contactController.text,
      category: _category,
      expiresInHours: _hours,
    );
    if (!mounted) return;
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: '$name için belge yükleme linki',
        detail: 'Tür: $_category. Süre: $_hours saat. Link kayıt kartında.',
        status: 'link_ready',
        payload: {
          'recipient': name,
          'contact': _contactController.text.trim(),
          'category': _category,
          'expires_in_hours': _hours,
          'upload_url': link.uploadUrl,
          'token': link.token,
          'link_source': link.source,
        },
      ),
    );
  }
}

class _AddPrintoutSheet extends StatefulWidget {
  const _AddPrintoutSheet({required this.feature});

  final VisionFeatureSpec feature;

  @override
  State<_AddPrintoutSheet> createState() => _AddPrintoutSheetState();
}

class _AddPrintoutSheetState extends State<_AddPrintoutSheet> {
  bool _handover = true;
  bool _school = true;
  bool _specialDays = true;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SheetTitle(feature: widget.feature),
          const SizedBox(height: 12),
          SwitchListTile(
            value: _handover,
            onChanged: (v) => setState(() => _handover = v),
            title: const Text('Teslim günleri'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _school,
            onChanged: (v) => setState(() => _school = v),
            title: const Text('Okul ve etkinlikler'),
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            value: _specialDays,
            onChanged: (v) => setState(() => _specialDays = v),
            title: const Text('Özel günler'),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.preview_outlined),
            label: const Text('Ön gösterim kaydı oluştur'),
          ),
        ],
      ),
    );
  }

  void _save() {
    Navigator.of(context).pop(
      _VisionRecordDraft(
        title: 'Çocuk takvimi ön gösterimi',
        detail:
            'Dahil: ${[if (_handover) 'teslim', if (_school) 'okul', if (_specialDays) 'özel gün'].join(', ')}',
        status: 'preview',
        payload: {
          'handover': _handover,
          'school': _school,
          'special_days': _specialDays,
        },
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle({required this.feature});

  final VisionFeatureSpec feature;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FeatureIcon(feature: feature),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.primaryActionLabel,
                style: AppTypography.display(size: 28, height: 1),
              ),
              const SizedBox(height: 3),
              Text(feature.kicker, style: AppTypography.mono(letter: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateTimeButtons extends StatelessWidget {
  const _DateTimeButtons({
    required this.label,
    required this.date,
    required this.time,
    required this.onDate,
    required this.onTime,
  });

  final String label;
  final DateTime date;
  final TimeOfDay time;
  final VoidCallback onDate;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.ui(size: 12, weight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(DateFormat('d MMM', 'tr_TR').format(date)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTime,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(time.format(context)),
              ),
            ),
          ],
        ),
      ],
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
    this.payload = const {},
    this.calendarTitle,
    this.calendarStartAt,
    this.calendarEndAt,
    this.calendarLocation,
    this.notificationTitle,
    this.notificationBody,
  });

  final String title;
  final String detail;
  final String status;
  final Map<String, dynamic> payload;
  final String? calendarTitle;
  final DateTime? calendarStartAt;
  final DateTime? calendarEndAt;
  final String? calendarLocation;
  final String? notificationTitle;
  final String? notificationBody;
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
    badge: 'Profil',
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
    surface: 'sidebar',
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
