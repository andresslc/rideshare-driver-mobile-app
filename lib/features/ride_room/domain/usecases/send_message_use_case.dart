import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/chat_params.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_repository.dart';
import 'package:fpdart/fpdart.dart';

class SendMessageUseCase {
  final RideRepository repository;
  SendMessageUseCase(this.repository);

  Future<Either<Failure, bool>> call(SendMessageParams params) async {
    return await repository.sendMessage(params);
  }
}
