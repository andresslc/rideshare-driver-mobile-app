import 'package:driver_app/core/di/service_locator.dart';
import 'package:driver_app/features/carpool/presentation/states/carpool_state.dart';
import 'package:driver_app/features/carpool/domain/usecases/carpool_usecase.dart';
import 'package:flutter_riverpod/legacy.dart';


final carpoolProvider =
    StateNotifierProvider<CarpoolNotifier, CarpoolState>((ref) {
  final viewPassengerUseCase = locator<ViewPassengerUseCase>();
  return CarpoolNotifier(viewPassengerUseCase);
});
class CarpoolNotifier extends StateNotifier<CarpoolState> {
  final ViewPassengerUseCase _viewPassengerUseCase;

  CarpoolNotifier(this._viewPassengerUseCase) : super(CarpoolState());

  Future<bool> viewPassenger(String carpoolId) async {
    final normalizedCarpoolId = carpoolId.trim();
    if (normalizedCarpoolId.isEmpty) {
      state = state.copyWith(error: 'Missing carpool id');
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
      passengers: const [],
    );
    final result = await _viewPassengerUseCase(normalizedCarpoolId);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (passengers) {
        state = state.copyWith(isLoading: false, passengers: passengers);
        return true;
      },
    );
  }

  void removePassengerByBookingId(String bookingId) {
    final normalizedBookingId = bookingId.trim();
    if (normalizedBookingId.isEmpty) return;

    final updatedPassengers = state.passengers
        .where((p) => p.bookingId.trim() != normalizedBookingId)
        .toList();

    state = state.copyWith(passengers: updatedPassengers);
  }
}
