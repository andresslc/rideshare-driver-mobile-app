import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../../domain/entities/setup_account_url_entity.dart';
import '../../domain/entities/wallet_data_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_datasource.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource remoteDataSource;

  WalletRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, WalletDataEntity>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    final response = await remoteDataSource.getTransactionHistory(
      page: page,
      limit: limit,
      type: type,
    );

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (walletData) => Right(walletData),
    );
  }

  @override
  Future<Either<Failure, SetupAccountUrlEntity>> setupAccount() async {
    final response = await remoteDataSource.setupAccount();

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (data) => Right(data),
    );
  }

  @override
  Future<Either<Failure, List<BankEntity>>> getBankList() async {
    final response = await remoteDataSource.getBankList();

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (banks) => Right(banks),
    );
  }

  @override
  Future<Either<Failure, String>> withdraw({
    required double amount,
    required String bankId,
  }) async {
    final response = await remoteDataSource.withdraw(
      amount: amount,
      bankId: bankId,
    );

    return response.fold(
      (failure) => Left(ServerFailure(message: failure.message)),
      (message) => Right(message),
    );
  }
}
