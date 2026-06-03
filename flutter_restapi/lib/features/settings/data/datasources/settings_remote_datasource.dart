import 'package:dio/dio.dart';

import 'package:flutter_restapi/core/errors/exception_mapper.dart';
import 'package:flutter_restapi/core/network/api_client.dart';

class SettingsRemoteDataSource {
  final ApiClient _client;

  SettingsRemoteDataSource(this._client);

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _client.dio.put(
        '/users/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw ExceptionMapper.fromDio(e);
    }
  }
}
