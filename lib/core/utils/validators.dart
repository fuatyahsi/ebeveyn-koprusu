class Validators {
  const Validators._();

  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur.';
    }
    return null;
  }

  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'E-posta zorunludur.';
    }
    if (!text.contains('@') || !text.contains('.')) {
      return 'Geçerli bir e-posta girin.';
    }
    return null;
  }
}
