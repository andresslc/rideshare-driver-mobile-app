import '../entity/bank_entity.dart';

class BankModel extends BankEntity {
  const BankModel({
    required super.id,
    required super.bankId,
    required super.driver,
    required super.accountHolderName,
    required super.accountNumber,
    required super.bankTitle,
    required super.routingNumber,
    super.selected,
    required super.status,
    super.createdAt,
    super.updatedAt,
    super.version,
  });

  factory BankModel.fromJson(Map<String, dynamic> json) {
    return BankModel(
      id: json['_id'] ?? '',
      bankId: json['bankId'] ?? '',
      driver: json['driver'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      bankTitle: json['bankTitle'] ?? '',
      routingNumber: json['routingNumber'] ?? '',
      selected: json['selected'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bankId': bankId,
      'driver': driver,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'bankTitle': bankTitle,
      'routingNumber': routingNumber,
      'selected': selected,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}
