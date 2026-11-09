class BankEntity {
  final String id;
  final String bankId;
  final String driver;

  final String accountHolderName;
  final String accountNumber;
  final String bankTitle;
  final String routingNumber;

  final bool selected;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  const BankEntity({
    required this.id,
    required this.bankId,
    required this.driver,
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankTitle,
    required this.routingNumber,
    this.selected = false,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.version,
  });
}
