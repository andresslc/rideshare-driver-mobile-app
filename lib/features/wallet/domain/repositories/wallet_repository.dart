import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../../../../shared/entity/bank_entity.dart';
import '../entities/setup_account_url_entity.dart';
import '../entities/wallet_data_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletDataEntity>> getTransactionHistory({
    int page = 1,
    int limit = 20,
    String? type,
  });

  Future<Either<Failure, SetupAccountUrlEntity>> setupAccount();

  Future<Either<Failure, List<BankEntity>>> getBankList();

  Future<Either<Failure, String>> withdraw({
    required double amount,
    required String bankId,
  });
}
