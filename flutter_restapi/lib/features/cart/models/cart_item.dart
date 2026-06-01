import 'package:flutter_restapi/features/products/domain/entities/product_entity.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get totalPrice => product.price * quantity.toDouble();
}
