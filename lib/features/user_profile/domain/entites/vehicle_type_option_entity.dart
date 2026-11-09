class VehicleTypeOptionEntity {
  final String id;
  final String make;
  final String model;
  final String rideType;
  final bool isActive;
  final String notes;

  const VehicleTypeOptionEntity({
    required this.id,
    required this.make,
    required this.model,
    required this.rideType,
    required this.isActive,
    required this.notes,
  });
}
