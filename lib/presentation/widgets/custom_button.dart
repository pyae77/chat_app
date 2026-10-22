import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

class CustomButton extends StatelessWidget {
  final Color? backgroundColor;
  final String? text;
  final Color? textColor;
  final String? icon;
  final double? borderRadius;
  final FontWeight? textWeight;
  final double? fontSize;
  final String? border;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double? spacing;
  final double? iconWidth;
  final double? iconHeight;
  final double? buttonHeight;
  final double? buttonWidth;
  final Widget? child; 

  const CustomButton({
    super.key,
    this.backgroundColor,
    this.text,
    this.textColor,
    this.icon,
    this.borderRadius,
    this.textWeight,
    this.fontSize,
    this.border,
    this.onPressed,
    this.iconColor,
    this.spacing,
    this.iconWidth,
    this.iconHeight,
    this.buttonHeight,
    this.buttonWidth,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.buttonBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
          padding: EdgeInsets.zero,
        ),
      
        child: child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (text != null) ...[
                  CustomTextWidget(
                    text: text!,
                    color: textColor ?? AppColors.textPrimary,
                    fontWeight: textWeight ?? FontWeight.w500,
                    fontSize: fontSize ?? 15,
                  )
                ],
                if (spacing != null) ...[
                  SizedBox(width: spacing ?? 0)
                ],
                if (icon != null) ...[
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Image.asset(
                      icon ?? '',
                      color: iconColor,
                      height: iconHeight,
                      width: iconWidth,
                    ),
                  )
                ]
              ],
            ),
      ),
    );
  }
}