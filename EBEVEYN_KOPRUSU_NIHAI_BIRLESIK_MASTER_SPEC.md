# EBEVEYN KÖPRÜSÜ — NİHAİ BİRLEŞTİRİLMİŞ MASTER SPEC

**Dosya amacı:** Bu doküman, `Ebeveyn Köprüsü` mobil uygulamasını Flutter + Supabase + PostgreSQL kullanarak uçtan uca geliştirmek için Codex / yazılım ekibine verilecek ana geliştirme şartnamesidir.  
**Proje tipi:** Premium abonelikli mobil uygulama  
**Platformlar:** iOS + Android  
**Frontend:** Flutter  
**Backend:** Supabase  
**Database:** PostgreSQL  
**Auth:** Supabase Auth  
**Storage:** Supabase Storage  
**Realtime:** Supabase Realtime  
**Server-side logic:** Supabase Edge Functions  
**Push notification:** Firebase Cloud Messaging veya OneSignal  
**Subscription:** RevenueCat veya doğrudan App Store / Google Play Billing  
**Dil:** İlk sürüm Türkçe, altyapı çok dilli olacak şekilde hazırlanmalı  
**Uygulama adı:** Ebeveyn Köprüsü  
**Temel konumlandırma:** Boşanmış veya ayrı yaşayan ebeveynler için çocuk odaklı, güvenli, kayıtlı ve düzenli iletişim / koordinasyon uygulaması.

**Nihai birleşik sürüm:** Bu doküman, önceki uzun master specification dosyası ile daha sonra yüklenen `ebeveyn_koprusu_codex_master_spec(1).md` dosyasının tek nüsha hâline getirilmiş, genişletilmiş ve çelişkileri giderilmiş final sürümüdür. Codex'e verilecek tek ana dosya budur.

**Uygulama hedefi:** Bu dosya verildiğinde Codex; Flutter mobil arayüzünü, Supabase/PostgreSQL veritabanını, RLS politikalarını, Storage yapısını, Edge Functions altyapısını, RevenueCat abonelik sistemini, FCM bildirimlerini, PDF raporlamayı, hash-chain audit log sistemini, admin operasyon ekranlarını, KVKK/gizlilik ekranlarını ve yayın öncesi hazırlıkları uçtan uca üretmelidir.

**Önemli karar:** Uygulama “sadece MVP” olarak ele alınmayacaktır. Ekip kalabalık olduğu için bütün modüller tek ürün kapsamındadır. Geliştirme sırasında aşamalı sprint yapılabilir; ancak nihai teslim bu dokümandaki tüm modülleri kapsar.


---

## 0. Codex İçin En Üst Talimat

Bu doküman tek ana kaynak olarak kabul edilecektir. Uygulama MVP mantığıyla parçalara ayrılmayacak; ekip geniş olduğu için aşağıdaki tüm modüller tek ürün kapsamı içinde tasarlanacak ve geliştirilecektir.

Codex aşağıdaki hedefle çalışmalıdır:

> Flutter + Supabase + PostgreSQL mimarisiyle, boşanmış veya ayrı yaşayan ebeveynlerin çocukla ilgili takvim, teslim, masraf, belge, okul/servis/sağlık bilgisi, onay talepleri, mesajlaşma, uyuşmazlık, raporlama ve abonelik süreçlerini yöneteceği premium mobil uygulamayı geliştirmek.

Kodlama sırasında aşağıdaki ilkeler zorunludur:

1. Uygulama çocuk merkezli olmalıdır.
2. Çocuğa uygulama hesabı açılmamalıdır.
3. İki ebeveynin birlikte kullandığı mod desteklenmelidir.
4. Karşı ebeveyn uygulamaya katılmasa bile tek ebeveyn modu çalışmalıdır.
5. Tüm kritik işlemler audit log’a yazılmalıdır.
6. Mesajlar, talepler, masraflar, teslim kayıtları ve belge paylaşım işlemleri zaman damgalı olmalıdır.
7. Kullanıcılar kendilerine ait olmayan aile/çocuk/veri kayıtlarını görememelidir.
8. Supabase RLS zorunludur.
9. Dosyalar Storage’da güvenli klasör yapısıyla tutulmalıdır.
10. Premium abonelik kontrolü olmadan kritik özellikler kullanılmamalıdır.
11. Canlı konum takibi yapılmamalıdır. Sadece teslim/check-in anında isteğe bağlı konum kaydı alınabilir.
12. Çocuğun üstün yararı, veri minimizasyonu ve güvenlik tasarımın merkezinde olmalıdır.
13. Uygulama hukukî tavsiye vermemelidir. Raporlar “bilgilendirme ve kayıt çıktısı” olarak sunulmalıdır.
14. Uygulama “mahkemede kesin delildir” gibi iddia kullanmamalıdır.
15. Ton ve iletişim dili nötr, resmi, sakin ve çocuk odaklı olmalıdır.

---

## 1. Ürün Vizyonu

Ebeveyn Köprüsü, boşanmış veya ayrı yaşayan ebeveynlerin çocukla ilgili zorunlu iletişim süreçlerini düzenli, kayıtlı, güvenli ve çatışmayı azaltacak şekilde yürütmesini sağlayan mobil uygulamadır.

Uygulama; WhatsApp benzeri serbest ve dağınık iletişimin yerine, konu bazlı ve kayıtlı iletişim sağlar. Çocuğun hangi gün hangi ebeveynde kalacağı, teslim saatleri, okul/servis/sağlık bilgileri, masraflar, belgeler, onay gerektiren kararlar, değişiklik talepleri ve uyuşmazlıklar tek sistemde yönetilir.

Ana değer önerisi:

> Çocuğunuzla ilgili iletişimi düzenleyin, masrafları ve belgeleri takip edin, teslim günlerini kaçırmayın, kararları kayıtlı yönetin ve gerektiğinde düzenli rapor alın.

---

## 2. Ürün Konumlandırması

### 2.1 Doğru Konumlandırma

- Çocuk odaklı ebeveyn koordinasyon uygulaması
- Kayıtlı ve düzenli iletişim aracı
- Ortak takvim ve teslim takip sistemi
- Masraf, belge ve karar yönetimi platformu
- Çatışmayı azaltan iletişim destek aracı
- Raporlanabilir aile koordinasyon sistemi

### 2.2 Yanlış Konumlandırma

Aşağıdaki dil ve ürün yaklaşımı kullanılmamalıdır:

- “Eski eşinizi takip edin”
- “Mahkemede kesin delil üretin”
- “Karşı tarafı yakalayın”
- “Velayet savaşı uygulaması”
- “Çocuğun konumunu izleyin”
- “Gizlice takip edin”

---

## 3. Hedef Kullanıcılar

### 3.1 Birincil Kullanıcılar

1. Boşanmış anne
2. Boşanmış baba
3. Ayrı yaşayan ebeveynler
4. Mahkeme kararıyla kişisel ilişki düzeni bulunan ebeveynler
5. Anlaşmalı boşanma protokolüne göre çocukla ilgili düzen kurması gereken ebeveynler

### 3.2 İkincil Kullanıcılar

1. Avukat
2. Arabulucu
3. Pedagog / psikolog
4. Aile danışmanı
5. Teslim yetkilisi
6. Büyükanne / büyükbaba
7. Bakıcı
8. Vasi

### 3.3 Kullanılmaması Gereken Rol

Çocuk için aktif hesap açılmayacaktır. Çocuk uygulamanın konusu olabilir, kullanıcısı olmayacaktır.

---

## 4. Temel İlkeler

### 4.1 Çocuk Merkezlilik

Her özellik şu soruya göre tasarlanmalıdır:

> Bu özellik çocuğun düzenini, güvenliğini, ihtiyaçlarını veya ebeveynler arası zorunlu koordinasyonu iyileştiriyor mu?

Eğer cevap hayırsa özellik eklenmemelidir.

### 4.2 Kayıtlılık

Kritik her işlem kayıt altına alınır:

- Mesaj gönderildi
- Mesaj okundu
- Takvim oluşturuldu
- Takvim değişikliği talep edildi
- Talep kabul edildi
- Talep reddedildi
- Masraf eklendi
- Masrafa itiraz edildi
- Belge yüklendi
- Belge okundu
- Teslim gerçekleşti
- Teslim gerçekleşmedi
- Acil durum bildirimi yapıldı
- Onay talebi oluşturuldu
- Onay verildi
- Onay reddedildi

### 4.3 Veri Minimizasyonu

Uygulama sadece hizmet için gerekli veriyi toplamalıdır. Özellikle çocuk verisi, sağlık verisi, konum verisi ve belge verisi için minimum veri ilkesi uygulanmalıdır.

### 4.4 Gizlilik

Kişisel kayıt defteri gibi özel alanlar karşı ebeveyn tarafından görülememelidir. Aile içi paylaşılan ve kişisel alanlar net ayrılmalıdır.

### 4.5 Raporlanabilirlik

Tüm işlem geçmişleri tarih aralığına, çocuk profiline, konuya ve modüle göre PDF rapora dönüştürülebilmelidir.

### 4.6 Premium Ürün Mantığı

Uygulama ücretsiz ürün olmayacaktır. Sınırlı deneme süresi olabilir, ancak asıl kullanım abonelikle açılacaktır.

---

## 5. Teknik Mimari

### 5.1 Frontend

Flutter kullanılacaktır.

Önerilen temel paketler:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.0.0

  # State management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Routing
  go_router: ^14.0.0

  # UI
  flutter_svg: ^2.0.0
  intl: ^0.19.0
  table_calendar: ^3.1.0

  # Forms / validation
  reactive_forms: ^17.0.0

  # Files
  file_picker: ^8.0.0
  image_picker: ^1.1.0
  open_filex: ^4.4.0

  # PDF
  pdf: ^3.10.0
  printing: ^5.12.0

  # Notifications
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0

  # Subscriptions
  purchases_flutter: ^8.0.0

  # Device / security
  local_auth: ^2.2.0
  device_info_plus: ^10.0.0
  package_info_plus: ^8.0.0

  # Utilities
  uuid: ^4.4.0
  crypto: ^3.0.0
  freezed_annotation: ^2.4.0
  json_annotation: ^4.9.0
```

Not: Paket versiyonları geliştirme başlangıcında güncel sürümlere göre kontrol edilecektir.

### 5.2 Backend

Supabase kullanılacaktır:

- Supabase Auth
- PostgreSQL
- Row Level Security
- Supabase Storage
- Supabase Realtime
- Supabase Edge Functions
- Scheduled functions / cron jobs
- Database triggers
- Postgres functions

### 5.3 Ödeme

Önerilen:

- RevenueCat ile iOS + Android abonelik yönetimi
- App Store Connect subscription products
- Google Play Console subscription products
- Supabase `subscriptions` tablosu ile sunucu tarafı hak kontrolü
- RevenueCat webhook → Supabase Edge Function → subscription status update

Alternatif:

- Doğrudan StoreKit + Google Play Billing
- Ancak RevenueCat daha hızlı geliştirme ve çapraz platform takip sağlar.

### 5.4 Bildirim

Push notification için:

- Firebase Cloud Messaging
- Flutter local notifications
- Supabase Edge Functions ile bildirim tetikleme
- Scheduled reminders için cron tabanlı Edge Function

---

## 6. Kullanıcı Rolleri ve Yetki Modeli

### 6.1 Roller

| Rol | Açıklama |
|---|---|
| `parent` | Anne veya baba, ana kullanıcı |
| `guardian` | Yasal vasi |
| `lawyer` | Avukat, sınırlı rapor/kayıt erişimi |
| `mediator` | Arabulucu, uyuşmazlık ve rapor erişimi |
| `psychologist` | Pedagog/psikolog, seçili not ve rapor erişimi |
| `caregiver` | Bakıcı, sınırlı takvim ve teslim bilgisi |
| `delivery_authorized_person` | Teslim almaya yetkili kişi |
| `admin` | Platform yöneticisi |
| `support` | Destek personeli, sınırlı teknik inceleme |

### 6.2 Aile İçindeki Üyelik Durumları

`family_members` tablosunda her kullanıcının aile içindeki durumu tutulacaktır.

Durumlar:

- `active`
- `invited`
- `pending`
- `blocked`
- `removed`
- `solo_external_contact`

### 6.3 Yetki Seviyeleri

| Yetki | Açıklama |
|---|---|
| `full` | Tüm aile modülleri |
| `limited_read` | Seçili kayıtları okuma |
| `report_view` | Sadece raporları görme |
| `delivery_only` | Teslim kayıtlarıyla sınırlı |
| `calendar_only` | Takvim bilgisiyle sınırlı |
| `expense_only` | Masraf bilgisiyle sınırlı |
| `no_access` | Erişim yok |

---

## 7. Uygulama Modülleri

Bu bölümde önce 19 ana özellik listelenir, sonra her biri detaylandırılır.

### 7.1 Tam Özellik Listesi

Uygulamada aşağıdaki 19 ana özellik yer alacaktır:

1. Mahkeme kararı / protokol bazlı takvim motoru
2. Teslim / teslim alma kayıt sistemi
3. Yakınlar ve teslim yetkilileri modülü
4. Okul / servis / sağlık bilgi merkezi
5. Masraf ve ödeme anlaşmazlığı modülü
6. Onay gerektiren kararlar modülü
7. Konu bazlı mesajlaşma
8. Üslup yumuşatma / çatışma azaltma asistanı
9. Özel günlük / kişisel kayıt defteri
10. Tek taraflı kullanım modu
11. Üçüncü kişi erişimi
12. Uyuşmazlık / itiraz merkezi
13. Bildirim ve hatırlatma sistemi
14. Değiştirilemez kayıt / doğrulama kodlu PDF rapor
15. Çocuğun ihtiyaçları panosu
16. Teslim çantası kontrol listesi
17. Acil durum modu
18. Çocuk için hesap açmama kararı
19. Abonelik ve paket özellikleri

---

# 8. Modül 1 — Mahkeme Kararı / Protokol Bazlı Takvim Motoru

## 8.1 Amaç

Ebeveynlerin çocukla kişisel ilişki / görüş düzenini takvim üzerinde tanımlaması ve uygulamanın bu kurallardan otomatik etkinlik üretmesini sağlamak.

## 8.2 Kullanıcı Hikâyeleri

- Bir ebeveyn olarak çocuğun hangi gün hangi ebeveynde kalacağını görmek istiyorum.
- Bir ebeveyn olarak mahkeme kararındaki hafta sonu düzenini takvime işlemek istiyorum.
- Bir ebeveyn olarak bayram, yarıyıl ve yaz tatili düzenini ayrı tanımlamak istiyorum.
- Bir ebeveyn olarak teslim saatini, teslim noktasını ve teslim kişisini görmek istiyorum.
- Bir ebeveyn olarak takvim değişikliği talep etmek istiyorum.

## 8.3 Takvim Kural Tipleri

Takvim motoru aşağıdaki kural tiplerini desteklemelidir:

### 8.3.1 Haftalık Düzen

Örnek:

- Her pazartesi ve çarşamba 17:00–20:00 baba
- Her cuma okul çıkışı pazar 18:00 baba
- Hafta içi anne, hafta sonu dönüşümlü baba

### 8.3.2 Ayın Belirli Haftası

Örnek:

- Her ayın 1. ve 3. hafta sonu baba
- Her ayın 2. ve 4. hafta sonu anne

### 8.3.3 Tek/Çift Hafta Düzeni

Örnek:

- Tek haftalarda anne
- Çift haftalarda baba

### 8.3.4 Resmî Tatil Düzeni

Türkiye resmî tatilleri veri kaynağı olarak tutulmalıdır. İlk sürümde elle girilebilir; ileride harici API ile güncellenebilir.

Desteklenecek özel günler:

- Ramazan Bayramı
- Kurban Bayramı
- 23 Nisan
- 19 Mayıs
- 30 Ağustos
- 29 Ekim
- 1 Ocak
- Ara tatil
- Yarıyıl tatili
- Yaz tatili

### 8.3.5 Yıllık Dönüşümlü Kural

Örnek:

- Tek yıllarda Ramazan Bayramı anne
- Çift yıllarda Ramazan Bayramı baba

### 8.3.6 Yaz Tatili Kuralı

Örnek:

- 1 Temmuz–15 Temmuz baba
- 16 Temmuz–31 Temmuz anne
- Yaz tatilinin ilk yarısı anne, ikinci yarısı baba

### 8.3.7 Özel Gün Kuralı

Örnek:

- Çocuğun doğum günü dönüşümlü
- Annenin doğum günü anneyle
- Babanın doğum günü babayla

## 8.4 Takvim Etkinlik Alanları

Her takvim etkinliği aşağıdaki alanları içermelidir:

- Çocuk
- Sorumlu ebeveyn
- Başlangıç tarihi/saati
- Bitiş tarihi/saati
- Teslim noktası
- Teslim şekli
- Teslim yetkilisi
- Not
- Durum
- Oluşturma kaynağı
- Tekrarlama kuralı
- Değişiklik geçmişi

## 8.5 Etkinlik Durumları

- `scheduled`
- `change_requested`
- `accepted`
- `declined`
- `completed`
- `missed`
- `cancelled`
- `disputed`

## 8.6 Kullanıcı Akışı

1. Kullanıcı çocuk profiline girer.
2. “Ebeveynlik Planı” ekranını açar.
3. Yeni plan oluşturur.
4. Kural tipi seçer.
5. Gün/saat/teslim bilgilerini girer.
6. Kuralı kaydeder.
7. Sistem otomatik etkinlik üretir.
8. Diğer ebeveyne bildirim gönderilir.
9. Diğer ebeveyn planı kabul edebilir, itiraz edebilir veya not ekleyebilir.
10. Takvimde etkinlikler görünür.

## 8.7 Gelişmiş Özellik: Protokol/PDF’den Kural Çıkarma

İlk sürümde manuel giriş zorunludur. Ancak mimari, ileride şu özelliğe uygun olmalıdır:

1. Kullanıcı mahkeme kararı veya anlaşmalı boşanma protokolü yükler.
2. Sistem belgeyi işler.
3. Görüş günü / teslim kuralı taslak olarak çıkarılır.
4. Kullanıcı kontrol eder ve onaylar.
5. Onaylanan kural takvime dönüşür.

Bu özellik kesinlikle otomatik karar vermemeli; insan onayı zorunlu olmalıdır.

---

# 9. Modül 2 — Teslim / Teslim Alma Kayıt Sistemi

## 9.1 Amaç

Çocuğun teslim ve teslim alma süreçlerinin zaman damgalı, düzenli ve raporlanabilir şekilde kayıt altına alınması.

## 9.2 Teslim İşlemleri

Kullanıcı aşağıdaki teslim işlemlerini yapabilmelidir:

- Teslim için yola çıktım
- Teslim noktasına geldim
- Çocuk teslim edildi
- Çocuk teslim alındı
- Teslim gerçekleşmedi
- Gecikme bildir
- Bekliyorum
- Alternatif teslim kişisi seçildi
- Teslim noktasında sorun var
- Teslimden vazgeçildi

## 9.3 Teslim Kaydı Alanları

- Takvim etkinliği
- Çocuk
- İşlemi yapan kullanıcı
- İşlem tipi
- Tarih/saat
- Not
- Opsiyonel konum
- Opsiyonel fotoğraf
- Karşı taraf onayı
- İtiraz durumu
- Audit hash

## 9.4 Konum Politikası

Canlı konum takibi yasaktır.

Sadece kullanıcı açıkça “teslim noktasına geldim” veya benzeri bir işlem yaptığında opsiyonel konum alınabilir.

Konum bilgisi:

- Varsayılan kapalı olmalı
- Açık rıza ile alınmalı
- Sadece ilgili teslim kaydına bağlanmalı
- Genel profil veya sürekli takip için kullanılmamalı

## 9.5 Teslim Gerçekleşmedi Akışı

1. Kullanıcı takvim etkinliğine girer.
2. “Teslim gerçekleşmedi” seçer.
3. Neden seçer:
   - Karşı taraf gelmedi
   - Çocuk hazır değildi
   - Teslim noktası değişti
   - Ulaşım sorunu
   - Sağlık nedeni
   - Diğer
4. Not yazar.
5. Opsiyonel fotoğraf/konum ekler.
6. Kayıt oluşur.
7. Karşı tarafa bildirim gider.
8. Karşı taraf açıklama ekleyebilir.
9. Olay uyuşmazlık dosyasına dönüştürülebilir.

---

# 10. Modül 3 — Yakınlar ve Teslim Yetkilileri

## 10.1 Amaç

Çocuğun hayatındaki yakın kişilerin, acil kişilerin ve teslim yetkililerinin kayıtlı ve güncel tutulmasını sağlamak.

## 10.2 Kişi Tipleri

- Anne
- Baba
- Anneanne
- Babaanne
- Dede
- Teyze
- Hala
- Amca
- Dayı
- Bakıcı
- Öğretmen
- Okul yetkilisi
- Servis şoförü
- Doktor
- Psikolog
- Kurs öğretmeni
- Teslim yetkilisi
- Acil kişi
- Diğer

## 10.3 Kişi Alanları

- Ad soyad
- Yakınlık
- Telefon
- E-posta
- Adres
- Not
- Çocuğu teslim alabilir mi?
- Acil durumda aranabilir mi?
- Karşı ebeveyne gösterilsin mi?
- Ekleyen kullanıcı
- Son güncelleyen kullanıcı
- Onay durumu
- Güncelleme geçmişi

## 10.4 Telefon Değişikliği Bildirimi

Bir kişinin telefonu değişirse sistem otomatik bildirim üretmelidir:

> “Çocuk rehberinde kayıtlı bir kişinin telefon bilgisi güncellendi.”

Karşı ebeveyn bu güncellemeyi okuduğunda kayıt oluşmalıdır.

## 10.5 Yetkili Teslim Kişisi Akışı

1. Ebeveyn yeni teslim yetkilisi ekler.
2. Yetki tipi seçer:
   - Tek seferlik
   - Belirli tarih aralığı
   - Sürekli
3. Karşı tarafa bildirim gider.
4. Karşı taraf kabul/itiraz edebilir.
5. Teslim kayıtlarında bu kişi seçilebilir hale gelir.

---

# 11. Modül 4 — Okul / Servis / Sağlık Bilgi Merkezi

## 11.1 Amaç

Çocuğun okul, servis ve sağlık bilgilerinin merkezi, güncel ve kayıtlı olarak tutulması.

## 11.2 Okul Kartı

Alanlar:

- Okul adı
- Sınıf
- Şube
- Öğretmen adı
- Öğretmen telefonu
- Okul telefonu
- Okul adresi
- E-posta
- Web sitesi
- Veli toplantısı tarihleri
- Sınav tarihleri
- Etkinlikler
- Notlar
- Belgeler

## 11.3 Servis Kartı

Alanlar:

- Servis firması
- Şoför adı
- Şoför telefonu
- Araç plakası
- Güzergâh
- Sabah alış saati
- Akşam bırakış saati
- Yedek şoför
- Servis ücreti
- Servis sözleşmesi belgesi
- Servis değişiklik geçmişi

## 11.4 Sağlık Kartı

Alanlar:

- Kan grubu
- Alerjiler
- Düzenli ilaçlar
- Doktor adı
- Hastane / klinik
- Doktor telefonu
- Acil sağlık notu
- Kronik durum notu
- Reçeteler
- Raporlar
- Kontrol randevuları
- Aşı takvimi

## 11.5 Sağlık Verisi Güvenliği

Sağlık kartı özel kategori olarak ele alınmalıdır.

Kurallar:

- Varsayılan olarak minimum bilgi girilmelidir.
- Sağlık belgesi yükleme işlemi açık uyarı ile yapılmalıdır.
- Sağlık belgeleri storage’da ayrı klasörde tutulmalıdır.
- Erişim ayrı RLS ve yetki ile sınırlandırılmalıdır.
- Rapor dışa aktarımında kullanıcı sağlık verisinin dahil edilip edilmeyeceğini seçmelidir.

---

# 12. Modül 5 — Masraf ve Ödeme Anlaşmazlığı

## 12.1 Amaç

Çocuğa yapılan düzenli ve ani masrafların belge, onay, ödeme ve itiraz süreçleriyle takip edilmesi.

## 12.2 Masraf Kategorileri

- Okul
- Servis
- Kurs
- Sağlık
- İlaç
- Kıyafet
- Kırtasiye
- Etkinlik
- Spor
- Ulaşım
- Bakım
- Tatil
- Harçlık
- Diğer

## 12.3 Masraf Tipleri

- Düzenli gider
- Ani gider
- Acil sağlık gideri
- Bilgi amaçlı gider
- Onay gerektiren gider
- Paylaşımlı gider
- Nafaka dışı ek gider
- Kullanıcı özel gideri

## 12.4 Masraf Alanları

- Çocuk
- Gider adı
- Kategori
- Açıklama
- Tutar
- Para birimi
- Tarih
- Ödeyen ebeveyn
- Karşı taraftan istenen tutar
- Paylaşım oranı
- Belge/dekont
- Durum
- Son ödeme tarihi
- İtiraz nedeni
- Ödeme tarihi
- Audit hash

## 12.5 Durumlar

- `draft`
- `submitted`
- `read`
- `accepted`
- `partially_accepted`
- `rejected`
- `disputed`
- `paid`
- `partially_paid`
- `overdue`
- `cancelled`
- `reported`

## 12.6 Masraf Akışı

1. Kullanıcı masraf ekler.
2. Kategori ve tutar girer.
3. Fatura/dekont yükler.
4. Paylaşım oranını seçer.
5. Karşı tarafa gönderir.
6. Karşı taraf:
   - Kabul eder
   - Kısmen kabul eder
   - İtiraz eder
   - Ek belge ister
7. Ödeme yapılırsa kullanıcı ödenen tutarı işler.
8. Tüm süreç audit log’a yazılır.
9. İstenirse masraf raporuna eklenir.

## 12.7 OCR Desteği

İleride fiş/dekont üzerinden OCR ile şu bilgiler okunabilir:

- Tutar
- Tarih
- Firma adı
- Belge numarası

İlk sürümde OCR zorunlu değildir; ancak dosya ve veri modeli buna uygun olmalıdır.

---

# 13. Modül 6 — Onay Gerektiren Kararlar

## 13.1 Amaç

Çocukla ilgili önemli kararların yapılandırılmış talep, onay, ret ve itiraz akışıyla yönetilmesi.

## 13.2 Karar Tipleri

- Okul değişikliği
- Servis değişikliği
- Şehir dışı seyahat
- Yurt dışı seyahat
- Sağlık müdahalesi
- Kursa kayıt
- Psikolojik destek
- Spor faaliyeti
- Pasaport işlemi
- Kimlik işlemi
- Adres değişikliği
- Teslim düzeni değişikliği
- Özel etkinlik
- Diğer

## 13.3 Karar Talebi Alanları

- Çocuk
- Talep eden kullanıcı
- Karar tipi
- Başlık
- Açıklama
- İlgili tarih
- Son cevap tarihi
- Ek belgeler
- Durum
- Cevaplayan kullanıcı
- Cevap notu
- Karar geçmişi

## 13.4 Durumlar

- `draft`
- `submitted`
- `read`
- `approved`
- `rejected`
- `info_requested`
- `expired`
- `withdrawn`
- `disputed`

## 13.5 Akış

1. Kullanıcı karar talebi oluşturur.
2. Talep tipi seçer.
3. Açıklama yazar.
4. Belge ekler.
5. Son cevap tarihini belirler.
6. Karşı ebeveyne bildirim gider.
7. Karşı ebeveyn cevap verir.
8. Cevap kayıt altına alınır.
9. Gerekirse uyuşmazlık dosyası açılır.

---

# 14. Modül 7 — Konu Bazlı Mesajlaşma

## 14.1 Amaç

Dağınık ve kavga doğuran serbest mesajlaşma yerine, çocukla ilgili konulara bağlı, kayıtlı ve raporlanabilir iletişim sağlamak.

## 14.2 Mesaj Konuları

- Teslim / görüş günü
- Okul
- Servis
- Sağlık
- Masraf
- Belge
- Acil durum
- Genel bilgilendirme
- Onay talebi
- Tatil / seyahat
- Uyuşmazlık
- Çocuk ihtiyaçları
- Diğer

## 14.3 Mesaj Kuralları

- Mesaj silinemez.
- Mesaj düzenlenemez.
- Düzeltme gerekiyorsa yeni düzeltme mesajı gönderilir.
- Okundu bilgisi tutulur.
- Dosya eki varsa belge arşivine de bağlanabilir.
- Her mesaj audit log’a yazılır.
- Mesajlar rapora dahil edilebilir.
- Mesajlar sadece ilgili aile üyeleri tarafından görülebilir.

## 14.4 Mesaj Alanları

- Family
- Child optional
- Thread
- Topic
- Sender
- Body
- Attachment list
- Read receipts
- Reply to message
- Tone analysis status
- Created at
- Hash

## 14.5 Thread Mantığı

Her konu başlığı için thread kullanılacaktır. Örneğin:

- “Mayıs ayı servis değişikliği”
- “15 Mayıs teslim değişikliği”
- “Doktor randevusu”
- “Okul ödemesi”

Thread olmadan serbest mesaj yazılması engellenmemelidir ama sistem kullanıcıyı konu seçmeye yönlendirmelidir.

---

# 15. Modül 8 — Sakin Dil Asistanı

## 15.1 Amaç

Ebeveynlerin mesaj göndermeden önce sert, suçlayıcı veya çatışmayı artırabilecek ifadeleri fark etmesini ve daha nötr alternatif metinler kullanmasını sağlamak.

## 15.2 Temel İlkeler

- Otomatik mesaj gönderilmez.
- Kullanıcının yazdığı mesaj sansürlenmez.
- Sistem sadece uyarı ve öneri verir.
- Kullanıcı öneriyi kabul edebilir, düzenleyebilir veya yok sayabilir.
- Ton analizi özel ve geçici işlenmelidir.
- Mesaj metni üçüncü taraf AI sağlayıcısına gönderilecekse bu gizlilik politikasında açıkça belirtilmelidir.
- Yerel/kapalı model seçeneği ileride değerlendirilecektir.

## 15.3 Analiz Kategorileri

- Suçlayıcı dil
- Hakaret
- Tehdit
- Alaycı ifade
- Genelleme
- Çocuk üzerinden baskı
- Konu dışı kişisel saldırı
- Daha nötr ifade önerisi

## 15.4 Örnek

Kullanıcı mesajı:

> Sen yine geç kaldın, zaten hiçbir şeyi doğru düzgün yapmıyorsun.

Önerilen metin:

> Bugünkü teslim saatinde gecikme yaşandığını görüyorum. Bundan sonraki teslimlerde belirlenen saate uyulmasını rica ederim.

## 15.5 Teknik Tasarım

Flutter tarafında mesaj gönderilmeden önce:

1. Kullanıcı mesajı yazar.
2. “Gönder” tıklandığında mesaj `tone_analysis` servisine gönderilir.
3. Edge Function mesajı analiz eder.
4. Yanıt döner:
   - risk score
   - detected issues
   - rewritten suggestion
5. Kullanıcıya modal gösterilir.
6. Kullanıcı:
   - Orijinali gönder
   - Öneriyi kullan
   - Düzenle
   - Vazgeç

## 15.6 Provider-Agnostic AI Layer

AI sağlayıcısı doğrudan Flutter’a yazılmamalıdır.

Edge Function içinde soyut yapı:

```ts
interface ToneAssistantProvider {
  analyzeMessage(input: ToneAnalysisInput): Promise<ToneAnalysisOutput>
}
```

İlk sürümde mock provider veya basit kural tabanlı analizle başlanabilir. Daha sonra OpenAI, Gemini, Claude, yerel model vb. eklenebilir.

---

# 16. Modül 9 — Özel Günlük / Kişisel Kayıt Defteri

## 16.1 Amaç

Kullanıcının karşı tarafla paylaşmadan kendi gözlem ve notlarını tutmasını sağlamak.

## 16.2 Kullanım Örnekleri

- Teslimde gecikme yaşandı.
- Çocuk okul çantasız geldi.
- Servis değişikliği bana bildirilmedi.
- Doktor randevusuna diğer ebeveyn katılmadı.
- Çocuk belirli bir konuda üzgün görünüyordu.
- Bu ay masraflar düzensiz ilerledi.

## 16.3 Gizlilik

Bu kayıtlar varsayılan olarak sadece oluşturan kullanıcı tarafından görülebilir.

Karşı ebeveyn göremez.

Kullanıcı isterse:

- Avukatıyla paylaşabilir.
- Raporlara dahil edebilir.
- PDF olarak dışa aktarabilir.
- Hiç paylaşmadan saklayabilir.

## 16.4 Alanlar

- Kullanıcı
- Family
- Child optional
- Başlık
- Not
- Kategori
- Tarih/saat
- Dosya/fotoğraf ekleri
- Raporlara dahil edilsin mi?
- Created at
- Updated at

## 16.5 Kategoriler

- Teslim
- Okul
- Sağlık
- Masraf
- İletişim
- Çocuğun ihtiyacı
- Uyuşmazlık
- Genel not

---

# 17. Modül 10 — Tek Taraflı Kullanım Modu

## 17.1 Amaç

Diğer ebeveyn uygulamaya katılmasa bile kullanıcının uygulamayı değerli şekilde kullanabilmesini sağlamak.

## 17.2 Özellikler

Tek ebeveyn modu kullanıcısı şunları yapabilmelidir:

- Çocuk profili oluşturma
- Takvim tutma
- Teslim kayıtları girme
- Masraf kaydı girme
- Belge arşivi oluşturma
- Kişisel not tutma
- PDF rapor alma
- Karşı ebeveyne SMS/e-posta ile bildirim gönderme
- Davet linki oluşturma
- Karşı taraf uygulamaya sonradan katılırsa aile bağlantısı kurma

## 17.3 Dış Bildirim

Karşı ebeveyn uygulamada yoksa kullanıcı şu bildirimleri gönderebilmelidir:

- Takvim değişikliği önerisi
- Masraf bildirimi
- Belge bildirimi
- Teslim bilgisi
- Onay talebi
- Acil durum bildirimi

Bildirim kanalları:

- E-posta
- SMS
- WhatsApp paylaşım linki, sadece kullanıcı manuel paylaşır
- PDF çıktı

## 17.4 Dış Cevap Mantığı

E-posta/SMS ile gönderilen bildirimlerde güvenli cevap linki olabilir.

Karşı taraf linke tıklayarak:

- Kabul
- Ret
- Not ekle

yapabilir.

Bu işlem tam hesap açmadan “limited external response” olarak kaydedilir. Ancak güvenlik için tek kullanımlık token ve süre sınırı kullanılmalıdır.

---

# 18. Modül 11 — Üçüncü Kişi Erişimi

## 18.1 Amaç

Avukat, arabulucu, pedagog, bakıcı veya teslim yetkilisi gibi üçüncü kişilerin sınırlı ve kontrollü erişimle sisteme dahil olmasını sağlamak.

## 18.2 Roller ve Erişimler

### Avukat

- Seçili raporları görebilir.
- Kullanıcının izin verdiği mesaj/masraf/belge kayıtlarını görebilir.
- Aile içi mesajlaşmaya katılamaz.
- Karşı ebeveynin özel notlarını göremez.

### Arabulucu

- Uyuşmazlık dosyalarını görebilir.
- Tarafların paylaştığı belgeleri görebilir.
- Not ekleyebilir.
- Karar veremez.

### Pedagog / Psikolog

- Kullanıcının paylaştığı seçili notları görebilir.
- Çocuk ihtiyaçları ve bazı gözlem notlarını görebilir.
- Sağlık bilgilerine erişim ayrıca izin gerektirir.

### Bakıcı

- Sadece seçili takvim ve teslim bilgilerini görebilir.
- Çocuk teslim checklist’ini görebilir.
- Mesajları göremez.

### Teslim Yetkilisi

- Sadece kendisiyle ilgili teslim bilgilerini görebilir.
- Teslim alındı/verildi işlemi yapabilir.
- Diğer modüllere erişemez.

## 18.3 Paylaşım Süresi

Üçüncü kişi erişimleri süreli olmalıdır:

- Tek seferlik
- 7 gün
- 30 gün
- Belirli tarih aralığı
- Süresiz, kullanıcı iptal edene kadar

## 18.4 Paylaşım Log’u

Her üçüncü kişi erişimi audit log’a yazılır:

- Kim paylaştı?
- Kiminle paylaştı?
- Hangi modül paylaşıldı?
- Hangi tarih aralığı?
- Ne zaman erişildi?
- Paylaşım ne zaman iptal edildi?

---

# 19. Modül 12 — Uyuşmazlık / İtiraz Merkezi

## 19.1 Amaç

Ebeveynler arasında doğan anlaşmazlıkların mesaj karmaşasına dönüşmeden, yapılandırılmış dosya mantığıyla kaydedilmesi.

## 19.2 Uyuşmazlık Tipleri

- Masraf itirazı
- Teslim gerçekleşmedi
- Teslim gecikti
- Takvim değişikliği reddi
- Okul bilgisi paylaşılmadı
- Servis bilgisi paylaşılmadı
- Sağlık bilgisi paylaşılmadı
- Belge eksik
- Onay verilmedi
- Çocuğun eşyaları eksik teslim edildi
- İletişim problemi
- Diğer

## 19.3 Uyuşmazlık Alanları

- Family
- Child
- Açan kullanıcı
- Konu
- Açıklama
- İlgili modül
- İlgili kayıt ID
- Belgeler
- Karşı taraf cevabı
- Durum
- Çözüm notu
- Raporlara dahil edilsin mi?

## 19.4 Durumlar

- `open`
- `waiting_response`
- `responded`
- `in_review`
- `resolved`
- `unresolved`
- `closed`
- `reported`

## 19.5 Akış

1. Kullanıcı uyuşmazlık açar.
2. İlgili masraf/takvim/teslim/mesaj kaydını bağlar.
3. Açıklama ve belge ekler.
4. Karşı tarafa bildirim gider.
5. Karşı taraf cevap verebilir.
6. Taraflar çözüldü/çözülmedi işaretleyebilir.
7. Uyuşmazlık rapora dahil edilebilir.

---

# 20. Modül 13 — Bildirim ve Hatırlatma Sistemi

## 20.1 Amaç

Kullanıcıların teslim, takvim, masraf, belge, onay ve acil süreçleri kaçırmamasını sağlamak.

## 20.2 Bildirim Tipleri

- Takvim yaklaşan teslim
- Teslim saati geldi
- Teslim gecikti
- Takvim değişikliği talebi
- Talep kabul edildi
- Talep reddedildi
- Yeni mesaj
- Yeni belge
- Belge okundu
- Yeni masraf
- Masraf itirazı
- Ödeme tarihi geldi
- Onay talebi
- Onay süresi doluyor
- Acil durum bildirimi
- Çocuk ihtiyaç listesi hatırlatma
- Teslim çantası hatırlatma
- Abonelik yenileme / ödeme sorunu

## 20.3 Hassas İçerik Politikası

Push bildirimlerinde hassas detay gösterilmemelidir.

Yanlış:

> “Çocuğun kan tahlili sonucu yüklendi.”

Doğru:

> “Yeni bir sağlık belgesi paylaşıldı.”

Yanlış:

> “Karşı taraf 1.250 TL okul masrafını reddetti.”

Doğru:

> “Masraf talebinizle ilgili yeni bir yanıt var.”

## 20.4 Bildirim Tercihleri

Kullanıcı her bildirim tipi için tercih yapabilmelidir:

- Push
- E-posta
- Uygulama içi
- Kapalı

Acil durum bildirimleri varsayılan açık olmalıdır; ancak kullanıcı kontrolü olmalıdır.

---

# 21. Modül 14 — Değiştirilemez Kayıt / PDF Rapor

## 21.1 Amaç

Mesaj, takvim, teslim, masraf, belge, uyuşmazlık ve onay kayıtlarının tarih aralığına göre düzenli PDF rapor olarak dışa aktarılmasını sağlamak.

## 21.2 Rapor Türleri

- Mesaj raporu
- Takvim raporu
- Teslim raporu
- Masraf raporu
- Belge paylaşım raporu
- Onay talebi raporu
- Uyuşmazlık raporu
- Kişisel kayıt defteri raporu
- Tüm kayıtlar raporu

## 21.3 Rapor Filtreleri

- Tarih aralığı
- Çocuk
- Konu
- Modül
- Taraf
- Durum
- Sadece paylaşılanlar
- Sağlık verilerini dahil et / etme
- Dosya eklerini dahil et / etme

## 21.4 PDF İçeriği

PDF raporda:

- Uygulama adı
- Rapor başlığı
- Rapor oluşturma tarihi
- Kullanıcı bilgisi
- Çocuk bilgisi
- Tarih aralığı
- Filtreler
- Kayıt listesi
- Zaman damgaları
- Okundu/onay bilgileri
- Dosya listesi
- Hash doğrulama kodu
- QR doğrulama linki
- Hukuki uyarı

## 21.5 Hukuki Uyarı

PDF sonunda şu uyarı yer almalıdır:

> Bu rapor, Ebeveyn Köprüsü uygulamasında kayıtlı kullanıcı işlemlerinden oluşturulmuş bilgilendirme ve kayıt çıktısıdır. Raporun hukuki delil niteliği, geçerliliği ve değerlendirilmesi ilgili mevzuat, olayın niteliği ve yetkili makamların takdirine bağlıdır. Bu uygulama hukuki danışmanlık hizmeti sunmaz.

## 21.6 Hash Chain

Her kritik işlem audit log’a yazılırken hash oluşturulmalıdır.

Hash input örneği:

```json
{
  "previous_hash": "...",
  "actor_id": "...",
  "action_type": "message.created",
  "entity_type": "messages",
  "entity_id": "...",
  "payload_hash": "...",
  "created_at": "..."
}
```

Hash üretimi:

```text
current_hash = SHA256(previous_hash + actor_id + action_type + entity_type + entity_id + payload_hash + created_at)
```

Bu yapı kayıtların sonradan değiştirilmediğini teknik olarak destekler. Ancak uygulama bunu kesin hukuki delil olarak pazarlamamalıdır.

## 21.7 QR Doğrulama

PDF rapora QR kod eklenir. QR kod doğrulama sayfasına gider:

`https://app-domain.com/verify-report/{report_id}?token=...`

Doğrulama sayfası:

- Rapor ID
- Oluşturma tarihi
- Hash doğrulama sonucu
- Raporun değiştirilip değiştirilmediği bilgisi
- Sınırlı metadata

Tam içerik yalnızca yetkili kullanıcı girişiyle açılır.

---

# 22. Modül 15 — Çocuğun İhtiyaçları Panosu

## 22.1 Amaç

Çocuğun günlük/haftalık ihtiyaçlarının ebeveynler arasında düzenli takip edilmesi.

## 22.2 İhtiyaç Tipleri

- Okul çantası
- Kıyafet
- İlaç
- Kitap
- Ödev
- Spor ekipmanı
- Etkinlik malzemesi
- Sağlık randevusu
- Kurs malzemesi
- Harçlık
- Belge
- Diğer

## 22.3 Alanlar

- Çocuk
- İhtiyaç başlığı
- Açıklama
- Kategori
- Son tarih
- Sorumlu ebeveyn
- Durum
- Öncelik
- Ek dosya
- Hatırlatma tarihi

## 22.4 Durumlar

- `new`
- `in_progress`
- `completed`
- `cancelled`
- `overdue`

## 22.5 Kullanıcı Akışı

1. Kullanıcı ihtiyaç oluşturur.
2. Sorumlu kişi seçer.
3. Son tarih belirler.
4. Sistem bildirim gönderir.
5. İhtiyaç tamamlandı olarak işaretlenir.
6. Değişiklik audit log’a yazılır.

---

# 23. Modül 16 — Teslim Çantası Kontrol Listesi

## 23.1 Amaç

Çocuğun bir ebeveynden diğerine geçerken gerekli eşyalarının unutulmamasını sağlamak.

## 23.2 Varsayılan Checklist Maddeleri

- Okul çantası
- Kimlik
- Sağlık kartı
- İlaç
- Reçete
- Yedek kıyafet
- Spor kıyafeti
- Kitaplar
- Tablet
- Şarj cihazı
- Oyuncak
- Mont
- Ayakkabı
- Ödev
- Diğer

## 23.3 Checklist Tipleri

- Varsayılan teslim listesi
- Okul günü teslim listesi
- Tatil teslim listesi
- Sağlık randevusu teslim listesi
- Kullanıcı özel liste

## 23.4 Akış

1. Takvimde teslim etkinliği yaklaşır.
2. Sistem checklist hatırlatması gönderir.
3. Kullanıcı maddeleri işaretler.
4. “Teslim çantası hazırlandı” kaydı oluşur.
5. İstenirse karşı ebeveyne bilgi gider.

---

# 24. Modül 17 — Acil Durum Modu

## 24.1 Amaç

Çocukla ilgili acil durumlarda diğer ebeveyne hızlı ve kayıtlı bildirim göndermek.

## 24.2 Acil Durum Tipleri

- Sağlık
- Kaza
- Okuldan acil çağrı
- Servis problemi
- Teslim problemi
- Ulaşamama
- Güvenlik endişesi
- Diğer

## 24.3 Acil Bildirim Alanları

- Çocuk
- Bildiren kullanıcı
- Acil durum tipi
- Açıklama
- Konum opsiyonel
- Fotoğraf/belge opsiyonel
- Acil kişiler bildirilsin mi?
- Durum
- Oluşturulma zamanı

## 24.4 Akış

1. Kullanıcı “Acil Durum” butonuna basar.
2. Acil durum tipi seçer.
3. Kısa açıklama yazar.
4. Gerekirse konum/fotoğraf ekler.
5. Bildirim gönderilir.
6. Karşı taraf “gördüm” veya “yanıtladım” işaretler.
7. Kayıt audit log’a yazılır.

## 24.5 Güvenlik

Acil durum butonu kötüye kullanıma açık olabilir. Bu nedenle:

- Kullanıcı geçmiş acil durum kayıtlarını görebilir.
- Aşırı kullanım admin risk flag’i oluşturabilir.
- Bildirim dili panik yaratmayacak şekilde tasarlanmalıdır.

---

# 25. Modül 18 — Çocuk İçin Hesap Açmama Kararı

## 25.1 Kural

İlk ürün sürümünde çocuk için aktif kullanıcı hesabı açılmayacaktır.

## 25.2 Gerekçe

- Çocuğun ebeveyn çatışmasına dahil edilmemesi
- KVKK ve çocuk verisi risklerinin azaltılması
- Psikolojik yükün önlenmesi
- Çocuğun iletişim aracına dönüştürülmesinin engellenmesi
- Ürünün ebeveyn koordinasyon aracı olarak kalması

## 25.3 Gelecek İhtimal

İleride 15+ yaş için pasif takvim görüntüleme modu değerlendirilebilir. Ancak bu ilk kapsamda yapılmayacaktır.

---

# 26. Modül 19 — Abonelik ve Paket Özellikleri

## 26.1 Ücretlendirme Stratejisi

Ürün ücretsiz olmayacaktır. Sınırlı deneme süresi verilebilir.

Önerilen başlangıç modeli:

- 7 gün ücretsiz deneme
- Aylık abonelik
- Yıllık abonelik
- Apple App Store ve Google Play üzerinden ödeme
- Web ödeme ileride eklenebilir

## 26.2 Paketler

İlk sürümde sade yapı önerilir:

### Ebeveyn Köprüsü Premium

Özellikler:

- Çocuk profili
- Ebeveyn bağlantısı
- Tek ebeveyn modu
- Takvim
- Teslim kayıtları
- Mesajlaşma
- Masraf takibi
- Belge arşivi
- Okul/servis/sağlık bilgi merkezi
- Onay talepleri
- Uyuşmazlık merkezi
- Çocuk ihtiyaçları panosu
- Teslim çantası checklist
- Acil durum modu
- PDF raporlar
- Sakin Dil Asistanı
- Üçüncü kişi erişimi
- Bildirimler

## 26.3 İleride Paket Ayrımı

İleride şu paketler oluşturulabilir:

### Plus

- Temel takvim
- Temel mesajlaşma
- Çocuk profili
- Temel belge paylaşımı

### Premium

- Masraf
- Rapor
- Teslim kayıtları
- Sakin Dil Asistanı
- Uyuşmazlık
- Tek ebeveyn modu

### Professional

- Avukat erişimi
- Arabulucu erişimi
- Gelişmiş raporlar
- Kurumsal danışman paneli
- Geniş depolama

## 26.4 Subscription Entitlements

RevenueCat tarafında entitlement:

- `premium_access`
- `professional_access` future

Supabase `subscriptions` tablosunda:

- user_id
- provider
- entitlement
- status
- product_id
- current_period_start
- current_period_end
- trial_ends_at
- last_webhook_payload
- updated_at

## 26.5 Paywall

Paywall şu durumlarda gösterilir:

- Deneme süresi bitmişse
- Aktif abonelik yoksa
- Kullanıcı premium modüle erişmek isterse
- PDF rapor almak isterse
- Üçüncü kişi erişimi oluşturmak isterse
- Sakin Dil Asistanı kullanmak isterse
- Storage kotası aşılırsa

---

# 27. Uygulama Ekranları

## 27.1 Auth Ekranları

1. Splash Screen
2. Onboarding
3. Login
4. Register
5. Forgot Password
6. Email Verification
7. Phone Verification optional
8. Terms Acceptance
9. Privacy/KVKK Consent
10. Paywall / Subscription

## 27.2 İlk Kurulum Ekranları

1. Profil oluştur
2. Ebeveyn rolü seç
3. Çocuk ekle
4. Tek ebeveyn modu veya diğer ebeveyni davet et
5. Temel takvim düzeni oluştur
6. Bildirim izinleri
7. Biyometrik giriş önerisi

## 27.3 Ana Navigasyon

Bottom navigation önerisi:

1. Ana Sayfa
2. Takvim
3. Mesajlar
4. Masraflar
5. Daha Fazla

“Daha Fazla” içinde:

- Belgeler
- Çocuk Profili
- Okul/Servis/Sağlık
- Onay Talepleri
- Uyuşmazlık
- İhtiyaçlar
- Teslim Çantası
- Acil Durum
- Raporlar
- Kişisel Kayıt Defteri
- Üçüncü Kişi Erişimi
- Abonelik
- Ayarlar

## 27.4 Ana Sayfa

Ana sayfa kartları:

- Bugün çocuk kimde?
- Sonraki teslim
- Bekleyen onaylar
- Yeni mesajlar
- Bekleyen masraf talepleri
- Yaklaşan okul/sağlık etkinlikleri
- Açık uyuşmazlıklar
- Çocuk ihtiyaçları
- Acil durum butonu

## 27.5 Takvim Ekranı

- Aylık görünüm
- Haftalık görünüm
- Liste görünümü
- Renkli ebeveyn günleri
- Teslim bilgisi
- Değişiklik talebi butonu
- Filtre: çocuk, ebeveyn, etkinlik tipi
- Kural yönetimi

## 27.6 Mesaj Ekranı

- Thread listesi
- Konu filtresi
- Okunmamışlar
- Yeni thread oluştur
- Mesaj gönder
- Ek dosya
- Sakin Dil Asistanı
- Okundu bilgisi

## 27.7 Masraf Ekranı

- Toplam masraf özeti
- Bekleyenler
- Kabul edilenler
- İtiraz edilenler
- Ödenenler
- Yeni masraf
- Dekont yükle
- Rapor al

## 27.8 Belge Ekranı

- Kategori bazlı dosyalar
- Okul belgeleri
- Sağlık belgeleri
- Masraf belgeleri
- Mahkeme/protokol belgeleri
- Kişisel belgeler
- Paylaşılmış belgeler
- Dosya yükle

## 27.9 Rapor Ekranı

- Rapor tipi seç
- Tarih aralığı seç
- Çocuk seç
- Modül seç
- Sağlık verisi dahil edilsin mi?
- Kişisel notlar dahil edilsin mi?
- PDF oluştur
- Rapor geçmişi
- Rapor paylaş

---

# 28. Flutter Proje Yapısı

Aşağıdaki klasör yapısı kullanılmalıdır:

```text
lib/
  main.dart
  app.dart

  core/
    config/
      app_config.dart
      env.dart
    constants/
      app_colors.dart
      app_strings.dart
      app_routes.dart
    errors/
      app_exception.dart
      error_handler.dart
    security/
      local_auth_service.dart
      device_service.dart
    utils/
      date_utils.dart
      validators.dart
      formatters.dart
      hash_utils.dart
    widgets/
      app_button.dart
      app_text_field.dart
      app_card.dart
      loading_view.dart
      empty_state.dart
      error_view.dart

  data/
    supabase/
      supabase_client_provider.dart
      supabase_tables.dart
    repositories/
      auth_repository.dart
      family_repository.dart
      child_repository.dart
      calendar_repository.dart
      custody_repository.dart
      message_repository.dart
      expense_repository.dart
      document_repository.dart
      report_repository.dart
      audit_repository.dart
      subscription_repository.dart
      notification_repository.dart
      dispute_repository.dart
      decision_repository.dart
      personal_journal_repository.dart

  domain/
    models/
      app_user.dart
      family.dart
      family_member.dart
      child.dart
      custody_plan.dart
      custody_event.dart
      change_request.dart
      message_thread.dart
      message.dart
      expense.dart
      document.dart
      decision_request.dart
      dispute.dart
      contact.dart
      school_info.dart
      service_info.dart
      health_info.dart
      child_need.dart
      handover_checklist.dart
      emergency_event.dart
      report.dart
      audit_log.dart
      subscription.dart
    enums/
      user_role.dart
      member_status.dart
      custody_status.dart
      expense_status.dart
      message_topic.dart
      decision_status.dart
      dispute_status.dart
      document_category.dart

  features/
    auth/
      screens/
      widgets/
      controllers/
    onboarding/
      screens/
      widgets/
      controllers/
    home/
      screens/
      widgets/
      controllers/
    children/
      screens/
      widgets/
      controllers/
    calendar/
      screens/
      widgets/
      controllers/
    custody/
      screens/
      widgets/
      controllers/
    messages/
      screens/
      widgets/
      controllers/
    expenses/
      screens/
      widgets/
      controllers/
    documents/
      screens/
      widgets/
      controllers/
    decisions/
      screens/
      widgets/
      controllers/
    disputes/
      screens/
      widgets/
      controllers/
    contacts/
      screens/
      widgets/
      controllers/
    school_service_health/
      screens/
      widgets/
      controllers/
    needs/
      screens/
      widgets/
      controllers/
    handover_bag/
      screens/
      widgets/
      controllers/
    emergency/
      screens/
      widgets/
      controllers/
    journal/
      screens/
      widgets/
      controllers/
    reports/
      screens/
      widgets/
      controllers/
    subscriptions/
      screens/
      widgets/
      controllers/
    settings/
      screens/
      widgets/
      controllers/
    admin/
      screens/
      widgets/
      controllers/
```

---

# 29. PostgreSQL Veri Modeli

Aşağıda temel tablolar verilmiştir. Codex bu şemayı Supabase migration dosyalarına dönüştürmelidir.

## 29.1 Extensions

```sql
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";
```

## 29.2 users_profile

```sql
create table public.user_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  avatar_url text,
  default_language text not null default 'tr',
  timezone text not null default 'Europe/Istanbul',
  is_onboarding_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.3 families

```sql
create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text,
  mode text not null default 'co_parent' check (mode in ('co_parent', 'solo')),
  status text not null default 'active' check (status in ('active', 'archived', 'deleted')),
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.4 family_members

```sql
create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  user_id uuid references public.user_profiles(id) on delete cascade,
  external_name text,
  external_email text,
  external_phone text,
  role text not null check (role in (
    'parent',
    'guardian',
    'lawyer',
    'mediator',
    'psychologist',
    'caregiver',
    'delivery_authorized_person',
    'admin',
    'support'
  )),
  relation_label text,
  access_level text not null default 'full' check (access_level in (
    'full',
    'limited_read',
    'report_view',
    'delivery_only',
    'calendar_only',
    'expense_only',
    'no_access'
  )),
  status text not null default 'active' check (status in (
    'active',
    'invited',
    'pending',
    'blocked',
    'removed',
    'solo_external_contact'
  )),
  invited_by uuid references public.user_profiles(id),
  invitation_token text,
  invitation_expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(family_id, user_id)
);
```

## 29.5 children

```sql
create table public.children (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  first_name text not null,
  last_name text,
  birth_date date,
  gender text check (gender in ('female', 'male', 'other', 'not_specified')),
  avatar_url text,
  notes text,
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.6 custody_plans

```sql
create table public.custody_plans (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  title text not null,
  source_type text not null default 'manual' check (source_type in ('manual', 'court_order', 'protocol', 'agreement')),
  source_document_id uuid,
  status text not null default 'active' check (status in ('draft', 'active', 'archived')),
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.7 custody_rules

```sql
create table public.custody_rules (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.custody_plans(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  assigned_parent_id uuid not null references public.user_profiles(id),
  rule_type text not null check (rule_type in (
    'weekly',
    'monthly_nth_weekend',
    'odd_even_week',
    'holiday',
    'date_range',
    'special_day',
    'custom_rrule'
  )),
  rrule text,
  start_time time,
  end_time time,
  start_date date,
  end_date date,
  delivery_location text,
  handover_note text,
  priority integer not null default 0,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.8 custody_events

```sql
create table public.custody_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  plan_id uuid references public.custody_plans(id) on delete set null,
  rule_id uuid references public.custody_rules(id) on delete set null,
  assigned_parent_id uuid not null references public.user_profiles(id),
  title text not null,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  delivery_location text,
  delivery_person_id uuid,
  status text not null default 'scheduled' check (status in (
    'scheduled',
    'change_requested',
    'accepted',
    'declined',
    'completed',
    'missed',
    'cancelled',
    'disputed'
  )),
  source text not null default 'manual' check (source in ('manual', 'rule_generated', 'change_request')),
  notes text,
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.9 change_requests

```sql
create table public.change_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  custody_event_id uuid references public.custody_events(id) on delete cascade,
  requested_by uuid not null references public.user_profiles(id),
  requested_to uuid references public.user_profiles(id),
  title text not null,
  reason text,
  proposed_starts_at timestamptz,
  proposed_ends_at timestamptz,
  proposed_location text,
  status text not null default 'submitted' check (status in (
    'draft',
    'submitted',
    'read',
    'approved',
    'rejected',
    'counter_proposed',
    'withdrawn',
    'expired'
  )),
  response_note text,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.10 handover_logs

```sql
create table public.handover_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  custody_event_id uuid references public.custody_events(id) on delete set null,
  actor_id uuid not null references public.user_profiles(id),
  action_type text not null check (action_type in (
    'departed',
    'arrived',
    'delivered',
    'received',
    'not_completed',
    'delay_reported',
    'waiting',
    'alternative_person_selected',
    'problem_reported'
  )),
  note text,
  latitude numeric,
  longitude numeric,
  location_accuracy numeric,
  photo_document_id uuid,
  status text not null default 'recorded' check (status in ('recorded', 'confirmed', 'disputed')),
  created_at timestamptz not null default now()
);
```

## 29.11 contacts

```sql
create table public.contacts (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  name text not null,
  relation_type text not null,
  phone text,
  email text,
  address text,
  can_pickup_child boolean not null default false,
  can_be_emergency_contact boolean not null default false,
  visible_to_other_parent boolean not null default true,
  approval_status text not null default 'not_required' check (approval_status in (
    'not_required',
    'pending',
    'approved',
    'rejected'
  )),
  created_by uuid not null references public.user_profiles(id),
  updated_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.12 school_infos

```sql
create table public.school_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  school_name text,
  class_name text,
  teacher_name text,
  teacher_phone text,
  school_phone text,
  school_email text,
  school_address text,
  notes text,
  created_by uuid not null references public.user_profiles(id),
  updated_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.13 service_infos

```sql
create table public.service_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  company_name text,
  driver_name text,
  driver_phone text,
  vehicle_plate text,
  route_description text,
  morning_pickup_time time,
  evening_dropoff_time time,
  monthly_fee numeric(12,2),
  notes text,
  created_by uuid not null references public.user_profiles(id),
  updated_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.14 health_infos

```sql
create table public.health_infos (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  blood_type text,
  allergies text,
  regular_medications text,
  doctor_name text,
  hospital_name text,
  doctor_phone text,
  emergency_notes text,
  chronic_condition_notes text,
  created_by uuid not null references public.user_profiles(id),
  updated_by uuid references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.15 documents

```sql
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  uploaded_by uuid not null references public.user_profiles(id),
  category text not null check (category in (
    'school',
    'service',
    'health',
    'expense',
    'court',
    'protocol',
    'message_attachment',
    'handover',
    'emergency',
    'personal',
    'other'
  )),
  title text not null,
  description text,
  storage_bucket text not null,
  storage_path text not null,
  mime_type text,
  file_size bigint,
  is_shared_with_other_parent boolean not null default false,
  sensitivity_level text not null default 'normal' check (sensitivity_level in ('normal', 'sensitive', 'health', 'legal')),
  created_at timestamptz not null default now()
);
```

## 29.16 message_threads

```sql
create table public.message_threads (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  topic text not null check (topic in (
    'handover',
    'school',
    'service',
    'health',
    'expense',
    'document',
    'emergency',
    'general',
    'decision',
    'holiday_travel',
    'dispute',
    'child_needs',
    'other'
  )),
  title text not null,
  status text not null default 'active' check (status in ('active', 'closed', 'archived')),
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.17 messages

```sql
create table public.messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.message_threads(id) on delete cascade,
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  sender_id uuid not null references public.user_profiles(id),
  body text not null,
  reply_to_message_id uuid references public.messages(id) on delete set null,
  tone_risk_score numeric(5,2),
  tone_analysis jsonb,
  hash text,
  created_at timestamptz not null default now()
);
```

## 29.18 message_read_receipts

```sql
create table public.message_read_receipts (
  id uuid primary key default gen_random_uuid(),
  message_id uuid not null references public.messages(id) on delete cascade,
  user_id uuid not null references public.user_profiles(id) on delete cascade,
  read_at timestamptz not null default now(),
  unique(message_id, user_id)
);
```

## 29.19 expenses

```sql
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  paid_by uuid not null references public.user_profiles(id),
  title text not null,
  description text,
  category text not null,
  expense_type text not null default 'shared',
  amount numeric(12,2) not null,
  currency text not null default 'TRY',
  expense_date date not null,
  requested_share_amount numeric(12,2),
  requested_share_ratio numeric(5,2),
  due_date date,
  status text not null default 'draft' check (status in (
    'draft',
    'submitted',
    'read',
    'accepted',
    'partially_accepted',
    'rejected',
    'disputed',
    'paid',
    'partially_paid',
    'overdue',
    'cancelled',
    'reported'
  )),
  response_note text,
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.20 expense_documents

```sql
create table public.expense_documents (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid not null references public.expenses(id) on delete cascade,
  document_id uuid not null references public.documents(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique(expense_id, document_id)
);
```

## 29.21 decision_requests

```sql
create table public.decision_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  requested_by uuid not null references public.user_profiles(id),
  decision_type text not null,
  title text not null,
  description text,
  related_date date,
  response_deadline timestamptz,
  status text not null default 'submitted' check (status in (
    'draft',
    'submitted',
    'read',
    'approved',
    'rejected',
    'info_requested',
    'expired',
    'withdrawn',
    'disputed'
  )),
  response_by uuid references public.user_profiles(id),
  response_note text,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.22 disputes

```sql
create table public.disputes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  opened_by uuid not null references public.user_profiles(id),
  dispute_type text not null,
  title text not null,
  description text,
  related_entity_type text,
  related_entity_id uuid,
  status text not null default 'open' check (status in (
    'open',
    'waiting_response',
    'responded',
    'in_review',
    'resolved',
    'unresolved',
    'closed',
    'reported'
  )),
  response_text text,
  resolution_note text,
  include_in_report boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.23 personal_journal_entries

```sql
create table public.personal_journal_entries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  user_id uuid not null references public.user_profiles(id) on delete cascade,
  title text not null,
  body text not null,
  category text not null,
  include_in_report boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.24 child_needs

```sql
create table public.child_needs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  title text not null,
  description text,
  category text not null,
  assigned_to uuid references public.user_profiles(id),
  due_date date,
  priority text not null default 'normal' check (priority in ('low', 'normal', 'high', 'urgent')),
  status text not null default 'new' check (status in ('new', 'in_progress', 'completed', 'cancelled', 'overdue')),
  created_by uuid not null references public.user_profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.25 handover_checklists

```sql
create table public.handover_checklists (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  custody_event_id uuid references public.custody_events(id) on delete cascade,
  title text not null,
  checklist_type text not null default 'default',
  created_by uuid not null references public.user_profiles(id),
  completed_at timestamptz,
  created_at timestamptz not null default now()
);
```

## 29.26 handover_checklist_items

```sql
create table public.handover_checklist_items (
  id uuid primary key default gen_random_uuid(),
  checklist_id uuid not null references public.handover_checklists(id) on delete cascade,
  label text not null,
  is_checked boolean not null default false,
  checked_by uuid references public.user_profiles(id),
  checked_at timestamptz,
  sort_order integer not null default 0
);
```

## 29.27 emergency_events

```sql
create table public.emergency_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid not null references public.children(id) on delete cascade,
  reported_by uuid not null references public.user_profiles(id),
  emergency_type text not null,
  description text,
  latitude numeric,
  longitude numeric,
  status text not null default 'open' check (status in ('open', 'seen', 'responded', 'closed')),
  seen_at timestamptz,
  responded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

## 29.28 reports

```sql
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  family_id uuid not null references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  created_by uuid not null references public.user_profiles(id),
  report_type text not null,
  title text not null,
  filters jsonb not null default '{}'::jsonb,
  storage_bucket text,
  storage_path text,
  verification_token text not null,
  report_hash text,
  status text not null default 'created' check (status in ('created', 'generating', 'ready', 'failed', 'revoked')),
  created_at timestamptz not null default now()
);
```

## 29.29 audit_logs

```sql
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  actor_id uuid references public.user_profiles(id) on delete set null,
  action_type text not null,
  entity_type text not null,
  entity_id uuid,
  old_value jsonb,
  new_value jsonb,
  payload_hash text,
  previous_hash text,
  current_hash text not null,
  ip_address inet,
  user_agent text,
  device_id text,
  created_at timestamptz not null default now()
);
```

## 29.30 subscriptions

```sql
create table public.subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.user_profiles(id) on delete cascade,
  provider text not null check (provider in ('revenuecat', 'apple', 'google', 'manual')),
  entitlement text not null,
  status text not null check (status in ('active', 'trialing', 'past_due', 'cancelled', 'expired', 'unknown')),
  product_id text,
  original_transaction_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  trial_ends_at timestamptz,
  raw_payload jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
```

---

# 30. RLS Politikaları

## 30.1 Temel Yaklaşım

Tüm kullanıcı verisi tablolarında RLS aktif olmalıdır.

```sql
alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.children enable row level security;
alter table public.custody_events enable row level security;
alter table public.messages enable row level security;
alter table public.expenses enable row level security;
alter table public.documents enable row level security;
alter table public.audit_logs enable row level security;
```

## 30.2 Yardımcı Fonksiyon

```sql
create or replace function public.is_family_member(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.access_level <> 'no_access'
  );
$$;
```

## 30.3 Tam Erişim Kontrolü

```sql
create or replace function public.has_family_full_access(target_family_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.access_level = 'full'
  );
$$;
```

## 30.4 families SELECT

```sql
create policy "Members can view their families"
on public.families
for select
using (public.is_family_member(id));
```

## 30.5 children SELECT

```sql
create policy "Members can view children in their families"
on public.children
for select
using (public.is_family_member(family_id));
```

## 30.6 children INSERT

```sql
create policy "Full members can create children"
on public.children
for insert
with check (public.has_family_full_access(family_id));
```

## 30.7 messages SELECT

```sql
create policy "Family members can view messages"
on public.messages
for select
using (public.is_family_member(family_id));
```

## 30.8 messages INSERT

```sql
create policy "Full family members can send messages"
on public.messages
for insert
with check (
  public.has_family_full_access(family_id)
  and sender_id = auth.uid()
);
```

## 30.9 personal_journal_entries SELECT

Kişisel günlük sadece oluşturan kullanıcı tarafından görülebilir.

```sql
create policy "Users can view their own journal entries"
on public.personal_journal_entries
for select
using (user_id = auth.uid());
```

## 30.10 personal_journal_entries INSERT

```sql
create policy "Users can create their own journal entries"
on public.personal_journal_entries
for insert
with check (
  user_id = auth.uid()
  and public.is_family_member(family_id)
);
```

## 30.11 audit_logs SELECT

Audit log kullanıcıya doğrudan ham şekilde gösterilmeyebilir. Ancak raporlama için aile üyeleri sınırlı okuyabilir.

```sql
create policy "Family members can view audit logs"
on public.audit_logs
for select
using (family_id is not null and public.is_family_member(family_id));
```

## 30.12 Storage RLS

Storage path mantığı:

```text
family/{family_id}/children/{child_id}/documents/{document_id}/{filename}
family/{family_id}/health/{document_id}/{filename}
family/{family_id}/expenses/{expense_id}/{filename}
family/{family_id}/reports/{report_id}.pdf
user/{user_id}/private/{document_id}/{filename}
```

Storage erişimi tablo bazlı `documents` kaydı üzerinden kontrol edilmelidir.

---

# 31. Supabase Edge Functions

Aşağıdaki Edge Function’lar geliştirilecektir:

## 31.1 `create-audit-log`

Amaç:

- Kritik işlem sonrası audit log oluşturmak
- Hash chain üretmek
- Previous hash bulmak
- Current hash üretmek

## 31.2 `send-notification`

Amaç:

- Push notification göndermek
- E-posta bildirimleri için altyapı
- Hassas veri temizleme
- Bildirim tercihlerini kontrol etme

## 31.3 `generate-report`

Amaç:

- Rapor filtrelerini almak
- İlgili kayıtları toplamak
- PDF üretmek
- Storage’a kaydetmek
- Report hash üretmek
- QR doğrulama token oluşturmak

## 31.4 `verify-report`

Amaç:

- Rapor doğrulama token’ını kontrol etmek
- Hash doğrulama sonucunu döndürmek
- Public doğrulama için sınırlı bilgi vermek

## 31.5 `revenuecat-webhook`

Amaç:

- RevenueCat webhook event’lerini almak
- Subscription status güncellemek
- Entitlement kaydetmek
- Kullanıcı premium erişimini güncellemek

## 31.6 `tone-assistant`

Amaç:

- Mesaj ton analizi yapmak
- Risk skoru üretmek
- Daha nötr metin önerisi üretmek
- Sağlayıcı bağımsız AI mimarisi sağlamak

## 31.7 `external-response`

Amaç:

- Tek ebeveyn modunda dış kullanıcıların güvenli link üzerinden yanıt vermesini sağlamak
- Token geçerliliğini kontrol etmek
- Yanıtı ilgili talebe/masrafa/teslim kaydına bağlamak

## 31.8 `scheduled-reminders`

Amaç:

- Teslim zamanı yaklaşan etkinlikleri bulmak
- Ödeme son tarihlerini kontrol etmek
- Onay süresi dolmak üzere olan talepleri bildirmek
- Abonelik uyarıları göndermek

---

# 32. Audit Log Kuralları

Aşağıdaki işlemler zorunlu olarak audit log’a yazılmalıdır:

## 32.1 Auth/Profile

- Profil oluşturuldu
- Profil güncellendi
- Bildirim tercihi değişti
- Biyometrik giriş açıldı/kapatıldı

## 32.2 Family/Child

- Aile oluşturuldu
- Üye davet edildi
- Üye kabul etti
- Çocuk profili oluşturuldu
- Çocuk profili güncellendi

## 32.3 Calendar/Custody

- Plan oluşturuldu
- Kural oluşturuldu
- Etkinlik oluşturuldu
- Etkinlik değiştirildi
- Değişiklik talebi gönderildi
- Değişiklik kabul edildi
- Değişiklik reddedildi

## 32.4 Handover

- Teslim için yola çıkıldı
- Teslim noktasına gelindi
- Çocuk teslim edildi
- Teslim alınmadı
- Teslim gerçekleşmedi
- Gecikme bildirildi

## 32.5 Messages

- Mesaj gönderildi
- Mesaj okundu
- Thread oluşturuldu
- Dosya eklendi

## 32.6 Expenses

- Masraf oluşturuldu
- Masraf gönderildi
- Masraf okundu
- Masraf kabul edildi
- Masrafa itiraz edildi
- Masraf ödendi

## 32.7 Documents

- Belge yüklendi
- Belge paylaşıldı
- Belge okundu
- Belge rapora eklendi

## 32.8 Decisions

- Onay talebi oluşturuldu
- Onay verildi
- Ret verildi
- Ek bilgi istendi
- Talep süresi doldu

## 32.9 Disputes

- Uyuşmazlık açıldı
- Yanıt verildi
- Çözüldü
- Çözümsüz kapandı

## 32.10 Reports

- Rapor oluşturuldu
- Rapor indirildi
- Rapor paylaşıldı
- Rapor doğrulandı

---

# 33. KVKK / Gizlilik / Güvenlik Gereklilikleri

## 33.1 Aydınlatma ve Onay

Uygulama ilk kullanımda şu metinleri göstermelidir:

- Kullanım koşulları
- Gizlilik politikası
- KVKK aydınlatma metni
- Çocuk verisi işleme bilgilendirmesi
- Sağlık verisi işleme uyarısı
- Konum verisi uyarısı
- AI/Ton analizi veri işleme uyarısı

## 33.2 Veri Minimizasyonu

- Çocuğun T.C. kimlik numarası alınmamalıdır.
- Gereksiz sağlık verisi istenmemelidir.
- Canlı konum takip edilmemelidir.
- Çocuk için kullanıcı hesabı oluşturulmamalıdır.
- Push bildirimlerinde hassas içerik gösterilmemelidir.

## 33.3 Güvenlik

- Supabase RLS
- Storage policy
- TLS
- Şifreli dosya saklama, mümkünse
- Kullanıcı oturum kontrolü
- Biyometrik giriş desteği
- Device ID kayıtları
- IP/user-agent audit
- Rate limiting
- Anti-abuse kontrolleri

## 33.4 Hesap Silme

Kullanıcı hesap silme talebinde bulunabilmelidir.

Ancak audit log ve karşı tarafla paylaşılan kayıtların silinmesi hukuki/operasyonel açıdan dikkatli tasarlanmalıdır.

Önerilen politika:

- Kullanıcının özel verileri silinir/anonymize edilir.
- Aile içi paylaşılan kayıtlar karşı tarafın meşru kayıt hakkı nedeniyle tamamen silinmeyebilir.
- Kişisel günlük gibi sadece kullanıcıya ait özel kayıtlar silinebilir.
- Bu süreç gizlilik politikasında açıkça belirtilmelidir.

## 33.5 Veri Dışa Aktarma

Kullanıcı kendi verilerini dışa aktarabilmelidir:

- PDF
- JSON export
- Dosya listesi

---

# 34. Admin Panel ve Operasyon Yönetimi

Admin panel ilk sürümde web tabanlı ayrı bir panel olarak planlanmalıdır. Flutter mobil uygulamanın içine admin ekranı gömülmemelidir. Geliştirme hızlandırmak için ilk aşamada Supabase Studio kullanılabilir; ancak production için ayrı bir `admin_web` uygulaması önerilir.

## 34.1 Admin Panel Teknoloji Seçeneği

Önerilen seçenekler:

1. Flutter Web admin panel
2. Next.js admin panel
3. Supabase Studio + sınırlı internal dashboard

Kod üretiminde hızlı ilerlemek için Codex şu yapıyı hazırlamalıdır:

```text
/admin_web
  src/
    app/
    components/
    features/
      users/
      families/
      subscriptions/
      reports/
      support/
      audit/
      legal_requests/
```

Mobil app hazır edilecekse admin panel minimum seviyede web olarak oluşturulabilir; ama veritabanı ve yetki altyapısı admin paneli destekleyecek şekilde kurulmalıdır.

## 34.2 Admin Rolleri

- `admin`: Sistem yöneticisi
- `support`: Destek personeli
- `legal_ops`: KVKK/veri talebi operasyon kullanıcısı
- `finance_ops`: Abonelik/ödeme operasyon kullanıcısı

## 34.3 Admin Yetki İlkeleri

Admin kullanıcıları aile içeriklerine sınırsız erişmemelidir. Özellikle mesaj gövdeleri, sağlık belgeleri, çocuk notları, kişisel defter ve dosyalar varsayılan olarak maskelenmelidir.

Hassas erişim gerekiyorsa:

1. Erişim gerekçesi girilir.
2. Yetkili admin onayı gerekir.
3. Erişim süresi sınırlanır.
4. Tüm erişim `audit_logs` içine yazılır.
5. Kullanıcı destek talebiyle ilişkilendirilir.

## 34.4 Admin Panel Modülleri

Admin panelde şu modüller bulunmalıdır:

- Kullanıcı listesi
- Aile kayıtları
- Çocuk profil sayısı ama çocuk detayları maskeli
- Abonelik durumu
- RevenueCat customer id kontrolü
- Trial/aktif/iptal/refund durumları
- Destek talepleri
- Şikayetler
- Kötüye kullanım bildirimleri
- Rapor doğrulama
- Audit log görüntüleme
- Sistem bildirimleri
- Push bildirim test gönderimi
- Storage kota izleme
- KVKK veri indirme talepleri
- Hesap silme talepleri
- Hukuki talep kayıtları
- Sistem sağlığı/cron job kontrolü

## 34.5 Admin Dashboard Kartları

Dashboard üzerinde şu kartlar olmalıdır:

- Toplam kullanıcı
- Aktif abonelik
- Trial kullanıcı
- İptal eden kullanıcı
- Günlük aktif kullanıcı
- Aylık aktif kullanıcı
- Oluşturulan aile sayısı
- Tek ebeveyn modu kullanan aile sayısı
- Gönderilen mesaj sayısı
- Oluşturulan masraf sayısı
- Üretilen rapor sayısı
- Açık destek talebi sayısı
- Storage kullanımı
- Son 24 saat hata sayısı

## 34.6 Support View

Destek personeli aşağıdakileri görebilir:

- Kullanıcı adı/e-posta/telefon
- Abonelik durumu
- App version
- Device info
- Son giriş zamanı
- Son hata kaydı
- Ticket geçmişi

Destek personeli varsayılan olarak şunları göremez:

- Mesaj içerikleri
- Belge içerikleri
- Sağlık bilgileri
- Kişisel defter
- Çocuğun detay bilgileri

## 34.7 Rapor Doğrulama Paneli

Admin, doğrulama kodu veya QR token ile raporun sistemde var olup olmadığını kontrol edebilmelidir.

Gösterilecek bilgiler:

- Rapor ID
- Rapor türü
- Oluşturma tarihi
- Oluşturan kullanıcı ID
- Hash değeri
- Doğrulama durumu
- Rapor dosyasının sistemde var olup olmadığı

Admin rapor içeriğini otomatik olarak görememelidir. İçerik görüntüleme ayrı yetki ve audit log gerektirir.

## 34.8 KVKK Operasyon Akışları

Admin panelde şu talepler izlenmelidir:

- Verilerimi indir
- Hesabımı sil
- Açık rızamı geri çek
- Pazarlama iznimi iptal et
- Hatalı kişisel verinin düzeltilmesi
- Veri işleme itirazı

Her talep için durumlar:

- `received`
- `in_review`
- `waiting_user_confirmation`
- `processed`
- `rejected_with_reason`
- `closed`

## 34.9 Admin Kabul Kriterleri

Admin panel tamamlanmış sayılması için:

1. Admin login çalışmalı.
2. Admin rolü olmayan kullanıcı girememeli.
3. Kullanıcı listesi görüntülenebilmeli.
4. Abonelik durumu görüntülenebilmeli.
5. Destek talebi listelenebilmeli.
6. Audit log filtrelenebilmeli.
7. Rapor doğrulama yapılabilmeli.
8. Hassas içerikler varsayılan olarak maskeli olmalı.
9. Hassas erişimler audit log’a yazılmalı.
10. KVKK talepleri kayıt altına alınabilmeli.

---

# 35. UI/UX Tasarım Prensipleri

## 35.1 Görsel Dil

- Sakin
- Resmi
- Güven verici
- Çocuk odaklı
- Kavga dilinden uzak
- Aşırı renkli/oyuncu olmamalı
- Mahkeme/dava hissi fazla verilmemeli

## 35.2 Ana Renk Önerisi

- Lacivert / mavi tonları: güven
- Yumuşak yeşil: olumlu/çözüm
- Amber: bekleyen işlem
- Kırmızı: sadece acil/uyuşmazlık
- Gri: nötr kayıtlar

## 35.3 Dil

Yanlış:

- “Karşı taraf hata yaptı”
- “Eski eşinizi raporlayın”
- “Delil oluşturun”

Doğru:

- “Teslim kaydı oluşturuldu”
- “Yanıt bekleniyor”
- “Bilgi güncellendi”
- “Kayıt rapora dahil edilebilir”

## 35.4 Accessibility

- Büyük yazı desteği
- Kontrast yeterliliği
- Ekran okuyucu uyumu
- Basit formlar
- Hata mesajları açık ve yönlendirici

---


## 35.5 Nihai Arayüz Tasarım Sistemi

Codex sadece işlevsel ekran üretmemelidir; arayüz de kullanıma hazır, temiz, güven veren ve App Store/Google Play kalitesinde olmalıdır.

### 35.5.1 Tasarım Tonu

- Resmî ama soğuk olmayan
- Çocuk odaklı ama çocuksu olmayan
- Hukuki tehdit hissi vermeyen
- Sosyal medya/chat uygulaması gibi dağınık olmayan
- Eski eş çatışmasını körüklemeyen
- Veri güvenliği ve düzen duygusu veren

### 35.5.2 Renk Paleti

```dart
class AppColors {
  static const primary = Color(0xFF0F3D5E);      // petrol/lacivert
  static const primaryLight = Color(0xFFE8F2F7);
  static const secondary = Color(0xFF3A8D7C);    // yumuşak yeşil
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1F2933);
  static const textSecondary = Color(0xFF65717E);
  static const border = Color(0xFFE1E7ED);
  static const warning = Color(0xFFF2A93B);
  static const danger = Color(0xFFD64545);
  static const success = Color(0xFF2E8B57);
  static const info = Color(0xFF2F80ED);
}
```

### 35.5.3 Tipografi

- Başlıklar net, kısa ve güven verici olmalı.
- Form alanlarında açıklayıcı helper text kullanılmalı.
- Hata mesajları suçlayıcı olmamalı.
- Mesaj kategorileri ve durum etiketleri renk + metin ile anlaşılmalı; sadece renge güvenilmemeli.

Örnek:

```text
Yanlış: “Karşı taraf cevap vermedi.”
Doğru: “Bu talep için henüz cevap bekleniyor.”
```

### 35.5.4 Ana Bileşenler

Codex aşağıdaki reusable widget’ları üretmelidir:

```text
AppScaffold
AppTopBar
AppBottomNav
AppDrawer
AppPrimaryButton
AppSecondaryButton
AppDangerButton
AppTextField
AppDateTimeField
AppDropdownField
AppFilePickerTile
AppInfoCard
AppStatusChip
AppTimelineItem
AppAuditBadge
AppEmptyState
AppErrorState
AppLoadingOverlay
AppConfirmDialog
AppPaywallCard
AppChildSelector
AppFamilySelector
AppSensitiveDataNotice
AppReportPreviewCard
AppChecklistTile
AppNotificationPermissionSheet
```

### 35.5.5 Durum Etiketleri

```text
sent -> Gönderildi
read -> Okundu
accepted -> Kabul edildi
rejected -> Reddedildi
counter_proposed -> Alternatif önerildi
expired -> Süresi doldu
completed -> Tamamlandı
missed -> Gerçekleşmedi
disputed -> İtiraz edildi
overdue -> Gecikti
```

### 35.5.6 Loading / Empty / Error State Standardı

Her liste ekranında şu üç durum zorunludur:

1. Loading skeleton
2. Empty state
3. Error state + retry

Örnek boş durum metinleri:

- Takvim: “Henüz bir ebeveynlik planı oluşturulmadı.”
- Masraflar: “Bu çocuk için kayıtlı masraf bulunmuyor.”
- Belgeler: “Henüz belge yüklenmedi.”
- Mesajlar: “Bu konuda henüz mesaj yok.”
- Uyuşmazlıklar: “Açık uyuşmazlık bulunmuyor.”

### 35.5.7 Form Tasarım Kuralları

- Her formda kaydetmeden önce validasyon yapılmalı.
- Hassas veri içeren formlarda bilgi notu gösterilmeli.
- Sağlık bilgisi girilen ekranda özel gizlilik uyarısı bulunmalı.
- Dosya yüklenen formlarda dosya boyutu ve desteklenen format gösterilmeli.
- Kaydetme sırasında çift tıklama engellenmeli.
- Başarılı işlem sonrası kullanıcıya sade confirmation gösterilmeli.

### 35.5.8 Ekran Wireframe Talimatları

#### Ana Sayfa

```text
[TopBar: Ebeveyn Köprüsü | Child Selector | Notification Icon]

[Card] Bugün
  Çocuk: ...
  Bugünkü durum: Anne/Baba yanında
  Sonraki teslim: tarih/saat
  CTA: Teslim detayını gör

[Card] Bekleyenler
  - 2 onay talebi
  - 1 masraf yanıtı
  - 1 okunmamış belge

[Quick Actions Grid]
  Mesaj Yaz | Masraf Ekle | Belge Yükle | Teslim Kaydı | Rapor Oluştur | Acil Bildirim

[Card] Yaklaşan Etkinlikler
[Card] Son Kayıtlar
```

#### Takvim

```text
[Header] Takvim
[Segmented Control] Ay | Hafta | Liste
[Filter Chips] Çocuk | Ebeveyn | Etkinlik Türü
[Calendar View]
[Event Cards]
[CTA] Değişiklik Talep Et
```

#### Mesajlar

```text
[Header] Mesajlar
[Search]
[Topic Filter Chips]
[Thread List]
  Konu etiketi + başlık + son mesaj + okunmamış sayısı
[CTA] Yeni Konu Aç
```

#### Mesaj Detayı

```text
[Thread Header: Konu + ilgili çocuk + bağlı kayıt]
[Message Timeline]
[Attachment List]
[Input Area]
  Text input
  Attachment button
  Sakin Dil Asistanı button
  Send button
```

#### Masraflar

```text
[Summary Cards]
  Bu ay toplam | Bekleyen | Ödenen | İtiraz edilen
[Tabs] Tümü | Bekleyen | Kabul | İtiraz | Ödenen
[Expense List]
[Floating CTA] Masraf Ekle
```

#### Raporlar

```text
[Report Type Cards]
[Date Range Picker]
[Child Selector]
[Module Filters]
[Checkbox] Kişisel notlar dahil edilsin
[Checkbox] Sağlık verileri dahil edilsin
[CTA] PDF Oluştur
[Report History]
```

### 35.5.9 Accessibility

- Tüm butonlar minimum 44x44 px tıklama alanına sahip olmalı.
- Font scaling desteklenmeli.
- Renk körlüğü için sadece renk ile anlam verilmemeli.
- Form hataları ekran okuyucuya uygun olmalı.
- Kritik işlemlerde confirm dialog kullanılmalı.

### 35.5.10 Dark Mode

İlk sürümde light mode zorunludur. Dark mode altyapısı theme üzerinden hazır olmalı; ancak yayın öncesi test edilmemişse ayarlarda gösterilmemelidir.

# 36. Bildirim Metni Örnekleri

## 36.1 Takvim

- “Yarın planlanmış bir teslim etkinliği var.”
- “Teslim saatine 2 saat kaldı.”
- “Takvim değişikliği talebinize yanıt verildi.”

## 36.2 Masraf

- “Yeni bir masraf kaydı paylaşıldı.”
- “Masraf talebinizle ilgili yeni bir yanıt var.”
- “Ödeme tarihi yaklaşan bir masraf var.”

## 36.3 Belge

- “Yeni bir belge paylaşıldı.”
- “Paylaştığınız belge görüntülendi.”

## 36.4 Acil

- “Çocukla ilgili acil bir bildirim var.”
- “Acil bildirim yanıtlandı.”

---

# 37. Hata Yönetimi

Flutter tarafında tüm repository çağrıları try/catch ile yönetilmelidir.

Hata tipleri:

- Auth hatası
- RLS erişim hatası
- Network hatası
- Storage yükleme hatası
- Subscription hatası
- Validation hatası
- Edge Function hatası

Kullanıcıya teknik hata mesajı gösterilmemelidir.

Örnek:

Yanlış:

> PostgrestException: new row violates row-level security policy

Doğru:

> Bu işlemi yapma yetkiniz bulunmuyor veya oturumunuz yenilenmeli.

---

# 38. Test Gereklilikleri

## 38.1 Unit Tests

- Date rule generator
- Calendar event generation
- Expense calculations
- Hash generation
- Subscription entitlement check
- Notification content sanitizer
- RLS helper logic, SQL-level test mümkünse
- Tone assistant mock output

## 38.2 Widget Tests

- Login form
- Child creation form
- Calendar screen
- Expense form
- Message composer
- Report filter screen

## 38.3 Integration Tests

- User register/login
- Create family
- Invite co-parent
- Create child
- Create custody plan
- Generate events
- Send message
- Add expense
- Upload document
- Generate report
- Subscription gate

## 38.4 Security Tests

- Kullanıcı başka family verisini görememeli
- Kişisel journal karşı ebeveyn tarafından görülememeli
- Health docs yetkisiz erişilememeli
- Storage path manipülasyonu engellenmeli
- External response token süresi dolunca çalışmamalı

---

# 39. Kabul Kriterleri

Aşağıdaki kriterler sağlanmadan proje tamamlanmış sayılmayacaktır.

## 39.1 Genel

- iOS ve Android build alınabilir.
- Supabase migration dosyaları çalışır.
- RLS politikaları aktiftir.
- Auth akışı çalışır.
- Abonelik kontrolü çalışır.
- Bildirim izinleri yönetilir.
- Kullanıcı oturumu güvenli yönetilir.

## 39.2 Kullanıcı/Aile

- Kullanıcı kayıt olabilir.
- Profil oluşturabilir.
- Aile oluşturabilir.
- Tek ebeveyn modu seçebilir.
- Diğer ebeveyni davet edebilir.
- Çocuk profili ekleyebilir.

## 39.3 Takvim

- Kural oluşturulabilir.
- Takvim etkinliği üretilebilir.
- Teslim saati/noktası görüntülenir.
- Değişiklik talebi gönderilir.
- Talep kabul/reddedilir.

## 39.4 Teslim

- Teslim kaydı oluşturulur.
- Gecikme bildirilebilir.
- Teslim gerçekleşmedi kaydı açılabilir.
- Karşı taraf yanıt verebilir.
- Raporlanabilir.

## 39.5 Mesaj

- Konu bazlı thread oluşturulur.
- Mesaj gönderilir.
- Mesaj silinemez/düzenlenemez.
- Okundu bilgisi tutulur.
- Sakin Dil Asistanı çalışır veya mock çalışır.

## 39.6 Masraf

- Masraf oluşturulur.
- Belge eklenir.
- Karşı taraf kabul/itiraz eder.
- Ödeme durumu takip edilir.
- PDF rapora dahil edilir.

## 39.7 Belgeler

- Dosya yüklenir.
- Kategori atanır.
- Paylaşım ayarlanır.
- Storage RLS çalışır.
- Sağlık belgesi özel hassas kategoride tutulur.

## 39.8 Rapor

- Tarih aralığı seçilir.
- PDF oluşturulur.
- Storage’a kaydedilir.
- QR doğrulama token oluşur.
- Rapor hash üretilir.

## 39.9 Güvenlik

- Başka aile verisine erişim engellenir.
- Kişisel günlük özel kalır.
- Audit log oluşturulur.
- Hash chain çalışır.
- Push bildirimlerinde hassas detay gösterilmez.

---

# 40. Codex İçin Uygulama Görev Listesi

Codex aşağıdaki sırayla geliştirme yapmalıdır.

## 40.1 Proje Kurulumu

- Flutter projesi oluştur.
- Supabase bağlantısını yapılandır.
- Environment dosyalarını ayır.
- Riverpod, GoRouter, Supabase paketlerini ekle.
- Ortak theme ve UI componentlerini oluştur.

## 40.2 Supabase Kurulumu

- Migration dosyalarını oluştur.
- Tabloları oluştur.
- RLS politikalarını yaz.
- Storage bucket’ları oluştur.
- Edge Function iskeletlerini oluştur.

## 40.3 Auth ve Onboarding

- Register/login
- Email verification
- Profile creation
- Terms/KVKK acceptance
- Family creation
- Child creation
- Co-parent invitation
- Solo mode

## 40.4 Core Features

- Home dashboard
- Calendar/custody plan
- Handover logs
- Contacts
- School/service/health info
- Messages
- Expenses
- Documents
- Decision requests
- Disputes
- Journal
- Child needs
- Handover checklist
- Emergency mode
- Reports

## 40.5 Premium

- RevenueCat integration
- Subscription screen
- Entitlement check
- Paywall
- Webhook function

## 40.6 AI / Tone Assistant

- Mock tone analysis first
- Edge Function interface
- Flutter modal
- Provider-agnostic structure

## 40.7 Reporting

- PDF generator
- QR verification
- Report storage
- Report list
- Report sharing

## 40.8 Finalization

- Tests
- Error handling
- Localization
- App icon/splash
- Store metadata placeholders
- Privacy policy link placeholders
- Build scripts

---

# 41. Store Listing Taslağı

## 41.1 Kısa Açıklama

Ebeveyn Köprüsü, ayrı yaşayan ebeveynler için çocuk odaklı takvim, teslim, masraf, belge ve güvenli iletişim uygulamasıdır.

## 41.2 Uzun Açıklama

Ebeveyn Köprüsü, boşanmış veya ayrı yaşayan ebeveynlerin çocuklarıyla ilgili günlük koordinasyonu daha düzenli ve kayıtlı şekilde yürütmesini sağlar.

Çocuğun hangi gün hangi ebeveynde kalacağını takip edin, teslim saatlerini ve noktalarını yönetin, masrafları belgeleyin, okul/servis/sağlık bilgilerini güncel tutun, önemli kararlar için onay talepleri oluşturun ve gerektiğinde tarih aralığına göre PDF rapor alın.

Öne çıkan özellikler:

- Ortak çocuk takvimi
- Teslim ve teslim alma kayıtları
- Konu bazlı mesajlaşma
- Masraf ve fatura takibi
- Belge arşivi
- Okul, servis ve sağlık bilgi merkezi
- Onay gerektiren kararlar
- Uyuşmazlık ve itiraz merkezi
- Kişisel kayıt defteri
- Acil durum bildirimi
- PDF raporlar
- Sakin Dil Asistanı
- Tek ebeveyn modu

Not: Ebeveyn Köprüsü hukuki danışmanlık hizmeti sunmaz. Uygulamada oluşturulan kayıt ve raporlar bilgilendirme amaçlıdır.

---

# 42. Önemli Ürün Kararları

## 42.1 Canlı Konum Takibi Yok

Gerekçe:

- Kötüye kullanım riski
- Mahremiyet riski
- Güvenlik riski
- Ürünün çocuk odaklı amacından sapma riski

Sadece teslim anında opsiyonel konum check-in olabilir.

## 42.2 Çocuk Hesabı Yok

Gerekçe:

- Çocuğu ebeveyn çatışmasına dahil etmemek
- KVKK risklerini azaltmak
- Psikolojik yük oluşturmamak

## 42.3 Mesaj Silme Yok

Gerekçe:

- Kayıt bütünlüğü
- Raporlanabilirlik
- Güvenilir iletişim geçmişi

Düzeltme gerekiyorsa yeni mesaj atılır.

## 42.4 Hukuki İddia Yok

Gerekçe:

- Uygulama hukuk hizmeti değildir.
- Raporların delil niteliği mahkeme/avukat değerlendirmesine bağlıdır.
- Yanlış pazarlama riski önlenmelidir.

## 42.5 Tek Ebeveyn Modu Var

Gerekçe:

- Diğer ebeveyn uygulamaya katılmak istemeyebilir.
- Tek taraflı kayıt yine değer üretir.
- Kullanıcı kazanımını artırır.

---

# 43. Minimum Done Definition

Kod tarafında bir modül “bitti” sayılabilmesi için:

1. UI ekranı var.
2. Form validasyonu var.
3. Supabase CRUD çalışıyor.
4. RLS ile güvenli.
5. Audit log yazıyor.
6. Bildirim gerekiyorsa tetikleniyor.
7. Hata mesajları kullanıcı dostu.
8. Loading/empty/error state var.
9. Test senaryosu var.
10. Raporlanması gerekiyorsa rapora dahil ediliyor.

---


# 44. Environment, Kurulum ve Deployment Dosyaları

Codex aşağıdaki dosyaları oluşturmalıdır.

## 44.1 `.env.example`

```env
APP_ENV=development
APP_NAME=Ebeveyn Köprüsü
APP_DEFAULT_LOCALE=tr
APP_TIMEZONE=Europe/Istanbul

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_DB_PASSWORD=

REVENUECAT_IOS_API_KEY=
REVENUECAT_ANDROID_API_KEY=
REVENUECAT_WEBHOOK_SECRET=

FIREBASE_API_KEY=
FIREBASE_PROJECT_ID=
FIREBASE_MESSAGING_SENDER_ID=
FCM_SERVER_KEY=

SENTRY_DSN=
POSTHOG_API_KEY=

OPENAI_API_KEY=
GEMINI_API_KEY=
TONE_ASSISTANT_PROVIDER=mock

APP_STORE_PRIVACY_URL=
APP_STORE_TERMS_URL=
SUPPORT_EMAIL=
```

Güvenlik kuralı: `SUPABASE_SERVICE_ROLE_KEY` Flutter client içine asla konulmaz. Sadece Edge Functions ve güvenli server ortamında kullanılır.

## 44.2 README.md İçeriği

Codex ayrıca `README.md` oluşturmalı ve şu başlıkları yazmalıdır:

- Proje özeti
- Ürün konumlandırması
- Teknik mimari
- Flutter kurulum
- Supabase local development
- Migration çalıştırma
- Storage bucket kurulumu
- RLS policy kurulumu
- Edge Functions deploy
- Firebase/FCM kurulum
- RevenueCat ürün tanımları
- iOS build
- Android build
- Test çalıştırma
- Production environment
- KVKK/gizlilik notları
- Bilinen sınırlılıklar
- Geliştirici onboarding

## 44.3 `IMPLEMENTATION_NOTES.md`

Codex eksik bıraktığı veya mock olarak kurduğu yerleri bu dosyada açıkça listelemelidir. Kod içinde belirsiz TODO bırakılmamalıdır.

Örnek:

```md
# IMPLEMENTATION NOTES

## Mock Implementations
- tone-assistant currently uses rule-based mock provider.
- SMS provider adapter created but provider credentials not configured.

## Required Production Configuration
- RevenueCat products must be created in dashboard.
- Firebase plist/json files must be added.
```

## 44.4 CI/CD

Codex GitHub Actions workflow dosyaları hazırlamalıdır:

```text
.github/workflows/flutter_test.yml
.github/workflows/supabase_migrations_check.yml
.github/workflows/build_android.yml
.github/workflows/build_ios_placeholder.yml
```

Minimum CI adımları:

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Dart format kontrolü
- Migration dosyalarının syntax kontrolü
- Android debug build

## 44.5 Supabase Dosya Yapısı

```text
supabase/
  config.toml
  migrations/
    0001_extensions.sql
    0002_enums.sql
    0003_tables.sql
    0004_indexes.sql
    0005_rls_helpers.sql
    0006_rls_policies.sql
    0007_storage_buckets.sql
    0008_triggers_audit.sql
    0009_seed_subscription_plans.sql
  functions/
    send-notification/
    schedule-reminders/
    generate-report-pdf/
    verify-report/
    revenuecat-webhook/
    generate-audit-hash/
    tone-assistant/
    ocr-expense-receipt/
    invite-family-member/
    external-response/
    expire-pending-requests/
```

## 44.6 Flutter Build Flavors

En az üç flavor hazırlanmalıdır:

```text
dev
staging
production
```

Flavor bazlı:

- Supabase URL
- RevenueCat key
- Firebase config
- Sentry DSN
- App display name
- Bundle identifier/application id

Örnek:

```text
com.ebeveynkoprusu.app.dev
com.ebeveynkoprusu.app.staging
com.ebeveynkoprusu.app
```

---

# 45. Yayın Öncesi Kontrol Listesi

## 45.1 App Store / Google Play Hazırlığı

- Apple Developer hesabı hazır
- Google Play Console hesabı hazır
- Bundle ID / package name hazır
- App icon hazır
- Splash screen hazır
- RevenueCat products tanımlı
- iOS subscription products tanımlı
- Android subscription products tanımlı
- Privacy Policy URL hazır
- Terms URL hazır
- KVKK Aydınlatma Metni URL hazır
- Account deletion URL veya app içi silme akışı hazır
- Support e-mail hazır
- Screenshots hazır
- App açıklaması hazır
- Demo kullanıcı hesabı hazır
- App Review notları hazır
- Push notification permission açıklaması hazır
- Child data / health data açıklaması hazır
- Legal disclaimer hazır

## 45.2 Store Screenshot Seti

iPhone için önerilen screenshot sırası:

1. Ana sayfa: “Çocuğunuzun düzenini tek ekrandan yönetin”
2. Takvim: “Teslim günleri ve ebeveynlik planı”
3. Mesajlar: “Konu bazlı, kayıtlı iletişim”
4. Masraflar: “Fatura ve giderleri düzenli takip edin”
5. Belgeler: “Okul, servis ve sağlık belgeleri tek yerde”
6. Raporlar: “Tarih aralığına göre PDF rapor alın”
7. Sakin Dil Asistanı: “İletişimi daha nötr ve çocuk odaklı tutun”
8. Tek Ebeveyn Modu: “Diğer ebeveyn katılmasa da kayıt tutun”

## 45.3 App Review Notları

App Review açıklaması:

```text
Ebeveyn Köprüsü, ayrı yaşayan veya boşanmış ebeveynlerin çocukla ilgili takvim, teslim, belge, masraf ve iletişim süreçlerini düzenli şekilde yönetmesini sağlayan abonelikli bir ebeveyn koordinasyon uygulamasıdır. Uygulama hukuki danışmanlık vermez, çocuk için kullanıcı hesabı açmaz ve canlı konum takibi yapmaz. Konum sadece kullanıcı açıkça teslim/check-in işlemi yaparsa opsiyonel olarak kullanılabilir.
```

## 45.4 Hukuki/Ürün Disclaimer Metni

App içinde ve raporlarda şu metin kullanılmalıdır:

```text
Ebeveyn Köprüsü hukuki danışmanlık hizmeti sunmaz. Uygulamada oluşturulan kayıtlar, kullanıcıların çocukla ilgili koordinasyon süreçlerini düzenlemesine yardımcı olmak amacıyla tutulur. Kayıtların hukuki niteliği ve değerlendirilmesi ilgili makamlar, mahkemeler veya hukuk profesyonelleri tarafından yapılır.
```

---

# 46. Dış Bildirim ve Uygulamaya Katılmayan Ebeveyn Akışı

Bu bölüm, Tek Ebeveyn Modu’nun ticari ve operasyonel başarısı için zorunludur.

## 46.1 Amaç

Diğer ebeveyn uygulamaya kayıt olmasa bile kullanıcı; çocukla ilgili takvim, teslim, masraf, belge ve onay taleplerini kendi hesabında kayıt altına alabilmeli ve isterse dış bildirim gönderebilmelidir.

## 46.2 Desteklenen Dış Kanallar

İlk sürümde teknik adaptörler hazırlanmalıdır:

- E-posta
- SMS opsiyonel
- WhatsApp yok, çünkü resmi API ve gizlilik süreçleri ayrıca değerlendirilmelidir

## 46.3 Dış Bildirim Tipleri

- Takvim değişikliği bildirimi
- Masraf talebi bildirimi
- Belge paylaşıldı bildirimi
- Teslim hatırlatması
- Onay talebi bildirimi
- Acil durum bildirimi

## 46.4 Dış Cevap Linki

Dış bildirim alan kişi uygulama hesabı açmadan sınırlı cevap verebilmelidir.

Örnek link:

```text
https://app.ebeveynkoprusu.com/external-response/{token}
```

Cevap seçenekleri:

- Kabul ediyorum
- Reddediyorum
- Alternatif öneriyorum
- Ek bilgi istiyorum
- Okudum

Güvenlik:

- Token tek kullanımlık veya süreli olmalı
- Token 7 gün içinde expire olmalı
- Cevap IP/user-agent ile kayıtlanmalı
- Cevap audit log’a yazılmalı
- Cevap veren kişi tam kullanıcı sayılmamalı
- Sonradan hesap açarsa kayıtlar bağlanabilmeli

## 46.5 Veritabanı Ek Tablosu

```sql
create table public.external_notifications (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  created_by uuid references public.profiles(id),
  channel text check (channel in ('email','sms')) not null,
  recipient_email text,
  recipient_phone text,
  notification_type text not null,
  related_entity_type text,
  related_entity_id uuid,
  subject text,
  body text,
  token text unique not null,
  status text default 'sent',
  expires_at timestamptz not null,
  responded_at timestamptz,
  response_payload jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz default now()
);
```

## 46.6 Kabul Kriterleri

1. Tek ebeveyn modu uygulama daveti gerektirmeden çalışmalı.
2. Kullanıcı dış bildirim gönderebilmeli.
3. Dış cevap linki çalışmalı.
4. Cevap audit log’a yazılmalı.
5. Token süresi dolunca link çalışmamalı.
6. Diğer ebeveyn sonradan kayıt olursa eski davet/cevap kayıtları bağlanabilmeli.

---

# 47. Nihai Codex Komutu / Ana Talimat

Codex’e bu dosya verildiğinde aşağıdaki komut niteliğindeki talimat uygulanmalıdır:

```text
Bu dokümanı tek ana kaynak kabul et. Flutter + Supabase + PostgreSQL kullanarak Ebeveyn Köprüsü uygulamasını uçtan uca üret. Sadece ekran taslağı değil, çalışan mobil uygulama iskeleti, Supabase migration dosyaları, RLS politikaları, Storage bucket/policy tanımları, Edge Functions, RevenueCat servisleri, FCM bildirim servisleri, PDF raporlama sistemi, audit log/hash-chain yapısı, admin web altyapısı, testler, README ve deployment dosyalarını oluştur.

Tüm modülleri feature-based architecture ile yaz. State management için Riverpod, routing için GoRouter kullan. Her ekran için loading/empty/error state oluştur. Form validasyonlarını ekle. Hassas veriler için gizlilik uyarıları koy. Mesajların update/delete edilmesini engelle. Tüm kritik işlemleri audit log’a yaz. RLS olmadan hiçbir family-scoped tablo bırakma. Service role key’i client’a koyma. Eksik kalan provider credential alanlarını .env.example içine koy. Kodda belirsiz TODO bırakma; üretim için yapılandırılması gerekenleri IMPLEMENTATION_NOTES.md dosyasında belirt.
```

---

# 48. Nihai Tamamlanma Tanımı

Uygulama “hazır” sayılması için aşağıdakilerin tamamı karşılanmalıdır:

1. Flutter app iOS ve Android’de build almalı.
2. Auth, onboarding ve abonelik akışı çalışmalı.
3. Kullanıcı aile oluşturabilmeli.
4. Kullanıcı diğer ebeveyni davet edebilmeli.
5. Tek ebeveyn modu davetsiz çalışmalı.
6. Çocuk profili ve çocuk bilgi merkezi çalışmalı.
7. Ebeveynlik planı oluşturulup takvim üretmeli.
8. Takvim değişiklik talebi kabul/ret akışı çalışmalı.
9. Teslim kayıt sistemi çalışmalı.
10. Mesajlaşma konu bazlı çalışmalı.
11. Sakin Dil Asistanı en az mock/rule-based çalışmalı.
12. Masraf ve ödeme yanıt akışı çalışmalı.
13. Belge yükleme ve okundu kaydı çalışmalı.
14. Onay gerektiren kararlar modülü çalışmalı.
15. Uyuşmazlık merkezi çalışmalı.
16. Kişisel defter sadece sahibine görünmeli.
17. Acil durum modu çalışmalı.
18. Çocuk ihtiyaç listesi çalışmalı.
19. Teslim çantası checklist çalışmalı.
20. Push notification altyapısı çalışmalı.
21. PDF rapor üretilebilmeli.
22. QR/doğrulama kodu çalışmalı.
23. Audit log ve hash-chain çalışmalı.
24. RevenueCat entitlement kontrolü çalışmalı.
25. RLS tüm tablolarda aktif olmalı.
26. Storage private çalışmalı.
27. Admin panel minimum operasyonel seviyede çalışmalı.
28. README hazırlanmalı.
29. `.env.example` hazırlanmalı.
30. Testler yazılmalı.
31. App Store / Google Play yayın checklist dosyası hazırlanmalı.

---

# 49. Sonuç

Bu proje, klasik “chat + calendar” uygulaması değildir. Ebeveyn Köprüsü’nün rekabetçi değeri şu birleşimde oluşur:

- Çocuk merkezli düzen
- Kayıtlı iletişim
- Otomatik ebeveynlik takvimi
- Teslim kayıtları
- Masraf ve belge yönetimi
- Onay ve uyuşmazlık akışı
- Tek ebeveyn modu
- Zaman damgalı raporlar
- Sakin Dil Asistanı
- Premium ve güvenli abonelik modeli

Codex bu dokümanı ana geliştirme dosyası olarak kullanmalı ve uygulamayı Flutter + Supabase + PostgreSQL üzerinde bu kapsamla kurmalıdır.


---

# 50. Birleştirme Notu

Bu nihai dosya, önceki uzun `EBEVEYN_KOPRUSU_MASTER_SPEC.md` dokümanındaki detaylı modül açıklamalarını ve yüklenen `ebeveyn_koprusu_codex_master_spec(1).md` dosyasındaki daha temiz teknik/operasyonel başlıkları tek nüshada birleştirir. Çelişki oluşabilecek alanlarda bu final dosyadaki kararlar geçerlidir.
