import 'package:flutter/material.dart';
import 'package:flutter_chat_app/gen/fonts.gen.dart';

class AppTypography {
  static TextStyle fredoka({double fontSize=14,FontWeight fontWeight=FontWeight.normal,Color? color}){
    return TextStyle(
      fontFamily: FontFamily.fredoka,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color
    );
  }

  static TextStyle get bold=>fredoka(fontWeight: FontWeight.bold);
  static TextStyle get semiBold=>fredoka(fontWeight: FontWeight.w600);
  static TextStyle get medium => fredoka(fontWeight: FontWeight.w500);
  static TextStyle get regular => fredoka(fontWeight: FontWeight.normal);
  
}
