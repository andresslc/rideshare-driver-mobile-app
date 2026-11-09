import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/driver_referral_item_entity.dart';
import '../entities/driver_referral_summary_entity.dart';

abstract class DriverReferralRepository {
  Future<Either<Failure, DriverReferralSummaryEntity>> getSummary();

  Future<Either<Failure, DriverReferralHistoryEntity>> getHistory({
    int page = 1,
    int limit = 20,
  });
}
