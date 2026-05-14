# Ebeveyn Köprüsü

Ebeveyn Köprüsü, ayrılmış veya boşanmış ebeveynlerin çocukla ilgili takvim, teslim, masraf, belge, onay, mesajlaşma ve raporlama süreçlerini çocuk odaklı ve kayıtlı şekilde yönetmesi için hazırlanmış Flutter + Supabase mobil uygulama iskeletidir.

## Ürün Konumlandırması

Bu uygulama bir eski eş takip aracı veya hukuki garanti ürünü değildir. Amaç çocukla ilgili zorunlu koordinasyonu sakin, düzenli, zaman damgalı ve raporlanabilir hale getirmektir. Çocuk için kullanıcı hesabı açılmaz ve canlı konum takibi yapılmaz.

## Teknik Mimari

- Frontend: Flutter, Riverpod, GoRouter
- Backend: Supabase Auth, PostgreSQL, RLS, Storage, Edge Functions
- Bildirim: FCM altyapısına hazır servis katmanı
- Abonelik: RevenueCat entitlement modeli
- Raporlama: PDF, hash ve QR doğrulama altyapısı
- Güvenlik: family_id izolasyonu, RLS, private Storage, audit hash-chain

## Flutter Kurulum

```powershell
flutter pub get
flutter run
```

Credential verilmeden uygulama mock modda açılır. Supabase bağlantısı için `--dart-define` değerleri kullanılabilir:

```powershell
flutter run --dart-define=SUPABASE_URL=https://example.supabase.co --dart-define=SUPABASE_ANON_KEY=public-anon-key
```

## Supabase Local Development

Supabase CLI bu makinede kurulu değilse önce CLI kurulmalıdır. Migration dosyaları `supabase/migrations` altında hazırdır.

```powershell
supabase start
supabase db reset
```

## Migration İçeriği

- `0001_extensions.sql`: PostgreSQL extension kurulumu
- `0002_enums.sql`: rol, durum, belge, mesaj ve abonelik enumları
- `0003_tables.sql`: tüm ana ürün tabloları
- `0004_indexes.sql`: sorgu indeksleri
- `0005_rls_helpers.sql`: aile erişim helper fonksiyonları
- `0006_rls_policies.sql`: RLS politikaları
- `0007_storage_buckets.sql`: private bucket ve Storage policy tanımları
- `0008_triggers_audit.sql`: updated_at, mesaj mutasyon engeli, audit hash-chain
- `0009_seed_subscription_plans.sql`: Plus, Premium, Professional plan katalog verisi

## Edge Functions

`supabase/functions` altında şu fonksiyon iskeletleri vardır:

`send-notification`, `schedule-reminders`, `generate-report-pdf`, `verify-report`, `revenuecat-webhook`, `generate-audit-hash`, `tone-assistant`, `ocr-expense-receipt`, `invite-family-member`, `external-response`, `expire-pending-requests`.

Deploy örneği:

```powershell
supabase functions deploy send-notification
supabase functions deploy revenuecat-webhook
```

## Firebase / FCM

Firebase proje ayarları ve platform dosyaları üretim ortamında eklenmelidir. Push bildirimlerinde hassas detay gösterilmez; Edge Function tarafında bildirim metni temizleme örneği vardır.

## RevenueCat

Plan entitlement kodları:

- `plus_access`
- `premium_access`
- `professional_access`

RevenueCat webhook endpoint’i `revenuecat-webhook` fonksiyonudur. Webhook secret `REVENUECAT_WEBHOOK_SECRET` olarak ayarlanır.

## Test

```powershell
flutter analyze
flutter test
```

## Build

Android debug:

```powershell
flutter build apk --debug
```

iOS build için macOS/Xcode ortamı gerekir:

```bash
flutter build ios --no-codesign
```

## KVKK ve Güvenlik Notları

- Çocuğun T.C. kimlik numarası alınmaz.
- Sağlık verileri hassas kategori olarak ele alınır.
- Canlı konum yoktur; yalnızca teslim/check-in anında açık rıza ile konum kaydı alınabilir.
- Mesajlar update/delete edilemez.
- Kişisel defter sadece sahibine görünür.
- Service role key Flutter client içine konulmaz.

## Bilinen Sınırlılıklar

Üretim credential’ları, Firebase platform dosyaları, RevenueCat ürünleri, gerçek PDF render işlemi, OCR sağlayıcısı ve gerçek push gönderimi `IMPLEMENTATION_NOTES.md` içinde listelenmiştir.

## Geliştirici Onboarding

1. `.env.example` içindeki alanları proje ortamında tanımlayın.
2. `flutter pub get` çalıştırın.
3. Supabase CLI kuruluysa `supabase db reset` ile migration’ları uygulayın.
4. Uygulamayı mock modda açıp ana modülleri kontrol edin.
5. Credential’lar eklendikten sonra servisleri gerçek provider’lara bağlayın.
