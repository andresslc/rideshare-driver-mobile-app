import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';
import 'package:driver_app/features/user_profile/domain/usecase/fetch_vehicle_types_usecase.dart';
import 'package:driver_app/features/user_profile/domain/usecase/update_profile_usecase.dart';
import 'package:driver_app/features/user_profile/domain/usecase/user_profile_usecase.dart';
import 'package:driver_app/features/user_profile/presentation/states/user_states.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entites/user_profile_entity.dart';

final getProfileUseCaseProvider = Provider<UserProfileUseCase>(
  (ref) => locator<UserProfileUseCase>(),
);

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => locator<UpdateProfileUseCase>(),
);

final fetchVehicleTypesUseCaseProvider = Provider<FetchVehicleTypesUseCase>(
  (ref) => locator<FetchVehicleTypesUseCase>(),
);

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfileState>(
      UserProfileController.new,
    );

class UserProfileController extends Notifier<UserProfileState> {
  @override
  UserProfileState build() {
    return const UserProfileState();
  }

  Future<void> fetchProfile({
    bool force = false,
    Function(UserProfileEntity profileData)? onSuccess,
    Function()? onError,
  }) async {
    if (state.isFetchingProfile) return;
    if (!force && state.profile != null) return;

    state = state.copyWith(
      isFetchingProfile: true,
      errorMessage: null,
      successMessage: null,
    );

    final result = await ref.read(getProfileUseCaseProvider)();
    result.fold(
      (failure) {
        state = state.copyWith(
          isFetchingProfile: false,
          errorMessage: failure.message,
        );
        onError?.call();
      },
      (profileData) {
        state = state.copyWith(
          isFetchingProfile: false,
          profile: profileData,
          errorMessage: null,
        );
        onSuccess?.call(profileData);
      },
    );
  }

  Future<bool> updateSection(UpdateDriverProfileParams params) async {
    if (state.isUpdatingSection) return false;

    state = state.copyWith(
      isUpdatingSection: true,
      updatingSectionType: params.type,
      errorMessage: null,
      successMessage: null,
    );

    final result = await ref.read(updateProfileUseCaseProvider)(params);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isUpdatingSection: false,
          updatingSectionType: null,
          errorMessage: failure.message,
        );
        return false;
      },
      (updatedProfile) {
        state = state.copyWith(
          profile: updatedProfile,
          isUpdatingSection: false,
          updatingSectionType: null,
          successMessage: updatedProfile.message?.trim().isNotEmpty == true
              ? updatedProfile.message
              : 'Profile updated successfully',
          errorMessage: null,
        );
        return true;
      },
    );
  }

  Future<void> fetchVehicleTypes({bool force = false}) async {
    if (state.isFetchingVehicleTypes) return;
    if (!force && state.vehicleTypeOptions.isNotEmpty) return;

    state = state.copyWith(
      isFetchingVehicleTypes: true,
      errorMessage: null,
      successMessage: null,
    );

    final result = await ref.read(fetchVehicleTypesUseCaseProvider)();
    result.fold(
      (failure) {
        state = state.copyWith(
          isFetchingVehicleTypes: false,
          errorMessage: failure.message,
        );
      },
      (vehicleTypes) {
        state = state.copyWith(
          isFetchingVehicleTypes: false,
          vehicleTypeOptions: vehicleTypes,
          errorMessage: null,
        );
      },
    );
  }

  /// ===============================
  /// UPDATE NOTIFICATION STATUS LOCALLY
  /// ===============================
  void updateNotificationStatus(bool isEnabled) {
    if (state.profile != null) {
      final updatedUser = state.profile!.user.copyWith(
        isNotificationEnabled: isEnabled,
      );
      final updatedProfile = state.profile!.copyWith(user: updatedUser);
      state = state.copyWith(profile: updatedProfile);
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}
