import '../../services/api_service.dart';
import '../../../features/bank_account/data/datasources/bank_account_remote_datasource.dart';
import '../../../features/bank_account/data/datasources/bank_account_stripe_datasource.dart';
import '../../../features/bank_account/data/repositories/bank_account_repository_impl.dart';
import '../../../features/bank_account/domain/repositories/bank_account_repository.dart';
import '../../../features/bank_account/domain/usecases/attach_bank_account_usecase.dart';
import '../../../features/bank_account/domain/usecases/delete_bank_account_usecase.dart';
import '../../../features/bank_account/domain/usecases/get_bank_accounts_usecase.dart';
import '../service_locator.dart';

void registerBankAccountModule() {
  locator.registerLazySingleton<BankAccountRemoteDataSource>(
    () => BankAccountRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<BankAccountStripeDataSource>(
    BankAccountStripeDataSourceImpl.new,
  );

  locator.registerLazySingleton<BankAccountRepository>(
    () => BankAccountRepositoryImpl(
      remoteDataSource: locator<BankAccountRemoteDataSource>(),
      stripeDataSource: locator<BankAccountStripeDataSource>(),
    ),
  );

  locator.registerLazySingleton<AttachBankAccountUseCase>(
    () => AttachBankAccountUseCase(locator<BankAccountRepository>()),
  );
  locator.registerLazySingleton<GetBankAccountsUseCase>(
    () => GetBankAccountsUseCase(locator<BankAccountRepository>()),
  );
  locator.registerLazySingleton<DeleteBankAccountUseCase>(
    () => DeleteBankAccountUseCase(locator<BankAccountRepository>()),
  );
}
