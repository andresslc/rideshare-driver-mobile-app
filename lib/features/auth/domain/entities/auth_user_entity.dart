// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../presentation/screens/account_review_status_screen.dart';
import '../../../../core/utils/name_utils.dart';

// class AuthResponseEntity {
//   final bool isOnboarded;
//   final String token;
//   final UserEntity user;
//   final AccountReviewStatus accountStatus;
//   final String? rejectedReason;

//   AuthResponseEntity({
//     required this.isOnboarded,
//     required this.token,
//     required this.user,
//     required this.accountStatus,
//     this.rejectedReason,
//   });
// // }
// class AuthResponseEntity {
//   final bool isOnboarded;
//   final String? token; // 👈 nullable
//   final AuthUserEntity? user; // 👈 nullable
//   final AccountReviewStatus accountStatus;
//   // final String? rejectedReason;

//   AuthResponseEntity({
//     required this.isOnboarded,
//     this.token,
//     this.user,
//     required this.accountStatus,
//     // this.rejectedReason,
//   });
// }
class AuthResponseEntity {
  final bool isOnboarded;
  final String? token;
  final AuthUserEntity? user;
  final AccountReviewStatus accountStatus;

  // 🔥 Raw document lists from TOP-LEVEL data
  final List<dynamic> approvedDocuments;
  final List<dynamic> pendingDocuments;
  final List<dynamic> rejectedDocuments;

  const AuthResponseEntity({
    required this.isOnboarded,
    this.token,
    this.user,
    required this.accountStatus,
    required this.approvedDocuments,
    required this.pendingDocuments,
    required this.rejectedDocuments,
  });

  /// 🔥 Derived Property (Not Stored)
  bool get isUserProfileCreated =>
      approvedDocuments.isNotEmpty ||
      pendingDocuments.isNotEmpty ||
      rejectedDocuments.isNotEmpty;
}

class AuthUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String phone;

  final String? stripeAccountId;
  final String? stripeCustomerId;

  final num balance;
  final String locale;
  final bool isNotificationEnabled;
  final String role;

  // 🔥 New Fields
  final DocumentEntity? driverLicense;
  final DocumentEntity? vehicleRegistration;
  final DocumentEntity? insurance;
  final DocumentEntity? vehicleDetails;

  final String? subscriptionStatus;

  final int v;

  const AuthUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    required this.phone,
    this.stripeAccountId,
    this.stripeCustomerId,
    required this.balance,
    required this.locale,
    required this.isNotificationEnabled,
    required this.role,
    this.driverLicense,
    this.vehicleRegistration,
    this.insurance,
    this.vehicleDetails,
    this.subscriptionStatus,
    required this.v,
  });

  /// 🔥 Business Logic Helper
  bool get hasRejectedDocument =>
      driverLicense?.status == DocumentStatus.rejected ||
      vehicleRegistration?.status == DocumentStatus.rejected ||
      insurance?.status == DocumentStatus.rejected ||
      vehicleDetails?.status == DocumentStatus.rejected;

  String get displayName => composeFullName(firstName, lastName);
  String get name => displayName;
}

DocumentStatus parseStatus(String? status) {
  switch (status) {
    case 'approved':
      return DocumentStatus.approved;
    case 'rejected':
      return DocumentStatus.rejected;
    default:
      return DocumentStatus.pending;
  }
}

enum DocumentStatus { approved, rejected, pending }

class DocumentEntity {
  final String id;
  final DocumentStatus status;
  final String? rejectReason;

  const DocumentEntity({
    required this.id,
    required this.status,
    this.rejectReason,
  });
}

// // extension AuthResponseEntityMapper on AuthResponseEntity {
// //   Map<String, dynamic> toJson() {
// //     return {'token': token, 'isOnboarded': isOnboarded, 'user': user.toJson()};
// //   }
// // }
// extension AuthResponseEntityMapper on AuthResponseEntity {
//   Map<String, dynamic> toJson() {
//     return {
//       'token': token,
//       'isOnboarded': isOnboarded,
//       'user': user?.toJson(), // ✅ null safe
//     };
//   }
// }
extension AuthResponseEntityMapper on AuthResponseEntity {
  Map<String, dynamic> toJson() {
    return {
      'data': {
        'token': token,
        'isOnboarded': isOnboarded,

        // Save enum as String
        'accountStatus': accountStatus.name,

        // Save rejection reason (if any)
        // 'rejectedReason': rejectedReason,

        // User object
        'user': user?.toJson(),
      },
    };
  }
}

extension UserEntityMapper on AuthUserEntity {
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'profilePicture': profilePicture,
      'phone': phone,
      'stripeAccountId': stripeAccountId,
      'stripeCustomerId': stripeCustomerId,
      'balance': balance,
      'locale': locale,
      'isNotificationEnabled': isNotificationEnabled,
      'role': role,
      'driverLicense': driverLicense?.toJson(),
      'vehicleRegistration': vehicleRegistration?.toJson(),
      'insurance': insurance?.toJson(),
      'vehicleDetails': vehicleDetails?.toJson(),
      'subscription': subscriptionStatus != null
          ? {'status': subscriptionStatus}
          : null,
      '__v': v,
    };
  }
}

extension DocumentEntityMapper on DocumentEntity {
  Map<String, dynamic> toJson() {
    return {'_id': id, 'status': status.name, 'rejectReason': rejectReason};
  }
}
