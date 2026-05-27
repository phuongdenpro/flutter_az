import 'package:flutter_go_router/config/data.dart';
import 'package:flutter_go_router/main.dart';
import 'package:flutter_go_router/pages/login_page.dart';
import 'package:flutter_go_router/pages/product_detail_page.dart';
import 'package:flutter_go_router/pages/product_page.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) =>
          const MyHomePage(title: 'Flutter Demo Home Page'),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: '/products',
      name: 'products',

      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return ProductPage(email: email);
      },
    ),

    GoRoute(
      path: '/product/:id',
      name: 'product',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        final product = products.firstWhere((item) => item.id == id);

        return ProductDetailPage(product: product);
      },
    ),
  ],
);
