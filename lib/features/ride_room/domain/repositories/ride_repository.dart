import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/params/chat_params.dart';

abstract class RideRepository {
  Future<Either<Failure, RideRequestResponseModel>> availableRides();
  Future<Either<Failure, RideEntity>> getRideById(String rideId);
  Future<Either<Failure, List<ChatMessageEntity>>> getChatHistory(
    String rideId,
  );
  Future<Either<Failure, bool>> sendMessage(SendMessageParams params);
}
