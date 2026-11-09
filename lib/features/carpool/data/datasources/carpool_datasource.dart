import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/features/carpool/data/models/view_carpool_passenger_model.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/error_handler.dart';

abstract class CarpoolDataSource {
  Future<Either<Failure, List<CarpoolPassengerModel>>> viewPassenger(
    String carpoolId,
  );
}

class CarpoolDataSourceImpl implements CarpoolDataSource {
  final ApiService apiService;

  CarpoolDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, List<CarpoolPassengerModel>>> viewPassenger(
    String carpoolId,
  ) {
    return handleNetworkError(() async {
      final res = await apiService.get(
        "${ApiEndpoints.viewPassenger}$carpoolId/passengers",
      );

      final List data = res.data['data']['passengers'] ?? [];

      return data.map((json) => CarpoolPassengerModel.fromJson(json)).toList();
    });
  }
}
