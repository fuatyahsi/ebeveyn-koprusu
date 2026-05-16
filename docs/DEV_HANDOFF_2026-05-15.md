# Dev Handoff - 2026-05-15

Durduğumuz yer:

- Kullanıcının özellik eksikleri için ilk büyük düzeltme seti yapıldı.
- `flutter analyze` temiz geçti.
- `flutter test` geçti.
- Production Supabase'e bakan yeni debug APK üretildi:
  `build/outputs/ebeveyn-koprusu-feature-fixes-v9-debug.apk`
- SHA256:
  `716FC170CEE4914CEA579C4547F882FF16AA7FA380472C7AB5ACB491E10A176C`
- Eski APK çıktıları temizlendi.
- Emülatör smoke test adımında duruldu; son denemede ADB "no devices/emulators found" dedi, yani emülatör kapalıydı veya ADB bağlantısı düşmüştü.

Yarın devam edilecek ilk adımlar:

1. Android emülatörü yeniden aç.
2. `build/outputs/ebeveyn-koprusu-feature-fixes-v9-debug.apk` dosyasını kur.
3. Smoke test yap:
   - Ana ekranda Bekleyen bölümü üstte, Sık kullanılan 6 kart altta mı?
   - Gün takası formu asıl gün + önerilen gün alıyor ve takvime kayıt düşüyor mu?
   - Takvimde güne dokununca kayıt ekleme formu açılıyor mu?
   - Masraf TL formatı `60.000 TL` gibi mi ve pay oranı kullanıcı seçimiyle mi yazılıyor?
   - Masraf satırına basınca kabul / ödendi / itiraz / pay güncelle aksiyonları açılıyor mu?
   - Mesaj yazarken Sakin Dil Asistanı kartı görünüyor mu?
   - Teslim sınırı hatırlatıcı kurunca lokal bildirim geliyor mu?
   - Beden kartında güncel beden alanı okunup yeni kayıtla güncelleniyor mu?
   - Evrak köprüsünde link kayıt kartında açıkça görünüyor mu?
   - Teen modu erişilebilir ekran seçimi alıyor mu?
   - Görsel çocuk takvimi ön gösterimi görünüyor mu?
4. Smoke testte çıkan hataları düzelt.
5. Gerekirse yeni APK üret.
6. Commit + push yap.
