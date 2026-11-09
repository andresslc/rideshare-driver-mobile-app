enum BankHolderType { individual, company }

class BankAccountFormEntity {
  final String accountHolderName;
  final String accountNumber;
  final String routingNumber;
  final String country;
  final String currency;
  final BankHolderType holderType;

  const BankAccountFormEntity({
    required this.accountHolderName,
    required this.accountNumber,
    required this.routingNumber,
    this.country = 'US',
    this.currency = 'usd',
    this.holderType = BankHolderType.individual,
  });
}
