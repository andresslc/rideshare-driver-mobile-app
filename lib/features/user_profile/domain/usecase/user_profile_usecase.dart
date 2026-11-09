import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/domain/repositories/user_repositories.dart';

class UserProfileUseCase {
  final UserProfileRepository repository;

  UserProfileUseCase(this.repository);

  FutureEither<UserProfileEntity> call() async {
    return await repository.getProfile();
  }
}
