// driver_dashboard_model.dart
import 'package:driver_app/features/dashboard/domain/entities/dashboard_entity.dart';

class DriverVehicleModel extends DriverVehicleEntity {
  const DriverVehicleModel({
    required super.id,
    required super.make,
    required super.model,
    required super.registrationNumber,
    required super.plateNumber,
    super.vehicleType,
  });

  factory DriverVehicleModel.fromJson(Map<String, dynamic> json) {
    return DriverVehicleModel(
      id: json['_id'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      registrationNumber: json['registrationNumber'] ?? '',
      plateNumber: json['licensePlateNumber'] ?? json['plateNumber'] ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'make': make,
      'model': model,
      'registrationNumber': registrationNumber,
      'plateNumber': plateNumber,
      'vehicleType': vehicleType,
    };
  }
}

class DriverModel extends DriverEntity {
  const DriverModel({
    required super.firstName,
    required super.lastName,
    required super.profilePicture,
    required super.balance,
    super.rewardedBalance,
    super.totalBalance,
    required super.vehicleDetails,
    required super.rating,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    final balance = (json['balance'] ?? 0).toDouble();
    final rewardedBalance = (json['rewardedBalance'] ?? 0).toDouble();
    final totalBalance = (json['totalBalance'] ?? (balance + rewardedBalance))
        .toDouble();

    return DriverModel(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profilePicture: json['profilePicture'] ?? '',
      balance: balance,
      rewardedBalance: rewardedBalance,
      totalBalance: totalBalance,
      vehicleDetails: DriverVehicleModel.fromJson(
        json['vehicleDetails'] ?? <String, dynamic>{},
      ),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'profilePicture': profilePicture,
      'balance': balance,
      'rewardedBalance': rewardedBalance,
      'totalBalance': totalBalance,
      'vehicleDetails': (vehicleDetails as DriverVehicleModel).toJson(),
    };
  }
}

class DriverDashboardModel extends DriverDashboardEntity {
  const DriverDashboardModel({
    required super.completedRides,
    required super.cancelledRides,
    required super.todayRides,
    required super.driver,
  });

  factory DriverDashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? <String, dynamic>{};
    return DriverDashboardModel(
      completedRides: data['completedRides'] ?? 0,
      cancelledRides: data['cancelledRides'] ?? 0,
      todayRides: data['todayRides'] ?? 0,
      driver: DriverModel.fromJson(data['driver'] ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'completedRides': completedRides,
      'cancelledRides': cancelledRides,
      'todayRides': todayRides,
      'driver': (driver as DriverModel).toJson(),
    };
  }
}
