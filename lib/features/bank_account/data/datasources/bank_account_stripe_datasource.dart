  import 'package:driver_app/core/utils/app_log.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../domain/entities/bank_account_form_entity.dart';

class BankTokenCollectionException implements Exception {
  final String message;

  const BankTokenCollectionException(this.message);

  @override
  String toString() => message;
}

abstract class BankAccountStripeDataSource {
  Future<String> collectBankAccountToken({
    required BankAccountFormEntity params,
  });
}

class BankAccountStripeDataSourceImpl implements BankAccountStripeDataSource {
  @override
  Future<String> collectBankAccountToken({
    required BankAccountFormEntity params,
  }) async {
    try {
      final result = await Stripe.instance.createToken(
        CreateTokenParams.bankAccount(
          params: BankAccountTokenParams(
            country: params.country,
            currency: params.currency,
            routingNumber: params.routingNumber,
            accountNumber: params.accountNumber,
            accountHolderName: params.accountHolderName,
            accountHolderType: params.holderType == BankHolderType.company
                ? BankAccountHolderType.Company
                : BankAccountHolderType.Individual,
          ),
        ),
      );

      final tokenId = result.id;
      if (tokenId.isEmpty || !tokenId.startsWith('btok_')) {
        throw const BankTokenCollectionException(
          'Stripe did not return a valid bank token.',
        );
      }

      return tokenId;
    } on StripeException catch (e, st) {
      log("::::error${e.error}");
      log("::::st$st");
      final message =
          e.error.localizedMessage ??
          e.error.message ??
          'Bank token collection was canceled.';
      checkIfInternet(e);
      throw BankTokenCollectionException(message);
    } catch (e, st) {
      log("::::error${e.toString()}");
      log("::::st$st");

      checkIfInternet(e);

      throw BankTokenCollectionException(e.toString());
    }
  }

  void checkIfInternet(e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('unable to resolve host') ||
        msg.contains('no address associated') ||
        msg.contains('network is unreachable') ||
        msg.contains('socketexception') ||
        msg.contains('connection refused')) {
      throw const BankTokenCollectionException(
        'No internet connection. Please check your network and try again.',
      );
    }
  }
}
