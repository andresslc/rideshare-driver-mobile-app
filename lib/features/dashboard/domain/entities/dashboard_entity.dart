// driver_dashboard_entity.dart

class DriverVehicleEntity {
  final String id;
  final String make;
  final String model;
  final String registrationNumber;
  final String plateNumber;
  final String vehicleType;

  const DriverVehicleEntity({
    required this.id,
    required this.make,
    required this.model,
    required this.registrationNumber,
    required this.plateNumber,
    this.vehicleType = '',
  });

  DriverVehicleEntity copyWith({
    String? id,
    String? make,
    String? model,
    String? registrationNumber,
    String? plateNumber,
    String? vehicleType,
  }) {
    return DriverVehicleEntity(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      plateNumber: plateNumber ?? this.plateNumber,
      vehicleType: vehicleType ?? this.vehicleType,
    );
  }
}

class DriverEntity {
  final String firstName;
  final String lastName;
  final String profilePicture;
  final num balance;
  final num rewardedBalance;
  final num totalBalance;
  final DriverVehicleEntity vehicleDetails;
  final num rating;

  const DriverEntity({
    required this.firstName,
    required this.lastName,
    required this.profilePicture,
    required this.balance,
    this.rewardedBalance = 0.0,
    this.totalBalance = 0.0,
    required this.vehicleDetails,
    required this.rating,
  });

  String get displayName => [
    firstName.trim(),
    lastName.trim(),
  ].where((part) => part.isNotEmpty).join(' ');
  String get name => displayName;

  DriverEntity copyWith({
    String? firstName,
    String? lastName,
    String? profilePicture,
    num? balance,
    num? rewardedBalance,
    num? totalBalance,
    DriverVehicleEntity? vehicleDetails,
    num? rating,
  }) {
    return DriverEntity(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePicture: profilePicture ?? this.profilePicture,
      balance: balance ?? this.balance,
      rewardedBalance: rewardedBalance ?? this.rewardedBalance,
      totalBalance: totalBalance ?? this.totalBalance,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      rating: rating ?? this.rating,
    );
  }
}

class DriverDashboardEntity {
  final int completedRides;
  final int cancelledRides;
  final int todayRides;
  final DriverEntity driver;

  const DriverDashboardEntity({
    required this.completedRides,
    required this.cancelledRides,
    required this.todayRides,
    required this.driver,
  });

  /// ✅ ADD THIS METHOD
  DriverDashboardEntity copyWith({
    int? completedRides,
    int? cancelledRides,
    int? todayRides,
    DriverEntity? driver,
  }) {
    return DriverDashboardEntity(
      completedRides: completedRides ?? this.completedRides,
      cancelledRides: cancelledRides ?? this.cancelledRides,
      todayRides: todayRides ?? this.todayRides,
      driver: driver ?? this.driver,
    );
  }
}
