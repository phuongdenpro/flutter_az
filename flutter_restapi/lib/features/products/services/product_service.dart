import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../models/product_model.dart';

class ProductService {
  final ApiClient client;

  ProductService(this.client);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await client.dio.get('/admin/products');
      final responseData = response.data;

      // Support two possible response formats:
      // 1) A plain JSON array: [ {..}, {..} ]
      // 2) A paginated object: { ..., "data": [ {..}, {..} ] }
      List<dynamic> items = [];
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map<String, dynamic> && responseData['data'] is List) {
        items = responseData['data'] as List<dynamic>;
      } else {
        // Unexpected format - return empty list to avoid crash
        return <ProductModel>[];
      }

      return items.map((item) => ProductModel.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductModel> getProductById(int id) async {
    try {
      final response = await client.dio.get('/admin/products/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductModel> createProduct({required String name, required String description, required int price}) async {
    try {
      final response = await client.dio.post(
        '/admin/products',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'quantity': 1, // quantity is not editable in this form, so we can just pass a dummy value
        },
      );
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductModel> updateProduct({required int id, required String name, required String description, required int price}) async {
    try {
      final response = await client.dio.put(
        '/admin/products/$id',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'quantity': 1, // quantity is not editable in this form, so we can just pass a dummy value
        },
      );
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await client.dio.delete('/admin/products/$id');
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<void> uploadProductImage({required int productId, required File image}) async {
    try {
      final fileName = image.path.split('/').last;
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(image.path, filename: fileName),
      });
      await client.dio.post('/admin/products/$productId/upload-image', data: formData);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  String _extractError(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      return error.response?.data['message']?.toString() ?? error.message ?? 'Lỗi kết nối máy chủ';
    }
    return error.message ?? 'Lỗi kết nối máy chủ';
  }
}
