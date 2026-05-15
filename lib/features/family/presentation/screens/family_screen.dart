import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key, this.showBack = true});

  final bool showBack;

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  bool _loading = false;
  FamilyOverview? _overview;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final overview = await AppDataService.fetchFamilyOverview();
      if (!mounted) return;
      setState(() => _overview = overview);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _editFamily() async {
    final current = _overview;
    if (current == null) return;
    final draft = await showModalBottomSheet<_FamilyDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FamilySheet(overview: current),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      await AppDataService.updateFamily(
        name: draft.name,
        isSingleParentMode: draft.isSingleParentMode,
      );
      await _load();
      _showMessage('Aile bilgisi güncellendi.');
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _invite() async {
    final draft = await showModalBottomSheet<_InviteDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _InviteSheet(),
    );
    if (draft == null) return;

    setState(() => _loading = true);
    try {
      await AppDataService.createFamilyInvitation(
        email: draft.email,
        phone: draft.phone,
        role: draft.role,
      );
      await _load();
      _showMessage('Davet oluşturuldu. Kodu davet edeceğin kişiyle paylaş.');
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _acceptInvite() async {
    final code = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _InviteCodeSheet(),
    );
    if (!mounted || code == null || code.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      await AppDataService.acceptFamilyInvitation(code);
      await _load();
      _showMessage('Davet onaylandı.');
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
    final overview = _overview;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ScreenHeader(
              eyebrow: 'Aile alanı',
              title: 'Aile',
              showBack: widget.showBack,
              trailing: IconButton.filled(
                onPressed: _loading ? null : _invite,
                icon: const Icon(Icons.person_add_alt_1_outlined),
              ),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ModuleUsageTip(
                    icon: Icons.groups_2_outlined,
                    text:
                        'Aile modülü ortak çalışma alanıdır. Aile adını düzenle, e-posta veya telefonla davet oluştur, davet koduyla başka hesabı aileye kat ve onaylanmış üyeleri buradan takip et.',
                  ),
                  const SizedBox(height: 14),
                  if (overview == null)
                    const AppCard(child: Text('Aile bilgisi yükleniyor.'))
                  else ...[
                    _FamilyHero(overview: overview, onEdit: _editFamily),
                    const SizedBox(height: 14),
                    _ActionRow(onInvite: _invite, onAccept: _acceptInvite),
                    const SizedBox(height: 14),
                    const SectionLabel(label: 'Üyeler'),
                    _MembersCard(members: overview.members),
                    const SizedBox(height: 14),
                    const SectionLabel(label: 'Davetler'),
                    _InvitesCard(invitations: overview.invitations),
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

class _FamilyHero extends StatelessWidget {
  const _FamilyHero({required this.overview, required this.onEdit});

  final FamilyOverview overview;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.home_work_outlined, color: AppColors.paper),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overview.name,
                  style: AppTypography.display(
                    size: 30,
                    color: AppColors.paper,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  overview.isSingleParentMode
                      ? 'Tek ebeveyn modu açık'
                      : 'Ortak ebeveyn alanı',
                  style: AppTypography.ui(
                    size: 12,
                    color: AppColors.paper.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Aileyi düzenle',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.paper),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.onInvite, required this.onAccept});

  final VoidCallback onInvite;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onInvite,
            icon: const Icon(Icons.mail_outline),
            label: const Text('Davet et'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onAccept,
            icon: const Icon(Icons.verified_user_outlined),
            label: const Text('Davet onayla'),
          ),
        ),
      ],
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({required this.members});

  final List<FamilyMemberInfo> members;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const AppCard(child: Text('Henüz üye yok.'));
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < members.length; i++) ...[
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(members[i].label),
              subtitle: Text('${members[i].role} · ${members[i].accessLevel}'),
              trailing: AppPill(label: members[i].status, tone: PillTone.sage),
            ),
            if (i < members.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _InvitesCard extends StatelessWidget {
  const _InvitesCard({required this.invitations});

  final List<FamilyInvitationInfo> invitations;

  @override
  Widget build(BuildContext context) {
    if (invitations.isEmpty) {
      return const AppCard(
        child: Text(
          'Henüz davet yok. Davet et butonu ile e-posta veya telefon ekle.',
        ),
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < invitations.length; i++) ...[
            ListTile(
              leading: const Icon(Icons.mark_email_unread_outlined),
              title: Text(invitations[i].contact),
              subtitle: Text(
                'Kod: ${invitations[i].code} · ${DateFormat('d MMM', 'tr_TR').format(invitations[i].expiresAt)} tarihine kadar',
              ),
              trailing: AppPill(
                label: invitations[i].status,
                tone: invitations[i].status == 'accepted'
                    ? PillTone.sage
                    : PillTone.ochre,
              ),
            ),
            if (i < invitations.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _FamilySheet extends StatefulWidget {
  const _FamilySheet({required this.overview});

  final FamilyOverview overview;

  @override
  State<_FamilySheet> createState() => _FamilySheetState();
}

class _FamilySheetState extends State<_FamilySheet> {
  late final TextEditingController _nameController;
  late bool _singleParent;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.overview.name);
    _singleParent = widget.overview.isSingleParentMode;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          Text('Aileyi düzenle', style: AppTypography.display(size: 30)),
          const SizedBox(height: 14),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Aile adı'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _singleParent,
            onChanged: (value) => setState(() => _singleParent = value),
            title: const Text('Tek ebeveyn modu'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop(
                _FamilyDraft(
                  name: _nameController.text,
                  isSingleParentMode: _singleParent,
                ),
              );
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }
}

class _InviteSheet extends StatefulWidget {
  const _InviteSheet();

  @override
  State<_InviteSheet> createState() => _InviteSheetState();
}

class _InviteSheetState extends State<_InviteSheet> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _role = 'parent';

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
          Text('Aileye davet et', style: AppTypography.display(size: 30)),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'E-posta'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(labelText: 'Telefon'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Rol'),
            items: const [
              DropdownMenuItem(value: 'parent', child: Text('Ebeveyn')),
              DropdownMenuItem(value: 'guardian', child: Text('Vasi')),
              DropdownMenuItem(value: 'relative', child: Text('Yakın')),
              DropdownMenuItem(value: 'caregiver', child: Text('Bakıcı')),
            ],
            onChanged: (value) => setState(() => _role = value ?? 'parent'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop(
                _InviteDraft(
                  email: _emailController.text,
                  phone: _phoneController.text,
                  role: _role,
                ),
              );
            },
            icon: const Icon(Icons.send_outlined),
            label: const Text('Daveti oluştur'),
          ),
        ],
      ),
    );
  }
}

class _InviteCodeSheet extends StatefulWidget {
  const _InviteCodeSheet();

  @override
  State<_InviteCodeSheet> createState() => _InviteCodeSheetState();
}

class _InviteCodeSheetState extends State<_InviteCodeSheet> {
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
            Text(
              'Davet kodu ile katıl',
              style: AppTypography.display(size: 30),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(labelText: '8 haneli kod'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Davet kodu zorunlu.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.verified_user_outlined),
              label: const Text('Onayla'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_controller.text.trim().toUpperCase());
  }
}

class _FamilyDraft {
  const _FamilyDraft({required this.name, required this.isSingleParentMode});

  final String name;
  final bool isSingleParentMode;
}

class _InviteDraft {
  const _InviteDraft({
    required this.email,
    required this.phone,
    required this.role,
  });

  final String email;
  final String phone;
  final String role;
}
