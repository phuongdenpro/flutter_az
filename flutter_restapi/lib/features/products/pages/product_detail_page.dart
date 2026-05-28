import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../products/models/product_model.dart';
import '../../products/services/product_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../cart/services/cart_service.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/loading_widget.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductService _productService;
  late Future<ProductModel> _futureProduct;
  int _selectedQuantity = 1;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(ApiClient(TokenStorage()));
    _futureProduct = _productService.getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel>(
      future: _futureProduct,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết sản phẩm'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            body: const LoadingWidget(message: 'Đang tải chi tiết...'),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Chi tiết sản phẩm'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/home');
                  }
                },
              ),
            ),
            body: AppErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _futureProduct = _productService.getProductById(
                    widget.productId,
                  );
                });
              },
            ),
          );
        }

        final product = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chi tiết sản phẩm'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () async {
                  final text =
                      '${product.name}\nGiá: ${product.price} đ\n${product.imageUrl ?? ''}';
                  await Clipboard.setData(ClipboardData(text: text));
                  if (!mounted) return;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thông tin sản phẩm đã được sao chép'),
                      ),
                    );
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => context.push('/cart'),
                
              //   onPressed: product.quantity > 0
              //       ? () {
              //           CartService().addToCart(product, _selectedQuantity);
              //           if (mounted) {
              //             ScaffoldMessenger.of(context).showSnackBar(
              //               SnackBar(content: Text('Đã thêm $_selectedQuantity sản phẩm vào giỏ hàng')),
              //             );
              //           }
              //         }
              //       : null,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child:
                      product.imageUrl != null && product.imageUrl!.isNotEmpty
                      ? Image.network(
                          product.imageUrl!,
                          height: 300,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 70,
                              color: Colors.black38,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${product.price} đ',
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.indigo,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Số lượng còn lại: ${product.quantity}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                const SizedBox(height: 16),
                const Text(
                  'Mô tả',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                const Text('Số lượng thêm vào giỏ hàng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _selectedQuantity > 1
                          ? () => setState(() => _selectedQuantity--) 
                          : null,
                    ),
                    Text('$_selectedQuantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _selectedQuantity < product.quantity
                          ? () => setState(() => _selectedQuantity++)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào giỏ hàng'),
                        onPressed: product.quantity > 0
                            ? () {
                                CartService().addToCart(product, _selectedQuantity);
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã thêm $_selectedQuantity sản phẩm vào giỏ hàng')),
                                  );
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
