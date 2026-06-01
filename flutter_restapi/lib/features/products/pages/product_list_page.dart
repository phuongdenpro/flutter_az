import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/product_model.dart';

typedef ProductPageLoader = Future<List<ProductModel>> Function({required int page, required int pageSize});

typedef ProductTapCallback = void Function(ProductModel product);

class ProductListPage extends StatefulWidget {
  final List<ProductModel> products;
  final ProductTapCallback onTap;
  final ProductPageLoader loadPage;
  final int pageSize;

  const ProductListPage({
    super.key,
    required this.products,
    required this.onTap,
    required this.loadPage,
    this.pageSize = 10,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late List<ProductModel> _products;
  late int _page;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _products = List<ProductModel>.from(widget.products);
    _page = widget.products.isEmpty ? 1 : 2;
    _hasMore = widget.products.length == widget.pageSize;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant ProductListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.products, oldWidget.products)) {
      _products = List<ProductModel>.from(widget.products);
      _page = widget.products.isEmpty ? 1 : 2;
      _hasMore = widget.products.length == widget.pageSize;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newProducts = await widget.loadPage(page: _page, pageSize: widget.pageSize);
      if (!mounted) return;
      setState(() {
        _products.addAll(newProducts);
        _page++;
        _hasMore = newProducts.length == widget.pageSize;
      });
    } catch (_) {
      // Ignore load more errors and keep current list.
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_products.isEmpty) {
      return const Center(
        child: Text('Chưa có sản phẩm nào.', style: TextStyle(fontSize: 16, color: Colors.black54)),
      );
    }

    final crossAxisCount = MediaQuery.of(context).size.width > 700 ? 3 : 2;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _products.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final product = _products[index];
        return GestureDetector(
          onTap: () => widget.onTap(product),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.05), blurRadius: 12, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.black38)),
                            ),
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.black38)),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 10),
                      Text('${product.price} đ', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.indigo)),
                      const SizedBox(height: 6),
                      Text('Còn lại: ${product.quantity}', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
