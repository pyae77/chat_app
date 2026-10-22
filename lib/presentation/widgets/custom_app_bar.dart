import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? leading;
  final Widget? middleWidget;
  final String? trailing;
  final VoidCallback? leadingPressed;
  final VoidCallback? trailingAction;

  const CustomAppBar({
    super.key,
    this.leading,
    this.middleWidget,
    this.trailing,
    this.leadingPressed,
    this.trailingAction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
        leading: leading != null
            ? InkWell(
    onTap: leadingPressed,
    borderRadius: BorderRadius.circular(20),
    child: Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
        
        
          Image.asset(
            leading!,
            height: 26, 
            width: 26,
            color: AppColors.primary,
          ),
        ],
      )))
            : null,
      
      
        title: middleWidget,
      
      
        actions: [
           if(trailing!=null)...[
            InkWell(
                onTap: trailingAction,
                child: Center(
                  
                  child: Image.asset(
                              trailing!,
                              height: 26, 
                              width: 26,
                              color: AppColors.primary,
                            ),
                ),
              ),
              const SizedBox(width: 16),
           ]
        ],
      
    );
  }
}