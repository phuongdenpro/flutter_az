import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../../products/pages/product_list_page.dart';
import '../../profile/services/profile_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProductService _productService;
  late final ProfileService _profileService;
  late Future<List<ProductModel>> _futureProducts;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiClient(TokenStorage()));
    _profileService = ProfileService(ApiClient(TokenStorage()));
    _futureProducts = _productService.getProducts();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final user = await _profileService.getMe();
      if (!mounted) return;
      setState(() {
        _isAdmin = user.role.toLowerCase() == 'admin';
      });
    } catch (_) {
      // ignore errors and keep non-admin view
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureProducts = _productService.getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.manage_accounts),
              onPressed: () => context.go('/manage'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<ProductModel>>(
          future: _futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingWidget(message: 'Đang tải sản phẩm...');
            }
            if (snapshot.hasError) {
              return AppErrorWidget(
                message: snapshot.error.toString(),
                onRetry: _refresh,
              );
            }
            final products = snapshot.data ?? [];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Text('Danh sách sản phẩm', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ProductListPage(
                    products: products,
                    onTap: (product) {
                      context.push('/product/${product.id}');
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
