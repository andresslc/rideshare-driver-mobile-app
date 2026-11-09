import 'package:driver_app/features/user_profile/domain/entites/vehicle_type_option_entity.dart';

class VehicleTypeOptionModel extends VehicleTypeOptionEntity {
  const VehicleTypeOptionModel({
    required super.id,
    required super.make,
    required super.model,
    required super.rideType,
    required super.isActive,
    required super.notes,
  });

  factory VehicleTypeOptionModel.fromJson(Map<String, dynamic> json) {
    return VehicleTypeOptionModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      make: (json['make'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      rideType: (json['rideType'] ?? json['vehicleType'] ?? '').toString(),
      isActive: json['isActive'] == true,
      notes: (json['notes'] ?? '').toString(),
    );
  }
}
