# EBEVEYN KÖPRÜSÜ — Flutter + Supabase + PostgreSQL Mobil Uygulama Geliştirme Ana Şartnamesi

**Doküman amacı:**  
Bu dosya, Codex veya benzeri bir kod üretim asistanına tek parça olarak verilecek ana proje talimatıdır. Proje kapsamı sonradan ekleme gerektirmeyecek şekilde ürün, teknik mimari, veritabanı, güvenlik, ödeme, ekranlar, iş akışları, raporlama, test ve teslim kriterleriyle birlikte tanımlanmıştır.

**Uygulama adı:** Ebeveyn Köprüsü  
**Platform:** iOS + Android  
**Frontend:** Flutter  
**Backend:** Supabase  
**Veritabanı:** PostgreSQL  
**Dosya depolama:** Supabase Storage  
**Bildirim:** Firebase Cloud Messaging + Supabase Edge Functions  
**Abonelik / ödeme:** RevenueCat + App Store / Google Play abonelikleri  
**Dil:** İlk sürüm Türkçe. Mimari çok dilli yapıya hazır olmalı.  
**Hedef ülke:** Öncelikle Türkiye. Mimari daha sonra global kullanıma uygun olmalı.  
**Ana konumlandırma:** Boşanmış veya ayrı yaşayan ebeveynlerin çocukla ilgili takvim, iletişim, masraf, belge, teslim ve onay süreçlerini kayıtlı, güvenli ve düzenli şekilde yönetmesini sağlayan çocuk merkezli ebeveyn koordinasyon uygulaması.

---

## 1. Ürün Vizyonu

Ebeveyn Köprüsü, boşanmış veya ayrı yaşayan ebeveynlerin, çocuklarıyla ilgili zorunlu iletişim ve koordinasyon süreçlerini kavga, belirsizlik ve kayıt kaybı olmadan yönetmesini sağlar.

Uygulamanın amacı eski eşleri sosyalleştirmek değildir. Amaç, çocuğu ilgilendiren konuları yapılandırılmış, kayıtlı, güvenli, saygılı ve raporlanabilir bir sisteme taşımaktır.

Uygulama şu problemleri çözer:

- Çocuk hangi gün, hangi saat aralığında, hangi ebeveynde kalacak?
- Teslim nerede ve nasıl yapılacak?
- Takvim değişikliği nasıl talep edilecek ve kayıt altına alınacak?
- Okul, servis, doktor, sağlık, yakın kişi ve acil durum bilgileri nasıl güncel tutulacak?
- Masraflar, faturalar, dekontlar ve ödeme talepleri nasıl takip edilecek?
- Hangi belge kime ne zaman bildirildi?
- Hangi mesaj okundu, hangi talep onaylandı veya reddedildi?
- Gerekirse avukat, arabulucu, pedagog veya danışmana düzenli rapor nasıl sunulacak?
- Karşı taraf uygulamaya katılmasa bile tek taraflı kayıt nasıl tutulacak?

---

## 2. Temel Ürün İlkeleri

1. **Çocuk merkezlilik:**  
   Uygulamadaki dil, tasarım ve iş akışları ebeveyn kavgasına değil çocuğun düzenine odaklanmalıdır.

2. **Tarafsızlık:**  
   Uygulama anne veya baba lehine çalışmaz. Tüm kayıtlar aktör bazlı ve zaman damgalı tutulur.

3. **Kayıt bütünlüğü:**  
   Mesaj, masraf, belge, teslim, onay ve değişiklik işlemleri sonradan sessizce değiştirilemez. Gerekirse düzeltme yeni kayıt olarak açılır.

4. **KVKK ve mahremiyet:**  
   Çocuk, sağlık, okul, adres, iletişim ve belge verileri hassastır. Varsayılan ayarlar minimum veri paylaşımı ve kontrollü erişim üzerine kurulmalıdır.

5. **Canlı takip yok:**  
   İlk sürümde sürekli konum takibi yapılmayacaktır. Sadece teslim/check-in gibi kullanıcının açık işlem yaptığı anlarda opsiyonel konum kaydı alınabilir.

6. **Çocuğa hesap yok:**  
   İlk sürümde çocuk kullanıcı olarak uygulamaya dahil edilmeyecektir. Çocuk uygulamanın konusu olur, kullanıcısı olmaz.

7. **Hukuki garanti yok:**  
   Uygulama “mahkemede kesin delil üretir” iddiasında bulunmamalıdır. Doğru ifade: “zaman damgalı, raporlanabilir, değişiklik geçmişi tutulan kayıt sistemi.”

8. **Tek taraflı kullanım mümkün:**  
   Diğer ebeveyn katılmasa bile kullanıcı takvim, masraf, belge, teslim ve kişisel kayıt defteri modüllerini kullanabilmelidir.

---

## 3. Hedef Kullanıcılar

### 3.1 Birincil kullanıcılar

- Boşanmış anne
- Boşanmış baba
- Ayrı yaşayan ebeveynler
- Mahkeme kararı veya protokol ile çocukla kişisel ilişki düzeni bulunan ebeveynler
- Ortak çocuk giderleri, teslim saatleri, okul ve sağlık konularında düzenli iletişim kurmak zorunda olan kişiler

### 3.2 İkincil kullanıcılar

- Avukat
- Arabulucu
- Pedagog
- Psikolog
- Aile danışmanı
- Teslim yetkilisi
- Bakıcı
- Yakın akraba

İkincil kullanıcıların erişimi sınırlı ve davet bazlı olmalıdır.

---

## 4. Ürün Modülleri

Uygulama aşağıdaki modüllerin tamamını içermelidir.

1. Kimlik doğrulama ve kullanıcı profili
2. Aile / ebeveyn eşleştirme sistemi
3. Tek ebeveyn modu
4. Çocuk profili
5. Mahkeme/protokol bazlı ebeveynlik planı
6. Otomatik takvim motoru
7. Teslim ve teslim alma kayıt sistemi
8. Konu bazlı mesajlaşma
9. Sakin Dil Asistanı
10. Masraf ve ödeme takip sistemi
11. Belge arşivi
12. Okul bilgi merkezi
13. Servis bilgi merkezi
14. Sağlık bilgi merkezi
15. Yakınlar ve teslim yetkilileri rehberi
16. Onay gerektiren kararlar modülü
17. Uyuşmazlık / itiraz merkezi
18. Kişisel kayıt defteri
19. Acil durum modu
20. Çocuk ihtiyaç listesi
21. Teslim çantası kontrol listesi
22. Bildirim ve hatırlatma sistemi
23. PDF raporlama sistemi
24. Hash doğrulama ve audit log
25. Avukat / uzman paylaşım paneli
26. Abonelik ve ödeme sistemi
27. Admin panel / operasyon yönetimi
28. Ayarlar, gizlilik ve hesap silme
29. Yardım, destek, sık sorulan sorular

---

## 5. Kullanıcı Rolleri ve Yetkiler

### 5.1 Roller

- `parent`: Ebeveyn
- `guardian`: Vasi
- `lawyer`: Avukat
- `mediator`: Arabulucu
- `psychologist`: Psikolog / pedagog / danışman
- `relative`: Yakın kişi
- `pickup_delegate`: Teslim yetkilisi
- `admin`: Sistem yöneticisi
- `support`: Destek personeli

### 5.2 Yetki ilkeleri

- Her aile alanı `family_id` ile izole edilmelidir.
- Bir kullanıcı birden fazla aile kaydında bulunabilir.
- Bir çocuk kaydı sadece ilgili ailenin yetkili kullanıcıları tarafından görülebilir.
- Avukat ve uzmanlar sadece davet edildikleri aile/çocuk/rapor kapsamını görebilir.
- Teslim yetkilisi sadece kendisiyle ilgili teslim bilgilerini görebilir.
- Support personeli hassas içerikleri varsayılan olarak görememelidir. Gerekirse maskeli destek görünümü kullanılmalıdır.
- Admin yalnızca operasyonel metaverilere erişebilmelidir; hassas belge ve mesaj içeriklerine erişim ayrı audit log ile tutulmalıdır.

---

## 6. Teknoloji Mimarisi

### 6.1 Frontend

- Flutter stable
- Dart
- Riverpod veya Bloc state management. Tercih: Riverpod
- GoRouter ile route yönetimi
- Supabase Flutter SDK
- Firebase Messaging
- RevenueCat Flutter SDK
- Flutter Secure Storage
- Local notifications
- PDF preview / share
- File picker
- Image picker
- Camera
- Internationalization altyapısı: `flutter_localizations`, `intl`

### 6.2 Backend

- Supabase Auth
- PostgreSQL
- Supabase Storage
- Supabase Edge Functions
- Supabase Realtime
- Row Level Security
- PostgreSQL functions ve triggers
- Audit log trigger sistemi
- Cron / scheduled functions
- Webhook endpointleri:
  - RevenueCat webhook
  - Store subscription event webhook
  - Notification scheduler
  - PDF generation trigger

### 6.3 Harici servisler

- Firebase Cloud Messaging: Push bildirim
- RevenueCat: Abonelik yönetimi
- Apple App Store / Google Play Billing: Mobil abonelik
- Sentry veya Firebase Crashlytics: Hata izleme
- PostHog veya Firebase Analytics: Ürün analitiği
- Opsiyonel: OpenAI / Gemini API veya self-hosted LLM: Sakin Dil Asistanı
- Opsiyonel: OCR servisi: Fatura/dekont otomatik okuma

### 6.4 Ödeme politikası notu

Dijital abonelikler için iOS tarafında App Store in-app purchase gereklilikleri dikkate alınmalıdır. Apple App Review Guidelines düzenli değişebilir; yayın öncesi güncel kurallar kontrol edilmelidir. Google Play tarafında da Play Billing ve alternatif ödeme politikaları değişebildiği için yayın öncesi güncel Play Console politikaları kontrol edilmelidir. Kod mimarisi RevenueCat ile kurulmalı, böylece iOS ve Android abonelik durumları tek entitlement sistemiyle yönetilebilmelidir.

Kaynaklar:
- Apple App Review Guidelines: https://developer.apple.com/app-store/review/guidelines/
- Google Play Billing Subscriptions: https://developer.android.com/google/play/billing/subscriptions
- RevenueCat Flutter SDK: https://www.revenuecat.com/docs/getting-started/installation/flutter
- Supabase RLS: https://supabase.com/docs/guides/database/postgres/row-level-security

---

## 7. Klasör Yapısı

Flutter uygulaması aşağıdaki gibi modüler yapılandırılmalıdır:

```text
ebeveyn_koprusu/
  app/
    main.dart
    app.dart
    router.dart
    theme/
      app_theme.dart
      colors.dart
      typography.dart
    localization/
      tr.json
      en.json

  core/
    config/
      env.dart
      constants.dart
    errors/
      app_exception.dart
      failure.dart
    utils/
      date_utils.dart
      validators.dart
      formatters.dart
      file_utils.dart
      hash_utils.dart
    services/
      supabase_service.dart
      notification_service.dart
      revenuecat_service.dart
      analytics_service.dart
      secure_storage_service.dart
      pdf_service.dart

  features/
    auth/
      data/
      domain/
      presentation/
    onboarding/
    dashboard/
    family/
    children/
    parenting_plan/
    calendar/
    handover/
    messages/
    tone_assistant/
    expenses/
    documents/
    school/
    transport/
    health/
    contacts/
    decisions/
    disputes/
    personal_journal/
    emergency/
    checklists/
    reports/
    subscriptions/
    expert_access/
    settings/
    support/
    admin/

  shared/
    widgets/
    models/
    repositories/
    providers/
    components/
```

Her feature içinde şu yapı korunmalıdır:

```text
feature_name/
  data/
    datasources/
    repositories/
    dto/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    screens/
    widgets/
    controllers/
    providers/
```

---

## 8. UI/UX Genel Tasarım

### 8.1 Tasarım dili

- Resmî, sade, güven veren
- Fazla renkli, oyunlaştırılmış veya flört uygulaması gibi görünmemeli
- Çocuk odaklı ama çocuksu değil
- Hukuki tehdit hissi vermemeli
- Anne/baba kavgasını körükleyen kelimelerden kaçınmalı

### 8.2 Ana renk önerisi

- Ana renk: Lacivert / petrol mavisi
- İkincil renk: Yumuşak yeşil
- Uyarı: Amber
- Kritik: Kırmızı ama sınırlı kullanım
- Arka plan: Açık gri / beyaz

### 8.3 Temel navigasyon

Alt menü:

1. Ana Sayfa
2. Takvim
3. Mesajlar
4. Masraflar
5. Belgeler

Yan / daha fazla menüsü:

- Çocuk Bilgileri
- Teslimler
- Onaylar
- Uyuşmazlıklar
- Raporlar
- Kişisel Defter
- Acil Durum
- Ayarlar

---

## 9. Onboarding Akışı

### 9.1 İlk açılış

Ekranlar:

1. Hoş geldiniz
2. Uygulama amacı
3. Veri gizliliği özeti
4. Çocuk hesabı açılmayacağı bilgisi
5. Kullanım tipi seçimi:
   - Diğer ebeveyni davet edeceğim
   - Şimdilik tek başıma kullanacağım
6. Abonelik ekranı
7. Kayıt / giriş

### 9.2 Kayıt alanları

- Ad soyad
- E-posta
- Telefon
- Şifre
- Rol: Anne / Baba / Vasi / Diğer
- KVKK aydınlatma metni onayı
- Kullanım şartları onayı
- Pazarlama izni ayrı checkbox olmalı

### 9.3 Ebeveyn eşleştirme

- Kullanıcı aile kaydı oluşturur.
- Çocuk ekler.
- Diğer ebeveyni e-posta veya telefon ile davet eder.
- Davet kodu üretilir.
- Diğer ebeveyn daveti kabul ederse aynı `family_id` içine eklenir.
- Davet kabul edilmezse kullanıcı Tek Ebeveyn Modu ile devam eder.

---

## 10. Veritabanı Tasarımı

Aşağıda ana PostgreSQL şeması verilmiştir. Codex bu şemayı Supabase migration dosyalarına dönüştürmelidir.

### 10.1 Enum tipleri

```sql
create type user_role as enum (
  'parent',
  'guardian',
  'lawyer',
  'mediator',
  'psychologist',
  'relative',
  'pickup_delegate',
  'admin',
  'support'
);

create type family_member_status as enum (
  'invited',
  'active',
  'suspended',
  'removed'
);

create type invitation_status as enum (
  'pending',
  'accepted',
  'expired',
  'revoked',
  'rejected'
);

create type event_status as enum (
  'scheduled',
  'change_requested',
  'cancelled',
  'completed',
  'missed',
  'disputed'
);

create type request_status as enum (
  'draft',
  'sent',
  'read',
  'accepted',
  'rejected',
  'counter_proposed',
  'expired',
  'cancelled'
);

create type expense_status as enum (
  'draft',
  'sent',
  'read',
  'accepted',
  'partially_accepted',
  'rejected',
  'paid',
  'partially_paid',
  'overdue',
  'disputed',
  'cancelled'
);

create type document_category as enum (
  'school',
  'health',
  'transport',
  'expense',
  'legal',
  'identity',
  'activity',
  'other'
);

create type message_topic as enum (
  'handover',
  'school',
  'transport',
  'health',
  'expense',
  'document',
  'emergency',
  'general',
  'decision',
  'travel'
);

create type handover_status as enum (
  'planned',
  'on_the_way',
  'arrived',
  'completed',
  'delayed',
  'missed',
  'cancelled',
  'disputed'
);

create type subscription_status as enum (
  'trial',
  'active',
  'grace_period',
  'past_due',
  'cancelled',
  'expired',
  'refunded'
);
```

### 10.2 Ana tablolar

```sql
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text,
  phone text,
  default_role user_role default 'parent',
  avatar_url text,
  locale text default 'tr',
  timezone text default 'Europe/Istanbul',
  is_onboarding_completed boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.families (
  id uuid primary key default gen_random_uuid(),
  name text,
  created_by uuid references public.profiles(id),
  is_single_parent_mode boolean default false,
  status text default 'active',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.family_members (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role user_role not null,
  relationship_label text,
  status family_member_status default 'active',
  permissions jsonb default '{}'::jsonb,
  invited_by uuid references public.profiles(id),
  joined_at timestamptz,
  created_at timestamptz default now(),
  unique(family_id, user_id, role)
);

create table public.family_invitations (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  invited_email text,
  invited_phone text,
  invited_role user_role not null,
  invitation_code text unique not null,
  status invitation_status default 'pending',
  expires_at timestamptz not null,
  accepted_by uuid references public.profiles(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

create table public.children (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  full_name text not null,
  birth_date date,
  gender text,
  notes text,
  profile_photo_url text,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### 10.3 Çocuk bilgi merkezleri

```sql
create table public.child_school_info (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references public.children(id) on delete cascade,
  school_name text,
  class_name text,
  teacher_name text,
  teacher_phone text,
  school_phone text,
  school_address text,
  notes text,
  updated_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.child_transport_info (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references public.children(id) on delete cascade,
  company_name text,
  driver_name text,
  driver_phone text,
  vehicle_plate text,
  pickup_time time,
  dropoff_time time,
  route_notes text,
  updated_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.child_health_info (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references public.children(id) on delete cascade,
  blood_type text,
  allergies text,
  regular_medications text,
  doctor_name text,
  doctor_phone text,
  hospital_name text,
  emergency_notes text,
  updated_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.child_contacts (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references public.children(id) on delete cascade,
  full_name text not null,
  relation text,
  phone text,
  email text,
  address text,
  can_pickup boolean default false,
  can_be_called_in_emergency boolean default false,
  visible_to_other_parent boolean default true,
  requires_acknowledgement boolean default true,
  created_by uuid references public.profiles(id),
  updated_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### 10.4 Ebeveynlik planı ve takvim

```sql
create table public.parenting_plans (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  title text not null,
  source_type text check (source_type in ('manual', 'court_order', 'protocol', 'agreement')) default 'manual',
  source_document_id uuid,
  rules jsonb not null default '{}'::jsonb,
  effective_from date,
  effective_to date,
  is_active boolean default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.custody_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  assigned_parent_id uuid references public.profiles(id),
  title text not null,
  start_at timestamptz not null,
  end_at timestamptz not null,
  location_text text,
  location_lat numeric,
  location_lng numeric,
  event_type text default 'custody',
  status event_status default 'scheduled',
  source_plan_id uuid references public.parenting_plans(id),
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.change_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  custody_event_id uuid references public.custody_events(id) on delete set null,
  requested_by uuid references public.profiles(id),
  requested_to uuid references public.profiles(id),
  request_text text,
  proposed_start_at timestamptz,
  proposed_end_at timestamptz,
  proposed_location_text text,
  status request_status default 'sent',
  response_text text,
  responded_at timestamptz,
  expires_at timestamptz,
  created_at timestamptz default now()
);
```

### 10.5 Teslim kayıtları

```sql
create table public.handover_records (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  custody_event_id uuid references public.custody_events(id) on delete set null,
  actor_id uuid references public.profiles(id),
  counterparty_id uuid references public.profiles(id),
  status handover_status default 'planned',
  note text,
  location_text text,
  location_lat numeric,
  location_lng numeric,
  photo_url text,
  occurred_at timestamptz default now(),
  created_at timestamptz default now()
);
```

### 10.6 Mesajlaşma

```sql
create table public.message_threads (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  topic message_topic not null,
  title text,
  related_entity_type text,
  related_entity_id uuid,
  created_by uuid references public.profiles(id),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid references public.message_threads(id) on delete cascade,
  family_id uuid references public.families(id) on delete cascade,
  sender_id uuid references public.profiles(id),
  body text not null,
  body_original text,
  tone_score numeric,
  tone_warning jsonb,
  attachment_count integer default 0,
  is_system_message boolean default false,
  current_hash text,
  previous_hash text,
  created_at timestamptz default now()
);

create table public.message_reads (
  id uuid primary key default gen_random_uuid(),
  message_id uuid references public.messages(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  read_at timestamptz default now(),
  unique(message_id, user_id)
);
```

### 10.7 Masraf ve ödeme

```sql
create table public.expenses (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  paid_by uuid references public.profiles(id),
  requested_from uuid references public.profiles(id),
  title text not null,
  category text not null,
  amount numeric(12,2) not null,
  currency text default 'TRY',
  expense_date date not null,
  description text,
  share_type text check (share_type in ('equal', 'percentage', 'fixed', 'info_only')) default 'equal',
  requested_amount numeric(12,2),
  status expense_status default 'sent',
  due_date date,
  is_urgent_health_expense boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.expense_files (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid references public.expenses(id) on delete cascade,
  file_url text not null,
  file_name text,
  file_type text,
  uploaded_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

create table public.expense_responses (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid references public.expenses(id) on delete cascade,
  responder_id uuid references public.profiles(id),
  response_status expense_status,
  response_text text,
  accepted_amount numeric(12,2),
  created_at timestamptz default now()
);

create table public.payments (
  id uuid primary key default gen_random_uuid(),
  expense_id uuid references public.expenses(id) on delete set null,
  family_id uuid references public.families(id) on delete cascade,
  payer_id uuid references public.profiles(id),
  receiver_id uuid references public.profiles(id),
  amount numeric(12,2) not null,
  currency text default 'TRY',
  payment_date date,
  proof_file_url text,
  note text,
  created_at timestamptz default now()
);
```

### 10.8 Belgeler

```sql
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  uploaded_by uuid references public.profiles(id),
  category document_category default 'other',
  title text not null,
  description text,
  file_url text not null,
  file_name text,
  mime_type text,
  size_bytes bigint,
  visible_to_other_parent boolean default true,
  requires_acknowledgement boolean default false,
  current_hash text,
  created_at timestamptz default now()
);

create table public.document_reads (
  id uuid primary key default gen_random_uuid(),
  document_id uuid references public.documents(id) on delete cascade,
  user_id uuid references public.profiles(id),
  read_at timestamptz default now(),
  unique(document_id, user_id)
);
```

### 10.9 Onay gerektiren kararlar

```sql
create table public.decision_requests (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  requested_by uuid references public.profiles(id),
  requested_to uuid references public.profiles(id),
  decision_type text not null,
  title text not null,
  description text,
  due_at timestamptz,
  status request_status default 'sent',
  response_text text,
  responded_at timestamptz,
  created_at timestamptz default now()
);

create table public.decision_attachments (
  id uuid primary key default gen_random_uuid(),
  decision_request_id uuid references public.decision_requests(id) on delete cascade,
  document_id uuid references public.documents(id) on delete cascade,
  created_at timestamptz default now()
);
```

### 10.10 Uyuşmazlıklar

```sql
create table public.disputes (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  opened_by uuid references public.profiles(id),
  dispute_type text not null,
  title text not null,
  description text,
  related_entity_type text,
  related_entity_id uuid,
  status text default 'open',
  resolution_note text,
  closed_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table public.dispute_comments (
  id uuid primary key default gen_random_uuid(),
  dispute_id uuid references public.disputes(id) on delete cascade,
  author_id uuid references public.profiles(id),
  body text not null,
  created_at timestamptz default now()
);
```

### 10.11 Kişisel kayıt defteri

```sql
create table public.personal_journal_entries (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  owner_id uuid references public.profiles(id),
  title text,
  body text not null,
  category text,
  related_entity_type text,
  related_entity_id uuid,
  include_in_report boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### 10.12 Acil durum

```sql
create table public.emergency_events (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  reported_by uuid references public.profiles(id),
  emergency_type text not null,
  description text,
  location_text text,
  location_lat numeric,
  location_lng numeric,
  status text default 'open',
  created_at timestamptz default now(),
  closed_at timestamptz
);
```

### 10.13 Kontrol listeleri

```sql
create table public.checklists (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete cascade,
  title text not null,
  checklist_type text check (checklist_type in ('handover_bag', 'child_needs', 'custom')) default 'custom',
  created_by uuid references public.profiles(id),
  created_at timestamptz default now()
);

create table public.checklist_items (
  id uuid primary key default gen_random_uuid(),
  checklist_id uuid references public.checklists(id) on delete cascade,
  title text not null,
  is_checked boolean default false,
  checked_by uuid references public.profiles(id),
  checked_at timestamptz,
  sort_order integer default 0,
  created_at timestamptz default now()
);
```

### 10.14 Bildirimler

```sql
create table public.notification_preferences (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  channel_push boolean default true,
  channel_email boolean default true,
  channel_sms boolean default false,
  preferences jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique(user_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  family_id uuid references public.families(id) on delete cascade,
  title text not null,
  body text not null,
  notification_type text not null,
  related_entity_type text,
  related_entity_id uuid,
  is_read boolean default false,
  created_at timestamptz default now(),
  read_at timestamptz
);

create table public.device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  platform text,
  token text not null,
  created_at timestamptz default now(),
  last_seen_at timestamptz default now(),
  unique(user_id, token)
);
```

### 10.15 Raporlar

```sql
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  child_id uuid references public.children(id) on delete set null,
  generated_by uuid references public.profiles(id),
  report_type text not null,
  date_from date,
  date_to date,
  filters jsonb default '{}'::jsonb,
  file_url text,
  verification_code text unique,
  report_hash text,
  status text default 'generated',
  created_at timestamptz default now()
);

create table public.report_shares (
  id uuid primary key default gen_random_uuid(),
  report_id uuid references public.reports(id) on delete cascade,
  shared_by uuid references public.profiles(id),
  shared_with_email text,
  shared_with_user_id uuid references public.profiles(id),
  expires_at timestamptz,
  access_token text unique,
  created_at timestamptz default now()
);
```

### 10.16 Abonelik

```sql
create table public.subscription_plans (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  name text not null,
  description text,
  monthly_price numeric(12,2),
  yearly_price numeric(12,2),
  currency text default 'TRY',
  features jsonb default '{}'::jsonb,
  is_active boolean default true,
  created_at timestamptz default now()
);

create table public.user_subscriptions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles(id) on delete cascade,
  plan_code text references public.subscription_plans(code),
  status subscription_status,
  platform text,
  revenuecat_customer_id text,
  original_transaction_id text,
  current_period_start timestamptz,
  current_period_end timestamptz,
  will_renew boolean default true,
  entitlement jsonb default '{}'::jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### 10.17 Audit log

```sql
create table public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  family_id uuid references public.families(id) on delete cascade,
  actor_id uuid references public.profiles(id),
  action_type text not null,
  entity_type text not null,
  entity_id uuid,
  old_value jsonb,
  new_value jsonb,
  ip_address inet,
  user_agent text,
  device_id text,
  previous_hash text,
  current_hash text not null,
  created_at timestamptz default now()
);
```

---

## 11. RLS Güvenlik Kuralları

Tüm tablolar için Row Level Security aktif olmalıdır.

```sql
alter table public.profiles enable row level security;
alter table public.families enable row level security;
alter table public.family_members enable row level security;
alter table public.children enable row level security;
-- Diğer tüm tablolar için de enable edilmeli.
```

### 11.1 Yardımcı fonksiyonlar

```sql
create or replace function public.is_family_member(target_family_id uuid)
returns boolean
language sql
security definer
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
  );
$$;

create or replace function public.has_family_role(target_family_id uuid, allowed_roles user_role[])
returns boolean
language sql
security definer
as $$
  select exists (
    select 1
    from public.family_members fm
    where fm.family_id = target_family_id
      and fm.user_id = auth.uid()
      and fm.status = 'active'
      and fm.role = any(allowed_roles)
  );
$$;
```

### 11.2 Genel RLS politikası örneği

Her `family_id` içeren tablo için:

```sql
create policy "Family members can read family scoped rows"
on public.children
for select
using (public.is_family_member(family_id));

create policy "Parents and guardians can insert children"
on public.children
for insert
with check (
  public.has_family_role(family_id, array['parent','guardian']::user_role[])
);
```

### 11.3 Mesaj politikası

- Aile üyeleri ilgili aile mesajlarını okuyabilir.
- Mesajlar silinemez.
- Mesajlar update edilemez.
- Düzeltme gerekiyorsa yeni mesaj oluşturulur.

```sql
create policy "Family members can read messages"
on public.messages
for select
using (public.is_family_member(family_id));

create policy "Family members can insert messages"
on public.messages
for insert
with check (public.is_family_member(family_id));

-- Update/delete policy oluşturma. Mesajlar değiştirilemez.
```

### 11.4 Kişisel defter politikası

Kişisel defter sadece sahibi tarafından okunur.

```sql
create policy "Journal owner can read"
on public.personal_journal_entries
for select
using (owner_id = auth.uid());

create policy "Journal owner can insert"
on public.personal_journal_entries
for insert
with check (owner_id = auth.uid());

create policy "Journal owner can update"
on public.personal_journal_entries
for update
using (owner_id = auth.uid())
with check (owner_id = auth.uid());
```

---

## 12. Audit Log ve Hash Zinciri

Her kritik işlem audit log’a yazılmalıdır.

Kritik işlemler:

- Mesaj gönderme
- Belge yükleme
- Belge okundu
- Masraf oluşturma
- Masraf kabul/ret
- Ödeme kaydı
- Takvim etkinliği oluşturma
- Takvim değişikliği talebi
- Değişiklik kabul/ret
- Teslim kaydı
- Kişi bilgisi güncelleme
- Sağlık bilgisi güncelleme
- Okul/servis bilgisi güncelleme
- Rapor oluşturma
- Rapor paylaşma
- Abonelik değişikliği

Hash mantığı:

```text
current_hash = sha256(
  previous_hash +
  family_id +
  actor_id +
  action_type +
  entity_type +
  entity_id +
  json(old_value) +
  json(new_value) +
  created_at
)
```

Her aile için son hash bulunur ve yeni kayda `previous_hash` olarak yazılır. Böylece işlem geçmişi zincirlenir.

Codex bu mekanizma için PostgreSQL trigger veya Supabase Edge Function yazmalıdır.

---

## 13. Ekranlar ve Kullanıcı Akışları

### 13.1 Ana Sayfa

Ana sayfada gösterilecek kartlar:

- Bugün çocuk kimde?
- Sonraki teslim
- Bekleyen onaylar
- Bekleyen masraf talepleri
- Yeni belgeler
- Yaklaşan okul/servis/sağlık etkinlikleri
- Son mesajlar
- Acil durum butonu
- Hızlı işlem butonları:
  - Mesaj yaz
  - Masraf ekle
  - Belge yükle
  - Teslim kaydı
  - Takvim değişikliği iste
  - Rapor oluştur

### 13.2 Takvim ekranı

Görünümler:

- Günlük
- Haftalık
- Aylık
- Liste

Özellikler:

- Ebeveyne göre renkli gösterim
- Çocuk bazlı filtre
- Etkinlik türü filtresi
- Teslim noktası
- Teslim saati
- Değişiklik talebi
- Etkinlik detayına gitme
- PDF takvim çıktısı

### 13.3 Ebeveynlik planı ekranı

Kullanıcı kurallar oluşturur:

- Hafta içi düzen
- Hafta sonu düzen
- Ayın belirli haftaları
- Resmî tatiller
- Bayramlar
- Yaz tatili
- Yarıyıl tatili
- Doğum günleri
- Özel günler
- Teslim yeri ve saati

Kural oluşturma örneği:

```json
{
  "type": "monthly_weekend",
  "weeks": [1, 3],
  "parent_id": "...",
  "start_day": "friday",
  "start_time": "18:00",
  "end_day": "sunday",
  "end_time": "18:00",
  "location": "Okul çıkışı"
}
```

Plan aktif edildiğinde sistem `custody_events` tablosuna ileriye dönük 12 aylık etkinlik üretmelidir. Kullanıcı ayarlardan 3/6/12 ay üretim periyodu seçebilir.

### 13.4 Teslim ekranı

Teslim akışı:

1. Teslim etkinliği görüntülenir.
2. Kullanıcı “Yola çıktım” seçebilir.
3. “Teslim noktasına geldim” seçebilir.
4. “Çocuk teslim edildi” seçebilir.
5. Gecikme varsa “Gecikme bildir” seçebilir.
6. Teslim gerçekleşmediyse “Teslim gerçekleşmedi” seçebilir.
7. Not/fotoğraf eklenebilir.
8. Opsiyonel konum kaydı alınabilir.
9. Karşı taraf görür ve onay/itiraz verebilir.

### 13.5 Mesajlar ekranı

Mesajlar konu bazlı thread mantığında çalışır.

Thread oluştururken konu seçimi zorunlu:

- Teslim
- Okul
- Servis
- Sağlık
- Masraf
- Belge
- Acil
- Genel
- Onay
- Seyahat

Mesajlar:

- Silinemez
- Düzenlenemez
- Okundu bilgisi tutulur
- Dosya eki desteklenir
- Sakin Dil Asistanı ile gönderim öncesi kontrol edilebilir

### 13.6 Sakin Dil Asistanı

Amaç: Kullanıcının sert, suçlayıcı veya çatışmayı artırabilecek mesajını daha nötr ve çocuk odaklı ifade etmesine yardımcı olmak.

Kurallar:

- Asistan mesajı otomatik göndermez.
- Kullanıcı isterse önerilen metni kullanır.
- Orijinal metin `body_original` alanında sadece kullanıcının izniyle saklanabilir.
- Hassas veriler LLM’e gönderilmeden önce maskeleme uygulanmalıdır.
- İlk versiyonda basit kural tabanlı + opsiyonel LLM yapılabilir.

Örnek:

Kullanıcı mesajı:
> Sen yine çocuğu zamanında getirmedin, hiçbir şeyi düzgün yapmıyorsun.

Öneri:
> Bugünkü teslim saatinde gecikme yaşandığını görüyorum. Sonraki teslimlerde belirlenen saate uyulmasını rica ederim.

### 13.7 Masraflar ekranı

Sekmeler:

- Tüm masraflar
- Bekleyenler
- Kabul edilenler
- İtiraz edilenler
- Ödenenler
- Düzenli giderler

Masraf ekleme alanları:

- Çocuk
- Başlık
- Kategori
- Tutar
- Tarih
- Ödeyen
- Karşı taraftan talep edilen tutar
- Paylaşım tipi
- Açıklama
- Belge/dekont/fatura
- Acil sağlık gideri mi?
- Son ödeme tarihi

Karşı taraf işlemleri:

- Kabul et
- Kısmen kabul et
- İtiraz et
- Ek belge iste
- Ödendi olarak işaretle

### 13.8 Belgeler ekranı

Kategoriler:

- Okul
- Sağlık
- Servis
- Masraf
- Hukuki
- Kimlik
- Etkinlik
- Diğer

Belge işlemleri:

- Yükle
- Görüntüle
- Karşı tarafla paylaş
- Okundu bilgisi
- Raporlara dahil et
- Belgeye açıklama ekle
- Belgeyi ilgili masraf/onay/takvim kaydına bağla

### 13.9 Çocuk Bilgi Merkezi

Alt sayfalar:

- Genel bilgiler
- Okul
- Servis
- Sağlık
- Yakınlar
- Teslim yetkilileri
- İhtiyaç listesi
- Teslim çantası

Her değişiklik karşı tarafa bildirilir ve audit log’a yazılır.

### 13.10 Onaylar ekranı

Onay türleri:

- Okul değişikliği
- Servis değişikliği
- Şehir dışı seyahat
- Yurt dışı seyahat
- Sağlık müdahalesi
- Kurs kaydı
- Psikolojik destek
- Spor etkinliği
- Pasaport/kimlik işlemi
- Adres değişikliği
- Teslim düzeni değişikliği

Akış:

- Talep oluştur
- Belge ekle
- Son cevap tarihi belirle
- Gönder
- Karşı taraf kabul/ret/ek bilgi iste
- Karar kayıt altına alınır

### 13.11 Uyuşmazlık merkezi

Uyuşmazlık türleri:

- Teslim gerçekleşmedi
- Teslim gecikti
- Masrafa itiraz
- Bilgi verilmedi
- Belge paylaşılmadı
- Onay verilmedi
- Çocuğun eşyası eksik geldi
- Okul/servis değişikliği bildirilmedi

Her uyuşmazlık ilgili entity’ye bağlanabilir.

### 13.12 Kişisel kayıt defteri

Özellikler:

- Sadece sahibi görür
- Not, fotoğraf, belge eklenebilir
- İstenirse rapora dahil edilir
- Tarih/saat otomatik
- Kategori seçimi
- İlgili takvim/teslim/masraf kaydına bağlama

### 13.13 Acil durum modu

Ekranda belirgin ama panik yaratmayan bir “Acil Bildirim” alanı olmalı.

Acil türleri:

- Sağlık
- Kaza
- Okuldan acil çağrı
- Servis problemi
- Teslim problemi
- Ulaşamama
- Güvenlik endişesi

Acil durumda:

- Diğer ebeveyne öncelikli bildirim gider
- Acil kişiler listesi açılır
- Sağlık kartı gösterilir
- Olay audit log’a yazılır
- Olay kapatılana kadar ana sayfada görünür

---

## 14. Bildirim Kuralları

Push bildirimleri hassas veriyi açık göstermemelidir.

Doğru:
- “Yeni bir belge paylaşıldı.”
- “Bekleyen bir masraf talebiniz var.”
- “Yarın teslim günü var.”
- “Bir onay talebi bekliyor.”

Yanlış:
- “Çocuğun alerji raporu yüklendi.”
- “Psikolog raporu gönderildi.”
- “Karşı taraf 3.250 TL okul masrafı istedi.”

Bildirim tipleri:

- `handover_reminder`
- `handover_delay`
- `message_new`
- `expense_request`
- `expense_response`
- `document_shared`
- `decision_request`
- `decision_response`
- `emergency_event`
- `calendar_change_request`
- `report_ready`
- `subscription_status`

---

## 15. PDF Raporlama Sistemi

Rapor türleri:

1. Mesaj raporu
2. Takvim raporu
3. Teslim raporu
4. Masraf raporu
5. Belge raporu
6. Onay talepleri raporu
7. Uyuşmazlık raporu
8. Kişisel defter raporu
9. Tam dönem raporu

Rapor filtreleri:

- Tarih aralığı
- Çocuk
- Konu
- Ebeveyn
- Durum
- Kategori
- Rapor kapsamı

PDF içeriği:

- Uygulama adı
- Rapor türü
- Tarih aralığı
- Oluşturan kullanıcı
- Oluşturma tarihi
- Çocuk bilgisi
- Kayıt listesi
- Zaman damgaları
- Okundu/onay/ret bilgileri
- Ek dosya listeleri
- Rapor hash değeri
- Doğrulama kodu
- QR doğrulama linki
- Açıklama: “Bu rapor uygulama kayıtlarından üretilmiştir; hukuki değerlendirme yetkili makamlarca yapılır.”

---

## 16. Abonelik ve Ödeme Planı

Uygulama ücretsiz olmamalıdır. Ancak ilk kullanıcı kazanımı için deneme süresi kullanılabilir.

### 16.1 Paketler

#### Plan 1 — Ebeveyn Köprüsü Plus

Aylık: 299 TL  
Yıllık: 2.999 TL  
Deneme: 7 gün

Özellikler:

- Ortak takvim
- Ebeveynlik planı
- Çocuk profili
- Konu bazlı mesajlaşma
- Masraf takibi
- Belge yükleme
- Okul/servis/sağlık bilgi merkezi
- Teslim kayıtları
- Bildirimler
- 1 çocuk
- 2 GB dosya alanı
- Basit PDF rapor

#### Plan 2 — Ebeveyn Köprüsü Premium

Aylık: 499 TL  
Yıllık: 4.999 TL  
Deneme: 7 gün

Özellikler:

- Plus içeriğinin tamamı
- Çoklu çocuk
- Hash doğrulamalı PDF rapor
- Sakin Dil Asistanı
- Kişisel kayıt defteri
- Uyuşmazlık merkezi
- Onay gerektiren kararlar
- Gelişmiş masraf raporu
- Avukat/uzman paylaşım linki
- 10 GB dosya alanı

#### Plan 3 — Ebeveyn Köprüsü Professional

Aylık: 899 TL  
Yıllık: 8.999 TL  
Deneme: yok veya 7 gün

Özellikler:

- Premium içeriğin tamamı
- Avukat, arabulucu, pedagog sınırlı erişimi
- Gelişmiş rapor setleri
- Çoklu aile desteği
- Uzman notları
- Öncelikli destek
- 50 GB dosya alanı
- Kurumsal danışmanlık paneline hazırlık

### 16.2 Entitlement mantığı

RevenueCat entitlement kodları:

```text
plus_access
premium_access
professional_access
```

Özellik kontrolleri:

```text
can_create_multiple_children
can_generate_verified_reports
can_use_tone_assistant
can_invite_expert
can_use_dispute_center
storage_limit_gb
max_children
```

### 16.3 Ücretsiz deneme

- 7 gün trial
- Trial bitmeden 24 saat önce bildirim
- Trial bittiğinde read-only mod:
  - Kullanıcı eski kayıtları görebilir
  - Yeni mesaj/masraf/belge ekleyemez
  - Acil durum özelliği sınırlı devam edebilir
  - Abonelik ekranına yönlendirilir

### 16.4 Ödeme ekranında gösterilecekler

- Plan adı
- Aylık/yıllık fiyat
- Deneme süresi
- Yenileme bilgisi
- İptal yöntemi
- Kullanım şartları
- Gizlilik politikası
- Abonelik otomatik yenilenir bilgisi

---

## 17. Supabase Storage Yapısı

Bucket’lar:

```text
avatars
documents
expense-files
handover-photos
journal-files
report-pdfs
support-files
```

Storage path standardı:

```text
families/{family_id}/children/{child_id}/documents/{document_id}/{filename}
families/{family_id}/expenses/{expense_id}/{filename}
families/{family_id}/reports/{report_id}.pdf
families/{family_id}/handover/{handover_id}/{filename}
```

Storage RLS:

- Dosya yolundaki `family_id` üzerinden erişim kontrolü yapılmalıdır.
- Kişisel defter dosyalarında `owner_id` kontrolü yapılmalıdır.
- Report share için signed URL veya token bazlı erişim kullanılmalıdır.
- Public bucket kullanılmamalıdır.

---

## 18. Edge Functions

Gerekli Supabase Edge Functions:

1. `send-notification`
2. `schedule-reminders`
3. `generate-report-pdf`
4. `verify-report`
5. `revenuecat-webhook`
6. `generate-audit-hash`
7. `tone-assistant`
8. `ocr-expense-receipt`
9. `invite-family-member`
10. `expire-pending-requests`

### 18.1 revenuecat-webhook

Görev:

- RevenueCat eventlerini alır.
- Kullanıcı aboneliğini günceller.
- Entitlement alanını günceller.
- Audit log oluşturur.

### 18.2 generate-report-pdf

Görev:

- Rapor filtrelerini alır.
- İlgili kayıtları çeker.
- PDF üretir.
- Supabase Storage’a kaydeder.
- `reports` tablosunu günceller.
- Verification code üretir.

### 18.3 tone-assistant

Görev:

- Mesaj metnini alır.
- Gerekiyorsa kişisel isimleri maskeleyebilir.
- Sertlik/çatışma riskini puanlar.
- Daha nötr alternatif önerir.
- Kullanıcıya döndürür.

---

## 19. Admin Panel

İlk sürümde Flutter içinde ayrı admin route veya Supabase Studio + basit web panel yapılabilir. Ancak prod için ayrı web admin önerilir.

Admin özellikleri:

- Kullanıcı listesi
- Abonelik durumu
- Aile sayısı
- Aktif çocuk profilleri
- Destek talepleri
- Şikayetler
- Sistem logları
- Rapor doğrulama
- Kullanıcı silme talepleri
- KVKK veri talepleri
- İçerik kötüye kullanım bildirimleri

Admin hassas mesaj ve belgeleri doğrudan görememeli. Gerekirse kullanıcı izni veya yasal gerekçe ile erişim açılmalı ve audit log’a yazılmalıdır.

---

## 20. Gizlilik ve KVKK Gereklilikleri

Uygulamada aşağıdaki metin ve akışlar bulunmalıdır:

- KVKK Aydınlatma Metni
- Açık rıza gerektiren alanlar
- Kullanım Şartları
- Gizlilik Politikası
- Çerez / analitik tercihleri
- Hesap silme talebi
- Verilerimi indir talebi
- Pazarlama iletişimi onayı
- Sağlık verileri için özel açıklama
- Çocuk verilerinin işlenmesine ilişkin özel bölüm

Teknik gereklilikler:

- Sensitive data minimum tutulmalı
- Sağlık bilgileri ayrı erişim politikasıyla korunmalı
- Push bildirimlerinde hassas detay gösterilmemeli
- Tüm kritik işlemler audit log’a yazılmalı
- Dosyalar private storage’da tutulmalı
- Kullanıcı hesabını kapatsa bile aile kayıtlarının hukuki/operasyonel saklama süresi politikaya göre yönetilmeli
- Veri silme taleplerinde karşı tarafın kayıt hakkı ve sistem kayıt bütünlüğü dikkate alınmalı

---

## 21. Analitik Olayları

Takip edilecek eventler:

```text
app_opened
signup_started
signup_completed
family_created
parent_invited
parent_joined
child_created
parenting_plan_created
calendar_event_created
change_request_sent
change_request_accepted
change_request_rejected
message_sent
tone_assistant_used
expense_created
expense_accepted
expense_disputed
document_uploaded
handover_completed
handover_disputed
decision_request_created
report_generated
subscription_started
subscription_cancelled
trial_started
trial_converted
```

Analitik veriler kişisel mesaj içeriği veya belge içeriği içermemelidir.

---

## 22. Test Planı

### 22.1 Unit test

- Tarih/takvim kural üretimi
- Masraf paylaşım hesapları
- Hash üretimi
- Yetki kontrol fonksiyonları
- Abonelik entitlement mapping
- Validasyonlar

### 22.2 Integration test

- Supabase Auth
- RLS erişim kontrolü
- Mesaj gönderme/okuma
- Masraf oluşturma/yanıtlama
- Belge yükleme
- PDF rapor üretme
- RevenueCat webhook
- Push notification

### 22.3 E2E test senaryoları

1. Anne hesap açar.
2. Çocuk ekler.
3. Baba davet edilir.
4. Baba daveti kabul eder.
5. Ebeveynlik planı oluşturulur.
6. Takvim etkinlikleri oluşur.
7. Takvim değişiklik talebi gönderilir.
8. Karşı taraf kabul eder.
9. Masraf eklenir.
10. Karşı taraf masrafı kabul eder.
11. Belge yüklenir.
12. Belge okundu kaydı oluşur.
13. Teslim kaydı tamamlanır.
14. PDF rapor oluşturulur.
15. Rapor doğrulama kodu çalışır.

### 22.4 Güvenlik testleri

- Kullanıcı başka aile verisini görememeli
- Kişisel defter sahibi dışında görünmemeli
- Mesajlar update/delete edilememeli
- Expired report share link çalışmamalı
- Storage path manipülasyonu ile dosya erişimi engellenmeli
- Subscription entitlement olmayan kullanıcı premium özelliğe erişememeli

---

## 23. Kabul Kriterleri

Proje tamamlandığında aşağıdaki kriterler sağlanmalıdır:

1. iOS ve Android için Flutter app çalışır durumda olmalı.
2. Supabase Auth ile kayıt/giriş/şifre sıfırlama çalışmalı.
3. Aile oluşturma ve diğer ebeveyni davet etme çalışmalı.
4. Tek ebeveyn modu çalışmalı.
5. Çocuk profili oluşturulabilmeli.
6. Okul, servis, sağlık, yakınlar modülleri çalışmalı.
7. Ebeveynlik planından otomatik takvim üretilebilmeli.
8. Takvim değişikliği talep/onay/ret akışı çalışmalı.
9. Teslim kayıt sistemi çalışmalı.
10. Konu bazlı mesajlaşma çalışmalı.
11. Mesaj okundu bilgisi tutulmalı.
12. Mesaj silme/düzenleme engellenmeli.
13. Sakin Dil Asistanı çalışmalı.
14. Masraf ekleme, belge/dekont yükleme ve masraf yanıtları çalışmalı.
15. Belge arşivi ve okundu bilgisi çalışmalı.
16. Onay gerektiren kararlar modülü çalışmalı.
17. Uyuşmazlık merkezi çalışmalı.
18. Kişisel kayıt defteri sadece sahibine görünmeli.
19. Acil durum modu çalışmalı.
20. Çocuk ihtiyaç listesi ve teslim çantası checklist çalışmalı.
21. Push bildirimleri çalışmalı.
22. PDF rapor üretilebilmeli.
23. Rapor doğrulama kodu/QR mantığı çalışmalı.
24. Audit log ve hash zinciri çalışmalı.
25. RevenueCat abonelik entegrasyonu çalışmalı.
26. Entitlement bazlı özellik kilitleme çalışmalı.
27. RLS tüm tablolarda aktif ve test edilmiş olmalı.
28. Storage private erişimle çalışmalı.
29. Hesap silme ve veri indirme talep ekranı olmalı.
30. Uygulama production build alabilmeli.

---

## 24. Codex İçin Uygulama Talimatı

Aşağıdaki işi uçtan uca yap:

1. Bu dokümandaki Flutter + Supabase + PostgreSQL mimarisine göre projeyi oluştur.
2. Flutter klasör yapısını yukarıdaki feature-based architecture ile kur.
3. Supabase migration dosyalarını oluştur.
4. Enum, tablo, index, trigger, function ve RLS politikalarını yaz.
5. Supabase Storage bucket ve policy yapılarını oluştur.
6. Edge Function dosyalarını oluştur.
7. RevenueCat servis katmanını yaz.
8. FCM bildirim servis katmanını yaz.
9. Flutter ekranlarını modül modül geliştir.
10. State management için Riverpod kullan.
11. Routing için GoRouter kullan.
12. Tema, localization, error handling ve loading state altyapısını kur.
13. Tüm form validasyonlarını yaz.
14. Audit log mekanizmasını uygula.
15. Mesajların update/delete edilememesini garanti et.
16. PDF raporlama sistemini uygula.
17. Hash doğrulama sistemini uygula.
18. Testleri yaz.
19. README, setup ve deployment dokümanlarını oluştur.
20. Kod içinde TODO bırakma; eksik kalan yerleri açıkça `IMPLEMENTATION_NOTES.md` dosyasında listele.

---

## 25. Environment Değişkenleri

`.env.example` oluştur:

```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
REVENUECAT_IOS_API_KEY=
REVENUECAT_ANDROID_API_KEY=
FCM_SERVER_KEY=
SENTRY_DSN=
OPENAI_API_KEY=
GEMINI_API_KEY=
APP_ENV=development
```

Service role key kesinlikle client app içinde kullanılmamalıdır. Sadece Edge Functions ortamında kullanılmalıdır.

---

## 26. README İçeriği

Codex ayrıca README.md dosyasında şunları yazmalıdır:

- Proje özeti
- Mimari
- Kurulum
- Flutter çalıştırma
- Supabase local development
- Migration çalıştırma
- Environment ayarları
- RevenueCat ayarları
- Firebase bildirim ayarları
- Test çalıştırma
- Production build
- Güvenlik notları
- KVKK notları
- Bilinen sınırlılıklar

---

## 27. Yayın Öncesi Kontrol Listesi

- App Store hesabı hazır
- Google Play Console hazır
- RevenueCat products tanımlı
- iOS subscription products tanımlı
- Android subscription products tanımlı
- Privacy Policy URL hazır
- Terms URL hazır
- KVKK metni hazır
- Account deletion URL veya app içi akış hazır
- Support e-mail hazır
- Screenshots hazır
- App açıklaması hazır
- Demo kullanıcı hesabı hazır
- App Review notları hazır
- Push notification permission açıklaması hazır
- Health data / child data açıklaması hazır
- Legal disclaimer hazır

---

## 28. App Store / Google Play Açıklama Taslağı

### Kısa açıklama

Ebeveyn Köprüsü, ayrı yaşayan veya boşanmış ebeveynlerin çocukla ilgili takvim, teslim, masraf, belge ve iletişim süreçlerini güvenli ve kayıtlı şekilde yönetmesini sağlar.

### Uzun açıklama

Ebeveyn Köprüsü, çocuğunuzla ilgili günlük koordinasyonu daha düzenli, sakin ve kayıtlı hale getirmek için tasarlanmış bir ebeveyn koordinasyon uygulamasıdır.

Uygulama ile:

- Ortak ebeveynlik takvimi oluşturabilir,
- Teslim günlerini ve saatlerini takip edebilir,
- Takvim değişikliklerini onay akışıyla yönetebilir,
- Çocukla ilgili okul, servis ve sağlık bilgilerini düzenli tutabilir,
- Masrafları, faturaları ve ödeme taleplerini takip edebilir,
- Belgeleri güvenli şekilde arşivleyebilir,
- Konu bazlı mesajlaşma ile iletişimi düzenleyebilir,
- Gerekirse tarih aralığına göre PDF rapor oluşturabilirsiniz.

Ebeveyn Köprüsü, çocuğun düzenini merkeze alan, güvenli ve sade bir koordinasyon aracıdır.

Yasal not:
Ebeveyn Köprüsü hukuki danışmanlık hizmeti sunmaz. Uygulama kayıtları bilgilendirme ve düzenleme amacıyla tutulur. Hukuki değerlendirme için avukatınıza veya yetkili makamlara başvurunuz.

---

## 29. Nihai Ürün Kararı

Bu uygulama bir “chat app” değildir.  
Bu uygulama bir “hukuk app’i” değildir.  
Bu uygulama bir “eski eş takip app’i” değildir.

Bu uygulama:

> Çocuğun hayatını ilgilendiren tüm koordinasyon süreçlerini kayıtlı, düzenli, güvenli ve çocuk merkezli hale getiren premium ebeveyn koordinasyon platformudur.

Codex, tüm geliştirme kararlarını bu ürün konumlandırmasına göre almalıdır.
