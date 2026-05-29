import 'user_model.dart';

class LoginResponse {
  final String accessToken;
  final UserModel? user;

  LoginResponse({required this.accessToken, this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['accessToken'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'user': user?.toJson(),
    };
  }
}
