import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failure.dart';
import '../entities/wallet_data_entity.dart';
import '../repositories/wallet_repository.dart';

class GetTransactionHistoryUseCase {
  final WalletRepository repository;

  GetTransactionHistoryUseCase(this.repository);

  Future<Either<Failure, WalletDataEntity>> call({
    int page = 1,
    int limit = 20,
    String? type,
  }) {
    return repository.getTransactionHistory(
      page: page,
      limit: limit,
      type: type,
    );
  }
}
