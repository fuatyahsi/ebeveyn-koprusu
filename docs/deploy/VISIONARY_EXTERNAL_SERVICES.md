# Visionary Feature External Services

Bu liste canlıya çıkmadan önce hangi özellik için hangi dış üyelik veya secret
gerektiğini netleştirir. Ebeveyn Asistanı kaldırıldı; vizyon özellikleri için
LLM API zorunlu değildir.

## Zorunlu Genel Kurulum

- Supabase project: URL, publishable/anon key, service role key ve DB password.
- Firebase Cloud Messaging: push bildirimleri ve sessiz zaman erteleme bildirimleri.
- RevenueCat: abonelik ve mağaza entitlement takibi.
- Android release signing: `key.properties` ve `.jks` dosyası Git dışında tutulmalı.

## Özellik Bazlı Servisler

| Özellik | Durum | Dış servis | Gereken secret/env |
| --- | --- | --- | --- |
| Akıllı gün takası | Hazır | Yok | Supabase tabloları yeterli |
| Teslim sınırı | Hazır | Cihaz izinleri | Android/iOS konum ve lokal bildirim izinleri |
| Banka taslağı | Sağlayıcı gerekli | Lisanslı açık bankacılık sağlayıcısı | `OPEN_BANKING_PROVIDER`, `OPEN_BANKING_CLIENT_ID`, `OPEN_BANKING_CLIENT_SECRET`, `OPEN_BANKING_REDIRECT_URI`, `OPEN_BANKING_AUTHORIZATION_URL`, `OPEN_BANKING_TOKEN_URL` |
| Uyum skoru | Hazır | Supabase scheduled function | `SUPABASE_SERVICE_ROLE_KEY` |
| Teen modu | Hazır | Yok | Ebeveyn rıza metni ve mağaza gizlilik açıklaması |
| Beden kartı | Hazır | Yok | Supabase tabloları yeterli |
| Çocuk çıktısı | Hazır | Yok | `pdf` + `printing` paketleri uygulamada mevcut |
| Sessiz zaman | Hazır | Firebase push | `FIREBASE_PROJECT_ID`, `FCM_SERVER_KEY` |
| Evrak köprüsü | Function hazır | Supabase Storage + Edge Function | `DOCUMENTS_BUCKET`, `PUBLIC_APP_URL`, `SUPABASE_SERVICE_ROLE_KEY` |
| Uygulama içi arama | Sağlayıcı gerekli | Agora veya Twilio | `RTC_PROVIDER`, `AGORA_APP_ID`, `AGORA_APP_CERTIFICATE` veya `TWILIO_ACCOUNT_SID`, `TWILIO_API_KEY_SID`, `TWILIO_API_KEY_SECRET` |
| Sıra hafızası | Hazır | Yok | Takvim kayıtları yeterli |

## Eklenen Edge Function Girişleri

```powershell
supabase functions deploy open-banking-session
supabase functions deploy open-banking-callback
supabase functions deploy create-call-token
supabase functions deploy external-dropbox-link
```

`npm run supabase:functions:deploy` komutu artık bu function'ları da deploy eder.

## Kullanıcıdan Beklenen Hesaplar

1. Firebase console'da Android app oluştur ve FCM yapılandırmasını indir.
2. RevenueCat hesabında Android product/entitlement tanımla.
3. Açık bankacılık için Türkiye'de yetkili bir sağlayıcıyla sözleşme yap.
4. Uygulama içi arama istenecekse Agora veya Twilio hesabı aç.
5. Public web upload ekranı için `PUBLIC_APP_URL` alanını canlı domain ile doldur.

## İlk Canlı Smoke Test Stratejisi

1. Supabase migration ve Edge Function deploy edilir.
2. `.env.production` sadece Supabase + Firebase + RevenueCat ile doldurulur.
3. `RTC_PROVIDER=mock` bırakılır; gerçek arama mağaza öncesi açılır.
4. Açık bankacılık secret'ları yoksa Banka Taslağı ekranı kayıt oluşturur ama provider bağlantısı 409 ile eksik secret listesini döner.
5. Android debug production APK cihazda kayıt, giriş, aile, takvim, masraf ve vizyon kayıtlarıyla test edilir.
