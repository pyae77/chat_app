
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

class OnlineTabContent extends StatelessWidget {
  const OnlineTabContent({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CustomTextWidget(text: 'Online Users Screen', fontSize: 18));
  }
}