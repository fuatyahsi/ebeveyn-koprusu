import 'package:ebeveyn_koprusu/app/theme/app_colors.dart';
import 'package:ebeveyn_koprusu/app/theme/app_typography.dart';
import 'package:ebeveyn_koprusu/core/services/app_data_service.dart';
import 'package:ebeveyn_koprusu/core/services/tone_assistant_service.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_card.dart';
import 'package:ebeveyn_koprusu/shared/widgets/app_pill.dart';
import 'package:ebeveyn_koprusu/shared/widgets/module_usage_tip.dart';
import 'package:ebeveyn_koprusu/shared/widgets/screen_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  MessageWorkspace? _workspace;
  ToneAssistantResult? _tone;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_analyzeTone);
    _load();
  }

  @override
  void dispose() {
    _controller.removeListener(_analyzeTone);
    _controller.dispose();
    super.dispose();
  }

  void _analyzeTone() {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      if (_tone != null) setState(() => _tone = null);
      return;
    }
    final result = ref.read(toneAssistantServiceProvider).analyze(text);
    setState(() => _tone = result);
  }

  void _useSuggestion() {
    final suggestion = _tone?.suggestion;
    if (suggestion == null || suggestion.trim().isEmpty) return;
    _controller.text = suggestion;
    _controller.selection = TextSelection.collapsed(offset: suggestion.length);
  }

  Future<void> _load() async {
    if (!AppDataService.hasSession) return;
    setState(() => _loading = true);
    try {
      final workspace = await AppDataService.fetchMessageWorkspace();
      if (!mounted) return;
      setState(() => _workspace = workspace);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _controller.text;
    if (body.trim().isEmpty) return;
    _controller.clear();
    setState(() => _loading = true);
    try {
      final message = await AppDataService.sendMessage(body);
      if (!mounted) return;
      setState(() {
        final current = _workspace;
        if (current != null) {
          _workspace = MessageWorkspace(
            thread: current.thread,
            messages: [...current.messages, message],
          );
        }
      });
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppDataService.friendlyError(error)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messages = _workspace?.messages ?? const <MessageItem>[];
    return SafeArea(
      bottom: false,
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 92),
            children: [
              ScreenHeader(
                eyebrow: 'Canlı konuşma',
                title: _workspace?.thread.title ?? 'Mesaj',
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
                      icon: Icons.forum_outlined,
                      text:
                          'Burada yazdığın mesajlar canlı message_threads/messages tablolarına kaydedilir. Sakin dil skoru da gönderim anında hesaplanır; sonra rapor ve audit akışına bağlanabilir.',
                    ),
                    const SizedBox(height: 14),
                    if (messages.isEmpty)
                      AppCard(
                        child: Text(
                          'Henüz mesaj yok. Alttaki kutudan ilk mesajı gönder.',
                          style: AppTypography.ui(
                            size: 13,
                            color: AppColors.inkMute,
                          ),
                        ),
                      )
                    else
                      for (final message in messages) ...[
                        _Bubble(message: message),
                        const SizedBox(height: 10),
                      ],
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _Composer(
              controller: _controller,
              onSend: _loading ? null : _send,
              tone: _tone,
              onUseSuggestion: _useSuggestion,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final MessageItem message;

  @override
  Widget build(BuildContext context) {
    final bg = message.isMine ? AppColors.ink : AppColors.paperWhite;
    final fg = message.isMine ? AppColors.paper : AppColors.ink;
    final alignment = message.isMine
        ? Alignment.centerRight
        : Alignment.centerLeft;
    final time = DateFormat('HH:mm', 'tr_TR').format(message.createdAt);

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.74,
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: message.isMine
                    ? null
                    : Border.all(color: AppColors.line),
              ),
              child: Text(
                message.body,
                style: AppTypography.ui(
                  size: 13.5,
                  weight: FontWeight.w400,
                  color: fg,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              message.isMine ? '$time · sen' : time,
              style: AppTypography.mono(size: 9.5, letter: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.tone,
    required this.onUseSuggestion,
  });

  final TextEditingController controller;
  final VoidCallback? onSend;
  final ToneAssistantResult? tone;
  final VoidCallback onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.paper.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tone != null) ...[
                _ToneAssistantCard(
                  result: tone!,
                  onUseSuggestion: onUseSuggestion,
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Sakin bir mesaj yaz...',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Gönder',
                    onPressed: onSend,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToneAssistantCard extends StatelessWidget {
  const _ToneAssistantCard({
    required this.result,
    required this.onUseSuggestion,
  });

  final ToneAssistantResult result;
  final VoidCallback onUseSuggestion;

  @override
  Widget build(BuildContext context) {
    final risky = result.riskScore >= 35;
    return AppCard(
      padding: const EdgeInsets.all(10),
      tint: risky ? CardTint.sage : CardTint.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                risky
                    ? Icons.warning_amber_rounded
                    : Icons.check_circle_outline,
                size: 18,
                color: risky ? AppColors.ochre : AppColors.sage,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sakin dil asistanı',
                  style: AppTypography.ui(size: 12.5, weight: FontWeight.w700),
                ),
              ),
              AppPill(
                label: 'Risk ${result.riskScore}',
                tone: risky ? PillTone.ochre : PillTone.sage,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            result.suggestion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.ui(size: 11.5, color: AppColors.inkSoft),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onUseSuggestion,
              icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
              label: const Text('Bu dille değiştir'),
            ),
          ),
        ],
      ),
    );
  }
}
