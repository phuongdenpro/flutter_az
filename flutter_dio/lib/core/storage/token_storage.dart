import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final TokenStorage _instance = TokenStorage._internal();

  factory TokenStorage() {
    return _instance;
  }

  TokenStorage._internal();

  static const _tokenKey = 'auth_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ValueNotifier<bool> authNotifier = ValueNotifier<bool>(false);

  Future<void> init() async {
    final token = await getToken();
    authNotifier.value = token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    authNotifier.value = true;
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
    authNotifier.value = false;
  }
}