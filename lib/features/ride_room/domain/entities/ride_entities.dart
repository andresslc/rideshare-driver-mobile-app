import 'package:driver_app/core/entities.dart/pagination_entity.dart';

class GeoLocationEntity {
  final double longitude;
  final double latitude;

  const GeoLocationEntity({required this.longitude, required this.latitude});
}

class RidePointEntity {
  final String placeName;
  final GeoLocationEntity location;

  const RidePointEntity({required this.placeName, required this.location});
}

class RideUserEntity {
  final String firstName;
  final String lastName;
  final String phone;
  final double rating;
  final String id;
  final String profilePicture;

  const RideUserEntity({
    this.id = '',
    required this.firstName,
    required this.lastName,
    this.phone = '',
    this.rating = 0.0,
    this.profilePicture = '',
  });

  String get displayName => _resolveDisplayName(firstName, lastName);
  String get name => displayName;
}

class RideVehicleEntity {
  final String? name;
  final String? model;
  final String? numberPlate;
  final String? image;

  const RideVehicleEntity({
    this.name,
    this.model,
    this.numberPlate,
    this.image,
  });
}

/// Ring the driver was reached in, as sent by the backend on `ride:incoming`.
/// Explains why a request can land seconds after the passenger asked for it.
class RideDispatchEntity {
  final int? ring;

  /// Raw value, always in miles. Kept for logic, never printed.
  final double? radiusMiles;

  /// Value already expressed in [distanceUnit] — this is what gets printed.
  final double? radius;

  /// Unit the backend wants distances printed in (e.g. `mi`, `km`). The app
  /// never converts: it prints what it is given.
  final String? distanceUnit;

  const RideDispatchEntity({
    this.ring,
    this.radiusMiles,
    this.radius,
    this.distanceUnit,
  });

  bool get isEmpty => ring == null && radiusMiles == null && radius == null;

  /// Radius to display: [radius] when the backend sent it, [radiusMiles] as a
  /// fallback for payloads that predate the dynamic unit.
  double? get displayRadius => radius ?? radiusMiles;
}

class RideEntity {
  final String id;
  final String? userId;
  final String? driverId;
  final RideUserEntity? user;
  final RideUserEntity? driver;
  final RideVehicleEntity? vehicle;
  final String rideStatus;
  final String rideType;
  final String specialRequest;
  final double rideDistance;
  final String paymentMethod;
  final double rideFare;

  /// What the driver is paid. Computed on the original fare, so on a promo ride
  /// it is higher than [rideFare] (the platform absorbs the difference) and it
  /// is above zero even when the passenger pays nothing. Always show this one.
  final double? driverFare;
  final int averageTime;
  final String paymentStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final RidePointEntity? pickupPoint;
  final RidePointEntity? dropOffPointRequested;
  final String? otp;
  final RideDispatchEntity? dispatch;

  const RideEntity({
    required this.id,
    this.userId,
    this.driverId,
    this.user,
    this.driver,
    this.vehicle,
    this.specialRequest = '',
    required this.rideStatus,
    required this.rideType,
    required this.rideDistance,
    required this.paymentMethod,
    required this.rideFare,
    this.driverFare,
    required this.averageTime,
    required this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.pickupPoint,
    this.dropOffPointRequested,
    this.otp,
    this.dispatch,
  });

  /// Driver earnings for this ride: [driverFare] when the backend sent it,
  /// [rideFare] otherwise (older payloads and history records).
  double get payoutFare => driverFare ?? rideFare;

  RideEntity copyWith({
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
    return RideEntity(
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
}

// class GeoLocationEntity {
//   final double longitude;
//   final double latitude;

//   const GeoLocationEntity({required this.longitude, required this.latitude});
// }

// class RidePointEntity {
//   final String placeName;
//   final GeoLocationEntity location;

//   const RidePointEntity({required this.placeName, required this.location});
// }

class RideRequsetUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final num rating;

  const RideRequsetUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    required this.rating,
  });

  String get displayName => _resolveDisplayName(firstName, lastName);
  String get name => displayName;
}

String _resolveDisplayName(String? firstName, String lastName) {
  final parts = <String>[
    firstName?.trim() ?? '',
    lastName.trim(),
  ].where((part) => part.isNotEmpty);
  return parts.join(' ');
}

// class RideEntity {
//   final String id;
//   final RideRequsetUserEntity user;
//   final String driverId;
//   final String rideStatus;
//   final String rideType;
//   final double rideDistance;
//   final String paymentMethod;
//   final double rideFare;
//   final int averageTime;
//   final String paymentStatus;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   final RidePointEntity pickupPoint;
//   final RidePointEntity dropOffPointRequested;

//   const RideEntity({
//     required this.id,
//     required this.user,
//     required this.driverId,
//     required this.rideStatus,
//     required this.rideType,
//     required this.rideDistance,
//     required this.paymentMethod,
//     required this.rideFare,
//     required this.averageTime,
//     required this.paymentStatus,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.pickupPoint,
//     required this.dropOffPointRequested,
//   });
// }

class RideRequestResponseEntity {
  final List<RideEntity> rides;
  final PaginationEntity pagination;

  RideRequestResponseEntity({required this.rides, required this.pagination});
}
