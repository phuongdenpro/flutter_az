import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_restapi/app/router/route_paths.dart';
import 'package:flutter_restapi/config/app_constants.dart';
import 'package:flutter_restapi/core/di/app_dependencies.dart';
import 'package:flutter_restapi/core/theme/app_colors.dart';
import 'package:flutter_restapi/features/products/data/services/product_service.dart';
import 'package:flutter_restapi/features/products/domain/entities/product_entity.dart';
import 'package:flutter_restapi/features/products/presentation/widgets/product_grid_view.dart';
import 'package:flutter_restapi/shared/widgets/error_widget.dart';
import 'package:flutter_restapi/shared/widgets/loading_widget.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final ProductService _productService;
  late Future<List<ProductEntity>> _futureProducts;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _productService = ProductService(AppDependencies.instance.apiClient);
    _loadProducts();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _futureProducts = _productService.getProducts(page: 1, pageSize: AppConstants.defaultPageSize);
  }

  Future<void> _refresh() async {
    setState(_loadProducts);
    await _futureProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Danh mục', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('Khám phá toàn bộ sản phẩm', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, mô tả...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<ProductEntity>>(
                  future: _futureProducts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingWidget(message: 'Đang tải danh mục...');
                    }
                    if (snapshot.hasError) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height * 0.5,
                            child: AppErrorWidget(
                              message: snapshot.error.toString(),
                              onRetry: _refresh,
                            ),
                          ),
                        ],
                      );
                    }

                    return ProductGridView(
                      products: snapshot.data ?? [],
                      searchQuery: _searchQuery,
                      onTap: (p) => context.push(RoutePaths.product(p.id)),
                      loadPage: ({required page, required pageSize}) =>
                          _productService.getProducts(page: page, pageSize: pageSize),
                      pageSize: AppConstants.defaultPageSize,
                      shrinkWrap: false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
