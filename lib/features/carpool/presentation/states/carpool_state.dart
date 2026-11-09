import 'package:driver_app/features/carpool/domain/entities/view_carpool_passenger_entity.dart';

class CarpoolState {
  final bool isLoading;
  final String? error;
  final List<CarpoolPassengerEntity> passengers;

  CarpoolState({
    this.isLoading = false,
    this.error,
    this.passengers = const [],
  });

  CarpoolState copyWith({
    bool? isLoading,
    String? error,
    List<CarpoolPassengerEntity>? passengers,
  }) {
    return CarpoolState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      passengers: passengers ?? this.passengers,
    );
  }
}