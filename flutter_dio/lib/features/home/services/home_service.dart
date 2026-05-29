import 'dart:convert';

import 'package:flutter_dio/features/home/models/product.dart';
import 'package:http/http.dart' as http;

class HomeService {
  // Simulate fetching data from an API
  Future<List<ProductModel>> fetchHomeData() async {
    final response = await http.get(
    Uri.parse(
      'https://fakestoreapi.com/products',
    ),
  );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(response.body);

      return jsonData
          .map((item) => ProductModel.fromJson(item))
          .toList();
    }

    throw Exception('Failed to load products');
  }
}