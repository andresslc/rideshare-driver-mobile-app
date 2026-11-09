import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetChatHistoryUseCase {
  final RideRepository repository;
  GetChatHistoryUseCase(this.repository);

  Future<Either<Failure, List<ChatMessageEntity>>> call(String rideId) async {
    return await repository.getChatHistory(rideId);
  }
}
