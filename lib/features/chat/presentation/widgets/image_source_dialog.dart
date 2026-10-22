import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

enum ImageSourceType { gallery, camera }

class ImageSourceDialog extends StatelessWidget {
  const ImageSourceDialog({super.key});

  
  static Future<ImageSourceType?> show(BuildContext context) {
    return showModalBottomSheet<ImageSourceType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ImageSourceDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const CustomTextWidget(
            text: 'Send Image',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          // 1. Gallery Option
          ListTile(
            leading: Card(
              elevation: 0,
              child: 
              Image.asset(Assets.icons.icGallery.path, color: AppColors.accent,height: 24,width: 24,),
            ),
            title: const CustomTextWidget(text: 'Choose from Gallery', fontSize: 16),
            onTap: () => Navigator.pop(context, ImageSourceType.gallery),
          ),
          const Divider(height: 1),
          // 2. Camera Option
          ListTile(
            leading: Card(
              elevation: 0,
              
              child: Image.asset(Assets.icons.icPhotoCamera.path, color: AppColors.accent,height: 24,width: 24,),
            ),
            title: const CustomTextWidget(text: 'Take a Photo', fontSize: 16),
            onTap: () => Navigator.pop(context, ImageSourceType.camera),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}