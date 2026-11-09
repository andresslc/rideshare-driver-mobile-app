import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';
import 'package:driver_app/features/user_profile/domain/repositories/user_repositories.dart';

class FetchVehicleTypesUseCase {
  final UserProfileRepository repository;

  FetchVehicleTypesUseCase(this.repository);

  FutureEither<List<VehicleTypeOptionEntity>> call() {
    return repository.getVehicleTypes();
  }
}
