import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';
import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';

class UserProfileState {
  static const _unset = Object();

  final UserProfileEntity? profile;
  final bool isFetchingProfile;
  final bool isUpdatingSection;
  final bool isFetchingVehicleTypes;
  final DriverProfileEditType? updatingSectionType;
  final String? errorMessage;
  final String? successMessage;
  final List<VehicleTypeOptionEntity> vehicleTypeOptions;

  const UserProfileState({
    this.profile,
    this.isFetchingProfile = false,
    this.isUpdatingSection = false,
    this.isFetchingVehicleTypes = false,
    this.updatingSectionType,
    this.errorMessage,
    this.successMessage,
    this.vehicleTypeOptions = const <VehicleTypeOptionEntity>[],
  });

  UserProfileState copyWith({
    UserProfileEntity? profile,
    bool? isFetchingProfile,
    bool? isUpdatingSection,
    bool? isFetchingVehicleTypes,
    Object? updatingSectionType = _unset,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    List<VehicleTypeOptionEntity>? vehicleTypeOptions,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isFetchingProfile: isFetchingProfile ?? this.isFetchingProfile,
      isUpdatingSection: isUpdatingSection ?? this.isUpdatingSection,
      isFetchingVehicleTypes:
          isFetchingVehicleTypes ?? this.isFetchingVehicleTypes,
      updatingSectionType: identical(updatingSectionType, _unset)
          ? this.updatingSectionType
          : updatingSectionType as DriverProfileEditType?,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
      vehicleTypeOptions: vehicleTypeOptions ?? this.vehicleTypeOptions,
    );
  }
}
