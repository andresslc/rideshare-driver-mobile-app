import 'package:driver_app/features/auth/presentation/screens/account_review_status_screen.dart';
import 'package:driver_app/features/auth/presentation/screens/login_screen.dart';
import 'package:driver_app/features/auth/presentation/screens/subscription_review_status_screen.dart';
import 'package:driver_app/features/auth/presentation/screens/verification_screen.dart';
import 'package:driver_app/features/bank_account/presentation/screens/add_bank_account_screen.dart';
import 'package:driver_app/features/bank_account/presentation/screens/bank_accounts_screen.dart';
import 'package:driver_app/features/carpool/domain/entities/carpool_entity.dart';
import 'package:driver_app/features/carpool/presentation/screens/carpool_bottomsheet.dart';
import 'package:driver_app/features/carpool/presentation/screens/carpool_feedback_screen.dart';
import 'package:driver_app/features/carpool/presentation/screens/passenger_list.dart';
import 'package:driver_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:driver_app/features/reviews/presentation/screens/feed_back_screen.dart';
import 'package:driver_app/features/ride_history/domain/enitities/carpool_history_entities.dart';
import 'package:driver_app/features/ride_history/presentation/screens/passenger_detail_screen.dart';
import 'package:driver_app/features/ride_history/presentation/screens/ride_detail_carpool_screen.dart';
import 'package:driver_app/features/chat/presentation/chat_screen_args.dart';
import 'package:driver_app/features/chat/presentation/screens/chat_screen.dart';
import 'package:driver_app/features/ride_history/presentation/screens/rider_detail_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/delete_account_otp_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/delete_account_verify_otp_screen.dart';
import 'package:driver_app/features/ride_history/presentation/screens/ride_history_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/language_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/saved_locations_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/setting_screen.dart';
import 'package:driver_app/features/settings/presentation/screens/theme_preferences.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_driver_license_screen.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_insurance_screen.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_personal_information_screen.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_vehicle_details_screen.dart';
import 'package:driver_app/features/user_profile/presentation/screens/edit_vehicle_registration_screen.dart';
import 'package:driver_app/features/carpool/presentation/screens/create_carpool_screen.dart';
import 'package:driver_app/features/user_profile/presentation/screens/profile_screen.dart';
import 'package:driver_app/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:driver_app/shared/screens/place_picker_screen.dart';
import 'package:driver_app/shared/screens/splash_screen.dart';
import 'package:driver_app/shared/screens/success_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/account_status_screen.dart';
import '../../features/notification/presentation/screens/notifications_screen.dart';
import '../../features/driver_referral/presentation/screens/driver_referral_screen.dart';
import '../../features/reviews/presentation/screens/reviews_screen.dart';
import '../../features/ride_room/domain/entities/ride_entities.dart';
import '../../features/ride_room/presentation/screens/ride_request_screen.dart';
import '../../features/ride_room/presentation/screens/ride_room_screen.dart';
import '../../features/settings/presentation/screens/invite_friends_screen.dart';
import 'dashboard_refresh_on_wallet_pop_observer.dart';
import 'routes.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [DashboardRefreshOnWalletPopObserver()],
    initialLocation: Routes.root.path,
    debugLogDiagnostics: kDebugMode,
    routes: [
      GoRoute(
        name: Routes.root.name,
        path: Routes.root.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        name: Routes.login.name,
        path: Routes.login.path,
        pageBuilder: (context, state) {
          final extra = state.extra;
          String? warningId;
          String? sessionExpiredId;
          String? sessionExpiredMessage;

          if (extra is bool && extra) {
            warningId = 'extra_warning';
          } else if (extra is Map) {
            final extraMap = Map<String, dynamic>.from(extra);
            final extraWarning = extraMap['warningId']?.toString().trim();
            final hasSessionExpired = extraMap['sessionExpired'] == true;
            final backendMessage =
                (extraMap['message'] ?? extraMap['sessionExpiredMessage'])
                    ?.toString()
                    .trim();

            if (extraWarning != null && extraWarning.isNotEmpty) {
              warningId = extraWarning;
            }

            if (hasSessionExpired) {
              sessionExpiredId = (extraMap['dialogId'] ?? state.pageKey.value)
                  .toString();
              if (backendMessage != null && backendMessage.isNotEmpty) {
                sessionExpiredMessage = backendMessage;
              }
            }
          }

          final queryWarning = state.uri.queryParameters['show_warning'];
          warningId = queryWarning ?? warningId;
          final querySessionExpired =
              state.uri.queryParameters['sessionExpired'];
          final queryMessage = state.uri.queryParameters['message']?.trim();

          if (sessionExpiredId == null &&
              (querySessionExpired == 'true' || querySessionExpired == '1')) {
            sessionExpiredId = state.pageKey.value;
            if (queryMessage != null && queryMessage.isNotEmpty) {
              sessionExpiredMessage = queryMessage;
            }
          }

          return CupertinoPage(
            key: state.pageKey,
            child: LoginScreen(
              warningId: warningId,
              sessionExpiredId: sessionExpiredId,
              sessionExpiredMessage: sessionExpiredMessage,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.verification.name,
        path: Routes.verification.path,
        pageBuilder: (context, state) {
          final phoneNumber = state.extra as String;
          return CupertinoPage(
            key: state.pageKey,
            child: VerificationScreen(phoneNumber: phoneNumber),
          );
        },
      ),
      GoRoute(
        name: Routes.accountReviewStatus.name,
        path: Routes.accountReviewStatus.path,
        pageBuilder: (context, state) {
          final args = state.extra is AccountReviewStatusArgs
              ? state.extra as AccountReviewStatusArgs
              : const AccountReviewStatusArgs();
          return CupertinoPage(
            key: state.pageKey,
            child: AccountReviewStatusScreen(args: args),
          );
        },
      ),
      GoRoute(
        name: Routes.subscriptionStatus.name,
        path: Routes.subscriptionStatus.path,
        pageBuilder: (context, state) {
          final args = state.extra as String?;
          return CupertinoPage(
            key: state.pageKey,
            child: SubcriptionReviewStatusScreen(status: args),
          );
        },
      ),
      // ── Notification  ────────────────────────────────────────
      GoRoute(
        name: Routes.notificationsScreen.name,
        path: Routes.notificationsScreen.path,
        pageBuilder: (context, state) {
          // final currentSheet =
          //     ((state.extra as RideSheetsType?) ??
          //     RideSheetsType.whereToGoSheet);
          return CupertinoPage(
            key: state.pageKey,
            child: const NotificationsScreen(),
          );
        },
      ),
      // GoRoute(
      //   name: Routes.ridedetailcarpool.name,
      //   path: Routes.ridedetailcarpool.path,
      //   pageBuilder: (context, state) {
      //     final extraData = state.extra as Map<String, dynamic>?;
      //     final rideLabel = extraData?['rideLabel'] as String? ?? '';
      //     final rideId = extraData?['rideId'] as String? ?? '';
      //     final routes =
      //         extraData?['routes'] as List<CarpoolRouteEntity>? ?? [];
      //     final startTime =
      //         extraData?['startTime'] as DateTime? ?? DateTime.now();
      //     final value = extraData?['avgTime'];

      //     final int avgTime = (value is DateTime)
      //         ? value.millisecondsSinceEpoch
      //         : (value is int ? value : 0);
      //     final totalDistance = (extraData?['totalDistance'] is num)
      //         ? (extraData?['totalDistance'] as num).toDouble()
      //         : 0.0;
      //     return CupertinoPage(
      //       key: state.pageKey,
      //       child: RideDetailCarpoolScreen(
      //         rideId: rideId,
      //         rideLabel: rideLabel,
      //         routes: routes,
      //         startTime: startTime,
      //         avgTime: avgTime,
      //         totalDistance: totalDistance,
      //       ),
      //     );
      //   },
      // ),
      GoRoute(
        name: Routes.ridedetailcarpool.name,
        path: Routes.ridedetailcarpool.path,
        pageBuilder: (context, state) {
          // cast extra directly as CarpoolRideEntity
          final ride = state.extra as CarpoolRideEntity;
          //     final startTime =
          //         extraData?['startTime'] as DateTime? ?? DateTime.now();
          //     final value = extraData?['avgTime'];

          return CupertinoPage(
            key: state.pageKey,
            child: RideDetailCarpoolScreen(ride: ride),
          );
        },
      ),
      GoRoute(
        name: Routes.invitefriends.name,
        path: Routes.invitefriends.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const InviteFriendsScreen(),
        ),
      ),
      GoRoute(
        name: Routes.driverReferral.name,
        path: Routes.driverReferral.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const DriverReferralScreen(),
        ),
      ),
      GoRoute(
        name: Routes.success.name,
        path: Routes.success.path,
        pageBuilder: (context, state) {
          final args = state.extra is SuccessArgs
              ? state.extra as SuccessArgs
              : const SuccessArgs();
          return CupertinoPage(
            key: state.pageKey,
            child: SuccessScreen(args: args),
          );
        },
      ),
      GoRoute(
        name: Routes.home.name,
        path: Routes.home.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const Dashboard()),
      ),
      GoRoute(
        name: Routes.wallet.name,
        path: Routes.wallet.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          name: state.name ?? Routes.wallet.name,
          child: const WalletScreen(),
        ),
      ),
      GoRoute(
        name: Routes.bankAccount.name,
        path: Routes.bankAccount.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const BankAccountsScreen(),
        ),
      ),
      GoRoute(
        name: Routes.addBankAccount.name,
        path: Routes.addBankAccount.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const AddBankAccountScreen(),
        ),
      ),
      GoRoute(
        name: Routes.ridehistory.name,
        path: Routes.ridehistory.path,
        pageBuilder: (context, state) {
          final initialStatus =
              (state.extra as Map<String, dynamic>?)?["status"] ?? "completed";

          return CupertinoPage(
            key: state.pageKey,
            child: RideHistoryScreen(initialStatus: initialStatus),
          );
        },
      ),
      GoRoute(
        name: Routes.ridehistorydetail.name,
        path: Routes.ridehistorydetail.path,
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          final rideId = extraData?['rideId'] as String? ?? '';
          final rideLabel = extraData?['rideLabel'] as String? ?? '';
          final rideStatus = extraData?['rideStatus'] as String?;
          final userId = extraData?['userId'] as String? ?? '';
          final specialRequest = extraData?['specialRequest'] as String?;
          final cancellationReason =
              extraData?['cancellationReason'] as String?;
          final cancelledBy = extraData?['cancelledBy'] as String?;
          return CupertinoPage(
            key: state.pageKey,
            child: RiderDetailScreen(
              rideId: rideId,
              userId: userId,
              rideLabel: rideLabel,
              rideStatus: rideStatus,
              specialRequest: specialRequest,
              cancellationReason: cancellationReason,
              cancelledBy: cancelledBy,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.passengerdetail.name,
        path: Routes.passengerdetail.path,
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          // final rideId = extraData?['rideId'] as String? ?? '';
          final carpoolId = extraData?['carpoolId'] as String? ?? "";
          return CupertinoPage(
            key: state.pageKey,
            child: PassengerDetailScreen(
              // rideId: rideId,
              carpoolId: carpoolId,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.settings.name,
        path: Routes.settings.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const SettingsScreen()),
      ),
      GoRoute(
        name: Routes.themePreferences.name,
        path: Routes.themePreferences.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const ThemePreferencesScreen(),
        ),
      ),
      GoRoute(
        name: Routes.language.name,
        path: Routes.language.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const LanguageScreen()),
      ),
      GoRoute(
        name: Routes.savedLocations.name,
        path: Routes.savedLocations.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const SavedLocationsScreen(),
        ),
      ),
      GoRoute(
        name: Routes.deleteAccountOTP.name,
        path: Routes.deleteAccountOTP.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: DeleteAccountOTPScreen()),
      ),
      GoRoute(
        name: Routes.deleteAccountVerify.name,
        path: Routes.deleteAccountVerify.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const DeleteAccountVerifyOTPScreen(),
        ),
      ),
      // Add more route groups here…
      GoRoute(
        name: Routes.profile.name,
        path: Routes.profile.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const ProfileScreen()),
      ),
      GoRoute(
        name: Routes.editPersonalInformation.name,
        path: Routes.editPersonalInformation.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const EditPersonalInformationScreen(),
        ),
      ),
      GoRoute(
        name: Routes.editDriverLicense.name,
        path: Routes.editDriverLicense.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const EditDriverLicenseScreen(),
        ),
      ),
      GoRoute(
        name: Routes.editInsurance.name,
        path: Routes.editInsurance.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const EditInsuranceScreen(),
        ),
      ),
      GoRoute(
        name: Routes.editVehicleRegistration.name,
        path: Routes.editVehicleRegistration.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const EditVehicleRegistrationScreen(),
        ),
      ),
      GoRoute(
        name: Routes.editVehicleDetails.name,
        path: Routes.editVehicleDetails.path,
        pageBuilder: (context, state) => CupertinoPage(
          key: state.pageKey,
          child: const EditVehicleDetailsScreen(),
        ),
      ),

      //reviews
      GoRoute(
        name: Routes.reviews.name,
        path: Routes.reviews.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const ReviewsScreen()),
      ),
      GoRoute(
        name: Routes.feedback.name,
        path: Routes.feedback.path,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final rideId = extra?['rideId'] as String? ?? '';
          final carpoolId = extra?['carpoolId'] as String?;
          final user =
              extra?['user'] as RideUserEntity? ??
              const RideUserEntity(firstName: '', lastName: '');

          return CupertinoPage(
            key: state.pageKey,
            child: FeedBackScreen(
              user: user,
              rideId: rideId,
              carpoolId: carpoolId,
            ),
          );
        },
      ),

      GoRoute(
        name: Routes.rideRoom.name,
        path: Routes.rideRoom.path,
        pageBuilder: (context, state) =>
            CupertinoPage(key: state.pageKey, child: const RideRoomScreen()),
      ),

      GoRoute(
        name: Routes.accountStatus.name,
        path: Routes.accountStatus.path,
        pageBuilder: (context, state) {
          return CupertinoPage(
            key: state.pageKey,
            child: AccountStatusScreen(),
          );
        },
      ),
      GoRoute(
        name: Routes.rideRequest.name,
        path: Routes.rideRequest.path,
        pageBuilder: (context, state) {
          // `rideId` comes from the new-request push so the screen can open on
          // that request's card.
          final String rideId =
              state.uri.queryParameters['rideId']?.trim() ?? '';
          return CupertinoPage(
            key: state.pageKey,
            child: RideRequestScreen(
              focusRideId: rideId.isEmpty ? null : rideId,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.carpoolCreate.name,
        path: Routes.carpoolCreate.path,
        pageBuilder: (context, state) {
          return CupertinoPage(
            key: state.pageKey,
            child: const CreateCarpoolScreen(),
          );
        },
      ),
      GoRoute(
        name: Routes.carpoolFeedback.name,
        path: Routes.carpoolFeedback.path,
        pageBuilder: (context, state) {
          final args = state.extra is CarpoolFeedbackArgs
              ? state.extra as CarpoolFeedbackArgs
              : const CarpoolFeedbackArgs(
                  rideId: '',
                  passengers: <CarpoolIncomingRequestEntity>[],
                );
          return CupertinoPage(
            key: state.pageKey,
            child: CarpoolFeedbackScreen(args: args),
          );
        },
      ),
      GoRoute(
        name: Routes.passengerList.name,
        path: Routes.passengerList.path,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final id =
              extra?['carpoolId'] as String? ?? extra?['id'] as String? ?? '';
          return CupertinoPage(
            key: state.pageKey,
            child: PassengerList(carpoolId: id),
          );
        },
      ),
      GoRoute(
        name: Routes.rideMap.name,
        path: Routes.rideMap.path,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final pickupLocation = extra?['pickupLocation'] as SelectedLocation?;
          final dropoffLocation =
              extra?['dropoffLocation'] as SelectedLocation?;
          return CupertinoPage(
            key: state.pageKey,
            child: RideMapScreen(
              pickupLocation: pickupLocation,
              dropoffLocation: dropoffLocation,
            ),
          );
        },
      ),
      GoRoute(
        name: Routes.chat.name,
        path: Routes.chat.path,
        pageBuilder: (context, state) {
          final q = state.uri.queryParameters;
          final riderName = q['riderName'] ?? '';
          final riderProfileImage = q['riderProfileImage'];
          final rideId = q['rideId'];
          final riderId = q['riderId'];
          final isCarpool = q['isCarpool'] ?? 'false';
          return CupertinoPage(
            key: state.pageKey,
            child: ChatScreen(
              args: ChatScreenArgs(
                rideId: rideId,
                riderId: riderId,
                isCarpool: isCarpool,
                riderName: riderName.isNotEmpty ? riderName : 'Passenger',
                riderProfileImage: riderProfileImage?.isNotEmpty == true
                    ? riderProfileImage
                    : null,
              ),
            ),
          );
        },
      ),
    ],
  );
}
