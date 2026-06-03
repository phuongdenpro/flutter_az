import 'user_model.dart';

class LoginResponseModel {
  final String accessToken;
  final String? refreshToken;
  final UserModel? user;

  const LoginResponseModel({
    required this.accessToken,
    this.refreshToken,
    this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
