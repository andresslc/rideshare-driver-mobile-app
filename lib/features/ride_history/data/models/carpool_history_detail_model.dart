// import 'package:driver_app/features/ride_history.dart/domain/enitities/carpool_history_detail_entities.dart';

// class CarpoolModel extends CarpoolEntity {
//   CarpoolModel({
//     required super.id,
//     required super.driver,
//     required super.startingPoint,
//     required super.destination,
//     required super.routes,
//     required super.status,
//     required super.maxPassengers,
//     required super.availableSeats,
//     super.graceTime,
//     required super.passengers,
//     required super.createdAt,
//   });

//   factory CarpoolModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolModel(
//       id: json['_id'] ?? '',
//       driver: CarpoolDriverModel.fromJson(json['driver'] ?? {}),
//       startingPoint: CarpoolPointModel.fromJson(json['startingPoint'] ?? {}),
//       destination: CarpoolPointModel.fromJson(json['destination'] ?? {}),
//       routes: (json['routes'] as List<dynamic>? ?? [])
//           .map((e) => CarpoolRouteModel.fromJson(e))
//           .toList(),
//       status: json['status'] ?? '',
//       maxPassengers: json['maxPassengers'] ?? 0,
//       availableSeats: json['availableSeats'] ?? 0,
//       graceTime: json['graceTime'] != null
//           ? DateTime.parse(json['graceTime'])
//           : null,
//       passengers: (json['passengers'] as List<dynamic>? ?? [])
//           .map((e) => CarpoolPassengerModel.fromJson(e))
//           .toList(),
//       createdAt: DateTime.parse(
//         json['createdAt'] ?? DateTime.now().toIso8601String(),
//       ),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'driver': (driver as CarpoolDriverModel).toJson(),
//       'startingPoint': (startingPoint as CarpoolPointModel).toJson(),
//       'destination': (destination as CarpoolPointModel).toJson(),
//       'routes': routes.map((e) => (e as CarpoolRouteModel).toJson()).toList(),
//       'status': status,
//       'maxPassengers': maxPassengers,
//       'availableSeats': availableSeats,
//       'graceTime': graceTime?.toIso8601String(),
//       'passengers': passengers
//           .map((e) => (e as CarpoolPassengerModel).toJson())
//           .toList(),
//       'createdAt': createdAt.toIso8601String(),
//     };
//   }
// }

// // Driver Model
// class CarpoolDriverModel extends CarpoolDriverEntity {
//   CarpoolDriverModel({
//     required super.id,
//     required super.name,
//     required super.email,
//     super.profilePicture,
//     super.vehicleDetails,
//     required super.rating,
//   });

//   factory CarpoolDriverModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolDriverModel(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       profilePicture: json['profilePicture'],
//       vehicleDetails: json['vehicleDetails'] != null
//           ? VehicleDetailsModel.fromJson(json['vehicleDetails'])
//           : null,
//       rating: (json['rating'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'email': email,
//       'profilePicture': profilePicture,
//       'vehicleDetails': vehicleDetails != null
//           ? (vehicleDetails as VehicleDetailsModel).toJson()
//           : null,
//       'rating': rating,
//     };
//   }
// }

// // Vehicle Model
// class VehicleDetailsModel extends VehicleDetailsEntity {
//   VehicleDetailsModel({
//     required super.id,
//     required super.make,
//     required super.model,
//     required super.yearOfManufacture,
//     required super.color,
//     required super.licensePlateNumber,
//     required super.vehicleType,
//   });

//   factory VehicleDetailsModel.fromJson(Map<String, dynamic> json) {
//     return VehicleDetailsModel(
//       id: json['_id'] ?? '',
//       make: json['make'] ?? '',
//       model: json['model'] ?? '',
//       yearOfManufacture: json['yearOfManufacture'] ?? 0,
//       color: json['color'] ?? '',
//       licensePlateNumber: json['licensePlateNumber'] ?? '',
//       vehicleType: json['vehicleType'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'make': make,
//       'model': model,
//       'yearOfManufacture': yearOfManufacture,
//       'color': color,
//       'licensePlateNumber': licensePlateNumber,
//       'vehicleType': vehicleType,
//     };
//   }
// }

// // Point Model
// class CarpoolPointModel extends CarpoolPointEntity {
//   CarpoolPointModel({required super.placeName, required super.location});

//   factory CarpoolPointModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolPointModel(
//       placeName: json['placeName'] ?? '',
//       location: LocationModel.fromJson(json['location'] ?? {}),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'placeName': placeName,
//       'location': (location as LocationModel).toJson(),
//     };
//   }
// }

// // Location Model
// class LocationModel extends LocationEntity {
//   LocationModel({required super.type, required super.coordinates});

//   factory LocationModel.fromJson(Map<String, dynamic> json) {
//     return LocationModel(
//       type: json['type'] ?? '',
//       coordinates: (json['coordinates'] as List<dynamic>? ?? [])
//           .map((e) => (e as num).toDouble())
//           .toList(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {'type': type, 'coordinates': coordinates};
//   }
// }

// // Route Model
// class CarpoolRouteModel extends CarpoolRouteEntity {
//   CarpoolRouteModel({
//     required super.id,
//     required super.placeName,
//     required super.location,
//     required super.status,
//     required super.order,
//   });

//   factory CarpoolRouteModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolRouteModel(
//       id: json['_id'] ?? '',
//       placeName: json['placeName'] ?? '',
//       location: LocationModel.fromJson(json['location'] ?? {}),
//       status: json['status'] ?? '',
//       order: json['order'] ?? 0,
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'placeName': placeName,
//       'location': (location as LocationModel).toJson(),
//       'status': status,
//       'order': order,
//     };
//   }
// }

// // Passenger Model
// class CarpoolPassengerModel extends CarpoolPassengerEntity {
//   CarpoolPassengerModel({
//     required super.id,
//     required super.user,
//     required super.bookingId,
//     required super.pickupStop,
//     required super.dropOffStop,
//     required super.status,
//   });

//   factory CarpoolPassengerModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolPassengerModel(
//       id: json['_id'] ?? '',
//       user: CarpoolUserModel.fromJson(json['user'] ?? {}),
//       bookingId: json['bookingId'] ?? '',
//       pickupStop: CarpoolRouteModel.fromJson(json['pickupStop'] ?? {}),
//       dropOffStop: CarpoolRouteModel.fromJson(json['dropOffStop'] ?? {}),
//       status: json['status'] ?? '',
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'user': (user as CarpoolUserModel).toJson(),
//       'bookingId': bookingId,
//       'pickupStop': (pickupStop as CarpoolRouteModel).toJson(),
//       'dropOffStop': (dropOffStop as CarpoolRouteModel).toJson(),
//       'status': status,
//     };
//   }
// }

// // User Model
// class CarpoolUserModel extends CarpoolUserEntity {
//   CarpoolUserModel({
//     required super.id,
//     required super.name,
//     required super.email,
//     super.profilePicture,
//     required super.rating,
//   });

//   factory CarpoolUserModel.fromJson(Map<String, dynamic> json) {
//     return CarpoolUserModel(
//       id: json['_id'] ?? '',
//       name: json['name'] ?? '',
//       email: json['email'] ?? '',
//       profilePicture: json['profilePicture'],
//       rating: (json['rating'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'name': name,
//       'email': email,
//       'profilePicture': profilePicture,
//       'rating': rating,
//     };
//   }
// }
