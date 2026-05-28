import 'package:flutter/material.dart';

import '../models/product_model.dart';

class ProductListPage extends StatelessWidget {
  final List<ProductModel> products;
  final void Function(ProductModel) onTap;

  const ProductListPage({super.key, required this.products, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Center(
        child: Text('Chưa có sản phẩm nào.', style: TextStyle(fontSize: 16, color: Colors.black54)),
      );
    }

    final crossAxisCount = MediaQuery.of(context).size.width > 700 ? 3 : 2;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.7,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () => onTap(product),
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
