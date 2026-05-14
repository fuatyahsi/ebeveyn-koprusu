import 'package:flutter/material.dart';

/// Ebeveyn Köprüsü — premium palette
///
/// Sıcak kağıt zemin, derin lacivert mürekkep, sakin adaçayı, oker aksanı.
class AppColors {
  const AppColors._();

  // Ink (text / dark surfaces)
  static const ink = Color(0xFF0E2740);
  static const inkSoft = Color(0xFF2A4257);
  static const inkMute = Color(0xFF6B7785);

  // Paper (light surfaces)
  static const paper = Color(0xFFF5F0E6);
  static const paperHi = Color(0xFFFAF6EE);
  static const paperWhite = Color(0xFFFFFEFA);

  // Sage (positive / "anne")
  static const sage = Color(0xFF587A72);
  static const sageSoft = Color(0xFFDDE7E1);

  // Ochre (highlight / "baba")
  static const ochre = Color(0xFFC99662);
  static const ochreSoft = Color(0xFFEAD6B8);

  // Terra (warnings / disputes)
  static const terra = Color(0xFFB65F46);
  static const terraSoft = Color(0x1FB65F46); // ~0.12 alpha

  // Lines / dividers
  static const line = Color(0x1A0E2740); // 0.10
  static const lineHard = Color(0x2D0E2740); // 0.18

  // Legacy aliases — keeps old call sites working until they’re migrated.
  static const navy = ink;
  static const mutedInk = inkMute;
  static const teal = sage;
  static const mint = sageSoft;
  static const amber = ochre;
  static const red = terra;
  static const blue = inkSoft;
  static const surface = paper;
  static const border = line;
}
