import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; 
import '../../../../core/routes/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../presentation/widgets/custom_text_widget.dart';
import '../../../../gen/assets.gen.dart';
import '../widgets/custom_loading_bar.dart'; 

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward().whenComplete(() {
      if (!mounted) return;
      
     
      context.go(RouteNames.login); 
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Assets.images.splash.image(
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                CustomTextWidget(
                  text: 'Chat with your friends',
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppColors.white,
                ),
                SizedBox(height: 20),
                CustomTextWidget(
                  text: 'Simple.Safe.Secure.Connection',
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 30,
            right: 30,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomLoadingBar(progress: _controller.value);
              },
            ),
          ),
        ],
      ),
    );
  }
}