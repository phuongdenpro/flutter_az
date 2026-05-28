import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../auth/models/user_model.dart';

class ProfileService {
  final ApiClient client;

  ProfileService(this.client);

  Future<UserModel> getMe() async {
    try {
      final response = await client.dio.get('/profile');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<UserModel> updateProfile({required String fullName, required String email}) async {
    try {
      final response = await client.dio.put(
        '/profile',
        data: {
          'fullName': fullName,
          'email': email,
        },
      );
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw _extractError(error);
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await client.dio.put(
        '/users/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
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
