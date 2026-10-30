import 'dart:convert'; // 👈 base64Decode အတွက်
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/core/utils/image_picker_helper.dart';
import 'package:flutter_chat_app/core/utils/image_viewer_helper.dart';
import 'package:flutter_chat_app/core/utils/ui_helpers.dart';
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

  const ChatRoomScreen({super.key, required this.targetUser});

  String _getChatRoomId(String u1, String u2) {
    final ids = [u1, u2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void _sendMessage(WidgetRef ref, String chatRoomId) async {
    final controller = ref.read(chatMessageControllerProvider);
    final text = controller.text.trim();

    final selectedBase64Image = ref.read(selectedImagePathProvider);

    print(
      '_sendMessage called -> Text: $text, Has Image: ${selectedBase64Image != null}',
    );

    if (text.isEmpty && selectedBase64Image == null) return;

    controller.clear();
    ref.read(selectedImagePathProvider.notifier).state = null;

    try {
      if (selectedBase64Image != null) {
        print('Sending Image Message...');

        final result = await ref
            .read(sendImageMessageUseCaseProvider)
            .execute(
              chatRoomId: chatRoomId,
              receiverId: targetUser.uid,
              imagePath: selectedBase64Image,
            );

        result.fold(
          ifLeft: (failure) => print(' Image Send Failed: ${failure.message}'),
          ifRight: (_) {
            ref.invalidate(chatUsersProvider);
            print('Image Sent Successfully!');
          },
        );
      } else {
        print('✉️ Sending Text Message...');
        final result = await ref
            .read(sendMessageUseCaseProvider)
            .execute(
              chatRoomId: chatRoomId,
              receiverId: targetUser.uid,
              messageText: text,
            );

        result.fold(
          ifLeft: (failure) => print(' Text Send Failed: ${failure.message}'),
          ifRight: (_) {
            ref.invalidate(chatUsersProvider);
            print(' Text Sent Successfully!');
          },
        );
      }
    } catch (e, stackTrace) {
      print('EXCEPTION IN _sendMessage: $e');
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final chatRoomId = _getChatRoomId(currentUserId, targetUser.uid);

    final messagesAsync = ref.watch(messagesStreamProvider(chatRoomId));
    final currentTargetUser =
        ref.watch(userPresenceStreamProvider(targetUser.uid)).asData?.value ??
        targetUser;
    final messageController = ref.watch(chatMessageControllerProvider);
    final selectedImagePath = ref.watch(selectedImagePathProvider);

    return GestureDetector(
      onTap: () => UIHelpers.hideKeyboard(context),
      child: Scaffold(
        appBar: CustomAppBar(
          leading: Assets.icons.icArrowLeft.path,
          leadingPressed: () => context.pop(),
          middleWidget: Row(
            children: [
              UserAvatar.fromChatUser(currentTargetUser, radius: 18),
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
                    text: currentTargetUser.isOnline ? 'Online' : 'Offline',
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
            // 1. Message List Section
            Expanded(
              child: messagesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (eitherResult) {
                  return eitherResult.fold(
                    ifLeft: (failure) => Center(child: Text(failure.message)),
                    ifRight: (messages) {
                      if (messages.isEmpty) {
                        return const Center(
                          child: CustomTextWidget(
                            text: 'Say hi to start conversation!',
                          ),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.isMe(currentUserId);

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              constraints: const BoxConstraints(maxWidth: 250),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppColors.buttonBackground
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                              ),

                              child: message.imageUrl != null
                                  ? GestureDetector(
                                      onTap: () {
                                        ImageViewerHelper.showBase64Image(
                                          context,
                                          message.imageUrl!,
                                        );
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.memory(
                                          base64Decode(message.imageUrl!),
                                          fit: BoxFit.cover,
                                          width: 200,
                                          height: 200,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                                return const CustomTextWidget(
                                                  text: 'Failed to load image',
                                                );
                                              },
                                        ),
                                      ),
                                    )
                                  : CustomTextWidget(
                                      text: message.message,
                                      color: isMe
                                          ? AppColors.white
                                          : AppColors.black,
                                      fontSize: 14,
                                    ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // 2. Message Input Field & Preview Section
            SafeArea(
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
                    if (selectedImagePath != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),

                              child: Image.memory(
                                base64Decode(selectedImagePath),
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: Center(
                                      child: Icon(
                                        Icons.error,
                                        color: Colors.red,
                                      ),
                                    ),
                                  );
                                },
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
                              onPressed: () {
                                ref
                                        .read(
                                          selectedImagePathProvider.notifier,
                                        )
                                        .state =
                                    null;
                              },
                            ),
                          ],
                        ),
                      ),

                    // Input Row
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            final source = await ImageSourceDialog.show(
                              context,
                            );
                            if (source == null) return;
                            String? imagePath;
                            if (source == ImageSourceType.gallery) {
                              imagePath =
                                  await ImagePickerHelper.pickAndConvertImageFromGallery();
                            } else if (source == ImageSourceType.camera) {
                              imagePath =
                                  await ImagePickerHelper.pickAndConvertImageFromCamera();
                            }

                            if (imagePath != null) {
                              ref
                                      .read(selectedImagePathProvider.notifier)
                                      .state =
                                  imagePath;
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
                          onTap: () => _sendMessage(ref, chatRoomId),
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
            ),
          ],
        ),
      ),
    );
  }
}
