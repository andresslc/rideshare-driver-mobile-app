import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../../domain/entities/bank_account_form_entity.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_remote_datasource.dart';
import '../datasources/bank_account_stripe_datasource.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountRemoteDataSource _remoteDataSource;
  final BankAccountStripeDataSource _stripeDataSource;

  BankAccountRepositoryImpl({
    required BankAccountRemoteDataSource remoteDataSource,
    required BankAccountStripeDataSource stripeDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _stripeDataSource = stripeDataSource;

  @override
  FutureEither<String> collectBankToken({
    required BankAccountFormEntity params,
  }) async {
    try {
      final token = await _stripeDataSource.collectBankAccountToken(
        params: params,
      );
      return Right(token);
    } on BankTokenCollectionException catch (e) {
      return Left(ServerFailure(message: e.message, error: e));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to collect bank token: ${e.toString()}',
          error: e,
        ),
      );
    }
  }

  @override
  FutureEither<String> attachBankToken({required String token}) async {
    // return
    // handleNetworkError(
    // () =>
    // _remoteDataSource.attachBankToken(token: token);
    // );
    final response = await _remoteDataSource.attachBankToken(token: token);
    return response.fold(
      (left) => Left(ServerFailure(message: left.message)),
      (right) => Right(right),
    );
  }

  @override
  FutureEither<List<BankEntity>> getBanks() async {
    // return
    // handleNetworkError(
    // _remoteDataSource.getBanks();
    final response = await _remoteDataSource.getBanks();
    return response.fold(
      (left) => Left(ServerFailure(message: left.message)),
      (right) => Right(right),
    );
  }

  @override
  FutureEither<String> deleteBank({required String bankId}) async {
    // return
    // handleNetworkError(
    // () =>
    // _remoteDataSource.deleteBank(bankId: bankId);
    // );
    final response = await _remoteDataSource.deleteBank(bankId: bankId);
    return response.fold(
      (left) => Left(ServerFailure(message: left.message)),
      (right) => Right(right),
    );
  }
}
