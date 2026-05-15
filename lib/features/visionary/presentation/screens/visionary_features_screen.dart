import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VisionaryFeaturesScreen extends StatefulWidget {
  const VisionaryFeaturesScreen({super.key});

  @override
  State<VisionaryFeaturesScreen> createState() =>
      _VisionaryFeaturesScreenState();
}

class _VisionaryFeaturesScreenState extends State<VisionaryFeaturesScreen> {
  bool _busy = false;

  Future<void> _openFeature(_VisionaryFeature feature) async {
    final shouldActivate = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _FeatureDetailSheet(feature: feature),
    );
    if (shouldActivate == true) {
      await _activateFeature(feature);
    }
  }

  Future<void> _activateFeature(_VisionaryFeature feature) async {
    setState(() => _busy = true);
    try {
      switch (feature.action) {
        case _VisionaryAction.swapRequest:
          await AppDataService.addLiveRecord(
            moduleKey: 'decisions',
            title: 'Gün takası talebi',
            detail:
                'Önerilen gün ve karşılık gün aile onayına sunuldu. Sistem otomatik onay vermez.',
          );
          break;
        case _VisionaryAction.mentorLog:
          await AppDataService.addLiveRecord(
            moduleKey: 'journal',
            title: 'Ebeveyn asistanı sorusu',
            detail:
                'Pedagojik çerçevede cevaplanacak danışman sorusu. Hukuki tavsiye kapsamı dışındadır.',
          );
          break;
        case _VisionaryAction.geofenceReminder:
          await AppDataService.addLiveRecord(
            moduleKey: 'handover',
            title: 'Cihaz içi teslim hatırlatıcısı',
            detail:
                'Konum cihaz içinde değerlendirilir; canlı konum Supabase kaydına yazılmaz.',
          );
          break;
        case _VisionaryAction.bankDraft:
          await AppDataService.addLiveRecord(
            moduleKey: 'decisions',
            title: 'Açık bankacılık masraf taslağı',
            detail:
                'OAuth ile seçilecek tekil işlem masraf talebine dönüştürülmek üzere hazırlandı.',
          );
          break;
        case _VisionaryAction.harmonyReport:
          await AppDataService.createReport();
          break;
        case _VisionaryAction.teenConsent:
          await AppDataService.addLiveRecord(
            moduleKey: 'decisions',
            title: 'Teen modu ebeveyn onayı',
            detail:
                '13+ salt okunur takvim erişimi için açık rıza ve kapsam onayı gerekir.',
          );
          break;
        case _VisionaryAction.kidProfile:
          await AppDataService.addLiveRecord(
            moduleKey: 'journal',
            title: 'Beden kartı güncelleme notu',
            detail:
                'Boy, kilo, ayakkabı ve ihtiyaç vitrini sağlık verisine girmeden takip edilir.',
          );
          break;
        case _VisionaryAction.visualPrint:
          await AppDataService.createReport();
          break;
        case _VisionaryAction.quietHours:
          await AppDataService.addLiveRecord(
            moduleKey: 'journal',
            title: 'Sessiz zaman tercihi',
            detail:
                '21:00-08:00 arası acil olmayan mesajları erteleme kuralı taslağı.',
          );
          break;
        case _VisionaryAction.dropBox:
          await AppDataService.addLiveRecord(
            moduleKey: 'contacts',
            title: 'Öğretmen / doktor evrak köprüsü',
            detail:
                '48 saat geçerli tek yönlü belge yükleme bağlantısı hazırlanacak kişi.',
          );
          break;
        case _VisionaryAction.callLog:
          await AppDataService.addLiveRecord(
            moduleKey: 'journal',
            title: 'Uygulama içi arama meta kaydı',
            detail:
                'Ses kaydı tutulmadan yalnızca saat, süre ve durum bilgisinin raporlanması.',
          );
          break;
        case _VisionaryAction.holidayMemory:
          await AppDataService.createReport();
          break;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${feature.title} için canlı hazırlık kaydı oluşturuldu.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppDataService.friendlyError(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 28),
          children: [
            ScreenHeader(
              eyebrow: 'Güvenli gelecek katmanı',
              title: 'Vizyon',
              showBack: true,
              trailing: _busy
                  ? const SizedBox.square(
                      dimension: 36,
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton.filled(
                      tooltip: 'Rapor üret',
                      onPressed: () => context.push('/reports'),
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const _VisionHero(),
                  const SizedBox(height: 14),
                  const SectionLabel(label: '12 ileri özellik'),
                  for (final feature in _visionaryFeatures) ...[
                    _FeatureCard(
                      feature: feature,
                      onTap: _busy ? null : () => _openFeature(feature),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VisionHero extends StatelessWidget {
  const _VisionHero();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      tint: CardTint.ink,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.paper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.paper.withValues(alpha: 0.14),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_outlined,
                  color: AppColors.paper,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Çocuk odaklı, veri-minimum, kanıta hazır deneyler',
                  style: AppTypography.display(
                    size: 27,
                    color: AppColors.paper,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Bu alan ileri özellikleri tek tek güvenli bir MVP akışına indirir. Dış servis gerektiren işlemler önce hazırlık kaydı açar; canlı konum, banka şifresi, ses kaydı veya hukuki tavsiye üretmez.',
            style: AppTypography.ui(
              size: 12.5,
              color: AppColors.paper.withValues(alpha: 0.72),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _HeroChip(label: 'RLS uyumlu'),
              _HeroChip(label: 'Audit izli'),
              _HeroChip(label: 'Çocuk verisi sınırlı'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.paper.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: AppTypography.ui(
          size: 11,
          weight: FontWeight.w600,
          color: AppColors.paper,
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.onTap});

  final _VisionaryFeature feature;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paperWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: feature.tone,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(feature.icon, color: AppColors.ink, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            feature.title,
                            style: AppTypography.ui(
                              size: 13.5,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                        AppPill(label: feature.badge, tone: feature.pillTone),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      feature.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.ui(
                        size: 11.5,
                        color: AppColors.inkMute,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, color: AppColors.inkMute),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureDetailSheet extends StatelessWidget {
  const _FeatureDetailSheet({required this.feature});

  final _VisionaryFeature feature;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, bottom + 18),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: feature.tone,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(feature.icon, color: AppColors.ink),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.kicker.toUpperCase(),
                        style: AppTypography.mono(
                          size: 9,
                          letter: 1.6,
                          color: AppColors.inkMute,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        feature.title,
                        style: AppTypography.display(size: 30, height: 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _DetailPanel(
              icon: Icons.lightbulb_outline,
              title: 'Konsept',
              text: feature.concept,
            ),
            const SizedBox(height: 10),
            _DetailPanel(
              icon: Icons.dashboard_customize_outlined,
              title: 'Arayüz',
              text: feature.interface,
            ),
            const SizedBox(height: 10),
            _DetailPanel(
              icon: Icons.verified_user_outlined,
              title: 'Kısıt',
              text: feature.guardrail,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in feature.chips)
                  _SheetChip(label: chip, tone: feature.tone),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: Icon(feature.actionIcon),
              label: Text(feature.actionLabel),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Şimdilik kapat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.sage),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.ui(weight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: AppTypography.ui(
                    size: 12,
                    color: AppColors.inkSoft,
                    height: 1.32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Text(
        label,
        style: AppTypography.ui(size: 11, weight: FontWeight.w600),
      ),
    );
  }
}

enum _VisionaryAction {
  swapRequest,
  mentorLog,
  geofenceReminder,
  bankDraft,
  harmonyReport,
  teenConsent,
  kidProfile,
  visualPrint,
  quietHours,
  dropBox,
  callLog,
  holidayMemory,
}

class _VisionaryFeature {
  const _VisionaryFeature({
    required this.title,
    required this.kicker,
    required this.summary,
    required this.concept,
    required this.interface,
    required this.guardrail,
    required this.icon,
    required this.tone,
    required this.badge,
    required this.pillTone,
    required this.chips,
    required this.action,
    required this.actionLabel,
    required this.actionIcon,
  });

  final String title;
  final String kicker;
  final String summary;
  final String concept;
  final String interface;
  final String guardrail;
  final IconData icon;
  final Color tone;
  final String badge;
  final PillTone pillTone;
  final List<String> chips;
  final _VisionaryAction action;
  final String actionLabel;
  final IconData actionIcon;
}

const _visionaryFeatures = <_VisionaryFeature>[
  _VisionaryFeature(
    title: 'Akıllı takvim ve gün takası',
    kicker: 'Smart swapping',
    summary: 'Mahkeme takviminde gün değişimi talebi oluşturur.',
    concept:
        'Ebeveyn bir teslim veya görüşme gününü karşılık günle takas etmek için açık onay talebi başlatır.',
    interface:
        'Takvim kartı, önerilen tarih, karşılık tarih ve onay bekleyen durum etiketiyle görünür.',
    guardrail:
        'Sistem otomatik karar vermez; karşı tarafın açık onayı audit akışına düşmelidir.',
    icon: Icons.swap_horiz_rounded,
    tone: AppColors.sageSoft,
    badge: 'Canlı',
    pillTone: PillTone.sage,
    chips: ['Onaylar', 'Audit', 'Takvim'],
    action: _VisionaryAction.swapRequest,
    actionLabel: 'Takas talebi oluştur',
    actionIcon: Icons.fact_check_outlined,
  ),
  _VisionaryFeature(
    title: 'Ebeveyn asistanı',
    kicker: 'AI mentor',
    summary: 'Pedagojik çerçevede güvenli danışman ekranı.',
    concept:
        'LLM destekli danışman, ebeveyn iletişimini yumuşatır ve pedagojik öneri üretir.',
    interface:
        'Soru kutusu, güvenlik notu, cevap kartı ve kişisel geçmiş alanı tek ekranda toplanır.',
    guardrail:
        'Hukuki tavsiye vermez; çocuğun adı, adresi veya canlı konum prompta gönderilmez.',
    icon: Icons.psychology_alt_outlined,
    tone: AppColors.ochreSoft,
    badge: 'Edge',
    pillTone: PillTone.ochre,
    chips: ['LLM hazır', 'Kişisel günlük', 'Veri minimizasyonu'],
    action: _VisionaryAction.mentorLog,
    actionLabel: 'Danışman kaydı aç',
    actionIcon: Icons.chat_bubble_outline,
  ),
  _VisionaryFeature(
    title: 'Cihaz içi teslim hatırlatıcı',
    kicker: 'Geofence',
    summary: 'Okul veya teslim noktasına yaklaşınca lokal uyarı.',
    concept:
        'Teslim noktası için cihaz içinde 100 metrelik hatırlatıcı alanı kurulur.',
    interface:
        'Teslim kartında konum adı, izin durumu ve bildirim testi butonu yer alır.',
    guardrail:
        'Canlı konum takibi yasaktır; koordinat kontrolü cihaz dışına çıkmaz.',
    icon: Icons.location_searching_outlined,
    tone: AppColors.sageSoft,
    badge: 'Cihaz',
    pillTone: PillTone.sage,
    chips: ['Local only', 'Bildirim', 'Konum kaydı yok'],
    action: _VisionaryAction.geofenceReminder,
    actionLabel: 'Hatırlatıcı kaydı oluştur',
    actionIcon: Icons.notifications_active_outlined,
  ),
  _VisionaryFeature(
    title: 'Açık bankacılık masraf taslağı',
    kicker: 'Open banking',
    summary: 'Seçili banka işlemini masraf talebine dönüştürür.',
    concept:
        'OAuth sonrası yalnızca kullanıcının seçtiği tekil okul/sağlık/servis işlemi masrafa dönüşür.',
    interface:
        'Masraf ekranında Bankadan Çek butonu, işlem seçici ve taslak önizlemesi bulunur.',
    guardrail:
        'Banka şifresi tutulmaz; karşı taraf tüm ekstreyi değil sadece gönderilen masrafı görür.',
    icon: Icons.account_balance_outlined,
    tone: AppColors.ochreSoft,
    badge: 'OAuth',
    pillTone: PillTone.ochre,
    chips: ['Taslak', 'OAuth', 'Masraf'],
    action: _VisionaryAction.bankDraft,
    actionLabel: 'Masraf taslağı aç',
    actionIcon: Icons.receipt_long_outlined,
  ),
  _VisionaryFeature(
    title: 'Pozitif iletişim skoru',
    kicker: 'Harmony score',
    summary: 'Ailenin ortak uyumunu motivasyonel dille gösterir.',
    concept:
        'İtirazsız masraflar, sakin mesajlar ve zamanında teslimler aylık aile skoruna dönüşür.',
    interface:
        'Ana ekranda küçük bir skor kartı, trend oku ve “bu ay iyi gidiyor” metni gösterilir.',
    guardrail:
        'Skor kişilere karşı silah değildir; sadece ailenin toplam uyum göstergesidir.',
    icon: Icons.favorite_border_rounded,
    tone: AppColors.sageSoft,
    badge: 'Rapor',
    pillTone: PillTone.sage,
    chips: ['Dashboard', 'Motivasyon', 'Aile skoru'],
    action: _VisionaryAction.harmonyReport,
    actionLabel: 'Uyum raporu üret',
    actionIcon: Icons.picture_as_pdf_outlined,
  ),
  _VisionaryFeature(
    title: 'Teen modu',
    kicker: '13+ salt okunur',
    summary: 'Ergen çocuk için sınırlı takvim ve talep ekranı.',
    concept:
        '13 yaş üzeri çocuk sadece kendi takvimini görür ve ebeveyn onayına talep bırakabilir.',
    interface:
        'Basit giriş, Takvimim ekranı ve Talep Ekle butonu dışında veri erişimi yoktur.',
    guardrail:
        'Açık ebeveyn rızası gerekir; mesaj ve masraf erişimi kesinlikle kapalıdır.',
    icon: Icons.school_outlined,
    tone: AppColors.paperWhite,
    badge: 'Rıza',
    pillTone: PillTone.mute,
    chips: ['Salt okunur', 'KVKK/COPPA', 'Takvim'],
    action: _VisionaryAction.teenConsent,
    actionLabel: 'Onay talebi oluştur',
    actionIcon: Icons.verified_user_outlined,
  ),
  _VisionaryFeature(
    title: 'Beden kartı ve ihtiyaç vitrini',
    kicker: 'Kids wardrobe',
    summary: 'Boy, ayakkabı, kıyafet ve ihtiyaç takibi.',
    concept:
        'Çocuğun pratik beden bilgileri ve açık ihtiyaçları iki ebeveyn tarafından güncellenir.',
    interface:
        'Çocuk ekranında beden kartı, ihtiyaç listesi ve satın alındı durumu birlikte görünür.',
    guardrail:
        'Sağlık teşhisi tutulmaz; bilgiler fiziksel ölçü ve ihtiyaç düzeyinde kalır.',
    icon: Icons.child_friendly_outlined,
    tone: AppColors.sageSoft,
    badge: 'Profil',
    pillTone: PillTone.sage,
    chips: ['Çocuk', 'İhtiyaç', 'Bildirim'],
    action: _VisionaryAction.kidProfile,
    actionLabel: 'Beden kartı notu aç',
    actionIcon: Icons.note_alt_outlined,
  ),
  _VisionaryFeature(
    title: 'Görsel çocuk takvimi',
    kicker: 'Print out',
    summary: 'Çocuğun odasına asılabilecek ikonlu PDF.',
    concept:
        'Mevcut takvim renkli, yatay ve çocuğun okuyabileceği ikonlarla PDF çıktısına dönüşür.',
    interface:
        'Takvimde Çocuk Çıktısı butonu, ay seçici ve yazdırma önizlemesi yer alır.',
    guardrail:
        'PDF cihaz içinde üretilir; Edge Function veya dış servise çocuk takvimi gönderilmez.',
    icon: Icons.print_outlined,
    tone: AppColors.ochreSoft,
    badge: 'PDF',
    pillTone: PillTone.ochre,
    chips: ['Cihaz içi', 'PDF', 'Takvim'],
    action: _VisionaryAction.visualPrint,
    actionLabel: 'PDF hazırlık raporu üret',
    actionIcon: Icons.print_outlined,
  ),
  _VisionaryFeature(
    title: 'Sessiz zaman',
    kicker: 'Quiet hours',
    summary: 'Gece mesajlarını acil değilse sabaha erteler.',
    concept:
        'Kullanıcı sessiz saat aralığı seçer; acil olmayan mesajlar saygılı biçimde ertelenir.',
    interface:
        'Mesaj gönderirken sessiz saat uyarısı, Acil seçeneği ve erteleme özeti gösterilir.',
    guardrail:
        'Acil bayrağı audit ve uyuşmazlık raporuna iz bırakır; suistimal görünür olur.',
    icon: Icons.nightlight_round_outlined,
    tone: AppColors.paperWhite,
    badge: 'Sınır',
    pillTone: PillTone.mute,
    chips: ['Mesaj', 'Acil bayrak', 'Audit'],
    action: _VisionaryAction.quietHours,
    actionLabel: 'Sessiz saat kaydı aç',
    actionIcon: Icons.schedule_outlined,
  ),
  _VisionaryFeature(
    title: 'Tek yönlü evrak köprüsü',
    kicker: 'Drop box',
    summary: 'Öğretmen veya doktor linkle belge yükler.',
    concept:
        'Üçüncü kişi uygulamaya girmeden süreli linkle tek yönlü belge bırakabilir.',
    interface: 'Kişi, süre, kategori ve link durumu kartlarıyla yönetilir.',
    guardrail:
        'Link süreli olmalı; yüklenen belge şeffaflık için salt okunur tutulmalıdır.',
    icon: Icons.forward_to_inbox_outlined,
    tone: AppColors.sageSoft,
    badge: 'Link',
    pillTone: PillTone.sage,
    chips: ['48 saat', 'Belge', '3. kişi'],
    action: _VisionaryAction.dropBox,
    actionLabel: 'Dropbox kişisi ekle',
    actionIcon: Icons.contact_mail_outlined,
  ),
  _VisionaryFeature(
    title: 'Uygulama içi arama',
    kicker: 'VoIP metadata',
    summary: 'Telefon numarası gizli, sadece arama metası kayıtlı.',
    concept:
        'Agora veya Twilio token ile uygulama içi arama yapılır; numaralar paylaşılmaz.',
    interface:
        'Mesaj ekranında arama butonu, gelen arama kartı ve arama geçmişi listesi bulunur.',
    guardrail:
        'Ses veya görüntü kaydedilmez; yalnızca saat, süre ve cevap durumu raporlanır.',
    icon: Icons.call_outlined,
    tone: AppColors.ochreSoft,
    badge: 'Token',
    pillTone: PillTone.ochre,
    chips: ['VoIP', 'Metadata', 'Gizlilik'],
    action: _VisionaryAction.callLog,
    actionLabel: 'Arama meta kaydı aç',
    actionIcon: Icons.call_outlined,
  ),
  _VisionaryFeature(
    title: 'Sıra kimde hafızası',
    kicker: 'Holiday tracker',
    summary: 'Geçmiş bayram/yılbaşı teslimlerini özetler.',
    concept:
        'Etiketli geçmiş takvim kayıtlarından son üç yılın sıra hafızası çıkarılır.',
    interface:
        'Takvimde Hafıza butonu, yıl kırılımı ve tavsiye diliyle sonuç kartı gösterilir.',
    guardrail:
        'Hukuki emir dili kullanılmaz; sadece geçmiş veriye dayalı öngörü sunulur.',
    icon: Icons.history_edu_outlined,
    tone: AppColors.paperWhite,
    badge: 'Analiz',
    pillTone: PillTone.mute,
    chips: ['Takvim', 'Geçmiş', 'Tavsiye dili'],
    action: _VisionaryAction.holidayMemory,
    actionLabel: 'Hafıza raporu üret',
    actionIcon: Icons.history_outlined,
  ),
];
