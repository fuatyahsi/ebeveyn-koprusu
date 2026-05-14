import 'package:ebeveyn_koprusu/core/models/app_module.dart';
import 'package:ebeveyn_koprusu/core/models/domain_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final childrenProvider = Provider<List<ChildProfile>>(
  (ref) => const [
    ChildProfile(
      id: 'child-1',
      fullName: 'Deniz Yılmaz',
      ageLabel: '8 yaş',
      school: 'Atatürk İlkokulu',
    ),
  ],
);

final custodyEventsProvider = Provider<List<CustodyEvent>>((ref) {
  final today = DateTime.now();
  return [
    CustodyEvent(
      id: 'event-1',
      childName: 'Deniz',
      title: 'Hafta sonu teslimi',
      startAt: DateTime(today.year, today.month, today.day, 17),
      endAt: DateTime(today.year, today.month, today.day + 2, 18),
      assignedParent: 'Baba',
      location: 'Okul çıkışı',
      status: HandoverStatus.planned,
    ),
    CustodyEvent(
      id: 'event-2',
      childName: 'Deniz',
      title: 'Ara hafta görüşmesi',
      startAt: DateTime(today.year, today.month, today.day + 3, 18),
      endAt: DateTime(today.year, today.month, today.day + 3, 20),
      assignedParent: 'Anne',
      location: 'Park önü',
      status: HandoverStatus.arrived,
    ),
  ];
});

final messageThreadsProvider = Provider<List<MessageThread>>((ref) {
  final now = DateTime.now();
  return [
    MessageThread(
      id: 'thread-1',
      topic: 'Teslim',
      title: 'Cuma teslim saati',
      lastMessage: 'Teslim noktasında 17:00 için mutabıkız.',
      updatedAt: now.subtract(const Duration(minutes: 35)),
      unreadCount: 1,
    ),
    MessageThread(
      id: 'thread-2',
      topic: 'Okul',
      title: 'Veli toplantısı',
      lastMessage: 'Toplantı notlarını belge olarak ekledim.',
      updatedAt: now.subtract(const Duration(hours: 5)),
      unreadCount: 0,
    ),
  ];
});

final expensesProvider = Provider<List<ExpenseItem>>((ref) {
  final now = DateTime.now();
  return [
    ExpenseItem(
      id: 'expense-1',
      title: 'Okul servis ücreti',
      category: 'Servis',
      amount: 3200,
      requestedShare: 1600,
      status: ExpenseStatus.sent,
      date: now.subtract(const Duration(days: 1)),
    ),
    ExpenseItem(
      id: 'expense-2',
      title: 'Doktor kontrolü',
      category: 'Sağlık',
      amount: 1850,
      requestedShare: 925,
      status: ExpenseStatus.accepted,
      date: now.subtract(const Duration(days: 7)),
    ),
  ];
});

final appModulesProvider = Provider<List<AppModule>>(
  (ref) => const [
    AppModule(
      title: 'Aile',
      route: '/family',
      icon: Icons.groups_2_outlined,
      summary: 'Aile kaydı, üyeler, davet ve tek ebeveyn modu.',
      acceptance: 'Aile oluşturma, eş ebeveyn daveti ve erişim seviyesi.',
    ),
    AppModule(
      title: 'Çocuk',
      route: '/children',
      icon: Icons.child_care_outlined,
      summary: 'Çocuk profili, okul, servis ve sağlık bilgi merkezi.',
      acceptance: 'Çocuk hesabı yok; çocuk yalnızca kayıt konusu.',
    ),
    AppModule(
      title: 'Teslim',
      route: '/handover',
      icon: Icons.handshake_outlined,
      summary: 'Teslim/check-in, gecikme ve gerçekleşmedi kayıtları.',
      acceptance: 'Canlı konum yok; yalnızca işlem anında opsiyonel konum.',
    ),
    AppModule(
      title: 'Yakınlar',
      route: '/contacts',
      icon: Icons.contact_phone_outlined,
      summary: 'Yakınlar, acil kişiler ve teslim yetkilileri.',
      acceptance: 'Telefon değişiklikleri ve teslim yetkileri loglanır.',
    ),
    AppModule(
      title: 'Onaylar',
      route: '/decisions',
      icon: Icons.fact_check_outlined,
      summary: 'Okul, seyahat, sağlık ve servis karar talepleri.',
      acceptance: 'Kabul, ret, ek bilgi ve süre sonu akışları.',
    ),
    AppModule(
      title: 'Belgeler',
      route: '/documents',
      icon: Icons.folder_outlined,
      summary: 'Okul, sağlık, servis, masraf ve hukuki belge arşivi.',
      acceptance: 'Dosyalar aile kapsamlı private storage içinde saklanır.',
    ),
    AppModule(
      title: 'Uyuşmazlık',
      route: '/disputes',
      icon: Icons.gavel_outlined,
      summary: 'Masraf, teslim, belge ve karar itiraz dosyaları.',
      acceptance: 'Uyuşmazlık ilgili entity ve raporlarla ilişkilidir.',
    ),
    AppModule(
      title: 'Defter',
      route: '/journal',
      icon: Icons.note_alt_outlined,
      summary: 'Sadece sahibinin gördüğü kişisel kayıt defteri.',
      acceptance: 'Karşı ebeveyn tarafından görüntülenemez.',
    ),
    AppModule(
      title: 'Acil',
      route: '/emergency',
      icon: Icons.emergency_outlined,
      summary: 'Sağlık, okul, servis ve teslim acil bildirimleri.',
      acceptance: 'Hassas bildirim metinleri maskeleme politikasına uyar.',
    ),
    AppModule(
      title: 'Checklist',
      route: '/checklists',
      icon: Icons.checklist_outlined,
      summary: 'Teslim çantası ve ihtiyaç kontrol listeleri.',
      acceptance: 'Eksik eşya ve ihtiyaçlar durumla takip edilir.',
    ),
    AppModule(
      title: 'Raporlar',
      route: '/reports',
      icon: Icons.picture_as_pdf_outlined,
      summary: 'Tarih aralıklı PDF, hash ve QR doğrulama.',
      acceptance: 'Rapor hukuki tavsiye veya kesin delil iddiası taşımaz.',
    ),
    AppModule(
      title: 'Abonelik',
      route: '/subscriptions',
      icon: Icons.workspace_premium_outlined,
      summary: 'RevenueCat entitlement ve premium özellik kapıları.',
      acceptance: 'Plus, Premium ve Professional hakları ayrılır.',
      status: ModuleStatus.needsCredentials,
    ),
    AppModule(
      title: 'Ayarlar',
      route: '/settings',
      icon: Icons.settings_outlined,
      summary: 'KVKK, gizlilik, bildirim ve hesap silme talepleri.',
      acceptance: 'Veri indirme ve hesap kapatma akışı görünür.',
    ),
    AppModule(
      title: 'Admin',
      route: '/admin',
      icon: Icons.admin_panel_settings_outlined,
      summary: 'Operasyon, destek, abuse flag ve rapor doğrulama.',
      acceptance: 'Admin hassas aile içeriğine varsayılan erişmez.',
      status: ModuleStatus.mock,
    ),
  ],
);
