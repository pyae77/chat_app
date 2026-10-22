import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/core/utils/ui_helpers.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/chat_user_tile.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/people_providers.dart';

class PeopleTabContent extends ConsumerWidget {
  const PeopleTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peopleState = ref.watch(peopleProvider);
    final searchQuery = ref.watch(peopleSearchQueryProvider).toLowerCase();

    final filteredUsers = peopleState.users.where((user) {
      final nameMatch = user.name.toLowerCase().contains(searchQuery);
      final emailMatch = user.email.toLowerCase().contains(searchQuery);
      return nameMatch || emailMatch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Custom AppBar
        CustomAppBar(
          middleWidget: const CustomTextWidget(
            text: 'People',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
          trailing: Assets.icons.icUser1.path,
        ),

        // 2. Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: CustomTextField(
            hintText: 'Search people',
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

        // 3. People List View with NotificationListener (No ScrollController needed!)
        Expanded(
          child: peopleState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : peopleState.errorMessage != null
                  ? Center(child: CustomTextWidget(text: peopleState.errorMessage!, color: AppColors.error))
                  : filteredUsers.isEmpty
                      ? const Center(child: CustomTextWidget(text: 'No people found.'))
                      : NotificationListener<ScrollNotification>(
                          onNotification: (scrollInfo) {
                            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                              ref.read(peopleProvider.notifier).loadMorePeople();
                            }
                            return false;
                          },
                          child:  ListView.builder(
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
                            ),
                        ),
        ),
      ],
    );
  }
}