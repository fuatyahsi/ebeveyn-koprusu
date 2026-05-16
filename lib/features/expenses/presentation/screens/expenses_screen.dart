import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/models/domain_models.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/core/utils/formatters.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  int _filter = 0;
  bool _loading = false;
  List<ExpenseItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final items = await AppDataService.fetchExpenses();
      if (!mounted) return;
      setState(() => _items = items);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addExpense() async {
    final draft = await showModalBottomSheet<_ExpenseDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AddExpenseSheet(),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      final item = await AppDataService.addExpense(
        title: draft.title,
        category: draft.category,
        amount: draft.amount,
        requestedShare: draft.requestedShare,
        description: draft.description,
      );
      if (!mounted) return;
      setState(() => _items = [item, ..._items]);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masraf kaydi eklendi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateExpenseStatus(
    ExpenseItem item,
    ExpenseStatus status,
  ) async {
    setState(() => _loading = true);
    try {
      final updated = await AppDataService.updateExpenseStatus(
        id: item.id,
        status: switch (status) {
          ExpenseStatus.accepted => 'accepted',
          ExpenseStatus.disputed => 'disputed',
          ExpenseStatus.paid => 'paid',
          ExpenseStatus.overdue => 'overdue',
          ExpenseStatus.sent => 'sent',
        },
      );
      if (!mounted) return;
      setState(() {
        _items = [
          for (final current in _items)
            if (current.id == updated.id) updated else current,
        ];
      });
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateExpenseShare(ExpenseItem item) async {
    final share = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _UpdateShareSheet(item: item),
    );
    if (share == null) return;
    setState(() => _loading = true);
    try {
      final updated = await AppDataService.updateExpenseShare(
        id: item.id,
        requestedShare: share,
      );
      if (!mounted) return;
      setState(() {
        _items = [
          for (final current in _items)
            if (current.id == updated.id) updated else current,
        ];
      });
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
    final filtered = _filteredItems;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ScreenHeader(
              eyebrow: 'Mayis · Bu ay',
              title: 'Masraflar',
              showBack: widget.showBack,
              trailing: _HeaderAddButton(onTap: _loading ? null : _addExpense),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ModuleUsageTip(
                    icon: Icons.receipt_long_outlined,
                    text:
                        'Masraf eklediğinde toplam tutar ve karşı taraftan istenen pay canlı expenses tablosuna yazılır. Filtreler bekleyen, kabul edilen, ödenen ve itirazlı kayıtları ayırır.',
                  ),
                  const SizedBox(height: 12),
                  _SummaryCard(items: _items),
                  const SizedBox(height: 12),
                  _FilterChips(
                    selected: _filter,
                    items: _items,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                  const SizedBox(height: 14),
                  _ExpenseList(
                    items: filtered,
                    onStatus: _updateExpenseStatus,
                    onShare: _updateExpenseShare,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ExpenseItem> get _filteredItems {
    if (_filter == 0) return _items;
    final wanted = switch (_filter) {
      1 => ExpenseStatus.sent,
      2 => ExpenseStatus.accepted,
      3 => ExpenseStatus.paid,
      4 => ExpenseStatus.disputed,
      _ => null,
    };
    if (wanted == null) return _items;
    return _items.where((item) => item.status == wanted).toList();
  }
}

class _HeaderAddButton extends StatelessWidget {
  const _HeaderAddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Masraf ekle',
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

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.items});

  final List<ExpenseItem> items;

  @override
  Widget build(BuildContext context) {
    final totalShare = items.fold<double>(
      0,
      (sum, item) => sum + item.requestedShare,
    );
    final sent = items
        .where((item) => item.status == ExpenseStatus.sent)
        .fold<double>(0, (sum, item) => sum + item.requestedShare);
    final accepted = items
        .where((item) => item.status == ExpenseStatus.accepted)
        .fold<double>(0, (sum, item) => sum + item.requestedShare);
    final disputed = items
        .where((item) => item.status == ExpenseStatus.disputed)
        .fold<double>(0, (sum, item) => sum + item.requestedShare);

    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BU AY SENIN PAYIN',
            style: AppTypography.mono(
              letter: 1.8,
              color: AppColors.paper.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppFormatters.currency.format(totalShare),
            style: AppTypography.display(
              size: 40,
              color: AppColors.paper,
              height: 1,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(
                    flex: _barFlex(sent, totalShare),
                    child: Container(color: AppColors.ochre),
                  ),
                  Expanded(
                    flex: _barFlex(accepted, totalShare),
                    child: Container(color: AppColors.sage),
                  ),
                  Expanded(
                    flex: _barFlex(disputed, totalShare),
                    child: Container(color: AppColors.terra),
                  ),
                  Expanded(
                    flex: totalShare == 0 ? 100 : 5,
                    child: Container(
                      color: AppColors.paper.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(c: AppColors.ochre, label: 'Bekliyor'),
              _LegendDot(c: AppColors.sage, label: 'Kabul'),
              _LegendDot(c: AppColors.terra, label: 'Itiraz'),
            ],
          ),
        ],
      ),
    );
  }

  int _barFlex(double value, double total) {
    if (total <= 0 || value <= 0) return 1;
    return (value / total * 100).round().clamp(1, 100);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.c, required this.label});
  final Color c;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('●', style: TextStyle(color: c, fontSize: 10)),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTypography.ui(
            size: 11,
            color: AppColors.paper.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.items,
    required this.onChanged,
  });
  final int selected;
  final List<ExpenseItem> items;
  final ValueChanged<int> onChanged;

  static const _labels = ['Tümü', 'Bekliyor', 'Kabul', 'Ödendi', 'İtiraz'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _FilterChip(
              label: _labels[i],
              count: _countFor(i),
              active: i == selected,
              onTap: () => onChanged(i),
            ),
          ],
        ],
      ),
    );
  }

  int _countFor(int index) {
    if (index == 0) return items.length;
    final status = switch (index) {
      1 => ExpenseStatus.sent,
      2 => ExpenseStatus.accepted,
      3 => ExpenseStatus.paid,
      4 => ExpenseStatus.disputed,
      _ => null,
    };
    return items.where((item) => item.status == status).length;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.ink : AppColors.paperWhite,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: active ? AppColors.ink : AppColors.paperWhite,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active ? Colors.transparent : AppColors.line,
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: AppTypography.ui(
                  size: 11.5,
                  weight: FontWeight.w500,
                  color: active ? AppColors.paper : AppColors.inkSoft,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.paper.withValues(alpha: 0.18)
                        : AppColors.ink.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.mono(
                      color: active
                          ? AppColors.paper.withValues(alpha: 0.7)
                          : AppColors.inkMute,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    required this.items,
    required this.onStatus,
    required this.onShare,
  });

  final List<ExpenseItem> items;
  final void Function(ExpenseItem item, ExpenseStatus status) onStatus;
  final void Function(ExpenseItem item) onShare;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return AppCard(
        child: Text(
          'Henüz masraf kaydı yok. Sağ üstteki + ile ilk masrafı ekleyebilirsin.',
          style: AppTypography.ui(size: 13, color: AppColors.inkMute),
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _ExpenseRow(item: items[i], onStatus: onStatus, onShare: onShare),
            if (i < items.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.item,
    required this.onStatus,
    required this.onShare,
  });
  final ExpenseItem item;
  final void Function(ExpenseItem item, ExpenseStatus status) onStatus;
  final void Function(ExpenseItem item) onShare;

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(item.status);
    final iconBg = switch (tone) {
      PillTone.ochre => AppColors.ochreSoft,
      PillTone.sage => AppColors.sageSoft,
      PillTone.terra => AppColors.terra.withValues(alpha: 0.1),
      _ => AppColors.ink.withValues(alpha: 0.05),
    };
    final iconFg = switch (tone) {
      PillTone.ochre => const Color(0xFF7B5B33),
      PillTone.sage => AppColors.sage,
      PillTone.terra => AppColors.terra,
      _ => AppColors.inkSoft,
    };

    return InkWell(
      onTap: () => _openActions(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconFor(item.category), size: 16, color: iconFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.ui(
                      size: 13.5,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} · talep ${AppFormatters.currency.format(item.requestedShare)}',
                    style: AppTypography.ui(size: 11, color: AppColors.inkMute),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppFormatters.currency.format(item.amount),
                  style: AppTypography.display(size: 17, height: 1),
                ),
                const SizedBox(height: 5),
                AppPill(label: _labelFor(item.status), tone: tone),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openActions(BuildContext context) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item.title, style: AppTypography.display(size: 28)),
              const SizedBox(height: 6),
              Text(
                'Talep edilen pay: ${AppFormatters.currency.format(item.requestedShare)}',
                style: AppTypography.ui(color: AppColors.inkMute),
              ),
              const SizedBox(height: 14),
              _ActionTile(
                icon: Icons.check_circle_outline,
                label: 'Kabul et',
                onTap: () => Navigator.of(context).pop('accepted'),
              ),
              _ActionTile(
                icon: Icons.payments_outlined,
                label: 'Ödendi olarak işaretle',
                onTap: () => Navigator.of(context).pop('paid'),
              ),
              _ActionTile(
                icon: Icons.report_gmailerrorred_outlined,
                label: 'İtiraz et / reddet',
                onTap: () => Navigator.of(context).pop('disputed'),
              ),
              _ActionTile(
                icon: Icons.edit_outlined,
                label: 'Talep edilen payı güncelle',
                onTap: () => Navigator.of(context).pop('share'),
              ),
            ],
          ),
        ),
      ),
    );
    if (action == null) return;
    if (action == 'share') {
      onShare(item);
      return;
    }
    final status = switch (action) {
      'accepted' => ExpenseStatus.accepted,
      'paid' => ExpenseStatus.paid,
      'disputed' => ExpenseStatus.disputed,
      _ => ExpenseStatus.sent,
    };
    onStatus(item, status);
  }

  IconData _iconFor(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('servis')) return Icons.directions_bus_outlined;
    if (lower.contains('sag') || lower.contains('sağ')) {
      return Icons.health_and_safety_outlined;
    }
    if (lower.contains('okul') || lower.contains('egitim')) {
      return Icons.school_outlined;
    }
    return Icons.receipt_long_outlined;
  }

  String _labelFor(ExpenseStatus status) {
    return switch (status) {
      ExpenseStatus.accepted => 'Kabul',
      ExpenseStatus.disputed => 'İtiraz',
      ExpenseStatus.paid => 'Ödendi',
      ExpenseStatus.overdue => 'Gecikti',
      _ => 'Bekliyor',
    };
  }

  PillTone _toneFor(ExpenseStatus status) {
    return switch (status) {
      ExpenseStatus.accepted => PillTone.sage,
      ExpenseStatus.disputed => PillTone.terra,
      ExpenseStatus.paid => PillTone.mute,
      ExpenseStatus.overdue => PillTone.terra,
      _ => PillTone.ochre,
    };
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.sage),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.ui(weight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddExpenseSheet extends StatefulWidget {
  const _AddExpenseSheet();

  @override
  State<_AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<_AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _requestedShareController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _category = 'Okul';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _requestedShareController.dispose();
    _descriptionController.dispose();
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
            Text('Masraf ekle', style: AppTypography.display(size: 30)),
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
                DropdownMenuItem(value: 'Okul', child: Text('Okul')),
                DropdownMenuItem(value: 'Sağlık', child: Text('Sağlık')),
                DropdownMenuItem(value: 'Servis', child: Text('Servis')),
                DropdownMenuItem(value: 'Etkinlik', child: Text('Etkinlik')),
                DropdownMenuItem(value: 'Diğer', child: Text('Diğer')),
              ],
              onChanged: (value) => setState(() => _category = value ?? 'Okul'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Tutar'),
              onChanged: _syncDefaultShare,
              validator: (value) {
                final amount = _parseAmount(value ?? '');
                if (amount <= 0) return 'Geçerli bir tutar gir.';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _requestedShareController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Karşı taraftan istenecek pay',
                helperText: 'Yarı yarıya olmak zorunda değil.',
              ),
              validator: (value) {
                final amount = _parseAmount(_amountController.text);
                final share = _parseAmount(value ?? '');
                if (share < 0 || share > amount) {
                  return 'Pay 0 ile toplam tutar arasında olmalı.';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _SharePreset(label: '%0', onTap: () => _setShareRate(0)),
                _SharePreset(label: '%25', onTap: () => _setShareRate(0.25)),
                _SharePreset(label: '%50', onTap: () => _setShareRate(0.5)),
                _SharePreset(label: '%100', onTap: () => _setShareRate(1)),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Not'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _prefillBankDraft,
              icon: const Icon(Icons.account_balance_outlined),
              label: const Text('Bankadan çek'),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.add),
              label: const Text('Masrafı ekle'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _ExpenseDraft(
        title: _titleController.text,
        category: _category,
        amount: _parseAmount(_amountController.text),
        requestedShare: _parseAmount(_requestedShareController.text),
        description: _descriptionController.text,
      ),
    );
  }

  void _syncDefaultShare(String input) {
    if (_requestedShareController.text.trim().isNotEmpty) return;
    final amount = _parseAmount(input);
    if (amount > 0) {
      _requestedShareController.text = (amount / 2).round().toString();
    }
  }

  void _setShareRate(double rate) {
    final amount = _parseAmount(_amountController.text);
    _requestedShareController.text = (amount * rate).round().toString();
  }

  double _parseAmount(String input) {
    return double.tryParse(input.trim().replaceAll(',', '.')) ?? 0;
  }

  void _prefillBankDraft() {
    setState(() {
      _titleController.text = 'Banka işlem taslağı';
      _category = 'Okul';
      _descriptionController.text =
          'OAuth sağlayıcısı bağlanınca seçilen tekil işlem buraya gelecek.';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Banka OAuth arayüz taslağı hazırlandı.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SharePreset extends StatelessWidget {
  const _SharePreset({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(onPressed: onTap, child: Text(label));
  }
}

class _UpdateShareSheet extends StatefulWidget {
  const _UpdateShareSheet({required this.item});

  final ExpenseItem item;

  @override
  State<_UpdateShareSheet> createState() => _UpdateShareSheetState();
}

class _UpdateShareSheetState extends State<_UpdateShareSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.item.requestedShare.round().toString(),
  );

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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Payı güncelle', style: AppTypography.display(size: 30)),
          const SizedBox(height: 10),
          Text(
            'Toplam: ${AppFormatters.currency.format(widget.item.amount)}',
            style: AppTypography.ui(color: AppColors.inkMute),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Karşı taraftan istenecek pay',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              final value =
                  double.tryParse(
                    _controller.text.trim().replaceAll(',', '.'),
                  ) ??
                  0;
              if (value < 0 || value > widget.item.amount) return;
              Navigator.of(context).pop(value);
            },
            icon: const Icon(Icons.check),
            label: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }
}

class _ExpenseDraft {
  const _ExpenseDraft({
    required this.title,
    required this.category,
    required this.amount,
    required this.requestedShare,
    required this.description,
  });

  final String title;
  final String category;
  final double amount;
  final double requestedShare;
  final String description;
}
