import 'package:driver_app/features/reviews/presentation/states/report_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/params/report_params.dart';
import '../../domain/use_case/report_usecase.dart';

final reportProvider = NotifierProvider<ReportController, ReportState>(
  ReportController.new,
);

class ReportController extends Notifier<ReportState> {
  ReportUsecase get _reportUsecase => locator<ReportUsecase>();

  @override
  ReportState build() {
    return const ReportInitial();
  }

  Future<void> reportsubmit(ReportParam params) async {
    state = const ReportLoading();

    final result = await _reportUsecase.call(params);

    result.fold(
      (failure) => state = ReportError(failure.message),
      (message) => state = ReportSuccess(message),
    );
  }
}
