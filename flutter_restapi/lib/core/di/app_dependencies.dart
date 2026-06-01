import '../network/api_client.dart';
import '../storage/token_storage.dart';

/// Điểm khởi tạo dependency dùng chung toàn app (singleton).
class AppDependencies {
  AppDependencies._();

  static final AppDependencies instance = AppDependencies._();

  late final TokenStorage tokenStorage;
  late final ApiClient apiClient;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tokenStorage = TokenStorage();
    apiClient = ApiClient(tokenStorage);
    await tokenStorage.init();
    _initialized = true;
  }
}
