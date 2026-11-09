import 'package:driver_app/core/models/pagination_models.dart';
import 'package:driver_app/features/ride_room/domain/entities/ride_entities.dart';

class GeoLocationModel extends GeoLocationEntity {
  const GeoLocationModel({required super.longitude, required super.latitude});

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['coordinates'];
    final coords = rawCoords is List ? rawCoords : const <dynamic>[0.0, 0.0];
    final longitude = coords.isNotEmpty
        ? (coords[0] as num?)?.toDouble() ?? 0.0
        : 0.0;
    final latitude = coords.length > 1
        ? (coords[1] as num?)?.toDouble() ?? 0.0
        : 0.0;

    return GeoLocationModel(longitude: longitude, latitude: latitude);
  }

  Map<String, dynamic> toJson() => {
    "type": "Point",
    "coordinates": [longitude, latitude],
  };
}

class RidePointModel extends RidePointEntity {
  const RidePointModel({required super.placeName, required super.location});

  factory RidePointModel.fromJson(Map<String, dynamic> json) {
    final rawLocation = json['location'];
    final locationMap = rawLocation is Map<String, dynamic>
        ? rawLocation
        : (rawLocation is Map ? Map<String, dynamic>.from(rawLocation) : null);
    return RidePointModel(
      placeName: json['placeName']?.toString() ?? '',
      location: locationMap != null
          ? GeoLocationModel.fromJson(locationMap)
          : const GeoLocationModel(longitude: 0.0, latitude: 0.0),
    );
  }

  Map<String, dynamic> toJson() => {
    "placeName": placeName,
    "location": (location as GeoLocationModel).toJson(),
  };
}

class RideUserModel extends RideUserEntity {
  const RideUserModel({
    super.id,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.rating,
    super.profilePicture,
  });

  factory RideUserModel.fromJson(Map<String, dynamic> json) {
    // The ring-dispatch payload is a trimmed field list, so absent keys must
    // fall back to empty rather than to the string "null".
    String read(List<String> keys) {
      for (final String key in keys) {
        final String value = json[key]?.toString().trim() ?? '';
        if (value.isNotEmpty && value != 'null') return value;
      }
      return '';
    }

    return RideUserModel(
      id: read(<String>['_id', 'id']),
      firstName: read(<String>['firstName']),
      lastName: read(<String>['lastName']),
      phone: read(<String>['phone', 'phoneNumber']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      profilePicture: read(<String>['profileImage', 'profilePicture', 'image']),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "rating": rating,
    "profileImage": profilePicture,
  };
}

class RideVehicleModel extends RideVehicleEntity {
  const RideVehicleModel({
    super.name,
    super.model,
    super.numberPlate,
    super.image,
  });

  factory RideVehicleModel.fromJson(Map<String, dynamic> json) {
    return RideVehicleModel(
      name:
          json['name']?.toString() ??
          json['carName']?.toString() ??
          json['make']?.toString(),
      model: json['model']?.toString(),
      numberPlate:
          json['numberPlate']?.toString() ??
          json['plateNumber']?.toString() ??
          json['licensePlateNumber']?.toString(),
      image: json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    "name": name,
    "model": model,
    "numberPlate": numberPlate,
    "image": image,
  };
}

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    super.userId,
    super.driverId,
    super.user,
    super.driver,
    super.vehicle,
    super.specialRequest,
    required super.rideStatus,
    required super.rideType,
    required super.rideDistance,
    required super.paymentMethod,
    required super.rideFare,
    super.driverFare,
    required super.averageTime,
    required super.paymentStatus,
    super.createdAt,
    super.updatedAt,
    super.pickupPoint,
    super.dropOffPointRequested,
    super.otp,
    super.dispatch,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final rawRide = json['ride'];
    final ride = rawRide is Map<String, dynamic> ? rawRide : json;

    return RideModel(
      id:
          ride['_id']?.toString() ??
          ride['id']?.toString() ??
          ride['rideId']?.toString() ??
          '',
      userId: _valueOrNestedId(ride['user']),
      driverId: _valueOrNestedId(ride['driver']),
      user: _parseUser(ride['user']),
      driver: _parseUser(ride['driver']),
      vehicle: _parseVehicle(
        ride['vehicle'] ??
            ride['car'] ??
            _asMap(ride['driver'])?['vehicle'] ??
            _asMap(ride['driver'])?['vehicleDetails'],
      ),
      specialRequest: ride['specialRequest']?.toString() ?? '',
      rideStatus:
          ride['rideStatus']?.toString() ?? ride['status']?.toString() ?? '',
      rideType: ride['rideType']?.toString() ?? '',
      rideDistance:
          (ride['rideDistance'] as num?)?.toDouble() ??
          (ride['distance'] as num?)?.toDouble() ??
          0.0,
      paymentMethod: ride['paymentMethod']?.toString() ?? '',
      rideFare:
          (ride['rideFare'] as num?)?.toDouble() ??
          (ride['offeredFare'] as num?)?.toDouble() ??
          (ride['fare'] as num?)?.toDouble() ??
          0.0,
      // On referral rides `rideFare` is the rider's discounted fare; the
      // driver is paid the full fare (`originalRideFare`).
      driverFare:
          (ride['driverFare'] as num?)?.toDouble() ??
          (ride['originalRideFare'] as num?)?.toDouble(),
      averageTime:
          (ride['averageTime'] as num?)?.toInt() ??
          (ride['duration'] as num?)?.toInt() ??
          0,
      paymentStatus: ride['paymentStatus']?.toString() ?? '',
      createdAt: _parseDateTime(ride['createdAt']),
      updatedAt: _parseDateTime(ride['updatedAt']),
      pickupPoint: _parseRidePoint(ride['pickupPoint']),
      dropOffPointRequested: _parseRidePoint(
        ride['dropOffPointRequested'] ??
            ride['dropoffPointRequested'] ??
            ride['dropOffPoint'],
      ),
      otp:
          ride['otp']?.toString() ??
          _asMap(ride['rideOtp'])?['otp']?.toString() ??
          ride['rideOtp']?.toString(),
      dispatch: _parseDispatch(ride['dispatch'] ?? json['dispatch']),
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": userId,
    "driver": driverId,
    "userDetails": user is RideUserModel
        ? (user as RideUserModel).toJson()
        : null,
    "driverDetails": driver is RideUserModel
        ? (driver as RideUserModel).toJson()
        : null,
    "vehicle": vehicle is RideVehicleModel
        ? (vehicle as RideVehicleModel).toJson()
        : null,
    "rideStatus": rideStatus,
    "rideType": rideType,
    "rideDistance": rideDistance,
    "paymentMethod": paymentMethod,
    "rideFare": rideFare,
    "driverFare": driverFare,
    "averageTime": averageTime,
    "paymentStatus": paymentStatus,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "pickupPoint": pickupPoint is RidePointModel
        ? (pickupPoint as RidePointModel).toJson()
        : null,
    "dropOffPointRequested": dropOffPointRequested is RidePointModel
        ? (dropOffPointRequested as RidePointModel).toJson()
        : null,
    "dispatch": dispatch == null
        ? null
        : <String, dynamic>{
            "ring": dispatch!.ring,
            "radiusMiles": dispatch!.radiusMiles,
            "radius": dispatch!.radius,
            "distanceUnit": dispatch!.distanceUnit,
          },
  };

  @override
  RideModel copyWith({
    String? id,
    String? userId,
    String? driverId,
    RideUserEntity? user,
    RideUserEntity? driver,
    RideVehicleEntity? vehicle,
    String? rideStatus,
    String? rideType,
    String? specialRequest,
    double? rideDistance,
    String? paymentMethod,
    double? rideFare,
    double? driverFare,
    int? averageTime,
    String? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    RidePointEntity? pickupPoint,
    RidePointEntity? dropOffPointRequested,
    String? otp,
    RideDispatchEntity? dispatch,
  }) {
    return RideModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      driverId: driverId ?? this.driverId,
      user: user ?? this.user,
      driver: driver ?? this.driver,
      vehicle: vehicle ?? this.vehicle,
      rideStatus: rideStatus ?? this.rideStatus,
      rideType: rideType ?? this.rideType,
      specialRequest: specialRequest ?? this.specialRequest,
      rideDistance: rideDistance ?? this.rideDistance,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rideFare: rideFare ?? this.rideFare,
      driverFare: driverFare ?? this.driverFare,
      averageTime: averageTime ?? this.averageTime,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      dropOffPointRequested:
          dropOffPointRequested ?? this.dropOffPointRequested,
      otp: otp ?? this.otp,
      dispatch: dispatch ?? this.dispatch,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    final text = value?.toString();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  static RideDispatchEntity? _parseDispatch(dynamic value) {
    final map = _asMap(value);
    if (map == null) return null;
    final String unit = map['distanceUnit']?.toString().trim() ?? '';
    final RideDispatchEntity dispatch = RideDispatchEntity(
      ring: (map['ring'] as num?)?.toInt(),
      radiusMiles: (map['radiusMiles'] as num?)?.toDouble(),
      radius: (map['radius'] as num?)?.toDouble(),
      distanceUnit: unit.isEmpty ? null : unit,
    );
    return dispatch.isEmpty ? null : dispatch;
  }

  static RidePointModel? _parseRidePoint(dynamic value) {
    final map = _asMap(value);
    if (map != null) return RidePointModel.fromJson(map);
    return null;
  }

  static String? _valueOrNestedId(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return value.toString();
  }

  static RideUserModel? _parseUser(dynamic value) {
    final map = _asMap(value);
    if (map != null) return RideUserModel.fromJson(map);
    return null;
  }

  static RideVehicleModel? _parseVehicle(dynamic value) {
    final map = _asMap(value);
    if (map != null) return RideVehicleModel.fromJson(map);
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }
}

// class GeoLocationModel extends GeoLocationEntity {
//   const GeoLocationModel({required super.longitude, required super.latitude});

//   factory GeoLocationModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) {
//       return const GeoLocationModel(longitude: 0.0, latitude: 0.0);
//     }

//     final coords = (json['coordinates'] as List? ?? [0.0, 0.0])
//         .map((e) => (e as num).toDouble())
//         .toList();

//     return GeoLocationModel(
//       longitude: coords.isNotEmpty ? coords[0] : 0.0,
//       latitude: coords.length > 1 ? coords[1] : 0.0,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     "type": "Point",
//     "coordinates": [longitude, latitude],
//   };
// }

// class RidePointModel extends RidePointEntity {
//   const RidePointModel({required super.placeName, required super.location});

//   factory RidePointModel.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return RidePointModel.empty();

//     return RidePointModel(
//       placeName: json['placeName'] ?? '',
//       location: GeoLocationModel.fromJson(json['location']),
//     );
//   }
//   factory RidePointModel.empty() {
//     return RidePointModel(
//       placeName: '',
//       location: GeoLocationModel(longitude: 0.0, latitude: 0.0),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     "placeName": placeName,
//     "location": (location as GeoLocationModel).toJson(),
//   };
// }

// class RideModel extends RideEntity {
//   const RideModel({
//     required super.id,
//     required super.user,
//     required super.driverId,
//     required super.rideStatus,
//     required super.rideType,
//     required super.rideDistance,
//     required super.paymentMethod,
//     required super.rideFare,
//     required super.averageTime,
//     required super.paymentStatus,
//     required super.createdAt,
//     required super.updatedAt,
//     required super.pickupPoint,
//     required super.dropOffPointRequested,
//   });

//   factory RideModel.fromJson(Map<String, dynamic> json) {
//     RideRequsetUserEntity parseUser(dynamic userData) {
//       if (userData is String) {
//         return RideRequsetUserEntity(
//           id: userData,
//           name: "Passenger",
//           email: "",
//         );
//       } else if (userData is List && userData.isNotEmpty) {
//         final u = userData[0];
//         return RideRequsetUserEntity(
//           id: u['_id'] ?? '',
//           name: u['name'] ?? 'Passenger',
//           email: u['email'] ?? '',
//           profilePicture: u['profilePicture'],
//         );
//       } else if (userData is Map<String, dynamic>) {
//         return RideRequsetUserEntity(
//           id: userData['_id'] ?? '',
//           name: userData['name'] ?? 'Passenger',
//           email: userData['email'] ?? '',
//           profilePicture: userData['profilePicture'],
//         );
//       }
//       return RideRequsetUserEntity(id: '', name: 'Passenger', email: '');
//     }

//     return RideModel(
//       id: json['_id'] ?? json['id'] ?? json['rideId'] ?? '',
//       user: parseUser(json['user']),
//       driverId: json['driver'] is Map
//           ? (json['driver']['_id'] ?? json['driver']['id'] ?? '')
//           : (json['driver'] ?? ''),
//       rideStatus: json['rideStatus'] ?? json['status'] ?? '',
//       rideType: json['rideType'] ?? '',
//       rideDistance: ((json['rideDistance'] ?? json['distance']) ?? 0)
//           .toDouble(),
//       paymentMethod: json['paymentMethod'] ?? '',
//       rideFare: ((json['rideFare'] ?? json['fare']) ?? 0).toDouble(),
//       averageTime: json['averageTime'] ?? json['duration'] ?? 0,
//       paymentStatus: json['paymentStatus'] ?? '',
//       createdAt: json['createdAt'] != null
//           ? DateTime.parse(json['createdAt'])
//           : DateTime.now(),
//       updatedAt: json['updatedAt'] != null
//           ? DateTime.parse(json['updatedAt'])
//           : DateTime.now(),

//       pickupPoint: json['pickupPoint'] != null
//           ? RidePointModel.fromJson(json['pickupPoint'])
//           : RidePointModel.empty(),

//       dropOffPointRequested: json['dropOffPointRequested'] != null
//           ? RidePointModel.fromJson(json['dropOffPointRequested'])
//           : json['dropOffPoint'] != null
//           ? RidePointModel.fromJson(json['dropOffPoint'])
//           : RidePointModel.empty(),
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "user": user,
//     "driver": driverId,
//     "rideStatus": rideStatus,
//     "rideType": rideType,
//     "rideDistance": rideDistance,
//     "paymentMethod": paymentMethod,
//     "rideFare": rideFare,
//     "averageTime": averageTime,
//     "paymentStatus": paymentStatus,
//     "createdAt": createdAt.toIso8601String(),
//     "updatedAt": updatedAt.toIso8601String(),
//     "pickupPoint": (pickupPoint as RidePointModel).toJson(),
//     "dropOffPointRequested": (dropOffPointRequested as RidePointModel).toJson(),
//   };
// }

class RideRequestResponseModel extends RideRequestResponseEntity {
  RideRequestResponseModel({required super.rides, required super.pagination});

  factory RideRequestResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final pagination = json['pagination'] ?? {};

    List<RideModel> parsedRides = [];

    if (data is List) {
      parsedRides = data
          .whereType<Map<String, dynamic>>()
          .map((e) => RideModel.fromJson(e))
          .toList();
    } else if (data is Map<String, dynamic>) {
      parsedRides = [RideModel.fromJson(data)];
    }

    return RideRequestResponseModel(
      rides: parsedRides,
      pagination: PaginationModel.fromJson(pagination),
    );
  }

  RideRequestResponseEntity toEntity() =>
      RideRequestResponseEntity(rides: rides, pagination: pagination);
}
