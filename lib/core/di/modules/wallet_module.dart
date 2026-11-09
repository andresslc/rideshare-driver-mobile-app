import '../../../features/wallet/data/datasources/wallet_datasource.dart';
import '../../../features/wallet/data/repositories/wallet_repositories_impl.dart';
import '../../../features/wallet/domain/repositories/wallet_repository.dart';
import '../../../features/wallet/domain/usecases/get_bank_list_usecase.dart';
import '../../../features/wallet/domain/usecases/get_transaction_history_usecase.dart';
import '../../../features/wallet/domain/usecases/setup_account_usecase.dart';
import '../../../features/wallet/domain/usecases/withdraw_funds_usecase.dart';
import '../service_locator.dart';

void registerWalletModule() {
  // Data source
  locator.registerLazySingleton<WalletDataSource>(() => WalletDataSourceImpl());

  // Repository
  locator.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(locator<WalletDataSource>()),
  );

  // Use cases
  locator.registerLazySingleton<GetTransactionHistoryUseCase>(
    () => GetTransactionHistoryUseCase(locator<WalletRepository>()),
  );
  locator.registerLazySingleton<SetupAccountUseCase>(
    () => SetupAccountUseCase(locator<WalletRepository>()),
  );
  locator.registerLazySingleton<GetBankListUseCase>(
    () => GetBankListUseCase(locator<WalletRepository>()),
  );
  locator.registerLazySingleton<WithdrawFundsUseCase>(
    () => WithdrawFundsUseCase(locator<WalletRepository>()),
  );
}
