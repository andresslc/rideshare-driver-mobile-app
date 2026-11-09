import 'package:driver_app/features/auth/presentation/screens/account_review_status_screen.dart';
import 'package:driver_app/features/user_profile/domain/entites/user_entity.dart';

import '../../../auth/data/models/auth_user_model.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.ssn,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.profilePicture,
    required super.phone,
    required super.rating,
    required super.reviewsReceived,
    required super.reviewsGiven,
    required super.referralLink,
    super.referralCode,
    super.stripeAccountId,
    super.stripeCustomerId,
    required super.balance,
    required super.locale,
    required super.isNotificationEnabled,
    super.createdAt,
    super.updatedAt,
    required super.v,
    required super.personalInfoReview,
    required super.driverLicense,
    required super.insurance,
    required super.vehicleRegistration,
    required super.vehicleDetails,
    required super.subscriptionInfo,
    required super.bankInfo,
    required super.stripeCapabilities,

    required super.approvedDocuments,
    required super.pendingDocuments,
    required super.rejectedDocuments,
    required super.accountStatus,
    super.address,
    super.street,
    super.city,
    super.state,
    super.vehicleType,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Normalize known backend shape variations up front so the mapping
    // below reads like a single, consistent payload.
    final approvedDocs = (json['approvedDocuments'] as List?) ?? const [];

    final pendingDocs = (json['pendingDocuments'] as List?) ?? const [];

    final rejectedDocs = (json['rejectedDocuments'] as List?) ?? const [];

    AccountReviewStatus status;
    final savedStatus = parseAccountStatus(json['accountStatus']?.toString());

    if (savedStatus != null) {
      status = savedStatus;
    } else if (rejectedDocs.isNotEmpty) {
      status = AccountReviewStatus.notApproved;
    } else if (approvedDocs.isNotEmpty || pendingDocs.isNotEmpty) {
      status = AccountReviewStatus.underReview;
    } else {
      status = AccountReviewStatus.underReview;
    }
    final profileReviewMap =
        _asMap(json['profile']) ??
        _asMap(json['profileStatus']) ??
        _asMap(json['personalInformation']);

    final driverLicenseMap = _asMap(json['driverLicense']);
    final insuranceMap = _asMap(json['insurance']);
    final vehicleRegistrationMap = _asMap(json['vehicleRegistration']);
    final vehicleDetailsMap = _asMap(json['vehicleDetails']);
    final subscriptionMap = _asMap(json['subscription']);
    final bankInfoMap =
        _asMap(json['bankInfo']) ??
        _asMap(json['bank']) ??
        _asMap(json['attachedBank']);
    final stripeCapabilitiesMap =
        _asMap(json['stripeConnectCapabilities']) ??
        _asMap(json['stripeCapabilities']) ??
        _asMap(json['capabilities']) ??
        _asMap(json['stripe']);

    return UserModel(
      id: _readString(json, const ['_id', 'id']),
      ssn: _readNullableString(json, const ['ssn']),
      firstName: _readString(json, const ['firstName']),
      lastName: _readString(json, const ['lastName']),
      email: _readString(json, const ['email']),
      profilePicture: _readNullableString(json, const [
        'profilePicture',
        'avatar',
        'picture',
      ]),
      phone: _readString(json, const ['phone', 'phoneNumber']),
      rating: _readDouble(json, const ['rating']),
      reviewsReceived: _readInt(json, const ['reviewsReceived']),
      reviewsGiven: _readInt(json, const ['reviewsGiven']),
      referralLink: _readString(json, const [
        'referralLink',
        'referral_link',
        'referralUrl',
        'referral',
      ]),
      referralCode: _readNullableString(json, const ['referralCode']),
      stripeAccountId: _readNullableString(json, const [
        'stripeAccountId',
        'stripe_account_id',
      ]),
      stripeCustomerId: _readNullableString(json, const [
        'stripeCustomerId',
        'stripe_customer_id',
      ]),
      balance: _readInt(json, const ['balance']),
      locale: _readString(json, const ['locale'], fallback: 'en'),
      isNotificationEnabled: _readBool(json, const [
        'isNotificationEnabled',
      ], fallback: true),
      createdAt: _parseDate(_valueForKeys(json, const ['createdAt'])),
      updatedAt: _parseDate(_valueForKeys(json, const ['updatedAt'])),
      v: _readInt(json, const ['__v', 'v']),
      personalInfoReview: ReviewStatusModel.fromMap(
        profileReviewMap,
        fallbackStatus: _readNullableString(json, const ['accountStatus']),
        fallbackRejectReason: _readNullableString(json, const [
          'rejectedReason',
          'rejectReason',
        ]),
      ),
      driverLicense: DriverDocumentModel.fromMap(driverLicenseMap),
      insurance: DriverDocumentModel.fromMap(insuranceMap),
      vehicleRegistration: DriverDocumentModel.fromMap(vehicleRegistrationMap),
      vehicleDetails: VehicleDetailsModel.fromMap(vehicleDetailsMap),
      subscriptionInfo: SubscriptionInfoModel.fromMap(subscriptionMap),
      bankInfo: BankInfoModel.fromMap(bankInfoMap),
      stripeCapabilities: StripeCapabilitiesModel.fromMap(
        stripeCapabilitiesMap,
      ),
      approvedDocuments: approvedDocs,
      pendingDocuments: pendingDocs,
      rejectedDocuments: rejectedDocs,
      accountStatus: status,
      address: _readNullableString(json, const ['address']),
      street: _readNullableString(json, const ['street']),
      city: _readNullableString(json, const ['city']),
      state: _readNullableString(json, const ['state']),
      vehicleType: _readNullableString(json, const ['vehicleType']),
    );
  }
}

class ReviewStatusModel extends SectionReviewEntity {
  const ReviewStatusModel({required super.status, super.rejectReason});

  factory ReviewStatusModel.fromMap(
    Map<String, dynamic>? map, {
    String? fallbackStatus,
    String? fallbackRejectReason,
  }) {
    final statusValue =
        _readNullableString(map, const ['status', 'accountStatus']) ??
        fallbackStatus;
    final rejectReason =
        _readNullableString(map, const [
          'rejectReason',
          'rejectedReason',
          'reason',
        ]) ??
        fallbackRejectReason;

    return ReviewStatusModel(
      status: parseProfileSectionStatus(statusValue),
      rejectReason: rejectReason,
    );
  }
}

class DriverDocumentModel extends DriverDocumentEntity {
  const DriverDocumentModel({
    required super.id,
    required super.review,
    required super.fileUrls,
    super.expiryDate,
    super.licenseNumber,
  });

  factory DriverDocumentModel.fromMap(Map<String, dynamic>? map) {
    final payload = map ?? <String, dynamic>{};
    final metadata = _asMap(payload['metadata']);
    return DriverDocumentModel(
      id: _readString(payload, const ['_id', 'id']),
      review: ReviewStatusModel.fromMap(payload),
      fileUrls: _extractFileUrls(payload),
      expiryDate:
          _readNullableString(payload, const ['expiryDate']) ??
          _readNullableString(metadata, const ['expiryDate', 'expiry']),
      licenseNumber:
          _readNullableString(payload, const ['licenseNumber']) ??
          _readNullableString(metadata, const ['licenseNumber', 'number']),
    );
  }
}

class VehicleDetailsModel extends VehicleDetailsEntity {
  const VehicleDetailsModel({
    required super.id,
    required super.review,
    required super.fileUrls,
    required super.make,
    required super.model,
    required super.yearOfManufacture,
    required super.color,
    required super.vehicleIdentificationNumber,
    required super.licensePlateNumber,
    required super.registrationNumber,
    required super.regionOfRegistration,
    required super.expiryDate,
    required super.vehicleType,
  });

  factory VehicleDetailsModel.fromMap(Map<String, dynamic>? map) {
    final payload = map ?? <String, dynamic>{};
    final details = _asMap(payload['details']) ?? payload;

    return VehicleDetailsModel(
      id: _readString(payload, const ['_id', 'id']),
      review: ReviewStatusModel.fromMap(payload),
      fileUrls: _extractFileUrls(payload),
      make: _readString(details, const ['make']),
      model: _readString(details, const ['model']),
      yearOfManufacture: _readNullableInt(details, const ['yearOfManufacture']),
      color: _readString(details, const ['color']),
      vehicleIdentificationNumber: _readString(details, const [
        'vehicleIdentificationNumber',
      ]),
      licensePlateNumber: _readString(details, const ['licensePlateNumber']),
      registrationNumber: _readString(details, const ['registrationNumber']),
      regionOfRegistration: _readString(details, const [
        'regionOfRegistration',
      ]),
      expiryDate: _readString(details, const ['expiryDate']),
      vehicleType: _readString(details, const ['vehicleType']),
    );
  }
}

class SubscriptionInfoModel extends SubscriptionInfoEntity {
  const SubscriptionInfoModel({
    required super.review,
    required super.status,
    required super.planName,
    super.expiryDate,
  });

  factory SubscriptionInfoModel.fromMap(Map<String, dynamic>? map) {
    final payload = map ?? <String, dynamic>{};
    final planName = _readString(payload, const [
      'planName',
      'plan',
      'productName',
    ]);
    return SubscriptionInfoModel(
      review: ReviewStatusModel.fromMap(payload),
      status: _readString(payload, const ['status', 'subscriptionStatus']),
      planName: planName.isNotEmpty
          ? planName
          : _readString(payload, const ['productId', 'priceId']),
      expiryDate: _parseDate(
        _valueForKeys(payload, const [
          'expiryDate',
          'expiresAt',
          'currentPeriodEnd',
          'current_period_end',
        ]),
      ),
    );
  }
}

class BankInfoModel extends BankInfoEntity {
  const BankInfoModel({
    required super.review,
    required super.bankName,
    required super.accountHolderName,
    required super.accountNumberLast4,
    required super.routingNumber,
  });

  factory BankInfoModel.fromMap(Map<String, dynamic>? map) {
    final payload = map ?? <String, dynamic>{};
    final accountNumberValue = _readString(payload, const [
      'accountNumberLast4',
      'last4',
      'accountNumber',
      'account_number',
    ]);

    return BankInfoModel(
      review: ReviewStatusModel.fromMap(payload),
      bankName: _readString(payload, const ['bankName', 'bank', 'bankTitle']),
      accountHolderName: _readString(payload, const [
        'accountHolderName',
        'holderName',
        'account_holder_name',
      ]),
      accountNumberLast4: _normalizeLast4(accountNumberValue),
      routingNumber: _readString(payload, const ['routingNumber']),
    );
  }
}

class StripeCapabilitiesModel extends StripeCapabilitiesEntity {
  const StripeCapabilitiesModel({
    required super.review,
    required super.cardPaymentsEnabled,
    required super.transfersEnabled,
    required super.payoutsEnabled,
    required super.raw,
  });

  factory StripeCapabilitiesModel.fromMap(Map<String, dynamic>? map) {
    final payload = map ?? <String, dynamic>{};
    final capabilities = _asMap(payload['capabilities']) ?? payload;

    final cardPayments = _parseCapability(
      capabilities['card_payments'] ??
          capabilities['cardPayments'] ??
          capabilities['card_payments_enabled'],
    );
    final payouts = _parseCapability(
      capabilities['payout'] ??
          capabilities['payouts'] ??
          capabilities['payout_enabled'] ??
          capabilities['payouts_enabled'] ??
          capabilities['instant_payouts'],
    );

    return StripeCapabilitiesModel(
      review: ReviewStatusModel.fromMap(payload),
      cardPaymentsEnabled: cardPayments ?? payouts,
      transfersEnabled: _parseCapability(
        capabilities['transfers'] ??
            capabilities['transfer'] ??
            capabilities['transfers_enabled'],
      ),
      payoutsEnabled: payouts,
      raw: Map<String, dynamic>.from(capabilities),
    );
  }
}

bool? _parseCapability(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'active':
      case 'enabled':
      case 'verified':
      case 'true':
        return true;
      case 'inactive':
      case 'disabled':
      case 'false':
        return false;
      default:
        return null;
    }
  }
  final map = _asMap(value);
  if (map != null) {
    return _parseCapability(map['enabled'] ?? map['status']);
  }
  return null;
}

String _normalizeLast4(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty) return '';
  if (normalized.length <= 4) return normalized;
  return normalized.substring(normalized.length - 4);
}

List<String> _extractFileUrls(Map<String, dynamic> map) {
  final urls = <String>{};

  void addUrl(dynamic value) {
    if (value == null) return;
    if (value is String && value.trim().isNotEmpty) {
      urls.add(value.trim());
      return;
    }
    if (value is Map<String, dynamic>) {
      addUrl(
        value['url'] ??
            value['file'] ??
            value['path'] ??
            value['location'] ??
            value['secure_url'],
      );
      return;
    }
    if (value is List) {
      for (final item in value) {
        addUrl(item);
      }
    }
  }

  addUrl(map['frontImage']);
  addUrl(map['backImage']);
  addUrl(map['image']);
  addUrl(map['file']);
  addUrl(map['files']);
  addUrl(map['images']);

  return urls.toList();
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (dynamic key, dynamic val) => MapEntry(key.toString(), val),
    );
  }
  return null;
}

dynamic _valueForKeys(Map<String, dynamic>? map, List<String> keys) {
  if (map == null) return null;
  for (final key in keys) {
    if (map.containsKey(key)) {
      return map[key];
    }
  }
  return null;
}

String _readString(
  Map<String, dynamic>? map,
  List<String> keys, {
  String fallback = '',
}) {
  final value = _valueForKeys(map, keys);
  if (value == null) return fallback;
  return value.toString().trim();
}

String? _readNullableString(Map<String, dynamic>? map, List<String> keys) {
  final value = _valueForKeys(map, keys);
  if (value == null) return null;
  final parsed = value.toString().trim();
  return parsed.isEmpty ? null : parsed;
}

int _readInt(Map<String, dynamic>? map, List<String> keys, {int fallback = 0}) {
  final value = _valueForKeys(map, keys);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double _readDouble(
  Map<String, dynamic>? map,
  List<String> keys, {
  double fallback = 0,
}) {
  final value = _valueForKeys(map, keys);
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int? _readNullableInt(Map<String, dynamic>? map, List<String> keys) {
  final value = _valueForKeys(map, keys);
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

bool _readBool(
  Map<String, dynamic>? map,
  List<String> keys, {
  bool fallback = false,
}) {
  final value = _valueForKeys(map, keys);
  if (value is bool) return value;
  if (value is String) {
    final normalized = value.toLowerCase();
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
  }
  return fallback;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}
