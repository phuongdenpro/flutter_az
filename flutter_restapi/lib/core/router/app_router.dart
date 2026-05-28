import 'package:go_router/go_router.dart';

import '../../features/auth/pages/login_page.dart';
import '../../features/auth/pages/register_page.dart';
import '../../features/home/pages/home_page.dart';
import '../../features/products/pages/product_detail_page.dart';
import '../../features/products/pages/product_form_page.dart';
import '../../features/products/pages/product_management_page.dart';
import '../../features/cart/pages/cart_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/profile/pages/edit_profile_page.dart';
import '../../features/profile/pages/change_password_page.dart';
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
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final id = int.tryParse(state.params['id'] ?? '0') ?? 0;
            return ProductDetailPage(productId: id);
          },
        ),
        GoRoute(
          path: '/manage',
          builder: (context, state) => const ProductManagementPage(),
        ),
        GoRoute(
          path: '/cart',
          builder: (context, state) => const CartPage(),
        ),
        GoRoute(
          path: '/manage-form',
          builder: (context, state) => const ProductFormPage(),
        ),
        GoRoute(
          path: '/manage-form/:id',
          builder: (context, state) {
            final id = int.tryParse(state.params['id'] ?? '0') ?? 0;
            return ProductFormPage(productId: id);
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/profile/edit',
          builder: (context, state) => const EditProfilePage(),
        ),
        GoRoute(
          path: '/profile/change-password',
          builder: (context, state) => const ChangePasswordPage(),
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
