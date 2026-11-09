import 'package:driver_app/features/user_profile/data/models/user_model.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({required super.user, super.message});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? <String, dynamic>{};

    final userJson =
        _asMap(data['driver']) ??
        _asMap(json['user']) ??
        (_looksLikeUser(data) ? data : null) ??
        (_looksLikeUser(json) ? json : null);

    if (userJson == null) {
      throw const FormatException('User payload not found in response.');
    }

    return UserProfileModel(
      user: UserModel.fromJson(userJson),
      message:
          _readNullableString(json, const ['message']) ??
          _readNullableString(data, const ['message']),
    );
  }

  UserProfileModel copyWith({
    UserEntity? user,
    String? message,
    bool clearMessage = false,
  }) {
    return UserProfileModel(
      user: user ?? this.user,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

bool _looksLikeUser(Map<String, dynamic>? map) {
  if (map == null) return false;
  return map.containsKey('_id') ||
      map.containsKey('id') ||
      map.containsKey('firstName') ||
      map.containsKey('lastName') ||
      map.containsKey('email');
}

Map<String, dynamic>? _asMap(dynamic value) {
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
    final dynamic value = map[key];
    if (value == null) continue;
    final parsed = value.toString().trim();
    if (parsed.isNotEmpty) return parsed;
  }
  return null;
}
