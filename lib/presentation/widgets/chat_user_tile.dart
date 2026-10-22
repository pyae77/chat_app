import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

class ChatUserTile extends StatelessWidget {
  final ChatUserEntity user;
  final VoidCallback onTap;

  const ChatUserTile({
    super.key,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user.photoUrl != null && user.photoUrl!.isNotEmpty;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
     ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage: hasPhoto ? NetworkImage(user.photoUrl!) : null,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: !hasPhoto
                  ? CustomTextWidget(
                      text: user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    )
                  : null,
            ),
            if (user.isOnline)
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
          text: user.name.isNotEmpty ? user.name : 'No Name',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: CustomTextWidget(
            text: user.email,
            color: AppColors.textSecondary,
            fontSize: 13,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          Icons.circle,
          color: user.isOnline ? AppColors.success : AppColors.iconInactive,
          size: 12,
        ),
        onTap: onTap,
      ),
    );
  }
}