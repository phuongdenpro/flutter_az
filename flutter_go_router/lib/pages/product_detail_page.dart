import 'package:flutter/material.dart';
import 'package:flutter_go_router/models/product.dart';
import 'package:go_router/go_router.dart';

class ProductDetailPage
    extends StatelessWidget {

  final Product product;

  const ProductDetailPage({
    super.key,
    required this.product,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(product.name),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,

          children: [

            Center(
              child:
                  Image.asset(
                product.image,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(
              product.name,
              style:
                  const TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              '${product.price} VNĐ',
              style:
                  const TextStyle(
                fontSize: 22,
                color:
                    Colors.red,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                // Xử lý logic mua hàng ở đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mua hàng thành công!'),
                    
                  ),
                );
                context.pop();
              },
              child: const Text(
                'Mua ngay',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.amber,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text(
                'Back to Product Page',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}