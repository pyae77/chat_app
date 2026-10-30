import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_app_bar.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_button.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_textfield.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  // Photo Picker and Base64 Encoder Logic
  Future<void> _pickAndUploadImage(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // Optimize Base64 size
      maxWidth: 600,
    );

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64String = base64Encode(bytes);

      final currentProfile = ref.read(userProfileStreamProvider).value;
      if (currentProfile != null) {
        ref
            .read(profileControllerProvider.notifier)
            .updateProfile(
              name: currentProfile.name,
              bio: currentProfile.bio,
              photoBase64: base64String,
            );
      }
    }
  }

  // Bottom Sheet for Editing Name and Bio
  void _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    String currentName,
    String currentBio,
  ) {
    final nameController = TextEditingController(text: currentName);
    final bioController = TextEditingController(text: currentBio);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomTextWidget(
                text: 'Edit Profile',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              CustomTextField(controller: nameController, hintText: 'name'),
              const SizedBox(height: 12),
              CustomTextField(
                controller: bioController,
                maxlines: 4,
                hintText: 'bio',
              ),
              const SizedBox(height: 20),
              CustomButton(
                buttonWidth: double.infinity,
                textColor: AppColors.white,
                text: 'Save  Changes',
                onPressed: () {
                  context.pop();
                  ref
                      .read(profileControllerProvider.notifier)
                      .updateProfile(
                        name: nameController.text.trim(),
                        bio: bioController.text.trim(),
                      );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final profileState = ref.watch(profileControllerProvider);
    final isLoggingOut =
        profileState.isLoading &&
        ref.read(profileControllerProvider.notifier).isSigningOut;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        middleWidget: CustomTextWidget(
          text: 'Profile',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.accent,
        ),
        leading: Assets.icons.icArrowLeft.path,
        leadingPressed: () {
          context.pop();
        },
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) =>
            Center(child: CustomTextWidget(text: 'Error: $err')),
        data: (profile) {
          if (profile == null)
            return const Center(
              child: CustomTextWidget(text: 'User not found'),
            );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 1. Profile Avatar with Edit Camera Overlay
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        backgroundImage:
                            profile.photoBase64 != null &&
                                profile.photoBase64!.trim().isNotEmpty
                            ? MemoryImage(base64Decode(profile.photoBase64!))
                            : null,
                        child:
                            profile.photoBase64 == null ||
                                profile.photoBase64!.trim().isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 54,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () => _pickAndUploadImage(context, ref),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.primary,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Name & Bio Display with Quick Edit
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextWidget(
                      text: profile.name,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showEditProfileDialog(
                        context,
                        ref,
                        profile.name,
                        profile.bio,
                      ),
                      child: Image.asset(
                        Assets.icons.icEdit.path,
                        height: 24,
                        width: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                CustomTextWidget(
                  text: profile.bio,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                // 2. Info Cards
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Email Display
                      ListTile(
                        leading: Image.asset(
                          Assets.icons.icMail.path,
                          width: 24,
                          height: 24,
                          color: AppColors.buttonBackground,
                        ),
                        title: const CustomTextWidget(
                          text: 'Email',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        subtitle: CustomTextWidget(
                          text: profile.email,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(height: 1),

                      // Online / Presence Toggle Switch
                      SwitchListTile(
                        value: profile.isOnline,
                        activeColor: AppColors.primary,
                        title: const CustomTextWidget(
                          text: 'Online Status',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        subtitle: CustomTextWidget(
                          text: profile.isOnline
                              ? 'Visible as Online'
                              : 'Appears Offline',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        secondary: Icon(
                          Icons.circle,
                          color: profile.isOnline ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        onChanged: (val) {
                          ref
                              .read(profileControllerProvider.notifier)
                              .toggleOnlineStatus(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. App Settings Section
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Image.asset(
                          Assets.icons.icNotification.path,
                          height: 24,
                          width: 24,
                        ),
                        title: const CustomTextWidget(
                          text: 'Notifications',
                          fontSize: 15,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: Image.asset(
                          Assets.icons.icLock.path,
                          height: 24,
                          width: 24,
                          color: AppColors.black,
                        ),
                        title: const CustomTextWidget(
                          text: 'Privacy & Security',
                          fontSize: 15,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Logout Button
                CustomButton(
                  text: isLoggingOut ? 'Logging out...' : 'Log Out',
                  onPressed: isLoggingOut
                      ? null
                      : () async {
                          await ref
                              .read(profileControllerProvider.notifier)
                              .signOut();

                          final signOutState = ref.read(
                            profileControllerProvider,
                          );
                          if (context.mounted && !signOutState.hasError) {
                            context.go(RouteNames.login);
                          }
                        },
                  icon: Assets.icons.icLogOut.path,
                  textColor: AppColors.white,
                  backgroundColor: AppColors.neutralRed,
                  iconColor: AppColors.white,
                  spacing: 12,
                  buttonWidth: double.infinity,

                  child: isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
