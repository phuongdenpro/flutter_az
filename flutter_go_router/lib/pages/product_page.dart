import 'package:flutter/material.dart';
import 'package:flutter_go_router/config/data.dart';
import 'package:flutter_go_router/models/product.dart';
import 'package:go_router/go_router.dart';

class ProductPage extends StatefulWidget {
   const ProductPage({super.key, required this.email});
   final String email;


  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Xin chào ${widget.email ?? ''}'),
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          const Text(
            'Danh sách sản phẩm',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                return ListTile(
                  title: Text(product.name!),
                  subtitle: Text('Giá: ${product.price} VNĐ'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.push('/product/${product.id}');
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.go('/');
            },
            child: const Text('Go to Home Page'),
          ),
        ],
      ),
    );
  }
}
