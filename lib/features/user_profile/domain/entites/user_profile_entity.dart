import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';

class UserProfileEntity {
  final UserEntity user;
  final String? message;

  const UserProfileEntity({required this.user, this.message});
  UserProfileEntity copyWith({UserEntity? user}) {
    return UserProfileEntity(user: user ?? this.user);
  }
}
