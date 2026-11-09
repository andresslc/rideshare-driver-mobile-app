import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/driver_referral_item_entity.dart';
import '../repositories/driver_referral_repository.dart';

class GetDriverReferralHistoryUseCase {
  final DriverReferralRepository repository;

  GetDriverReferralHistoryUseCase(this.repository);

  Future<Either<Failure, DriverReferralHistoryEntity>> call({
    int page = 1,
    int limit = 20,
  }) {
    return repository.getHistory(page: page, limit: limit);
  }
}
