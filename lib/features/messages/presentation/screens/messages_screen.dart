import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              ScreenHeader(
                eyebrow: 'Konu: Teslim',
                title: 'Cuma teslim saati',
                trailing: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.sageSoft,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: AppColors.sage,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _Conversation(),
                    SizedBox(height: 14),
                    _ToneAssistant(),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: _Composer()),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DateStamp(label: 'Bugün · 14:02'),
        const SizedBox(height: 10),
        _Bubble(
          text: 'Cuma 17:00 teslim için okul çıkışında uygun musun?',
          meta: 'Baba · 14:02',
          me: false,
        ),
        const SizedBox(height: 10),
        _Bubble(
          text: 'Uygunum. Çantasında matematik kitabı eksik, sende mi kaldı?',
          meta: '14:05 · ✓✓ Okundu · Kayıtlı',
          me: true,
        ),
        const SizedBox(height: 10),
        _Bubble(
          text:
              "Bende. Yarın Deniz'e veririm. Teslim noktasında 17:00 için mutabıkız.",
          meta: 'Baba · 14:11',
          me: false,
        ),
      ],
    );
  }
}

class _DateStamp extends StatelessWidget {
  const _DateStamp({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.ink.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTypography.mono(letter: 1.6, color: AppColors.inkMute),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.meta, required this.me});
  final String text;
  final String meta;
  final bool me;

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width * 0.7;
    final bg = me ? AppColors.ink : AppColors.paperWhite;
    final fg = me ? AppColors.paper : AppColors.ink;
    final radius = me
        ? const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(14),
            bottomRight: Radius.circular(4),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(14),
          );

    return Align(
      alignment: me ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Column(
          crossAxisAlignment: me
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
                border: me ? null : Border.all(color: AppColors.line),
              ),
              child: Text(
                text,
                style: AppTypography.ui(
                  size: 13.5,
                  color: fg,
                  weight: FontWeight.w400,
                  height: 1.45,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(me ? 0 : 10, 3, me ? 10 : 0, 0),
              child: Text(
                meta,
                style: AppTypography.mono(
                  color: AppColors.inkMute,
                  letter: 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneAssistant extends StatelessWidget {
  const _ToneAssistant();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      clip: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.sageSoft, AppColors.ochreSoft],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.ink.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.line),
                  ),
                  child: const Icon(
                    Icons.psychology_alt_outlined,
                    size: 14,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sakin Dil Asistanı',
                        style: AppTypography.display(size: 18, height: 1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Gönderim öncesi · Premium',
                        style: AppTypography.ui(
                          size: 10.5,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],
                  ),
                ),
                const AppPill(label: 'Risk 62/100', tone: PillTone.ink),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'YAZDIĞIN',
                  style: AppTypography.mono(
                    letter: 1.6,
                    color: AppColors.inkMute,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.terra.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.terra.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Text(
                    '"Yine geç kalıyorsun, hep böyle yapıyorsun. Çocuğa karşı sorumsuzsun."',
                    style: AppTypography.ui(
                      size: 13,
                      color: AppColors.inkSoft,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'ÖNERİ',
                        style: AppTypography.mono(
                          letter: 1.6,
                          color: AppColors.sage,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sageSoft,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.sage.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '"Birkaç teslim geç kaldı; Deniz\'in beklemesini önlemek için saati birlikte gözden geçirelim mi?"',
                    style: AppTypography.ui(size: 13.5, height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          minimumSize: const Size(0, 0),
                        ),
                        child: Text(
                          'Öneriyi kullan',
                          style: AppTypography.ui(
                            size: 12.5,
                            weight: FontWeight.w600,
                            color: AppColors.paper,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        minimumSize: const Size(0, 0),
                      ),
                      child: Text(
                        'Düzenle',
                        style: AppTypography.ui(
                          size: 12.5,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.94),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
          decoration: BoxDecoration(
            color: AppColors.paperWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Sakin bir mesaj yaz…',
                  style: AppTypography.ui(
                    size: 13,
                    color: AppColors.inkMute,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  size: 14,
                  color: AppColors.paper,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
