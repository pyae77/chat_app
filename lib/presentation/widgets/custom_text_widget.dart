import 'package:flutter/widgets.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/gen/fonts.gen.dart';
class CustomTextWidget extends StatelessWidget {
  final String text;

  // Optional overrides
  final String? fontFamily;
  final FontWeight? fontWeight;
  final Color? color;
  final double? fontSize;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? textHeight;

  // Layout / behavior
  final int? maxLines;
  final TextAlign? textAlign;
  final TextOverflow? overflow;

  const CustomTextWidget({super.key, required this.text, this.fontFamily, this.fontWeight, this.color, this.fontSize, this.letterSpacing, this.wordSpacing, this.textHeight, this.maxLines, this.textAlign, this.overflow});

  @override
  Widget build(BuildContext context) {
    return  Text(
      text,
      style: TextStyle(
      fontFamily: fontFamily?? FontFamily.fredoka,
       fontWeight: fontWeight ?? FontWeight.w400,
       color: color ?? AppColors.textPrimary,
       fontSize: fontSize?? 14,
       letterSpacing: letterSpacing ?? 0.0,
       wordSpacing: wordSpacing,
       height: textHeight ?? 1.2,
       
       
      ),
       overflow: overflow,
       textAlign: textAlign,
       maxLines: maxLines,
      
    );
  }
}