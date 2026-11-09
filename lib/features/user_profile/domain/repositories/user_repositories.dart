import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';

abstract class UserProfileRepository {
  FutureEither<UserProfileEntity> getProfile();

  FutureEither<List<VehicleTypeOptionEntity>> getVehicleTypes();

  FutureEither<UserProfileEntity> updateProfileSection({
    required UpdateDriverProfileParams params,
  });
}
