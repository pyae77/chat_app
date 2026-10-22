import 'package:flutter/material.dart';

class CustomLoadingBar extends StatelessWidget {
  final double progress; 

  const CustomLoadingBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 12,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      alignment: Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth * progress,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.6),
                  blurRadius: 6,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}