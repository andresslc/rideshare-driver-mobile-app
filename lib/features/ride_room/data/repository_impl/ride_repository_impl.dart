import 'package:driver_app/core/errors/failure.dart';
import 'package:driver_app/core/params/chat_params.dart';
import 'package:driver_app/features/ride_room/data/datasources/ride_datasource.dart';
import 'package:driver_app/features/ride_room/data/models/ride_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/chat_entity.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';
import 'package:driver_app/features/ride_room/domain/repositories/ride_repository.dart';
import 'package:fpdart/fpdart.dart';

class RideRepositoryImpl implements RideRepository {
  final RideDataSource dataSource;

  RideRepositoryImpl(this.dataSource);

  @override
  @override
  Future<Either<Failure, RideRequestResponseModel>> availableRides() async {
    final response = await dataSource.availableRides();


    return response.fold(
      (left) => Left(ServerFailure(message: left.message)),
      (right) => Right(right),
    );
  }

  @override
  Future<Either<Failure, RideEntity>> getRideById(String rideId) async {
    final response = await dataSource.getRideById(rideId);
    return response.fold(
      (left) => Left(ServerFailure(message: left.message)),
      (right) => Right(right),
    );
  }

  @override
  Future<Either<Failure,List<ChatMessageEntity>>> getChatHistory(String rideId) async {
    final response = await dataSource.getChatHistory(rideId);
    return response.fold(
          (left) => Left(ServerFailure(message: left.message)),
          (right) => Right(right),
    );
  }

  @override
  Future<Either<Failure, bool>> sendMessage(SendMessageParams params) async {
    final response = await dataSource.sendMessage(params);
    return response.fold(
          (left) => Left(ServerFailure(message: left.message)),
          (right) => Right(right),
    );
  }
}
