import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_chat_app/features/home/presentation/providers/home_providers.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/chat_user_tile.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ChatsTabContent extends ConsumerWidget {
  const ChatsTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatUsersAsync = ref.watch(chatUsersStreamProvider);
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomAppBar(
         middleWidget: CustomTextWidget(text: 'Chats',fontSize: 24,fontWeight: FontWeight.w600,color: AppColors.accent,),
         trailing: Assets.icons.icUser1.path,
         trailingAction: () {
           
           context.pushNamed(RouteNames.profileName);
         },
        ),
        // Search Bar Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomTextField(
            hintText: 'Search users / conversations',
            radius: 30.0,
            fillColor: AppColors.surface,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                Assets.icons.icSearch.path,
                width: 16,
                height: 16,
                color: AppColors.iconSecondary,
              ),
            ),
            onChanged: (value) {
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),
        const SizedBox(height: 16),

        // Chat List View
        Expanded(
          child: chatUsersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: CustomTextWidget(text: 'Error: $error', color: AppColors.error),
            ),
            data: (eitherResult) {
              return eitherResult.fold(
                ifLeft: (failure) => Center(child: CustomTextWidget(text: failure.message, color: AppColors.error)),
                ifRight: (users) {
                  final filteredUsers = users.where((user) {
              final nameMatch = user.name.toLowerCase().contains(searchQuery);
              final emailMatch = user.email.toLowerCase().contains(searchQuery);
              return nameMatch || emailMatch;
            }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(child: CustomTextWidget(text: 'No conversations found.'));
                  }

                  return ListView.builder(
                    itemCount: filteredUsers.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      return ChatUserTile(
                        user: user,
                        onTap: () {
                          context.pushNamed(
                          RouteNames.chatroomName,
                          extra: user, 
                        );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}


