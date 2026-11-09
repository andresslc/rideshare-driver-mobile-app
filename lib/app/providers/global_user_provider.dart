// import 'package:driver_app/core/core.dart';
// import 'package:driver_app/features/auth/domain/entities/otp_verification_result.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:fpdart/fpdart.dart';

// final globalUserProvider =
//     NotifierProvider<GlobalUserNotifier, GlobalUserState>(
//       GlobalUserNotifier.new,
//     );

// class GlobalUserState {
//   final bool isLoggedIn;
//   final String? token;
//   final Map<String, dynamic>? user;
//   final String? error;

//   const GlobalUserState({
//     this.isLoggedIn = false,
//     this.token,
//     this.user,
//     this.error,
//   });

//   static const Object _sentinel = Object();

//   GlobalUserState copyWith({
//     bool? isLoggedIn,
//     Object? token = _sentinel,
//     Object? user = _sentinel,
//     Object? error = _sentinel,
//   }) {
//     return GlobalUserState(
//       isLoggedIn: isLoggedIn ?? this.isLoggedIn,
//       token: identical(token, _sentinel) ? this.token : token as String?,
//       user: identical(user, _sentinel)
//           ? this.user
//           : user as Map<String, dynamic>?,
//       error: identical(error, _sentinel) ? this.error : error as String?,
//     );
//   }
// }

// class GlobalUserNotifier extends Notifier<GlobalUserState> {
//   static const String _tokenKey = 'token';
//   static const String _userKey = 'user';

//   late final StorageService _storageService;
//   late final ApiService _apiService;

//   @override
//   GlobalUserState build() {
//     _storageService = locator<StorageService>();
//     _apiService = locator<ApiService>();

//     final token = _storageService.getToken;
//     if (token != null && token.isNotEmpty) {
//       _apiService.setAuthToken(token);
//     }

//     return GlobalUserState(
//       isLoggedIn: _storageService.isLoggedIn,
//       token: token,
//     );
//   }

//   FutureEither<void> applyOtpResult(OtpVerificationResult result) async {
//     final persisted = await TaskEither<Failure, void>.tryCatch(() async {
//       final token = result.token?.trim();

//       if (token != null && token.isNotEmpty) {
//         await _storageService.setToken(token);
//         _apiService.setAuthToken(token);
//         await _storageService.setLoginStatus(true);
//       } else {
//         await _storageService.remove(_tokenKey);
//         await _storageService.setLoginStatus(false);
//       }

//       if (result.user != null) {
//         await _storageService.setUser(result.user);
//       } else {
//         await _storageService.remove(_userKey);
//       }
//     }, (error, _) => CacheFailure(errorMessage: error.toString())).run();

//     persisted.fold(
//       (failure) {
//         state = state.copyWith(error: failure.errorMessage);
//       },
//       (_) {
//         state = state.copyWith(
//           isLoggedIn: result.hasSession,
//           token: result.token,
//           user: result.user,
//           error: null,
//         );
//       },
//     );

//     return persisted;
//   }
// }
