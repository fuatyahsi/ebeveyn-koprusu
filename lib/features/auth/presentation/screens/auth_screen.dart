import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/core/services/supabase_service.dart';
import 'package:ebeveyn_koprusu/core/utils/validators.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = true;
  bool _marketing = false;
  bool _isLoading = false;
  String? _notice;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading || !(_formKey.currentState?.validate() ?? false)) return;

    final client = SupabaseService.client;
    if (client == null) {
      _showError('Supabase ayari bulunamadi. Production APK ile deneyin.');
      return;
    }

    setState(() {
      _isLoading = true;
      _notice = null;
    });

    try {
      if (_isRegister) {
        final response = await client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'full_name': _nameController.text.trim()},
        );

        if (response.session == null) {
          setState(() {
            _notice =
                'Kayit alindi. Supabase e-posta dogrulamasi istiyorsa, '
                'maili onayladiktan sonra giris yap.';
          });
          return;
        }

        await AppDataService.ensureStarterWorkspace(
          fullName: _nameController.text,
          marketingConsent: _marketing,
        );
      } else {
        await client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await AppDataService.ensureStarterWorkspace();
      }

      if (!mounted) return;
      context.go('/');
    } catch (error) {
      _showError(AppDataService.friendlyError(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
          children: [
            const SizedBox(height: 10),
            const Center(child: BridgeMark(size: 46, color: AppColors.paper)),
            const SizedBox(height: 18),
            Text(
              'Ebeveyn Koprusu',
              textAlign: TextAlign.center,
              style: AppTypography.display(size: 42, color: AppColors.paper),
            ),
            const SizedBox(height: 8),
            Text(
              'Cocuk icin sakin koordinasyon',
              textAlign: TextAlign.center,
              style: AppTypography.mono(
                size: 10,
                letter: 1.9,
                color: AppColors.paper.withValues(alpha: 0.62),
              ),
            ),
            const SizedBox(height: 30),
            AppCard(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            label: 'Kayit',
                            active: _isRegister,
                            onTap: () => setState(() => _isRegister = true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _ModeButton(
                            label: 'Giris',
                            active: !_isRegister,
                            onTap: () => setState(() => _isRegister = false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (_isRegister) ...[
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Ad soyad',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: Validators.requiredText,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.mail_outline),
                      ),
                      validator: Validators.email,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: const InputDecoration(
                        labelText: 'Sifre',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: Validators.requiredText,
                    ),
                    if (_isRegister) ...[
                      const SizedBox(height: 8),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _marketing,
                        onChanged: (value) {
                          setState(() => _marketing = value ?? false);
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(
                          'Pazarlama iletisimine izin veriyorum',
                          style: AppTypography.ui(size: 12.5),
                        ),
                      ),
                    ],
                    if (_notice != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _notice!,
                        style: AppTypography.ui(
                          size: 12,
                          color: AppColors.sage,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isLoading ? null : _submit,
                      icon: _isLoading
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isRegister
                                  ? Icons.person_add_alt_1
                                  : Icons.login,
                            ),
                      label: Text(
                        _isRegister ? 'Kayit ol ve basla' : 'Giris yap',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.paper,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? AppColors.ink : AppColors.line),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.ui(
            size: 13,
            weight: FontWeight.w600,
            color: active ? AppColors.paper : AppColors.ink,
          ),
        ),
      ),
    );
  }
}
