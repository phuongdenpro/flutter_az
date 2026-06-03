import '../repositories/settings_repository.dart';

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });
}

class ChangePasswordUseCase {
  final SettingsRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<void> call(ChangePasswordParams params) {
    return _repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
      confirmPassword: params.confirmPassword,
    );
  }
}
