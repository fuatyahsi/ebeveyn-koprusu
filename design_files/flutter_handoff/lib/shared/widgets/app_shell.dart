import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:ebeveyn_koprusu/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:ebeveyn_koprusu/features/expenses/presentation/screens/expenses_screen.dart';
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
    MessagesScreen(),
    ExpensesScreen(),
    _MoreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
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
    (Icons.forum_outlined, Icons.forum, 'Mesaj'),
    (Icons.receipt_long_outlined, Icons.receipt_long, 'Masraf'),
    (Icons.grid_view_outlined, Icons.grid_view, 'Daha'),
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
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var i = 0; i < _items.length; i++)
                _BarItem(
                  icon: _items[i].$1,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.ui(
                size: 9.5,
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

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  static const _items = <(IconData, String, String)>[
    (Icons.groups_2_outlined, 'Aile', '/family'),
    (Icons.child_care_outlined, 'Çocuk', '/children'),
    (Icons.handshake_outlined, 'Teslim', '/handover'),
    (Icons.fact_check_outlined, 'Onaylar', '/decisions'),
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
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
            child: Row(
              children: [
                const BridgeMark(size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Modüller', style: AppTypography.display(size: 28)),
                      Text(
                        'Tüm akışlar bir bakışta',
                        style: AppTypography.ui(
                          size: 12,
                          color: AppColors.inkMute,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.95,
            children: [
              for (final item in _items)
                _ModuleTile(
                  icon: item.$1,
                  label: item.$2,
                  onTap: () => context.push(item.$3),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paperWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.sageSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: AppColors.sage),
              ),
              const Spacer(),
              Text(label, style: AppTypography.ui(weight: FontWeight.w600, size: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
