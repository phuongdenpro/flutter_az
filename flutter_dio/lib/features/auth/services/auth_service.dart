import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/login_response.dart';

class AuthService {
  final ApiClient client;
  final TokenStorage tokenStorage;

  AuthService(this.client, this.tokenStorage);

  Future<LoginResponse> login({required String email, required String password}) async {
    try {
      final response = await client.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      final loginResponse = LoginResponse.fromJson(response.data as Map<String, dynamic>);
      await tokenStorage.saveToken(loginResponse.accessToken);
      return loginResponse;
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<void> register({required String fullName, required String email, required String password}) async {
    try {
      await client.dio.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
          'confirmPassword': password,
        },
      );
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  String _extractError(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      return error.response?.data['message']?.toString() ?? error.message ?? 'Đã xảy ra lỗi máy chủ';
    }
    return error.message ?? 'Đã xảy ra lỗi máy chủ';
  }
}
