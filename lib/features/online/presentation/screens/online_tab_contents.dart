import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_chat_app/features/people/presentation/providers/people_providers.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/chat_user_tile.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OnlineUsersTabContent extends ConsumerWidget {
  const OnlineUsersTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(onlineUsersProvider);
    final currentUserId = ref.watch(currentUserIdProvider) ?? '';
    final searchQuery = ref.watch(peopleSearchQueryProvider).toLowerCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Custom AppBar
        CustomAppBar(
          middleWidget: const CustomTextWidget(
            text: 'Online Users',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
          trailing: Assets.icons.icUser1.path,
          trailingAction: () {
            context.pushNamed(RouteNames.profileName);
          },
        ),

        // 2. Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomTextField(
            hintText: 'Search online users',
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
              ref.read(peopleSearchQueryProvider.notifier).state = value;
            },
          ),
        ),
        const SizedBox(height: 16),

        // 3. Online Users List View
        Expanded(
          child: usersState.isLoading && usersState.users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : usersState.errorMessage != null && usersState.users.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextWidget(
                        text: usersState.errorMessage!,
                        color: AppColors.error,
                      ),
                      TextButton(
                        onPressed: () => ref
                            .read(onlineUsersProvider.notifier)
                            .fetchInitialPeople(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Builder(
                  builder: (context) {
                    final filteredUsers = usersState.users.where((user) {
                      final nameMatch = user.name.toLowerCase().contains(
                        searchQuery,
                      );
                      final emailMatch = user.email.toLowerCase().contains(
                        searchQuery,
                      );
                      return user.uid != currentUserId &&
                          user.isOnline &&
                          (nameMatch || emailMatch);
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomTextWidget(
                              text: searchQuery.isEmpty
                                  ? 'No online users found.'
                                  : 'No matching online users found.',
                            ),
                            if (usersState.hasMore)
                              TextButton(
                                onPressed: () => ref
                                    .read(onlineUsersProvider.notifier)
                                    .loadMore(),
                                child: const Text('Load more'),
                              ),
                          ],
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        if (notification.metrics.maxScrollExtent == 0 ||
                            notification.metrics.pixels >=
                                notification.metrics.maxScrollExtent * 0.8) {
                          ref.read(onlineUsersProvider.notifier).loadMore();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        itemCount:
                            filteredUsers.length +
                            (usersState.hasMore ||
                                    usersState.isLoadingMore ||
                                    usersState.errorMessage != null
                                ? 1
                                : 0),
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          if (index >= filteredUsers.length) {
                            if (usersState.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return TextButton(
                              onPressed: () => ref
                                  .read(onlineUsersProvider.notifier)
                                  .loadMore(),
                              child: Text(
                                usersState.errorMessage ?? 'Load more users',
                              ),
                            );
                          }

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
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
