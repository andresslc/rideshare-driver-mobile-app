import '../../domain/entities/transaction_entity.dart';
import '../../../../shared/model/bank_model.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.identifierKey,
    super.bank,
    required super.status,
    required super.createdAt,
    super.isRewarded,
    super.balanceSource,
    super.purpose,
    super.metadata,
    super.rideId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] ?? '',
      identifierKey: json['identifierKey'] ?? '',
      bank: json['bank'] != null ? BankModel.fromJson(json['bank']) : null,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRewarded: json['isRewarded'] as bool? ?? false,
      balanceSource: json['balanceSource'] as String?,
      purpose: json['purpose'] as String?,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      rideId: json['rideId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'amount': amount,
      'type': type,
      'identifierKey': identifierKey,
      'bank': bank != null ? (bank as BankModel).toJson() : null,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'isRewarded': isRewarded,
      'balanceSource': balanceSource,
      'purpose': purpose,
      'metadata': metadata,
      'rideId': rideId,
    };
  }
}
