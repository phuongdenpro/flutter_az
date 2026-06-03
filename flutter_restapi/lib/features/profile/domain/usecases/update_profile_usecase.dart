import 'package:flutter_restapi/features/auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileParams {
  final String fullName;
  final String email;

  const UpdateProfileParams({required this.fullName, required this.email});
}

class UpdateProfileUseCase {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  Future<UserEntity> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      fullName: params.fullName,
      email: params.email,
    );
  }
}
