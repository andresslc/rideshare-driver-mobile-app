import 'package:driver_app/core/constants/api_endpoints.dart';
import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/services/api_service.dart';
import 'package:driver_app/features/ride_room/data/models/chat_model.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../core/params/chat_params.dart';

abstract class RideDataSource {
  Future<Either<Failure, RideRequestResponseModel>> availableRides();

  Future<Either<Failure, RideModel>> getRideById(String rideId);

  Future<Either<Failure, List<ChatMessageModel>>> getChatHistory(String rideId);

  Future<Either<Failure, bool>> sendMessage(SendMessageParams params);
}

class RideDataSourceImpl implements RideDataSource {
  final ApiService apiService;

  RideDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, RideRequestResponseModel>> availableRides() {
    return handleNetworkError(() async {
      final res = await apiService.get(
        ApiEndpoints.availableRides,
        queryParameters: {"status": "requested"},
      );

      final Map<String, dynamic> json = res.data;

      return RideRequestResponseModel.fromJson(json);
    });
  }

  @override
  Future<Either<Failure, RideModel>> getRideById(String rideId) {
    return handleNetworkError(() async {
      final res = await apiService.get(ApiEndpoints.rideById(rideId));
      final Map<String, dynamic> payload = Map<String, dynamic>.from(res.data);

      final dynamic data = payload['data'];
      if (data is Map<String, dynamic>) {
        return RideModel.fromJson(data);
      }
      if (data is Map) {
        return RideModel.fromJson(Map<String, dynamic>.from(data));
      }

      return RideModel.fromJson(payload);
    });
  }

  @override
  Future<Either<Failure, List<ChatMessageModel>>> getChatHistory(
    String rideId,
  ) {
    return handleNetworkError(() async {
      final res = await apiService.get(ApiEndpoints.getChatHistory(rideId));

      final List data = res.data['data'] ?? [];

      final chats = data.map((e) => ChatMessageModel.fromJson(e)).toList();

      return chats;
    });
  }

  @override
  Future<Either<Failure, bool>> sendMessage(SendMessageParams params) {
    return handleNetworkError(() async {
      final res = await apiService.post(
        ApiEndpoints.sendMessage,
        data: params.toJson(),
      );
      final bool isSuccess = res.data['success'] ?? false;
      return isSuccess;
    });
  }
}
