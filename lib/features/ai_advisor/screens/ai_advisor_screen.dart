import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../providers/chat_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../widgets/action_confirmation_card.dart';

class AiAdvisorScreen extends ConsumerStatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  ConsumerState<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends ConsumerState<AiAdvisorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      ref.read(chatProvider.notifier).sendMessage(_controller.text);
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final isLoading = ref.watch(chatProvider.notifier).isLoading;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInfoBg : AppColors.infoBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: AppColors.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('FinWise AI Advisor'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: messages.length + (isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                // Typist Indicator
                if (index == messages.length && isLoading) {
                  return const _TypingIndicator();
                }

                final msg = messages[index];

                // Render action confirmation card
                if (msg.isAction) {
                  return ActionConfirmationCard(
                    title: msg.action!.displayTitle,
                    description: msg.action!.displayDescription,
                    status: msg.actionStatus,
                    onConfirm: msg.actionStatus == ActionCardStatus.pending
                        ? () => ref
                              .read(chatProvider.notifier)
                              .confirmAction(msg.actionId!)
                        : null,
                    onCancel: msg.actionStatus == ActionCardStatus.pending
                        ? () => ref
                              .read(chatProvider.notifier)
                              .cancelAction(msg.actionId!)
                        : null,
                  );
                }

                return _ChatBubble(
                  message: msg.text,
                  isUser: msg.isUser,
                  isDark: isDark,
                );
              },
            ),
          ),
          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Tanyakan sesuatu tentang keuanganmu...',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkCard
                      : AppColors.surfaceSubtle,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryLight : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.primaryLight : AppColors.primary)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  LucideIcons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool isDark;

  const _ChatBubble({
    required this.message,
    required this.isUser,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Japandi colors for bubbles
    final userBgColor = isDark ? AppColors.primary : AppColors.primaryMuted;
    final userTextColor = isDark ? Colors.white : AppColors.textPrimary;

    final botBgColor = isDark ? AppColors.darkCard : AppColors.surfaceCard;
    final botTextColor = isDark ? AppColors.textInverse : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUser ? userBgColor : botBgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  width: 1,
                ),
          boxShadow: [
            if (!isUser)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: SelectableText(
          message.replaceAll('**', '').replaceAll('*', ''),
          style: AppTextStyles.body.copyWith(
            color: isUser ? userTextColor : botTextColor,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.surfaceCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(20),
          ),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'FinWise sedang mengetik...',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
