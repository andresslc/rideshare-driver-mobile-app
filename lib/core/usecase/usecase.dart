import '../utils/typedefs.dart';

/// Base use case contract.
///
/// ```dart
/// class GetUser extends UseCase<UserEntity, String> {
///   final UserRepository _repo;
///   GetUser(this._repo);
///   @override
///   FutureEither<UserEntity> call(String userId) => _repo.getUser(userId);
/// }
/// ```
abstract class UseCase<Type, Params> {
  FutureEither<Type> call(Params params);
}

/// For use cases that don't require parameters.
class NoParams {
  const NoParams();
}
