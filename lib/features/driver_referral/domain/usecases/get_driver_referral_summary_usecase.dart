import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/driver_referral_summary_entity.dart';
import '../repositories/driver_referral_repository.dart';

class GetDriverReferralSummaryUseCase {
  final DriverReferralRepository repository;

  GetDriverReferralSummaryUseCase(this.repository);

  /// The first call also creates the driver's code if they don't have one.
  Future<Either<Failure, DriverReferralSummaryEntity>> call() {
    return repository.getSummary();
  }
}
