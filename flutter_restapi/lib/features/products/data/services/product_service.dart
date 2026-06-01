import 'dart:io';

import 'package:dio/dio.dart';

import 'package:flutter_restapi/core/network/api_client.dart';
import 'package:flutter_restapi/features/products/domain/entities/product_entity.dart';

class ProductService {
  final ApiClient client;

  ProductService(this.client);

  Future<List<ProductEntity>> getProducts({
    required int page,
    required int pageSize,
  }) async {
    try {
      final response = await client.dio.get(
        '/admin/products',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      final responseData = response.data;

      List<dynamic> items = [];
      if (responseData is List) {
        items = responseData;
      } else if (responseData is Map<String, dynamic> && responseData['data'] is List) {
        items = responseData['data'] as List<dynamic>;
      } else {
        return <ProductEntity>[];
      }

      return items.map((item) => ProductEntity.fromJson(item as Map<String, dynamic>)).toList();
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductEntity> getProductById(int id) async {
    try {
      final response = await client.dio.get('/admin/products/$id');
      return ProductEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductEntity> createProduct({
    required String name,
    required String description,
    required int price,
  }) async {
    try {
      final response = await client.dio.post(
        '/admin/products',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'quantity': 1,
        },
      );
      return ProductEntity.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<ProductEntity> updateProduct({
    required int id,
    required String name,
    required String description,
    required int price,
  }) async {
    try {
      final response = await client.dio.put(
        '/admin/products/$id',
        data: {
          'name': name,
          'description': description,
          'price': price,
          'quantity': 1,
        },
      );
      return ProductEntity.fromJson(response.data as Map<String, dynamic>);
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
      final fileName = image.path.split(Platform.pathSeparator).last;
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
