// import 'package:flutter/material.dart';

// import '../constants/app_colors.dart';

// /// Centralised UI feedback helpers.
// ///
// /// Keeps snackbar/dialog logic out of widgets.
// class UiHelpers {
//   UiHelpers._();

//   // ── Snackbars ──────────────────────────────────────────────────────────

//   static void showSnackBar(
//     BuildContext context,
//     String message, {
//     bool isError = false,
//     Duration duration = const Duration(seconds: 3),
//     SnackBarAction? action,
//   }) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: isError ? AppColors.error : null,
//           duration: duration,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           margin: const EdgeInsets.all(16),
//           action: action,
//         ),
//       );
//   }

//   static void showSuccess(BuildContext context, String message) =>
//       showSnackBar(context, message);

//   static void showError(BuildContext context, String message) =>
//       showSnackBar(context, message, isError: true);

//   // ── Loading Dialog ─────────────────────────────────────────────────────

//   static void showLoading(BuildContext context, {String? message}) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => PopScope(
//         canPop: false,
//         child: AlertDialog(
//           content: Row(
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(width: 20),
//               Expanded(child: Text(message ?? 'Please wait…')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   static void hideLoading(BuildContext context) {
//     if (Navigator.canPop(context)) Navigator.pop(context);
//   }

//   // ── Confirmation Dialog ────────────────────────────────────────────────

//   // static Future<bool> showConfirmation(
//   //   BuildContext context, {
//   //   required String title,
//   //   required String message,
//   //   String confirmText = 'Confirm',
//   //   String cancelText = 'Cancel',
//   // }) async {
//   //   final result = await showDialog<bool>(
//   //     context: context,
//   //     builder: (ctx) => AlertDialog(
//   //       title: Text(title),
//   //       content: Text(message),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(ctx, false),
//   //           child: Text(cancelText),
//   //         ),
//   //         ElevatedButton(
//   //           onPressed: () => Navigator.pop(ctx, true),
//   //           child: Text(confirmText),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   //   return result ?? false;
//   // }
// }
