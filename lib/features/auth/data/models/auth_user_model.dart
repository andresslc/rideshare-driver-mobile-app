import '../../domain/entities/auth_user_entity.dart';
import '../../presentation/screens/account_review_status_screen.dart';

// class AuthResponseModel extends AuthResponseEntity {
// AuthResponseModel({
//   required super.token,
//   required UserModel super.user,
//   required super.isOnboarded,
//   required super.accountStatus,
//   super.rejectedReason,
// });

// AuthResponseModel({
//   super.token,
//   AuthUserModel? super.user, // nullable
//   required super.isOnboarded,
//   required super.accountStatus,
//   required super.isUserProfileCreated,

//   // super.rejectedReason,
// });

class AuthResponseModel extends AuthResponseEntity {
  AuthResponseModel({
    super.token,
    super.user,
    required super.isOnboarded,
    required super.accountStatus,
    required super.approvedDocuments,
    required super.pendingDocuments,
    required super.rejectedDocuments,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;

    final approvedDocs = (data['approvedDocuments'] as List?) ?? const [];

    final pendingDocs = (data['pendingDocuments'] as List?) ?? const [];

    final rejectedDocs = (data['rejectedDocuments'] as List?) ?? const [];

    final userJson = data['user'] as Map<String, dynamic>?;
    final user = userJson != null ? AuthUserModel.fromJson(userJson) : null;

    AccountReviewStatus status;

    // final savedStatus = parseAccountStatus(data['accountStatus']?.toString());

    // if (savedStatus != null) {
    //   status = savedStatus;
    // } else if (rejectedDocs.isNotEmpty) {
    //   status = AccountReviewStatus.notApproved;
    // } else if (approvedDocs.isNotEmpty || pendingDocs.isNotEmpty) {
    //   status = AccountReviewStatus.underReview;
    // } else {
    //   status = AccountReviewStatus.underReview;
    // }

    if (rejectedDocs.isNotEmpty) {
      status = AccountReviewStatus.notApproved;
    } else if (pendingDocs.isNotEmpty) {
      status = AccountReviewStatus.underReview;
    } else {
      status = AccountReviewStatus.approved;
    }

    return AuthResponseModel(
      token: data['token']?.toString(),
      user: user,
      isOnboarded: data['isOnboarded'] == true,
      accountStatus: status,
      approvedDocuments: approvedDocs,
      pendingDocuments: pendingDocs,
      rejectedDocuments: rejectedDocs,
    );
  }
}
//   factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
//     final dynamic rawData = json['data'];
//     final Map<String, dynamic> data = rawData is Map<String, dynamic>
//         ? rawData
//         : json;

//     final List<dynamic> rejectedDocs =
//         (data['rejectedDocuments'] as List?) ?? const [];

//     AccountReviewStatus status;
//     // String? rejectReason = data['rejectedReason']?.toString();

//     final AccountReviewStatus? savedStatus = parseAccountStatus(
//       data['accountStatus']?.toString(),
//     );

//     if (savedStatus != null) {
//       status = savedStatus;
//     } else if (rejectedDocs.isNotEmpty) {
//       status = AccountReviewStatus.notApproved;

//       // final dynamic firstRejectedDoc = rejectedDocs.first;
//       // if (firstRejectedDoc is Map<String, dynamic>) {
//       //   rejectReason = firstRejectedDoc['rejectReason']?.toString();
//       // }
//     } else if (data['isOnboarded'] == false) {
//       status = AccountReviewStatus.underReview;
//     } else {
//       status = AccountReviewStatus.approved;
//     }

//     final dynamic userJson = data['user'];
//     return AuthResponseModel(
//       token: data['token']?.toString(),
//       user: userJson is Map<String, dynamic>
//           ? AuthUserModel.fromJson(userJson)
//           : null,
//       isOnboarded: data['isOnboarded'] == true,
//       accountStatus: status,
//       isUserProfileCreated:
//           (data['approvedDocuments'] as List?)?.isNotEmpty == true ||
//           (data['pendingDocuments'] as List?)?.isNotEmpty == true ||
//           (data['rejectedDocuments'] as List?)?.isNotEmpty == true,
//       // rejectedReason: rejectReason,
//     );
//   }
// }

AccountReviewStatus? parseAccountStatus(String? value) {
  switch (value) {
    case 'approved':
      return AccountReviewStatus.approved;
    case 'underReview':
      return AccountReviewStatus.underReview;
    case 'notApproved':
      return AccountReviewStatus.notApproved;
    default:
      return null;
  }
}

class AuthUserModel extends AuthUserEntity {
  AuthUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    super.profilePicture,
    required super.phone,
    super.stripeAccountId,
    super.stripeCustomerId,
    required super.balance,
    required super.locale,
    required super.isNotificationEnabled,
    required super.role,
    super.driverLicense,
    super.vehicleRegistration,
    super.insurance,
    super.vehicleDetails,
    super.subscriptionStatus,
    required super.v,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    DocumentEntity? parseDoc(Map<String, dynamic>? doc) {
      if (doc == null) return null;

      return DocumentEntity(
        id: doc['_id'] ?? '',
        status: parseStatus(doc['status']),
        rejectReason: doc['rejectReason'],
      );
    }

    return AuthUserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      phone: json['phone'] ?? '',
      stripeAccountId: json['stripeAccountId'],
      stripeCustomerId: json['stripeCustomerId'],
      balance: json['balance'] ?? 0,
      locale: json['locale'] ?? 'en',
      isNotificationEnabled: json['isNotificationEnabled'] ?? true,
      role: json['role'] ?? 'user',
      driverLicense: parseDoc(json['driverLicense']),
      vehicleRegistration: parseDoc(json['vehicleRegistration']),
      insurance: parseDoc(json['insurance']),
      vehicleDetails: parseDoc(json['vehicleDetails']),
      // subscriptionStatus: 'inactive',
      subscriptionStatus: json['subscription']?['status'],
      v: json['__v'] ?? 0,
    );
  }
}
