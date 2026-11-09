import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/domain/repositories/user_repositories.dart';

class UpdateProfileUseCase {
  final UserProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  FutureEither<UserProfileEntity> call(UpdateDriverProfileParams params) async {
    return await repository.updateProfileSection(params: params);
  }
}
