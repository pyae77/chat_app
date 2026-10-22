import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/utils/ui_helpers.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class GalleryHelper {

  static Future<void> saveBase64ImageToGallery(BuildContext context, String base64String) async {
    try {
    
      bool hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

     
      final bytes = base64Decode(base64String);

  
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/chat_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final file = File(filePath);
      await file.writeAsBytes(bytes);

    
      await Gal.putImage(file.path);

      if (context.mounted) {
        UIHelpers.showSnackBar(context, 'Image saved to gallery successfully!');
      }
    } catch (e) {
      if (context.mounted) {
        UIHelpers.showSnackBar(context, 'Failed to save image: $e');
      }
    }
  }
}