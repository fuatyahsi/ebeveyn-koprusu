# Ebeveyn Köprüsü — Tasarım Sistemi Aktarımı

Bu klasör, HTML tasarımının (`Ebeveyn Köprüsü — Tasarım.html`) Flutter projene
düşürmeye hazır Dart karşılığını içerir. Klasör yapısı mevcut `lib/` ağacını
**bire bir** yansıtır; dosyaları olduğu yere kopyalaman yeterlidir.

## 1) Bağımlılık ekle (`pubspec.yaml`)

```yaml
dependencies:
  google_fonts: ^6.2.1   # Instrument Serif + Geist + Geist Mono
```

Sonra:

```bash
flutter pub get
```

## 2) Renk ve tema dosyalarını güncelle

| Bu repo                                                 | Hedef                                                  |
|---------------------------------------------------------|--------------------------------------------------------|
| `lib/app/theme/app_colors.dart`                         | `lib/app/theme/app_colors.dart` *(üzerine yaz)*        |
| `lib/app/theme/app_typography.dart`                     | `lib/app/theme/app_typography.dart` *(yeni)*           |
| `lib/app/theme/app_theme.dart`                          | `lib/app/theme/app_theme.dart` *(üzerine yaz)*         |

Eski `AppColors` sabitleri (`navy`, `teal`, `mint`, `amber`, `red`, `blue`,
`surface`, `border`, `mutedInk`) yeni palete **alias** olarak korundu — geriye
dönük uyumluluk var; istersen sonra çağrı yerlerini yeni isimlere geçirirsin.

## 3) Paylaşılan widget'lar

`lib/shared/widgets/` altına dört yeni dosya geliyor + `app_shell.dart`
yenileniyor:

| Dosya              | Ne içerir                                              |
|--------------------|--------------------------------------------------------|
| `brand_mark.dart`  | `BridgeMark` (mini köprü ikonu), `AppIconWidget` (tam app icon — CustomPainter) |
| `app_pill.dart`    | `AppPill` + `PillTone` enum (status pill'leri)        |
| `app_card.dart`    | `AppCard` + `CardTint` enum, `SectionLabel`            |
| `screen_header.dart`| `ScreenHeader` (mono eyebrow + italic serif title)    |
| `app_shell.dart`   | Yeni bottom tab bar + "Daha" sekmesinde modül grid'i  |

Mevcut `module_detail_screen.dart`, `section_card.dart`, `status_pill.dart`
dosyalarına dokunmaya gerek yok — eski ekranlar bunları kullanmaya devam eder.
Yeni ekranlar yeni widget'ları kullanır.

## 4) Ekran dosyaları

Aşağıdaki sekiz dosya doğrudan kopyalanır:

```
lib/features/onboarding/presentation/screens/welcome_screen.dart   ← YENİ
lib/features/dashboard/presentation/screens/dashboard_screen.dart  ← üzerine yaz
lib/features/calendar/presentation/screens/calendar_screen.dart    ← üzerine yaz
lib/features/handover/presentation/screens/handover_screen.dart    ← üzerine yaz
lib/features/messages/presentation/screens/messages_screen.dart    ← üzerine yaz
lib/features/expenses/presentation/screens/expenses_screen.dart    ← üzerine yaz
lib/features/reports/presentation/screens/reports_screen.dart      ← üzerine yaz
lib/features/subscriptions/presentation/screens/subscriptions_screen.dart  ← üzerine yaz
```

> **Not:** Yeni ekranlar şimdilik mock veriyle çalışır (HTML tasarımındaki
> Deniz / 14 Mayıs / 16:42 sahnesi). Mevcut `mockDataProvider`'ları ekranlara
> bağlamak istersen yapıları aynı — `ConsumerWidget` / `ConsumerStatefulWidget`
> olarak yazıldılar.

## 5) App icon

`assets/icon/app_icon.svg` — 1024×1024 vektör. iOS ve Android ikon üretimi
için `flutter_launcher_icons` öneririm:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"  # SVG'yi 1024x1024 PNG olarak export et
  adaptive_icon_background: "#0E2740"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"
```

SVG'yi PNG'ye çevirmek için: `rsvg-convert -w 1024 app_icon.svg > app_icon.png`
veya tarayıcıda aç → ekran görüntüsü.

`AppIconWidget` ise aynı ikonu Flutter içinde `CustomPainter` ile aynen çizer
(onboarding ve abonelik ekranında kullanılıyor).

## 6) Router

Yeni `WelcomeScreen` için router'a ekle:

```dart
GoRoute(
  path: '/welcome',
  builder: (context, state) => const WelcomeScreen(),
),
```

İlk açılışta kullanıcı hesabı yoksa `/welcome`'a yönlendir; aksi halde `/`'a.

## 7) `flutter analyze` notları

Yeni dosyalar Material 3 + Dart 3 syntax kullanır (records, pattern matching).
Mevcut `analysis_options.yaml` (flutter_lints) ile uyumludur.

## Tasarım vokabüleri — özet

- **Tip**: Instrument Serif italic (display) + Geist (UI) + Geist Mono
  (kanıt: zaman damgaları, hash, etiketler)
- **Renk**: `#F5F0E6` kağıt zemin · `#0E2740` derin lacivert · `#587A72` adaçayı
  · `#C99662` oker · `#B65F46` terra
- **Geometri**: 14px köşe yarıçapı (kart), 12px (buton), 10px (chip), 999 (pill)
- **Pill'ler**: durum bildirimleri için **her zaman** `AppPill` kullan; renk
  enum üzerinden seçilir
- **Header**: `ScreenHeader` ile mono "eyebrow" + italic serif başlık —
  default `AppBar` kullanma
