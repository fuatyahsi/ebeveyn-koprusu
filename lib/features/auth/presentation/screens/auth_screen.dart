import 'package:ebeveyn_koprusu/core/utils/validators.dart';
import 'package:ebeveyn_koprusu/shared/widgets/section_card.dart';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isRegister = true;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isRegister ? 'Kayıt' : 'Giriş')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SectionCard(
              title: 'Hesap bilgileri',
              icon: Icons.person_outline,
              child: Column(
                children: [
                  if (_isRegister) ...[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Ad soyad'),
                      validator: Validators.requiredText,
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'E-posta'),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Şifre'),
                    obscureText: true,
                    validator: Validators.requiredText,
                  ),
                  if (_isRegister) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Rol'),
                      initialValue: 'parent',
                      items: const [
                        DropdownMenuItem(
                          value: 'parent',
                          child: Text('Ebeveyn'),
                        ),
                        DropdownMenuItem(
                          value: 'guardian',
                          child: Text('Vasi'),
                        ),
                      ],
                      onChanged: (_) {},
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _marketing,
                      onChanged: (value) => setState(() => _marketing = value!),
                      title: const Text('Pazarlama iletişimine izin veriyorum'),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _formKey.currentState?.validate(),
              child: Text(_isRegister ? 'Kayıt oluştur' : 'Giriş yap'),
            ),
            TextButton(
              onPressed: () => setState(() => _isRegister = !_isRegister),
              child: Text(
                _isRegister ? 'Zaten hesabım var' : 'Yeni hesap oluştur',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
