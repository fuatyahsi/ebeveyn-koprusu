import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _loading = false;
  List<LiveRecord> _plans = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final plans = await AppDataService.fetchSubscriptionPlans();
      if (!mounted) return;
      setState(() => _plans = plans);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppDataService.friendlyError(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ScreenHeader(
              eyebrow: 'Canlı katalog',
              title: 'Premium',
              showBack: true,
              trailing: IconButton(
                tooltip: 'Yenile',
                onPressed: _loading ? null : _load,
                icon: const Icon(Icons.refresh),
              ),
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const ModuleUsageTip(
                    icon: Icons.workspace_premium_outlined,
                    text:
                        'Bu ekran RevenueCat bağlanana kadar canlı Supabase plan kataloğunu okur. Fiyat, entitlement ve depolama limitleri backend’den gelir; satın alma aşaması mağaza credential’ları bağlanınca açılır.',
                  ),
                  const SizedBox(height: 14),
                  const SectionLabel(label: 'Planlar'),
                  if (_plans.isEmpty)
                    const AppCard(child: Text('Plan kataloğu boş.'))
                  else
                    Column(
                      children: [
                        for (final plan in _plans) ...[
                          AppCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        plan.title,
                                        style: AppTypography.display(size: 28),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        plan.subtitle,
                                        style: AppTypography.ui(
                                          size: 12,
                                          color: AppColors.inkMute,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AppPill(label: plan.status, tone: PillTone.ink),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
