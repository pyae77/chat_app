
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';

class NotificationTabContent extends StatelessWidget {
  const NotificationTabContent({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CustomTextWidget(text: 'Notifications Screen', fontSize: 18));
  }
}
