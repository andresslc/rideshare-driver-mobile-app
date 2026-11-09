import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/errors/error_handler.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/core/utils/typedefs.dart';
import 'package:driver_app/features/user_profile/data/models/vehicle_type_option_model.dart';
import 'package:driver_app/features/user_profile/data/models/user_profile_model.dart';
import 'package:driver_app/features/user_profile/domain/entites/update_profile_params.dart';

abstract class UserProfileDatasource {
  FutureEither<UserProfileModel> getProfile();

  FutureEither<List<VehicleTypeOptionModel>> getVehicleTypes();

  FutureEither<UserProfileModel> updateProfileSection(
    UpdateDriverProfileParams params,
  );
}

class UserProfileDatasourceImpl implements UserProfileDatasource {
  final ApiService _apiService;

  UserProfileDatasourceImpl(this._apiService);

  @override
  FutureEither<UserProfileModel> getProfile() {
    return handleNetworkError(() async {
      final res = await _apiService.get(ApiEndpoints.profile);

      return UserProfileModel.fromJson(_toMap(res.data));
    });
  }

  @override
  FutureEither<List<VehicleTypeOptionModel>> getVehicleTypes() {
    return handleNetworkError(() async {
      final res = await _apiService.get(ApiEndpoints.vehicleTypes);
      final responseMap = _toMap(res.data);
      final dataMap = _toNestedMap(responseMap['data']);
      final rawItems = dataMap?['result'] ?? responseMap['result'];
      if (rawItems is! List) {
        return <VehicleTypeOptionModel>[];
      }

      return rawItems
          .whereType<Map>()
          .map(
            (item) => VehicleTypeOptionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where((item) => item.isActive)
          .toList(growable: false);
    });
  }

  @override
  FutureEither<UserProfileModel> updateProfileSection(
    UpdateDriverProfileParams params,
  ) {
    return handleNetworkError(() async {
      final endpoint =
          '${ApiEndpoints.updateProfile}${params.type.pathSegment}';
      final payload = await _buildPayload(params);

      final response = await _apiService.patch(
        endpoint,
        data: payload,
        headers: <String, dynamic>{
          'Content-Type': params.type.requiresMultipart
              ? 'multipart/form-data'
              : 'application/json',
        },
      );

      final responseMap = _toMap(response.data);
      final message = _readNullableString(responseMap, const ['message']);

      if (_containsUserPayload(responseMap)) {
        return UserProfileModel.fromJson(
          responseMap,
        ).copyWith(message: message);
      }

      final refreshed = await _apiService.get(ApiEndpoints.profile);
      return UserProfileModel.fromJson(
        _toMap(refreshed.data),
      ).copyWith(message: message);
    });
  }
}

// Future<dynamic> _buildPayload(UpdateDriverProfileParams params) async {
//   final fields = params.toFields();
//   if (!params.type.requiresMultipart) {
//     return fields;
//   }

//   final data = <String, dynamic>{...fields};
//   for (int i = 0; i < params.files.length; i++) {
//     final file = params.files[i];
//     final fileName = file.path.split(RegExp(r'[\\/]')).last;
//     // data.()
//     data['files[$i]'] = await MultipartFile.fromFile(
//       file.path,
//       filename: fileName,
//     );
//   }
//   log("${data.entries}::::::::::::::::::::::::");
//   return FormData.fromMap(data);
// }
Future<FormData> _buildPayload(UpdateDriverProfileParams params) async {
  final fields = params.toFields();

  final formData = FormData();

  // Add normal fields
  fields.forEach((key, value) {
    if (value != null) {
      formData.fields.add(MapEntry(key, value.toString()));
    }
  });

  // Add files with correct index
  for (int i = 0; i < params.files.length; i++) {
    final file = params.files[i];
    final fileName = file.path.split(RegExp(r'[\\/]')).last;

    formData.files.add(
      MapEntry(
        'files',
        await MultipartFile.fromFile(file.path, filename: fileName),
      ),
    );
  }

  log(formData.fields.toString());
  log(formData.files.map((e) => e.key).toString());

  return formData;
}

bool _containsUserPayload(Map<String, dynamic> map) {
  final data = _toNestedMap(map['data']);
  final userMap = _toNestedMap(data?['user']) ?? _toNestedMap(map['user']);
  if (userMap != null) return true;

  final looksLikeDataUser =
      data != null &&
      (data.containsKey('_id') ||
          data.containsKey('id') ||
          data.containsKey('firstName') ||
          data.containsKey('lastName') ||
          data.containsKey('email'));

  final looksLikeRootUser =
      map.containsKey('_id') ||
      map.containsKey('id') ||
      map.containsKey('firstName') ||
      map.containsKey('lastName') ||
      map.containsKey('email');

  return looksLikeDataUser || looksLikeRootUser;
}

Map<String, dynamic> _toMap(dynamic value) {
  final mapped = _toNestedMap(value);
  return mapped ?? <String, dynamic>{};
}

Map<String, dynamic>? _toNestedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (dynamic key, dynamic val) => MapEntry(key.toString(), val),
    );
  }
  return null;
}

String? _readNullableString(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    final value = map[key];
    if (value == null) continue;
    final parsed = value.toString().trim();
    if (parsed.isNotEmpty) return parsed;
  }
  return null;
}
