import 'package:flutter/material.dart';
import 'package:flutter_dio/features/auth/pages/edit_profile_page.dart';
import 'package:flutter_dio/features/auth/pages/profile_page.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/home_page.dart';

import '../storage/token_storage.dart';

class AppRouter {
  static GoRouter createRouter(TokenStorage tokenStorage) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: tokenStorage.authNotifier,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const ProductPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfilePage(),
        ),
    
      ],
      redirect: (context, state) {
        final signedIn = tokenStorage.authNotifier.value;
        final loggingIn = state.location == '/login' || state.location == '/register';

        if (!signedIn && !loggingIn) {
          return '/login';
        }
        if (signedIn && loggingIn) {
          return '/home';
        }
        return null;
      },
    );
  }
}
