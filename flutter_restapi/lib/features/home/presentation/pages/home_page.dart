import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_restapi/app/router/route_paths.dart';
import 'package:flutter_restapi/config/app_constants.dart';
import 'package:flutter_restapi/core/di/app_dependencies.dart';
import 'package:flutter_restapi/core/notifiers/profile_refresh_notifier.dart';
import 'package:flutter_restapi/core/theme/app_colors.dart';
import 'package:flutter_restapi/features/cart/services/cart_service.dart';
import 'package:flutter_restapi/features/home/presentation/widgets/home_category_chips.dart';
import 'package:flutter_restapi/features/home/presentation/widgets/home_promo_banner.dart';
import 'package:flutter_restapi/features/home/presentation/widgets/home_quick_actions.dart';
import 'package:flutter_restapi/features/home/presentation/widgets/home_search_bar.dart';
import 'package:flutter_restapi/features/products/data/services/product_service.dart';
import 'package:flutter_restapi/features/products/domain/entities/product_entity.dart';
import 'package:flutter_restapi/features/profile/data/services/profile_service.dart';
import 'package:flutter_restapi/shared/widgets/error_widget.dart';
import 'package:flutter_restapi/shared/widgets/loading_widget.dart';
import 'package:flutter_restapi/shared/widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ProductService _productService;
  late final ProfileService _profileService;
  final CartService _cartService = CartService();
  final ScrollController _scrollController = ScrollController();

  final List<ProductEntity> _products = [];
  int _page = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool _isInitialLoading = true;
  String? _errorMessage;
  bool _isAdmin = false;
  String? _userName;

  @override
  void initState() {
    super.initState();
    final deps = AppDependencies.instance;
    _productService = ProductService(deps.apiClient);
    _profileService = ProfileService(deps.apiClient);
    _scrollController.addListener(_onScroll);
    ProfileRefreshNotifier.instance.tick.addListener(_onProfileChanged);
    _cartService.itemCountNotifier.addListener(_onCartUpdated);
    _loadInitial();
    _loadUser();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    ProfileRefreshNotifier.instance.tick.removeListener(_onProfileChanged);
    _cartService.itemCountNotifier.removeListener(_onCartUpdated);
    super.dispose();
  }

  void _onProfileChanged() {
    _loadUser();
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadUser() async {
    try {
      final user = await _profileService.getMe();
      if (!mounted) return;
      setState(() {
        _isAdmin = user.role.toLowerCase() == 'admin';
        _userName = user.fullName.split(' ').first;
      });
    } catch (_) {}
  }

  Future<void> _loadInitial() async {
    setState(() {
      _isInitialLoading = true;
      _errorMessage = null;
      _products.clear();
      _page = 1;
      _hasMore = true;
    });

    try {
      final items = await _productService.getProducts(
        page: 1,
        pageSize: AppConstants.defaultPageSize,
      );
      if (!mounted) return;
      setState(() {
        _products.addAll(items);
        _page = 2;
        _hasMore = items.length == AppConstants.defaultPageSize;
        _isInitialLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _isInitialLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore || _isInitialLoading) return;

    setState(() => _isLoadingMore = true);

    try {
      final newProducts = await _productService.getProducts(
        page: _page,
        pageSize: AppConstants.defaultPageSize,
      );
      if (!mounted) return;
      setState(() {
        _products.addAll(newProducts);
        _page++;
        _hasMore = newProducts.length == AppConstants.defaultPageSize;
      });
    } catch (_) {
      // Giữ danh sách hiện tại
    } finally {
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadInitial(), _loadUser()]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: LoadingWidget(message: 'Đang tải trang chủ...'),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: AppErrorWidget(message: _errorMessage!, onRetry: _refresh),
      );
    }

    final featured = _products.take(6).toList();
    final crossAxisCount = MediaQuery.sizeOf(context).width > 700 ? 4 : 2;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: RefreshIndicator(
        onRefresh: _refresh,
        edgeOffset: 120,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFEFF6FF), AppColors.surface],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Xin chào, ${_userName ?? 'bạn'} 👋',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: HomeSearchBar(),
              ),
            ),
            SliverToBoxAdapter(child: HomePromoBanner(productCount: _products.length)),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: HomeQuickActions(
                isAdmin: _isAdmin,
                cartCount: _cartService.itemCountNotifier.value,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            const SliverToBoxAdapter(child: HomeCategoryChips()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Nổi bật hôm nay',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go(RoutePaths.catalog),
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
              ),
            ),
            if (featured.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Chưa có sản phẩm nổi bật')),
                ),
              )
            else
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: featured.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (context, index) {
                      final product = featured[index];
                      return SizedBox(
                        width: 170,
                        child: ProductCard(
                          product: product,
                          onTap: () => context.push(RoutePaths.product(product.id)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: Text(
                  'Tất cả sản phẩm',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
              ),
            ),
            if (_products.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Chưa có sản phẩm')),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.72,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _products.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        );
                      }
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push(RoutePaths.product(product.id)),
                      );
                    },
                    childCount: _products.length + (_hasMore ? 1 : 0),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
