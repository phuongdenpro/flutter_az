import 'user_model.dart';

class LoginResponse {
  final String accessToken;
  final String? refreshToken;
  final UserModel? user;

  LoginResponse({required this.accessToken, this.refreshToken, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user?.toJson(),
      };
}
