// import 'dart:developer';

// import 'package:flutter_bloc/flutter_bloc.dart';

// /// Logs all BLoC transitions and errors in debug mode.
// ///
// /// Register in `main()`:
// /// ```dart
// /// Bloc.observer = AppBlocObserver();
// /// ```
// class AppBlocObserver extends BlocObserver {
//   @override
//   void onTransition(Bloc bloc, Transition transition) {
//     super.onTransition(bloc, transition);
//     log(
//       '${bloc.runtimeType} | ${transition.event.runtimeType} → ${transition.nextState.runtimeType}',
//       name: 'BLoC',
//     );
//   }

//   @override
//   void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
//     super.onError(bloc, error, stackTrace);
//     log(
//       '${bloc.runtimeType} ERROR: $error',
//       name: 'BLoC',
//       error: error,
//       stackTrace: stackTrace,
//     );
//   }
// }
