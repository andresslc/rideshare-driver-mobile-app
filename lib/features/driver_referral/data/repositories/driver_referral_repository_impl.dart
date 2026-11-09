import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/driver_referral_item_entity.dart';
import '../../domain/entities/driver_referral_summary_entity.dart';
import '../../domain/repositories/driver_referral_repository.dart';
import '../datasources/driver_referral_datasource.dart';

class DriverReferralRepositoryImpl implements DriverReferralRepository {
  final DriverReferralDataSource remoteDataSource;

  DriverReferralRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, DriverReferralSummaryEntity>> getSummary() async {
    final response = await remoteDataSource.getSummary();

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (summary) => Right(summary),
    );
  }

  @override
  Future<Either<Failure, DriverReferralHistoryEntity>> getHistory({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await remoteDataSource.getHistory(
      page: page,
      limit: limit,
    );

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (history) => Right(history),
    );
  }
}
