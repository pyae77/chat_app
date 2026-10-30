import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/core/entities/chat_user_entity.dart';
import 'package:flutter_chat_app/core/routes/auth_redirect_guard.dart';
import 'package:flutter_chat_app/core/routes/route_names.dart';
import 'package:flutter_chat_app/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_chat_app/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_chat_app/features/chat/presentation/screens/chat_room_screen.dart';
import 'package:flutter_chat_app/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_chat_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_chat_app/presentation/screens/splash_screen.dart';
import 'package:flutter_chat_app/presentation/widgets/custom_text_widget.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.splash,
    // refresh go router when state change
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),

    routes: <RouteBase>[
      GoRoute(
        path: RouteNames.splash,
        name: RouteNames.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        name: RouteNames.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        name: RouteNames.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        name: RouteNames.homeName,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.chatroom,
        name: RouteNames.chatroomName,
        builder: (context, state) {
          final targetUser = state.extra as ChatUserEntity;

          return ChatRoomScreen(targetUser: targetUser);
        },
      ),
      GoRoute(
        path: RouteNames.profile,
        name: RouteNames.profileName,
        builder: (context, state) {
          return const ProfileScreen();
        },
      ),
    ],
    redirect: (context, state) {
      if (AuthRedirectGuard.isRegistrationInProgress) {
        return null;
      }

      final user = FirebaseAuth.instance.currentUser;

      if (state.matchedLocation == RouteNames.register) {
        return null;
      }

      final isAuthRoute =
          state.matchedLocation == RouteNames.login ||
          state.matchedLocation == RouteNames.splash;

      // if user already logged in ,go to home
      if (user != null && isAuthRoute) {
        return RouteNames.home;
      }

      // if user trying to go to home without loggin in
      if (user == null && !isAuthRoute) {
        return RouteNames.login;
      }

      return null;
    },
    errorBuilder: (context, state) {
      return const Scaffold(
        body: Center(child: CustomTextWidget(text: 'Page Not Found')),
      );
    },
  );
}

// Helper class to use go router with stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
