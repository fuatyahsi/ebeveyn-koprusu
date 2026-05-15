import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:ebeveyn_koprusu/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ebeveyn_koprusu/features/documents/presentation/screens/documents_screen.dart';
import 'package:ebeveyn_koprusu/features/expenses/presentation/screens/expenses_screen.dart';
import 'package:ebeveyn_koprusu/features/family/presentation/screens/family_screen.dart';
import 'package:ebeveyn_koprusu/features/messages/presentation/screens/messages_screen.dart';
import 'package:ebeveyn_koprusu/shared/widgets/brand_mark.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _screens = <Widget>[
    DashboardScreen(),
    CalendarScreen(),
    FamilyScreen(showBack: false),
    MessagesScreen(),
    ExpensesScreen(showBack: false),
    DocumentsScreen(showBack: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      drawer: const _ModuleSidebar(),
      drawerEnableOpenDragGesture: true,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: _BottomBar(
        active: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.active, required this.onTap});
  final int active;
  final ValueChanged<int> onTap;

  static const _items = <(IconData, IconData, String)>[
    (Icons.cottage_outlined, Icons.cottage, 'Bugün'),
    (Icons.calendar_month_outlined, Icons.calendar_month, 'Takvim'),
    (Icons.groups_2_outlined, Icons.groups_2, 'Aile'),
    (Icons.forum_outlined, Icons.forum, 'Mesaj'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Masraf'),
    (Icons.folder_outlined, Icons.folder, 'Belge'),
  ];

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paperWhite.withValues(alpha: 0.94),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                _BarItem(
                  icon: active == i ? _items[i].$2 : _items[i].$1,
                  active: i == active,
                  label: _items[i].$3,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.icon,
    required this.active,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.ink : AppColors.inkMute;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.ui(
                size: 9,
                weight: FontWeight.w500,
                color: color,
                letter: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleSidebar extends StatelessWidget {
  const _ModuleSidebar();

  static const _items = <(IconData, String, String)>[
    (Icons.groups_2_outlined, 'Aile', '/family'),
    (Icons.child_care_outlined, 'Çocuk', '/children'),
    (Icons.handshake_outlined, 'Teslim', '/handover'),
    (Icons.fact_check_outlined, 'Onaylar', '/decisions'),
    (Icons.folder_outlined, 'Belgeler', '/documents'),
    (Icons.contact_phone_outlined, 'Yakınlar', '/contacts'),
    (Icons.gavel_outlined, 'Uyuşmazlık', '/disputes'),
    (Icons.note_alt_outlined, 'Defter', '/journal'),
    (Icons.emergency_outlined, 'Acil', '/emergency'),
    (Icons.checklist_outlined, 'Checklist', '/checklists'),
    (Icons.picture_as_pdf_outlined, 'Raporlar', '/reports'),
    (Icons.workspace_premium_outlined, 'Premium', '/subscriptions'),
    (Icons.settings_outlined, 'Ayarlar', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.paper,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 18),
              child: Row(
                children: [
                  const BridgeMark(size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modüller',
                          style: AppTypography.display(size: 30),
                        ),
                        Text(
                          'Tüm akışlar yan menüde',
                          style: AppTypography.ui(
                            size: 12,
                            color: AppColors.inkMute,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Kapat',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            for (final item in _items)
              _SidebarItem(
                icon: item.$1,
                label: item.$2,
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(item.$3);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.paperWhite,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.sageSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 17, color: AppColors.sage),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.ui(
                      size: 13.5,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.inkMute,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
