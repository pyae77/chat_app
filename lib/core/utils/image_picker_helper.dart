import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();


  static Future<String?> pickAndConvertImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, 
      );
      
      if (image == null) return null;

      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> pickAndConvertImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      
      if (image == null) return null;

      final bytes = await File(image.path).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }
}