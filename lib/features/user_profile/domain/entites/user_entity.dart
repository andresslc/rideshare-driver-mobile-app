import '../../../auth/presentation/screens/account_review_status_screen.dart';
import '../../../../core/utils/name_utils.dart';

enum ProfileSectionStatus { approved, pending, rejected, unknown }

ProfileSectionStatus parseProfileSectionStatus(String? value) {
  switch (value?.trim().toLowerCase()) {
    case 'approved':
    case 'active':
    case 'verified':
    case 'complete':
    case 'completed':
      return ProfileSectionStatus.approved;
    case 'pending':
    case 'underreview':
    case 'under_review':
    case 'in_review':
    case 'processing':
    case 'submitted':
      return ProfileSectionStatus.pending;
    case 'rejected':
    case 'declined':
    case 'notapproved':
    case 'not_approved':
      return ProfileSectionStatus.rejected;
    default:
      return ProfileSectionStatus.unknown;
  }
}

extension ProfileSectionStatusX on ProfileSectionStatus {
  String get label {
    switch (this) {
      case ProfileSectionStatus.approved:
        return 'Approved';
      case ProfileSectionStatus.pending:
        return 'Pending';
      case ProfileSectionStatus.rejected:
        return 'Rejected';
      case ProfileSectionStatus.unknown:
        return 'Unknown';
    }
  }
}

class SectionReviewEntity {
  final ProfileSectionStatus status;
  final String? rejectReason;

  const SectionReviewEntity({
    this.status = ProfileSectionStatus.unknown,
    this.rejectReason,
  });

  bool get isRejected => status == ProfileSectionStatus.rejected;
}

class DriverDocumentEntity {
  final String id;
  final SectionReviewEntity review;
  final List<String> fileUrls;
  final String? expiryDate;
  final String? licenseNumber;

  const DriverDocumentEntity({
    this.id = '',
    this.review = const SectionReviewEntity(),
    this.fileUrls = const <String>[],
    this.expiryDate,
    this.licenseNumber,
  });
}

class VehicleDetailsEntity {
  final String id;
  final SectionReviewEntity review;
  final List<String> fileUrls;
  final String make;
  final String model;
  final int? yearOfManufacture;
  final String color;
  final String vehicleIdentificationNumber;
  final String licensePlateNumber;
  final String registrationNumber;
  final String regionOfRegistration;
  final String expiryDate;
  final String vehicleType;

  const VehicleDetailsEntity({
    this.id = '',
    this.review = const SectionReviewEntity(),
    this.fileUrls = const <String>[],
    this.make = '',
    this.model = '',
    this.yearOfManufacture,
    this.color = '',
    this.vehicleIdentificationNumber = '',
    this.licensePlateNumber = '',
    this.registrationNumber = '',
    this.regionOfRegistration = '',
    this.expiryDate = '',
    this.vehicleType = '',
  });
}

class SubscriptionInfoEntity {
  final SectionReviewEntity review;
  final String status;
  final String planName;
  final DateTime? expiryDate;

  const SubscriptionInfoEntity({
    this.review = const SectionReviewEntity(),
    this.status = '',
    this.planName = '',
    this.expiryDate,
  });
}

class BankInfoEntity {
  final SectionReviewEntity review;
  final String bankName;
  final String accountHolderName;
  final String accountNumberLast4;
  final String routingNumber;

  const BankInfoEntity({
    this.review = const SectionReviewEntity(),
    this.bankName = '',
    this.accountHolderName = '',
    this.accountNumberLast4 = '',
    this.routingNumber = '',
  });
}

class StripeCapabilitiesEntity {
  final SectionReviewEntity review;
  final bool? cardPaymentsEnabled;
  final bool? transfersEnabled;
  final bool? payoutsEnabled;
  final Map<String, dynamic> raw;

  const StripeCapabilitiesEntity({
    this.review = const SectionReviewEntity(),
    this.cardPaymentsEnabled,
    this.transfersEnabled,
    this.payoutsEnabled,
    this.raw = const <String, dynamic>{},
  });
}

class UserEntity {
  final String id;
  final String? ssn;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String phone;
  final double rating;
  final int reviewsReceived;
  final int reviewsGiven;
  final String referralLink;

  /// Driver → rider referral code (`data.driver.referralCode`), 7 chars.
  final String? referralCode;
  final String? stripeAccountId;
  final String? stripeCustomerId;
  final int balance;
  final String locale;
  final bool isNotificationEnabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;
  final SectionReviewEntity personalInfoReview;
  final DriverDocumentEntity driverLicense;
  final DriverDocumentEntity insurance;
  final DriverDocumentEntity vehicleRegistration;
  final VehicleDetailsEntity vehicleDetails;
  final SubscriptionInfoEntity subscriptionInfo;
  final BankInfoEntity bankInfo;
  final StripeCapabilitiesEntity stripeCapabilities;
  final String? address;
  final String? street;
  final String? city;
  final String? state;
  final String? vehicleType;

  final List<dynamic> approvedDocuments;
  final List<dynamic> pendingDocuments;
  final List<dynamic> rejectedDocuments;
  final AccountReviewStatus accountStatus;

  const UserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    required this.phone,
    this.rating = 0,
    this.ssn = '0',
    this.reviewsReceived = 0,
    this.reviewsGiven = 0,
    this.referralLink = '',
    this.referralCode,
    this.stripeAccountId,
    this.stripeCustomerId,
    required this.balance,
    required this.locale,
    required this.isNotificationEnabled,
    this.createdAt,
    this.updatedAt,
    required this.v,
    this.personalInfoReview = const SectionReviewEntity(),
    this.driverLicense = const DriverDocumentEntity(),
    this.insurance = const DriverDocumentEntity(),
    this.vehicleRegistration = const DriverDocumentEntity(),
    this.vehicleDetails = const VehicleDetailsEntity(),
    this.subscriptionInfo = const SubscriptionInfoEntity(),
    this.bankInfo = const BankInfoEntity(),
    this.stripeCapabilities = const StripeCapabilitiesEntity(),
    required this.accountStatus,
    required this.approvedDocuments,
    required this.pendingDocuments,
    required this.rejectedDocuments,
    this.address,
    this.street,
    this.city,
    this.state,
    this.vehicleType,
  });

  bool get isUserProfileCreated =>
      approvedDocuments.isNotEmpty ||
      pendingDocuments.isNotEmpty ||
      rejectedDocuments.isNotEmpty;

  String get displayName => composeFullName(firstName, lastName);
  String get name => displayName;

  String get displayStreet {
    if (street != null && street!.trim().isNotEmpty) return street!.trim();
    if (address != null && address!.trim().isNotEmpty) {
      final parts = address!.split(',');
      return parts.first.trim();
    }
    return '';
  }

  String get displayCity {
    if (city != null && city!.trim().isNotEmpty) return city!.trim();
    if (address != null && address!.trim().isNotEmpty) {
      final parts = address!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 4) {
        return parts[parts.length - 3];
      } else if (parts.length == 3) {
        return parts[0];
      } else if (parts.length == 2) {
        return parts[0];
      }
    }
    return '';
  }

  String get displayState {
    if (state != null && state!.trim().isNotEmpty) return state!.trim();
    if (address != null && address!.trim().isNotEmpty) {
      final parts = address!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (parts.length >= 3) {
        return parts[parts.length - 2];
      } else if (parts.length == 2) {
        return parts[1];
      }
    }
    return '';
  }

  UserEntity copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? profilePicture,
    String? phone,
    double? rating,
    int? reviewsReceived,
    int? reviewsGiven,
    String? referralLink,
    String? referralCode,
    String? stripeAccountId,
    String? stripeCustomerId,
    int? balance,
    String? locale,
    bool? isNotificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    SectionReviewEntity? personalInfoReview,
    DriverDocumentEntity? driverLicense,
    DriverDocumentEntity? insurance,
    DriverDocumentEntity? vehicleRegistration,
    VehicleDetailsEntity? vehicleDetails,
    SubscriptionInfoEntity? subscriptionInfo,
    BankInfoEntity? bankInfo,
    StripeCapabilitiesEntity? stripeCapabilities,
    List<dynamic>? approvedDocuments,
    List<dynamic>? pendingDocuments,
    List<dynamic>? rejectedDocuments,
    AccountReviewStatus? accountStatus,
    String? address,
    String? street,
    String? city,
    String? state,
    String? vehicleType,
  }) {
    return UserEntity(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      phone: phone ?? this.phone,
      rating: rating ?? this.rating,
      reviewsReceived: reviewsReceived ?? this.reviewsReceived,
      reviewsGiven: reviewsGiven ?? this.reviewsGiven,
      referralLink: referralLink ?? this.referralLink,
      referralCode: referralCode ?? this.referralCode,
      stripeAccountId: stripeAccountId ?? this.stripeAccountId,
      stripeCustomerId: stripeCustomerId ?? this.stripeCustomerId,
      balance: balance ?? this.balance,
      locale: locale ?? this.locale,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      personalInfoReview: personalInfoReview ?? this.personalInfoReview,
      driverLicense: driverLicense ?? this.driverLicense,
      insurance: insurance ?? this.insurance,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      subscriptionInfo: subscriptionInfo ?? this.subscriptionInfo,
      bankInfo: bankInfo ?? this.bankInfo,
      stripeCapabilities: stripeCapabilities ?? this.stripeCapabilities,
      approvedDocuments: approvedDocuments ?? this.approvedDocuments,
      pendingDocuments: pendingDocuments ?? this.pendingDocuments,
      rejectedDocuments: rejectedDocuments ?? this.rejectedDocuments,
      accountStatus: accountStatus ?? this.accountStatus,
      address: address ?? this.address,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }
}
