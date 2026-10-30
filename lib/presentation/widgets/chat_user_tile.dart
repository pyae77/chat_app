import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/user_avatar.dart';
import 'package:flutter_chat_app/features/people/presentation/providers/people_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatUserTile extends ConsumerWidget {
  final ChatUserEntity user;
  final VoidCallback onTap;

  const ChatUserTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presence = ref
        .watch(userPresenceStreamProvider(user.uid))
        .asData
        ?.value;
    final currentUser = presence ?? user;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            UserAvatar.fromChatUser(currentUser),
            if (currentUser.isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: CustomTextWidget(
          text: currentUser.name.isNotEmpty ? currentUser.name : 'No Name',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: CustomTextWidget(
            text: currentUser.email,
            color: AppColors.textSecondary,
            fontSize: 13,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          Icons.circle,
          color: currentUser.isOnline
              ? AppColors.success
              : AppColors.iconInactive,
          size: 12,
        ),
        onTap: onTap,
      ),
    );
  }
}
