# Ebeveyn Köprüsü - Vizyoner Özellikler Mimari Raporu

Bu rapor, Ebeveyn Köprüsü uygulamasına eklenebilecek 12 ileri düzey özelliğin, mevcut **Flutter + Supabase** mimarisi ve "Çocuk odaklılık, canlı konum yasak, RLS ile veri izolasyonu" gibi katı kısıtlar çerçevesinde nasıl uygulanacağını detaylandırmaktadır.

---

## 1. Akıllı Takvim ve "Gün Takası" (Smart Swapping)
* **Konsept:** Ebeveynlerin mahkeme kararı takvimi üzerinde "Benim haftamı seninle değiştirelim" talebi oluşturması.
* **Supabase / Veritabanı:** `custody_events` tablosunda `swap_request_id` alanı açılır. `swap_requests` adında yeni bir tablo (talep eden, önerilen_tarih, karsilik_tarih, durum: pending/accepted/rejected) eklenir. RLS ile sadece aynı `family_id` okuyabilir.
* **Flutter / Metot:** Ebeveyn takvimde bir güne basılı tutar, "Takas Talep Et" der. Sistem `AppDataService.addLiveRecord` üzerinden bu talebi `decisions` (Onaylar) modülüne düşürür.
* **Kısıt / Kural:** Sistem asla otomatik onay vermez. Hak kaybı iddiası olmaması için karşı tarafın açık butona basarak onaylaması ve bu onayın Audit Log'a (değiştirilemez hash ile) yazılması zorunludur.

## 2. Pedagojik Bilgi Bankası ve "Ebeveyn Asistanı" (AI Mentor)
* **Konsept:** LLM destekli ebeveyn danışma botu.
* **Supabase / Veritabanı:** Deno tabanlı yeni bir Edge Function (`pedagogical-ai-chat`). Chat geçmişi `ai_chat_logs` tablosunda tutulur (RLS ile sadece soruyu soran ebeveyn görebilir, karşı ebeveyn göremez).
* **Flutter / Metot:** Sağ alt köşede bir "Danışman" FAB'ı (Floating Action Button). Mesajlar Edge Function'a gider, OpenAI API üzerinden sadece pedagojik promptlarla sınırlandırılmış sistemden cevap döner.
* **Kısıt / Kural:** Asistan "Hukuki tavsiye veremez" kuralı prompt içine hardcode edilmelidir. Veri minimizasyonu gereği promptlara çocuğun adı veya adresi gönderilmez.

## 3. Cihaz İçi Coğrafi Sınır (Geofencing) Destekli Hatırlatıcılar
* **Konsept:** Okul veya teslim noktasına yaklaşıldığında lokal bildirim atılması.
* **Supabase / Veritabanı:** Sadece teslimat noktalarının (okul, ev vb.) enlem/boylam bilgisi `custody_events` içinde tutulur. Konum verisi veritabanına **gönderilmez**.
* **Flutter / Metot:** `geofence_service` paketi kullanılır. Konum izni "Sadece Uygulama Açıkken / Arka planda" alınır ancak veriler cihaz dışına çıkmaz. OS düzeyinde 100 metrelik bir çit (fence) kurulur. Kullanıcı çite girince Flutter Local Notifications ile bildirim tetiklenir.
* **Kısıt / Kural:** Master Spec gereği "Canlı Konum Takibi Yasaktır". Coğrafi sınır kontrolü %100 cihaz içinde (on-device) çalışmalı, Supabase'e asla kullanıcının canlı konumu yazılmamalıdır.

## 4. Açık Bankacılık (Open Banking) Entegrasyonu
* **Konsept:** Masrafların banka hesabından otomatik uygulamaya düşmesi.
* **Supabase / Veritabanı:** Edge Function (`fetch-bank-transactions`) üzerinden TCMB (veya aracı API sağlayıcı) servisine bağlanılır. Gelen veriler `expense_drafts` (Taslak Masraflar) tablosuna yazılır.
* **Flutter / Metot:** "Yeni Masraf Ekle" ekranında "Bankadan Çek" butonu eklenir. Açık bankacılık OAuth akışı ile bankaya login olunur, sadece çocuğun harcamaları (örn: "Okul taksiti") seçilip gerçek masraf (`expenses` tablosu) haline getirilir.
* **Kısıt / Kural:** Banka şifreleri uygulamada tutulmaz (OAuth token kullanılır). Karşı ebeveyn, diğerinin tüm banka ekstresini asla göremez, sadece seçilip gönderilen spesifik "Masraf Talebi"ni görür.

## 5. Uyumu Ödüllendirme: "Pozitif İletişim Skoru" (Harmony Score)
* **Konsept:** İki tarafın da uyumlu davranışlarının puanlanması.
* **Supabase / Veritabanı:** Supabase PostgreSQL üzerinde bir `cron job` (pg_cron) veya Scheduled Edge Function, her ay sonu `disputes`, `handover_logs` ve `messages` tablolarını analiz eder. İtirazsız onaylanan masraflar, zamanında yapılan teslimler % olarak hesaplanıp `family_harmony_scores` tablosuna yazılır.
* **Flutter / Metot:** Dashboard (Ana Ekran) üzerinde ufak bir widget ile "Bu ayki uyum harika!" gibi motivasyonel ibareler gösterilir.
* **Kısıt / Kural:** Bu skor asla mahkemede "Karşı taraf uyumsuz" demek için bir hukuki silaha dönüşmemelidir. Bu nedenle skor kişisel değil, "Ailenin Toplam Uyum Skoru" olarak hesaplanır.

## 6. Ergen (Teen) Modu (Salt Okunur / Talep Girişli)
* **Konsept:** 13+ yaş çocukların takvime müdahil olması.
* **Supabase / Veritabanı:** `family_members` tablosuna yeni role: `teen_child`. RLS politikaları çok sıkı yazılır: `teen_child` sadece `custody_events` tablosunu okuyabilir, `messages` ve `expenses` tablolarına okuma/yazma erişimi kesinlikle **engellenir**.
* **Flutter / Metot:** Teen Modu için özel, basitleştirilmiş bir giriş (Auth) ekranı ve sadece "Takvimim" ile "Talep Ekle" butonunun olduğu farklı bir yönlendirme (GoRouter) tasarımı yapılır.
* **Kısıt / Kural:** Master Spec'te "Çocuk için hesap açılmayacaktır" yazar. Eğer bu modül eklenecekse, bu kural "Sadece 13 yaş üzeri ebeveyn onayı ile salt okunur erişim" olarak revize edilmeli ve KVKK/COPPA kuralları gereği özel açık rıza alınmalıdır.

## 7. Dijital Beden Kartı ve İhtiyaç Vitrini (Kids Profile & Wardrobe)
* **Konsept:** Çocuğun boy, kilo, ayakkabı bedeni gibi bilgilerinin tutulması.
* **Supabase / Veritabanı:** `children` tablosuna JSONB formatında `physical_attributes` kolonu (ayakkabı: 32, boy: 130cm vb.) eklenir. İhtiyaç vitrini için `child_needs` tablosu (status: open/purchased) oluşturulur.
* **Flutter / Metot:** "Çocuk" sekmesi altında yeni bir sekme (Tab) olarak tasarlanır. Her iki ebeveyn de güncelleyebilir. Biri güncellediğinde diğerine "Deniz'in ayakkabı numarası 33 olarak güncellendi" bildirimi gider.
* **Kısıt / Kural:** Sağlık verisine girmeyecek (hastalık değil, fiziksel özellik) kadar basit tutulmalıdır. Eğer kronik durumlar girilecekse bunlar Modül 4 (Sağlık Merkezi) kurallarına göre RLS ile korunmalıdır.

## 8. Çocuklar İçin "Görsel Takvim Çıktısı" (Visual Print-Outs for Kids)
* **Konsept:** Çocuğun odasına asılacak renkli, ikonsal çıktı.
* **Supabase / Veritabanı:** Veritabanı değişikliğine gerek yoktur. Mevcut `custody_events` verileri kullanılır.
* **Flutter / Metot:** `pdf` ve `printing` paketleri kullanılarak, yazı yerine özel SVG ikonları (Anne simgesi, Baba simgesi) içeren, sayfayı yatay (landscape) kullanan özel bir PDF şablonu (Widget to PDF) tasarlanır.
* **Kısıt / Kural:** Veri işleme cihaz içinde yapılmalıdır (Çocuk takvimi PDF'i için Edge Function'a gitmeye gerek yoktur, Flutter içinde çizilip doğrudan print dialog'a atılmalıdır).

## 9. Sınır Çizici: "Sessiz Zaman / Mola" Modu (Quiet Hours / Boundaries)
* **Konsept:** 21:00 - 08:00 arası mesaj ve bildirimlerin engellenmesi/ertelenmesi.
* **Supabase / Veritabanı:** `family_members` tablosuna `quiet_hours_start` ve `quiet_hours_end` kolonları eklenir. `messages` tablosuna `is_emergency` (boolean) eklenir.
* **Flutter / Metot:** Kullanıcı mesaj yazıp Gönder'e bastığında, uygulama karşı tarafın sessiz saatte olup olmadığını lokalde kontrol eder. Eğer sessiz saatteyse "Şu an karşı tarafın sessiz saati. Acil değilse mesajınız sabah iletilecek" uyarısı çıkar. "Acil" seçilirse `is_emergency=true` olarak Deno Edge Function'a (`send-notification`) gider ve FCM bildirimi zorunlu olarak çaldırılır.
* **Kısıt / Kural:** Acil durum bayrağının (flag) suistimal edilmesi durumunda, bu eylemler (gönderilen saat, aciliyet durumu) ileride "İletişim Uyuşmazlığı" raporuna otomatik yansıyacak şekilde Audit Log'a düşmelidir.

## 10. Öğretmen / Doktor İçin "Tek Yönlü Bilgi Köprüsü" (Third-Party Drop Box)
* **Konsept:** 3. şahısların uygulamaya giriş yapmadan, özel bir web linki üzerinden evrak/rapor yüklemesi.
* **Supabase / Veritabanı:** `external_drop_links` tablosu (link_hash, family_id, expires_at) oluşturulur.
* **Metot:** Supabase Edge Functions üzerinden HTTP GET/POST destekleyen ufak bir HTML web arayüzü sunulur. Öğretmen bu web linkine girer, PDF'i seçer. Edge Function, PDF'i `documents` bucket'ına yükler ve `documents` tablosuna `uploaded_by=teacher` olarak kaydeder.
* **Kısıt / Kural:** Linkler mutlaka süreli (Örn: 48 saat) olmalıdır. 3. şahsın yüklediği belge salt okunur olmalı ve her iki ebeveyn de bunu silememelidir (Şeffaflık garantisi).

## 11. Güvenli ve Kayıtlı "Uygulama İçi Arama" (In-App VoIP & Video Call)
* **Konsept:** Tarafların telefon numaraları gizli kalarak uygulama üzerinden VoIP araması yapması.
* **Supabase / Veritabanı:** `call_logs` tablosu (caller_id, receiver_id, start_time, duration, status: missed/answered/declined) oluşturulur.
* **Flutter / Metot:** Agora.io veya Twilio gibi bir SDK (Flutter plugin) entegre edilir. Arama başlatıldığında Edge Function üzerinden güvenli arama token'ı (RTC Token) üretilir.
* **Kısıt / Kural:** Arama sesleri (içeriği) mahremiyet yasaları gereği **KESİNLİKLE kaydedilmez**. Sadece metadata (arama saati, çalma süresi) loglanır ve Raporlara (Modül 14) "İletişim Karnesi" olarak eklenir.

## 12. "Sıra Kimde?" Hafızası (Holiday & Event Tracker)
* **Konsept:** "Geçen yılbaşında kimdeydi?" sorusunu çözen istatistik panosu.
* **Supabase / Veritabanı:** Veritabanına yeni tablo gerekmez. `custody_events` tablosundaki eski "Kurban Bayramı", "Yılbaşı" etiketli tamamlanmış teslimatlar (status=completed) üzerinden SQL Group By sorgusu çalıştırılır.
* **Flutter / Metot:** Takvim modülünün sağ üst köşesine "Hafıza" butonu eklenir. Tıklandığında `AppDataService` bir Supabase RPC (Remote Procedure Call) veya Edge Function çağırarak son 3 yılın analizini tek bir ekranda gösterir.
* **Kısıt / Kural:** Tahmin (gelecek yıl kimde olmalı) yaparken hukuki bir emir ("Çocuk annede olmalıdır!") dili yerine ("Dönüşümlü kurala ve geçen yılın verisine göre sistem sıranın babada olduğunu öngörmektedir") tavsiye dili kullanılmalıdır.
