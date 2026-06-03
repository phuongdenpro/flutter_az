abstract class SettingsRepository {
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
