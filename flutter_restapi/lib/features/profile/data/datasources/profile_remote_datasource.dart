import 'package:dio/dio.dart';

import 'package:flutter_restapi/core/errors/exception_mapper.dart';
import 'package:flutter_restapi/core/network/api_client.dart';
import 'package:flutter_restapi/features/auth/data/models/user_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _client;

  ProfileRemoteDataSource(this._client);

  Future<UserModel> getProfile() async {
    try {
      final response = await _client.dio.get('/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
  }) async {
    try {
      final response = await _client.dio.put(
        '/profile',
        data: {'fullName': fullName, 'email': email},
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }
}
