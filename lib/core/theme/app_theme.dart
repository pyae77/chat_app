// lib/core/theme/app_theme.dart


import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_typography.dart';



class AppTheme {
  // Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: Colors.white,

     
      textTheme: TextTheme(
        displayLarge: AppTypography.bold.copyWith(fontSize: 32),
        titleLarge: AppTypography.semiBold.copyWith(fontSize: 20),
        bodyLarge: AppTypography.regular.copyWith(fontSize: 16),
        bodyMedium: AppTypography.medium.copyWith(fontSize: 14),
      ),

     
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: AppTypography.bold.copyWith(
          fontSize: 18,
          color: Colors.black,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: AppTypography.medium.copyWith(fontSize: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  
  static ThemeData get darkTheme {
    return lightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
    );
  }
}