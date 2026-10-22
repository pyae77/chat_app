import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ref.read(profileControllerProvider.notifier).updateProfile(
              name: currentProfile.name,
              bio: currentProfile.bio,
              photoBase64: base64String,
            );
      }
    }
  }

  // Bottom Sheet for Editing Name and Bio
  void _showEditProfileDialog(BuildContext context, WidgetRef ref, String currentName, String currentBio) {
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
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bioController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(profileControllerProvider.notifier).updateProfile(
                          name: nameController.text.trim(),
                          bio: bioController.text.trim(),
                        );
                  },
                  child: const CustomTextWidget(
                    text: 'Save Changes',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const CustomTextWidget(
          text: 'Profile',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const Center(child: Text('User not found'));

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
                        backgroundImage: profile.photoBase64 != null
                            ? MemoryImage(base64Decode(profile.photoBase64!))
                            : null,
                        child: profile.photoBase64 == null
                            ? const Icon(Icons.person, size: 54, color: AppColors.primary)
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
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
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
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                      onPressed: () => _showEditProfileDialog(context, ref, profile.name, profile.bio),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      // Email Display
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                        title: const CustomTextWidget(text: 'Email', fontSize: 12, color: AppColors.textSecondary),
                        subtitle: CustomTextWidget(text: profile.email, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const Divider(height: 1),

                      // Online / Presence Toggle Switch
                      SwitchListTile(
                        value: profile.isOnline,
                        activeColor: AppColors.primary,
                        title: const CustomTextWidget(text: 'Online Status', fontSize: 15, fontWeight: FontWeight.w600),
                        subtitle: CustomTextWidget(
                          text: profile.isOnline ? 'Visible as Online' : 'Appears Offline',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        secondary: Icon(
                          Icons.circle,
                          color: profile.isOnline ? Colors.green : Colors.grey,
                          size: 16,
                        ),
                        onChanged: (val) {
                          ref.read(profileControllerProvider.notifier).toggleOnlineStatus(val);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. App Settings Section
                Card(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_none_outlined, color: AppColors.iconSecondary),
                        title: const CustomTextWidget(text: 'Notifications', fontSize: 15),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock_outline, color: AppColors.iconSecondary),
                        title: const CustomTextWidget(text: 'Privacy & Security', fontSize: 15),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Logout Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const CustomTextWidget(
                      text: 'Log Out',
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {
                      ref.read(profileControllerProvider.notifier).signOut();
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}