import 'dart:io';

import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _loading = false;
  List<AppDocument> _documents = const [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final documents = await AppDataService.fetchDocuments();
      if (!mounted) return;
      setState(() => _documents = documents);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.single;
    if (!mounted) return;
    final meta = await showModalBottomSheet<_DocumentMeta>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _DocumentMetaSheet(fileName: picked.name),
    );
    if (meta == null) return;

    setState(() => _loading = true);
    try {
      final file = picked.bytes == null && picked.path != null
          ? File(picked.path!)
          : null;
      final document = await AppDataService.uploadDocument(
        title: meta.title,
        category: meta.category,
        fileName: picked.name,
        sizeBytes: picked.size,
        mimeType: _mimeForExtension(picked.extension),
        bytes: picked.bytes,
        file: file,
      );
      if (!mounted) return;
      setState(() => _documents = [document, ..._documents]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belge yüklendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
              showBack: true,
              eyebrow: 'Arsiv',
              title: 'Belgeler',
              trailing: _UploadButton(onTap: _loading ? null : _uploadDocument),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _StorageCard(count: _documents.length),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Son belgeler'),
                  _DocumentList(documents: _documents),
                  const SizedBox(height: 16),
                  const _CategoryGuide(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _mimeForExtension(String? extension) {
    return switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      'txt' => 'text/plain',
      _ => null,
    };
  }
}

class _UploadButton extends StatelessWidget {
  const _UploadButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Belge yükle',
      child: Material(
        color: AppColors.ink,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox.square(
            dimension: 38,
            child: Icon(Icons.upload_file, size: 19, color: AppColors.paper),
          ),
        ),
      ),
    );
  }
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.paper.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.folder_outlined,
              color: AppColors.paper,
              size: 21,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count belge',
                  style: AppTypography.display(
                    size: 29,
                    height: 1,
                    color: AppColors.paper,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Private Supabase bucket · aile erişimi',
                  style: AppTypography.ui(
                    size: 12,
                    color: AppColors.paper.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentList extends StatelessWidget {
  const _DocumentList({required this.documents});

  final List<AppDocument> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return AppCard(
        child: Text(
          'Henüz belge yok. Sağ üstteki yükle butonu ile PDF, fotoğraf veya dosya ekleyebilirsin.',
          style: AppTypography.ui(size: 13, color: AppColors.inkMute),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < documents.length; i++) ...[
            _DocumentRow(document: documents[i]),
            if (i < documents.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.document});

  final AppDocument document;

  @override
  Widget build(BuildContext context) {
    final tone = document.isSensitive ? PillTone.terra : PillTone.sage;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: document.isSensitive
                  ? AppColors.terra.withValues(alpha: 0.1)
                  : AppColors.sageSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              document.isSensitive
                  ? Icons.health_and_safety_outlined
                  : Icons.description_outlined,
              color: document.isSensitive ? AppColors.terra : AppColors.sage,
              size: 17,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: AppTypography.ui(size: 13.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_categoryLabel(document.category)} · ${_sizeLabel(document.sizeBytes)}',
                  style: AppTypography.ui(size: 11.5, color: AppColors.inkMute),
                ),
              ],
            ),
          ),
          AppPill(label: document.isSensitive ? 'Hassas' : 'Arşiv', tone: tone),
        ],
      ),
    );
  }

  String _categoryLabel(String value) {
    return switch (value) {
      'school' => 'Okul',
      'health' => 'Sağlık',
      'transport' => 'Servis',
      'expense' => 'Masraf',
      'legal' => 'Hukuki',
      _ => 'Diğer',
    };
  }

  String _sizeLabel(int? bytes) {
    if (bytes == null || bytes <= 0) return 'boyut yok';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _CategoryGuide extends StatelessWidget {
  const _CategoryGuide();

  @override
  Widget build(BuildContext context) {
    const categories = [
      ('Okul', Icons.school_outlined, 'Veli toplantısı, sınav, etkinlik'),
      ('Sağlık', Icons.health_and_safety_outlined, 'Rapor, reçete, kontrol'),
      ('Servis', Icons.directions_bus_outlined, 'Sözleşme, güzergah'),
      ('Masraf', Icons.receipt_outlined, 'Fatura, dekont, fiş'),
      ('Hukuki', Icons.balance_outlined, 'Protokol, karar, yazışma'),
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategoriler', style: AppTypography.ui(weight: FontWeight.w700)),
          const SizedBox(height: 10),
          for (final category in categories)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(category.$2, color: AppColors.sage),
              title: Text(category.$1),
              subtitle: Text(category.$3),
            ),
        ],
      ),
    );
  }
}

class _DocumentMetaSheet extends StatefulWidget {
  const _DocumentMetaSheet({required this.fileName});

  final String fileName;

  @override
  State<_DocumentMetaSheet> createState() => _DocumentMetaSheetState();
}

class _DocumentMetaSheetState extends State<_DocumentMetaSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  String _category = 'school';

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.fileName);
  }

  @override
  void dispose() {
    _titleController.dispose();
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
            Text('Belge bilgisi', style: AppTypography.display(size: 30)),
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
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: const [
                DropdownMenuItem(value: 'school', child: Text('Okul')),
                DropdownMenuItem(value: 'health', child: Text('Sağlık')),
                DropdownMenuItem(value: 'transport', child: Text('Servis')),
                DropdownMenuItem(value: 'expense', child: Text('Masraf')),
                DropdownMenuItem(value: 'legal', child: Text('Hukuki')),
                DropdownMenuItem(value: 'other', child: Text('Diğer')),
              ],
              onChanged: (value) {
                setState(() => _category = value ?? 'school');
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.upload_file),
              label: const Text('Yükle'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(
      context,
    ).pop(_DocumentMeta(title: _titleController.text, category: _category));
  }
}

class _DocumentMeta {
  const _DocumentMeta({required this.title, required this.category});

  final String title;
  final String category;
}
