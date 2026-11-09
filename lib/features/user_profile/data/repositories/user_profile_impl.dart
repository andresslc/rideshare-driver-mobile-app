import 'package:fpdart/fpdart.dart';

import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/data/datasources/user_profile_datasource.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';
import 'package:driver_app/features/user_profile/domain/repositories/user_repositories.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  final UserProfileDatasource _dataSource;

  UserProfileRepositoryImpl(this._dataSource);

  @override
  FutureEither<UserProfileEntity> getProfile() async {
    final response = await _dataSource.getProfile();
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      Right.new,
    );
  }

  @override
  FutureEither<List<VehicleTypeOptionEntity>> getVehicleTypes() async {
    final response = await _dataSource.getVehicleTypes();
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      Right.new,
    );
  }

  @override
  FutureEither<UserProfileEntity> updateProfileSection({
    required UpdateDriverProfileParams params,
  }) async {
    final response = await _dataSource.updateProfileSection(params);
    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      Right.new,
    );
  }
}
