import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final String? photoBase64;
  final String? photoUrl;
  final double radius;

  const UserAvatar({
    super.key,
    required this.name,
    this.photoBase64,
    this.photoUrl,
    this.radius = 26,
  });

  factory UserAvatar.fromChatUser(
    ChatUserEntity user, {
    double radius = 26,
  }) {
    return UserAvatar(
      name: user.name,
      photoBase64: user.photoBase64,
      photoUrl: user.photoUrl,
      radius: radius,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      backgroundImage: image,
      child: image == null
          ? CustomTextWidget(
              text: name.isNotEmpty ? name[0].toUpperCase() : 'U',
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.7,
            )
          : null,
    );
  }

  ImageProvider? _resolveImage() {
    final encoded = photoBase64?.trim();
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final payload = encoded.contains(',') ? encoded.split(',').last : encoded;
        return MemoryImage(base64Decode(payload));
      } catch (_) {
        // Fall through to URL / initials if the stored Base64 is invalid.
      }
    }

    final url = photoUrl?.trim();
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }

    return null;
  }
}
