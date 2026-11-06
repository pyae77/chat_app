
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/core/utils/date_time_helper.dart';
import 'package:flutter_chat_app/core/utils/image_picker_helper.dart';
import 'package:flutter_chat_app/core/utils/image_viewer_helper.dart';
import 'package:flutter_chat_app/core/utils/ui_helpers.dart';
import 'package:flutter_chat_app/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_chat_app/features/chat/presentation/widgets/image_source_dialog.dart';
import 'package:flutter_chat_app/features/people/presentation/providers/people_providers.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textfield.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chat_room_providers.dart';

class ChatRoomScreen extends ConsumerWidget {
  final ChatUserEntity targetUser;

  const ChatRoomScreen({
    super.key,
    required this.targetUser,
  });

  String _getChatRoomId(String u1, String u2) {
    final ids = [u1, u2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  Future<void> _sendMessage(
    WidgetRef ref,
    String chatRoomId,
  ) async {
    final controller = ref.read(chatMessageControllerProvider);
    final text = controller.text.trim();

    final selectedImage = ref.read(selectedImagePathProvider);
    final replyMessage = ref.read(selectedReplyMessageProvider);

    if (text.isEmpty && selectedImage == null) return;

    var isSuccess = false;

    try {
      final result = selectedImage != null
          ? await ref.read(sendImageMessageUseCaseProvider).execute(
                chatRoomId: chatRoomId,
                receiverId: targetUser.uid,
                imagePath: selectedImage,
                caption: text,
                replyToMessageId: replyMessage?.id,
                replyToSenderId: replyMessage?.senderId,
                replyToMessage: replyMessage?.message,
                replyToImageUrl: replyMessage?.imageUrl,
              )
          : await ref.read(sendMessageUseCaseProvider).execute(
                chatRoomId: chatRoomId,
                receiverId: targetUser.uid,
                messageText: text,
                replyToMessageId: replyMessage?.id,
                replyToSenderId: replyMessage?.senderId,
                replyToMessage: replyMessage?.message,
                replyToImageUrl: replyMessage?.imageUrl,
              );

      result.fold(
        ifLeft: (failure) {
          debugPrint('Message Send Failed: ${failure.message}');
        },
        ifRight: (_) {
          isSuccess = true;
          debugPrint('Message Sent Successfully!');
        },
      );

      if (isSuccess) {
        controller.clear();

        ref.read(selectedImagePathProvider.notifier).state = null;
        ref.read(selectedReplyMessageProvider.notifier).state = null;

        ref.invalidate(chatUsersProvider);
      }
    } catch (e, stackTrace) {
      debugPrint('Send Message Exception: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? '';

    final chatRoomId = _getChatRoomId(
      currentUserId,
      targetUser.uid,
    );

    final currentTargetUser =
        ref.watch(userPresenceStreamProvider(targetUser.uid))
                .asData?.value ??
            targetUser;

    ref.listen(
      messagesStreamProvider(chatRoomId),
      (previous, next) {
        next.whenData((eitherResult) {
          eitherResult.fold(
            ifLeft: (_) {},
            ifRight: (messages) {
              final hasUnreadMessages = messages.any(
                (message) =>
                    !message.isMe(currentUserId) &&
                    !message.isRead,
              );

              if (hasUnreadMessages) {
                ref
                    .read(markMessagesAsReadUseCaseProvider)
                    .execute(chatRoomId, currentUserId);
              }
            },
          );
        });
      },
    );

    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(context),
      child: Scaffold(
        appBar: CustomAppBar(
          leading: Assets.icons.icArrowLeft.path,
          leadingPressed: () => context.pop(),
          middleWidget: Row(
            children: [
              UserAvatar.fromChatUser(
                currentTargetUser,
                radius: 18,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextWidget(
                    text: currentTargetUser.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  CustomTextWidget(
                    text: currentTargetUser.isOnline
                        ? 'Online'
                        : 'Offline',
                    fontSize: 12,
                    color: currentTargetUser.isOnline
                        ? AppColors.success
                        : AppColors.grey1,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: _MessageList(
                chatRoomId: chatRoomId,
                currentUserId: currentUserId,
                targetUserName: currentTargetUser.name,
              ),
            ),
            _ChatInputSection(
              currentUserId: currentUserId,
              targetUserName: currentTargetUser.name,
              onSend: () => _sendMessage(ref, chatRoomId),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// MESSAGE LIST
// --------------------------------------------------


class _MessageList extends ConsumerStatefulWidget {
  final String chatRoomId;
  final String currentUserId;
  final String targetUserName;

  const _MessageList({
    required this.chatRoomId,
    required this.currentUserId,
    required this.targetUserName,
  });

  @override
  ConsumerState<_MessageList> createState() => _MessageListState();
}

class _MessageListState extends ConsumerState<_MessageList> {
  final Map<String, GlobalKey> _messageKeys = {};

  final ScrollController _scrollController = ScrollController();

  String? _highlightedMessageId;
  String? _lastLatestMessageId;

  Timer? _highlightTimer;

  // Scroll to the latest message.
  // reverse: true means offset 0 is the bottom.
  Future<void> _scrollToLatest({
  bool animated = true,
}) async {
  if (!_scrollController.hasClients) return;

  if (animated) {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  } else {
    _scrollController.jumpTo(0);
  }
}

  // Scroll to the original message when reply quote is tapped.
  Future<void> _scrollToMessage(String messageId) async {
    final key = _messageKeys[messageId];
    final targetContext = key?.currentContext;

    if (targetContext == null) {
      debugPrint(
        'Original message is not in the current message list: $messageId',
      );
      return;
    }

    _highlightTimer?.cancel();

    setState(() {
      _highlightedMessageId = messageId;
    });

    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );

    if (!mounted) return;

    _highlightTimer = Timer(
      const Duration(milliseconds: 1500),
      () {
        if (!mounted) return;

        setState(() {
          _highlightedMessageId = null;
        });
      },
    );
  }

  void _handleNewMessages(List<MessageEntity> messages) {
  if (messages.isEmpty) return;

  // Newest message is the first item.
  final latestMessage = messages.first;

  if (_lastLatestMessageId == latestMessage.id) return;

  final isFirstLoad = _lastLatestMessageId == null;

  final isMyNewMessage =
      latestMessage.senderId == widget.currentUserId;

  _lastLatestMessageId = latestMessage.id;

  if (isFirstLoad || isMyNewMessage) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.jumpTo(0);
    });
  }
}

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(
      messagesStreamProvider(widget.chatRoomId),
    );

    return messagesAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: CustomTextWidget(
          text: 'Error: $error',
        ),
      ),
      data: (eitherResult) {
        return eitherResult.fold(
          ifLeft: (failure) => Center(
            child: CustomTextWidget(
              text: failure.message,
            ),
          ),
          ifRight: (messages) {
            if (messages.isEmpty) {
              return const Center(
                child: CustomTextWidget(
                  text: 'Say hi to start conversation!',
                ),
              );
            }

            // Create or reuse keys for all messages.
            for (final message in messages) {
              _messageKeys.putIfAbsent(
                message.id,
                () => GlobalKey(),
              );
            }

            // Remove keys for messages that no longer exist.
            final currentIds =
                messages.map((message) => message.id).toSet();

            _messageKeys.removeWhere(
              (id, key) => !currentIds.contains(id),
            );

            // Detect new messages.
            _handleNewMessages(messages);

            return SingleChildScrollView(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final message in messages.reversed)
                    _MessageBubble(
                      key: _messageKeys[message.id],
                      message: message,
                      currentUserId: widget.currentUserId,
                      targetUserName: widget.targetUserName,
                      isHighlighted:
                          _highlightedMessageId == message.id,
                      onReplyTap: _scrollToMessage,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


// --------------------------------------------------
// MESSAGE BUBBLE
// --------------------------------------------------

class _MessageBubble extends ConsumerWidget {
  final MessageEntity message;
  final String currentUserId;
  final String targetUserName;
  final bool isHighlighted;
  final ValueChanged<String> onReplyTap;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.targetUserName,
    required this.isHighlighted,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMe = message.isMe(currentUserId);

    final selectedMessageId = ref.watch(
      selectedMessageIdProvider,
    );

    final bool isSelected =
        selectedMessageId == message.id;

    final hasImage =
        message.imageUrl != null &&
        message.imageUrl!.isNotEmpty;

    final hasReply =
        message.replyToMessageId != null &&
        message.replyToMessageId!.isNotEmpty;

    return Column(
      crossAxisAlignment: isMe
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: CustomTextWidget(
                text: DatetimeHelper.formatDetailedTimestamp(
                  message.timestamp,
                ),
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        GestureDetector(
          onTap: () {
            ref.read(selectedMessageIdProvider.notifier).state =
                isSelected ? null : message.id;
          },
          onLongPress: () {
            ref.read(selectedReplyMessageProvider.notifier).state =
                message;
          },
          child: Align(
            alignment: isMe
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(vertical: 4),
              constraints: const BoxConstraints(maxWidth: 250),
              padding: EdgeInsets.all(
                hasImage && !hasReply ? 0 : 8,
              ),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? Colors.amber.withOpacity(0.35)
                    : hasImage
                        ? Colors.transparent
                        : isMe
                            ? AppColors.buttonBackground
                            : Colors.grey[200],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: hasImage
                  ? _ImageMessage(
                      message: message,
                      isMe: isMe,
                      currentUserId: currentUserId,
                      targetUserName: targetUserName,
                      onReplyTap: onReplyTap,
                    )
                  : _TextMessage(
                      message: message,
                      isMe: isMe,
                      currentUserId: currentUserId,
                      targetUserName: targetUserName,
                      onReplyTap: onReplyTap,
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// REPLY QUOTE
// --------------------------------------------------

class _ReplyQuote extends ConsumerWidget {
  final MessageEntity message;
  final String currentUserId;
  final String targetUserName;
  final bool isMe;
  final VoidCallback onTap;

  const _ReplyQuote({
    required this.message,
    required this.currentUserId,
    required this.targetUserName,
    required this.isMe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage =
        message.replyToImageUrl != null &&
        message.replyToImageUrl!.isNotEmpty;

    final senderName =
        message.replyToSenderId == currentUserId
            ? 'You'
            : targetUserName;

    final imageBytes = hasImage
        ? ref.watch(
            messageImageBytesProvider(message.replyToImageUrl!),
          )
        : null;

    final previewText = hasImage
        ? (message.replyToMessage?.isNotEmpty == true
            ? message.replyToMessage!
            : 'Photo')
        : (message.replyToMessage ?? '');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.black.withOpacity(0.12)
                : Colors.black.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border(
              left: BorderSide(
                color: AppColors.buttonBackground,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: imageBytes == null
                      ? Container(
                          width: 42,
                          height: 42,
                          color: Colors.grey.shade300,
                          child: const Icon(
                            Icons.image,
                            size: 20,
                            color: Colors.grey,
                          ),
                        )
                      : Image.memory(
                          imageBytes,
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                ),
              if (hasImage) const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextWidget(
                      text: senderName,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? AppColors.white
                          : AppColors.buttonBackground,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 3),
                    CustomTextWidget(
                      text: previewText,
                      fontSize: 12,
                      color: isMe
                          ? AppColors.white
                          : AppColors.grey1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.reply,
                size: 16,
                color: isMe ? Colors.white70 : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// IMAGE MESSAGE
// --------------------------------------------------

class _ImageMessage extends ConsumerWidget {
  final MessageEntity message;
  final bool isMe;
  final String currentUserId;
  final String targetUserName;
  final ValueChanged<String> onReplyTap;

  const _ImageMessage({
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.targetUserName,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageData = message.imageUrl ?? '';

    final imageBytes = ref.watch(
      messageImageBytesProvider(imageData),
    );

    final hasReply =
        message.replyToMessageId != null &&
        message.replyToMessageId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasReply)
          _ReplyQuote(
            message: message,
            currentUserId: currentUserId,
            targetUserName: targetUserName,
            isMe: isMe,
            onTap: () => onReplyTap(
              message.replyToMessageId!,
            ),
          ),
        GestureDetector(
          onTap: () {
            ImageViewerHelper.showBase64Image(
              context,
              imageData,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageBytes == null
                ? Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Image.memory(
                        imageBytes,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomTextWidget(
                                text: DatetimeHelper
                                    .formatDetailedTimestamp(
                                  message.timestamp,
                                ),
                                fontSize: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              if (isMe)
                                Icon(
                                  message.isRead
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: 12,
                                  color: message.isRead
                                      ? Colors.blue
                                      : Colors.white70,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------
// TEXT MESSAGE
// --------------------------------------------------

class _TextMessage extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;
  final String currentUserId;
  final String targetUserName;
  final ValueChanged<String> onReplyTap;

  const _TextMessage({
    required this.message,
    required this.isMe,
    required this.currentUserId,
    required this.targetUserName,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasReply =
        message.replyToMessageId != null &&
        message.replyToMessageId!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasReply)
          _ReplyQuote(
            message: message,
            currentUserId: currentUserId,
            targetUserName: targetUserName,
            isMe: isMe,
            onTap: () => onReplyTap(
              message.replyToMessageId!,
            ),
          ),
        CustomTextWidget(
          text: message.message,
          color: isMe ? AppColors.white : AppColors.black,
          fontSize: 14,
        ),
        const SizedBox(height: 4),
        if (isMe)
          Icon(
            message.isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: message.isRead
                ? Colors.blue
                : Colors.white70,
          ),
      ],
    );
  }
}

// --------------------------------------------------
// CHAT INPUT SECTION
// --------------------------------------------------

class _ChatInputSection extends ConsumerWidget {
  final VoidCallback onSend;
  final String currentUserId;
  final String targetUserName;

  const _ChatInputSection({
    required this.onSend,
    required this.currentUserId,
    required this.targetUserName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImagePath = ref.watch(selectedImagePathProvider);
    final replyMessage = ref.watch(selectedReplyMessageProvider);
    final messageController = ref.watch(chatMessageControllerProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyMessage != null)
              _ReplyPreview(
                message: replyMessage,
                currentUserId: currentUserId,
                targetUserName: targetUserName,
                onClose: () {
                  ref
                      .read(selectedReplyMessageProvider.notifier)
                      .state = null;
                },
              ),
            if (selectedImagePath != null)
              _SelectedImagePreview(
                imagePath: selectedImagePath,
                onRemove: () {
                  ref
                      .read(selectedImagePathProvider.notifier)
                      .state = null;
                },
              ),
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    final source =
                        await ImageSourceDialog.show(context);

                    if (source == null) return;

                    String? imagePath;

                    if (source == ImageSourceType.gallery) {
                      imagePath = await ImagePickerHelper
                          .pickAndConvertImageFromGallery();
                    } else if (source == ImageSourceType.camera) {
                      imagePath = await ImagePickerHelper
                          .pickAndConvertImageFromCamera();
                    }

                    if (imagePath != null) {
                      ref
                          .read(selectedImagePathProvider.notifier)
                          .state = imagePath;
                    }
                  },
                  child: Image.asset(
                    Assets.icons.icGallery.path,
                    height: 24,
                    width: 40,
                  ),
                ),
                Expanded(
                  child: CustomTextField(
                    controller: messageController,
                    hintText: selectedImagePath != null
                        ? 'Add a caption...'
                        : 'Type a message...',
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onSend,
                  child: Image.asset(
                    Assets.icons.icSend.path,
                    height: 24,
                    width: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// REPLY PREVIEW
// --------------------------------------------------

class _ReplyPreview extends ConsumerWidget {
  final MessageEntity message;
  final String currentUserId;
  final String targetUserName;
  final VoidCallback onClose;

  const _ReplyPreview({
    required this.message,
    required this.currentUserId,
    required this.targetUserName,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImage =
        message.imageUrl != null &&
        message.imageUrl!.isNotEmpty;

    final imageBytes = hasImage
        ? ref.watch(messageImageBytesProvider(message.imageUrl!))
        : null;

    final senderName =
        message.senderId == currentUserId
            ? 'You'
            : targetUserName;

    final previewText = hasImage
        ? (message.message.isNotEmpty
            ? message.message
            : 'Photo')
        : message.message;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: AppColors.buttonBackground,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: imageBytes == null
                  ? Container(
                      width: 42,
                      height: 42,
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image,
                        color: Colors.grey,
                      ),
                    )
                  : Image.memory(
                      imageBytes,
                      width: 42,
                      height: 42,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    ),
            ),
          if (hasImage) const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextWidget(
                  text: senderName,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.buttonBackground,
                ),
                const SizedBox(height: 4),
                CustomTextWidget(
                  text: previewText,
                  fontSize: 12,
                  color: AppColors.grey1,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 18),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------
// SELECTED IMAGE PREVIEW
// --------------------------------------------------

class _SelectedImagePreview extends ConsumerWidget {
  final String imagePath;
  final VoidCallback onRemove;

  const _SelectedImagePreview({
    required this.imagePath,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBytes = ref.watch(
      messageImageBytesProvider(imagePath),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageBytes == null
                ? const SizedBox(
                    width: 60,
                    height: 60,
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  )
                : Image.memory(
                    imageBytes,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: CustomTextWidget(
              text: 'Photo selected. Ready to send!',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.neutralRed,
              size: 20,
            ),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
