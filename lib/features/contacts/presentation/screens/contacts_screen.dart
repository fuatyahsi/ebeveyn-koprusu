import 'package:ebeveyn_koprusu/shared/widgets/live_module_screen.dart';
import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LiveModuleScreen(
      title: 'Yakınlar',
      eyebrow: 'Erişim',
      moduleKey: 'contacts',
      icon: Icons.contact_phone_outlined,
      usage:
          'Teslim alabilecek, acil durumda aranabilecek veya çocuğun bakım çevresinde yer alan kişileri ekle. Kayıtlar aile içinde görünür ve onay akışına hazır şekilde Supabase’e yazılır.',
      emptyText: 'Henüz yakın kaydı yok. + ile bir kişi ekleyebilirsin.',
      addTitle: 'Yakın ekle',
      addDetailLabel: 'Yakınlık, telefon, e-posta veya kısa not',
    );
  }
}
