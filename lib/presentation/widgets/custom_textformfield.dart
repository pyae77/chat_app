import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';
import 'package:flutter_chat_app/gen/assets.gen.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;

  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;

  final double? borderWidth;
  final double? radius;
  final bool obscureText;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.borderWidth,
    this.radius,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final double defaultRadius = radius ?? 18.0;
    final double defaultBorderWidth = borderWidth ?? 1.0;

    OutlineInputBorder buildBorder(Color color, [double? width]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: BorderSide(
          color: color,
          width: width ?? defaultBorderWidth,
        ),
      );
    }

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      style: TextStyle(
        color: AppColors.black,
        fontFamily: Assets.fonts.fredokaMedium,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: prefixIcon),
        suffixIcon: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: suffixIcon),
        filled: true,
        fillColor: fillColor ?? const Color.fromARGB(255, 230, 230, 236),
        labelStyle: TextStyle(
          color: AppColors.grey1,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: AppColors.grey1,
          fontFamily: Assets.fonts.fredokaMedium,
          fontSize: 14,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 24,
          maxWidth: 40,
          maxHeight: 24,
        ),
        errorStyle: TextStyle(
          color: AppColors.neutralRed,
          fontFamily: Assets.fonts.fredokaMedium,
          fontSize: 12,
        ),
        enabledBorder: buildBorder(Colors.transparent),
        focusedBorder: buildBorder(AppColors.primaryGreen, 1.5),
        errorBorder: buildBorder(AppColors.neutralRed),
        focusedErrorBorder: buildBorder(AppColors.neutralRed, 1.5),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}