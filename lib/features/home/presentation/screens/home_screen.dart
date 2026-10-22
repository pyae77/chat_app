import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/utils/ui_helpers.dart';
import 'package:flutter_chat_app/features/chat/presentation/screens/chats_tab_contents.dart';
import 'package:flutter_chat_app/features/home/presentation/screens/notification_tab_contents.dart';
import 'package:flutter_chat_app/features/home/presentation/screens/online_tab_contents.dart';
import 'package:flutter_chat_app/features/people/presentation/screens/people_tab_contents.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/core/services/user_presence_service.dart'; 
import '../providers/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
 
  final _presenceService = UserPresenceService();

  @override
  void initState() {
    super.initState();
    _presenceService.initialize(); 
  }

  @override
  void dispose() {
    _presenceService.dispose(); 
    super.dispose();
  }

  static const List<Widget> _tabScreens = [
    ChatsTabContent(),
    PeopleTabContent(),
    OnlineTabContent(),
    NotificationTabContent(),
  ];

  @override
  Widget build(BuildContext context) {
    // getting current index from provider
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: IndexedStack(
              index: currentIndex,
              children: _tabScreens,
            ),
          ),
        ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          // update state when tab changes
          ref.read(bottomNavIndexProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.iconSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          // 1. Chats Tab
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icMessage.path,
                color: AppColors.iconSecondary,
              ),
            ),
            activeIcon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icMessage.path,
                color: AppColors.primary,
              ),
            ),
            label: 'Chats',
          ),

          BottomNavigationBarItem(
            icon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icPeople.path, 
                color: AppColors.iconSecondary,
              ),
            ),
            activeIcon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icPeople.path,
                color: AppColors.primary,
              ),
            ),
            label: 'People',
          ),
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icOnline.path, 
                color: AppColors.iconSecondary,
              ),
            ),
            activeIcon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icOnline.path,
                color: AppColors.primary,
              ),
            ),
            label: 'Online',
          ),
          
          BottomNavigationBarItem(
            icon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icNotification.path, 
                color: AppColors.iconSecondary,
              ),
            ),
            activeIcon: SizedBox(
              width: 22,
              height: 22,
              child: Image.asset(
                Assets.icons.icNotification.path,
                color: AppColors.primary,
              ),
            ),
            label: 'Notification',
          ),
        ],
      ),

      // to show floating button only in chat tab
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                UIHelpers.showSnackBar(context, 'Start New Chat clicked');
              },
              backgroundColor: AppColors.buttonBackground,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const CustomTextWidget(
                text: 'New Chat',
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          : null,
    );
  }
}