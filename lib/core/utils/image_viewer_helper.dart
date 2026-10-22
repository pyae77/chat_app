import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/core/utils/gallery_helper.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart'; 
import 'package:go_router/go_router.dart';

class ImageViewerHelper {
  // showing base64 with full screen
  static void showBase64Image(BuildContext context, String base64String) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9), // bg black
      builder: (context) => _FullScreenImageViewer(
        imageWidget: Image.memory(
          base64Decode(base64String),
          fit: BoxFit.contain,
        ),
        base64String: base64String, 
      ),
    );
  }
  static void showNetworkImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) => _FullScreenImageViewer(
        imageWidget: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
      ),
    );
  }
}

// Internal FullScreen Dialog Widget (included Zoom & Pan support)
class _FullScreenImageViewer extends StatelessWidget {
  final Widget imageWidget;
  final String? base64String; 

  const _FullScreenImageViewer({
    required this.imageWidget,
    this.base64String,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // pinch to zoom with interactive viewer
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: imageWidget,
              ),
            ),
          ),

         
          if (base64String != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              right: 60, 
              child: InkWell(
                onTap: () {
                   GalleryHelper.saveBase64ImageToGallery(context, base64String!);
                },
                child: Image.asset(Assets.icons.icDownloads.path,color: AppColors.white,height: 20,width: 20,))
            ),

        
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: InkWell(
              onTap: () {
                context.pop();
              },
              child: Image.asset(Assets.icons.icCross.path,color: AppColors.white,height: 16,width: 16,))
          ),
        ],
      ),
    );
  }
}