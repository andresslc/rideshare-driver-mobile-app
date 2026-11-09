class DriverLocationEntity {
  final String driverId;
  final double longitude;
  final double latitude;
  final DateTime timestamp;

  const DriverLocationEntity({
    required this.driverId,
    required this.longitude,
    required this.latitude,
    required this.timestamp,
  });
}